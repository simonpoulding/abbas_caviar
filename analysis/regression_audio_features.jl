using DataFrames
using GLM
include("process_audio_data.jl")
include("process_entrant_data.jl")
include("process_voting_data.jl")
include("normalise_data.jl")


function get_audio_entrant_data(year::Int)

	
	# get audio features with columns:
	#	:title
	#	:artist
	#	:tempo
	#	...
	audiodf = load_audio_features_data(year)
	audiodf[:artist] = map(a->normalise_artist(a), audiodf[:artist])
	

	# get entrant data:
	#	:title
	#	:artist
	#	:country
	entrantdf = load_entrant_data(year)
	entrantdf[:country] = map(c->normalise_country(c), entrantdf[:country])
	entrantdf[:artist] = map(a->normalise_artist(a), entrantdf[:artist])
	
	unique!(join(entrantdf, audiodf, on=:artist, kind=:left), :country)
		
end

function get_aggregate_rank_data(year::Int, votetype::Symbol=:televote)
		# get aggregate vote with columns:
	#	:country
	#	:rank
	rankdf = aggregate_rank_by_entrant(year, votetype)
	# clean data
	rankdf[:country] = map(c->normalise_country(c), rankdf[:country])
	rankdf
end

function get_audio_entrant_rank_data(year::Int, votetype::Symbol=:televote)
	rankdf = get_aggregate_rank_data(year, votetype)
	audioentrantdf = get_audio_entrant_data(year)
	join(audioentrantdf, rankdf, on=:country, kind=:left) #, joindf, entrantdf, audiodf, votedf
end

function get_model(sourceyears::Vector{Int}, votetype::Symbol=:televote)
	sourcedata = vcat(map(year->get_audio_entrant_rank_data(year, votetype), sourceyears))
	lm(@formula(rank~tempo+liveness+mode+energy+speechiness+danceability+key+loudness+duration_ms+acousticness+instrumentalness+valence+time_signature), sourcedata)	
end

# votetype: :televote, :jury, :combined
function get_prediction(predictyear::Int, sourceyears::Vector{Int}, votetype::Symbol=:televote)

	model = get_model(sourceyears, votetype)
	
	predictdf =  get_audio_entrant_data(predictyear)
	predictdf[:predictedrank] = predict(model, predictdf)
	
	if predictyear < 2017
		rankdf = get_aggregate_rank_data(predictyear, votetype)
		predictdf = join(predictdf,rankdf, on=:country, kind=:left)
	else 
		predictdf[:rank] = fill(0, size(predictdf,1))
	end

	predictdf
	
end

