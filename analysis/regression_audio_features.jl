using DataFrames
include("process_audio_data.jl")
include("process_entrant_data.jl")
include("process_voting_data.jl")
include("normalise_data.jl")


function get_esc_data(year::Int)

	# get aggregate vote with columns:
	#	:country
	#	:televote
	votedf = aggregate_televote_by_entrant(year)
	# clean data
	votedf[:country] = map(c->normalise_country(c), votedf[:country])
	
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
	
	joindf=join(entrantdf, audiodf, on=:artist, kind=:left)
	unique!(joindf, :country)
	
	join(joindf, votedf, on=:country, kind=:left) #, joindf, entrantdf, audiodf, votedf
	
end


