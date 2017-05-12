using DataFrames
using GLM
include("process_audio_data.jl")
include("process_entrant_data.jl")
include("process_voting_data.jl")
include("normalise_data.jl")


function get_audio_entrant_data(year::Int)

	audiodf = load_audio_features_data(year)
	audiodf[:artist] = map(a->normalise_artist(a), audiodf[:artist])
	audiodf[:instrumentalness] = map(i -> normalise_instrumentalness(i), audiodf[:instrumentalness])
	# otherwise percountry models can become unstable
	audiodf[:duration_ms] = map(d -> normalise_duration(d), audiodf[:duration_ms])
	# since some (e.g. Italy 2017) are more than 3 minutes (since they are not the official ESC version)
	
	entrantdf = load_entrant_data(year)
	entrantdf[:country] = map(c->normalise_country(c), entrantdf[:country])
	entrantdf[:artist] = map(a->normalise_artist(a), entrantdf[:artist])
	
	unique!(join(entrantdf, audiodf, on=:artist, kind=:left), :country)
		
end

function get_aggregate_rank_data(year::Int, votetype::Symbol=:televote)
	rankdf = aggregate_rank_by_country(year, votetype)
	rankdf[:country] = map(c->normalise_country(c), rankdf[:country])
	rankdf
end

function get_byvotingcountry_rank_data(year::Int, votetype::Symbol=:televote)
	rankdf = rank_by_votingcountry(year, votetype)
	rankdf[:country] = map(c->normalise_country(c), rankdf[:country])
	rankdf[:votingcountry] = map(c->normalise_country(c), rankdf[:votingcountry])
	rankdf
end

function get_audio_entrant_rank_data(year::Int, votetype::Symbol=:televote, granularity::Symbol=:aggregate)
	rankdf = (granularity == :votingcountry) ? get_byvotingcountry_rank_data(year, votetype) : get_aggregate_rank_data(year, votetype)
	audioentrantdf = get_audio_entrant_data(year)
	join(rankdf, audioentrantdf, on=:country, kind=:left) #, joindf, entrantdf, audiodf, votedf
end

countrycolname(country::AbstractString) = replace(country, " ", "_")

function fit_model(df, modeltype=:audiofeatures, countries::Vector{AbstractString} = AbstractString[])
	indepvars = AbstractString[]
	if modeltype == :audiofeatures || modeltype == :all
		# append!(indepvars, ["tempo", "liveness", "mode", "energy", "speechiness", "danceability", "key", "loudness", "duration_ms", "acousticness", "instrumentalness", "valence", "time_signature"])
		append!(indepvars, ["tempo", "liveness", "mode", "energy", "speechiness", "danceability", "key", "loudness", "acousticness", "valence", "time_signature"])
		# duration_ms removed because it is of the spotify track, not the actual version played at Eurovision (which must be <= 180s) - this effects Italy in particular
		# instrumentallness removed because the number of small values close to zero seems to make the model unstable (large -ve predictions in some cases)
	end
	if modeltype == :countrybias || modeltype == :all
		append!(indepvars, map(c->countrycolname(c), countries))
	end
	intercept = (modeltype == :countrybias || modeltype == :all) ? "0+" : ""
	fmstr = "@formula(rank~" * intercept * join(indepvars, "+") * ")"
	lm(eval(parse(fmstr)), df)	
end

function add_country_cols!(df::DataFrame, countries::Vector{AbstractString} = AbstractString[])
	usedcountries = map(isempty(countries) ? unique(df[:country]) : countries) do country
			df[Symbol(countrycolname(country))] = map(c->c == country ? 1.0 : 0.0, df[:country])
			country
	end
	for i in 1:size(df,1)
		if !(df[i,:country] in usedcountries)
			for usedcountry in usedcountries
				df[i, Symbol(countrycolname(usedcountry))] = 1.0 / length(usedcountries)
			end
		end
	end
	convert(Vector{AbstractString}, usedcountries)
end

function get_model(sourceyears::Vector{Int}, votetype::Symbol=:televote, granularity::Symbol=:aggregate, modeltype::Symbol=:audiofeatures)
	sourcedatadf = vcat(map(year->get_audio_entrant_rank_data(year, votetype, granularity), sourceyears))
	if granularity == :votingcountry
		allvccountries = AbstractString[]
		model = Any[]
		for vc in unique(sourcedatadf[:votingcountry])
			vcdf = sourcedatadf[sourcedatadf[:votingcountry].==vc,:]
			vccountries = add_country_cols!(vcdf)
			append!(allvccountries, vccountries)
			try
				push!(model,(vc, fit_model(vcdf, modeltype, vccountries)))
			catch exc
				warn("Voting Country $(vc): $(exc)")
			end
		end
		countries = unique(allvccountries)
	else	
		countries = add_country_cols!(sourcedatadf)
		model = fit_model(sourcedatadf, modeltype, countries)
	end
	model, countries
end

# votetype: :televote, :jury, :combined
function predict_from_model(audioentrantdf::DataFrame, sourceyears::Vector{Int}, votetype::Symbol=:televote, granularity::Symbol=:aggregate, modeltype::Symbol=:audiofeatures)

	model, countries = get_model(sourceyears, votetype, granularity, modeltype)
	add_country_cols!(audioentrantdf, countries)

	predictdf = DataFrame(predictedrank=fill(0, size(audioentrantdf,1)), predictedvote=fill(0, size(audioentrantdf,1)))
	
	if granularity == :votingcountry
		for (vc, vcmodel) in model
			# if vc in audioentrantdf[:country] || vc in ["Ukraine", "France", "Germany"] # check whether countries are actually voting in predict year (i.e. are also an entrant)
			# but above doesn't work because in previous years because not all countries in the final
				prediction = predict(vcmodel, audioentrantdf)
				predictdf[:predictedrank] += prediction
				idx = sortperm(prediction)
				predictdf[idx[1:10], :predictedvote] += [12,10,8,7,6,5,4,3,2,1]
				# av = prediction[audioentrantdf[:country].=="Armenia"]
				# println("$vc: $av")
				# println(vcmodel)
			# end
		end
	else
		predictdf[:predictedrank] += predict(model, audioentrantdf)
	end
	
	predictdf
	
end

function get_prediction(predictyear::Int, sourceyears::Vector{Int}, votetype::Symbol=:televote, granularity=:aggregate, modeltype=:audiofeatures)
	# 3rd param (votetype)
	#	:separate			model televote and jury vote separately, and then add together
	#	:combined			add televote and jury vote together, and model as one [gives same prediction as separate for linear model]
	#	:televote			model only televote
	#	:jury				model only jury vote
	# 4th param (granularity)
	#	:aggregate			one model across all voting countries
	#	:votingcountry		a separate model for each voting country [may be model issues here - consider beta]
	# 5th param (modeltype)
	#	:audiofeatures		model using only audio features from Spotify
	#	:countrybias		model using only historic voting biases for each entrant country
	#	:all				model using both of the above set of factors

	
	audioentrantdf = get_audio_entrant_data(predictyear)
	
	if votetype == :separate
		predictdf = predict_from_model(audioentrantdf, sourceyears, :televote, granularity, modeltype)
		jurydf = predict_from_model(audioentrantdf, sourceyears, :jury, granularity, modeltype)
		predictdf[:predictedrank] += jurydf[:predictedrank]
		predictdf[:predictedvote] += jurydf[:predictedvote]
	else
		predictdf = predict_from_model(audioentrantdf, sourceyears, votetype, granularity, modeltype)
	end
	
	predictdf = hcat(audioentrantdf, predictdf)
	
	if predictyear < 2017
		rankdf = get_aggregate_rank_data(predictyear, votetype == :separate ? :combined : votetype)
		predictdf = join(predictdf,rankdf, on=:country, kind=:left)
	else 
		predictdf[:rank] = 0
	end
	
	granularity == :votingcountry ? sort(predictdf, cols=[:predictedvote], rev=true) : sort(predictdf, cols=[:predictedrank])
	
end

