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

function get_audio_entrant_vote_data(year::Int)
	
	audio_entrant_df = get_audio_entrant_data(year)
	
	# get aggregate vote with columns:
	#	:country
	#	:televote
	votedf = aggregate_televote_by_entrant(year)
	# clean data
	votedf[:country] = map(c->normalise_country(c), votedf[:country])
	
	join(audio_entrant_df, votedf, on=:country, kind=:left) #, joindf, entrantdf, audiodf, votedf

end

function get_model(sourceyears::Vector{Int})

	sourcedata = vcat(map(year->get_audio_entrant_vote_data(year), sourceyears))
	
	lm(@formula(televote~tempo+liveness+mode+energy+speechiness+danceability+key+loudness+duration_ms+acousticness+instrumentalness+valence+time_signature), sourcedata)
	
end

function get_prediction(predictyear::Int, sourceyears::Vector{Int})

	model = get_model(sourceyears)
	predictdata =  get_audio_entrant_data(predictyear)
	predictdata[:predictedtelevote] = predict(model, predictdata)
	predictdata

end

