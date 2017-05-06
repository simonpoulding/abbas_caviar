using DataFrames

function load_voting_data(filename::AbstractString, source::Symbol=:eurovisiontv)
	thisdir, thisfile = splitdir(@__FILE__)
	if source == :eurovisiontv
		readtable(joinpath(thisdir, "eurovision_tv", filename))
	else
		error("Unknown source: $source")
	end
end

function load_voting_data(year::Int, source::Symbol=:eurovisiontv)
	if source == :eurovisiontv
		load_voting_data("grand_final_votes_" * string(year) * ".csv")
	else
		error("Unknown source: $source")
	end
end

# returns aggregate vote with columns :entrant and :televote
function aggregate_televote_by_entrant(votingdf::DataFrame, source::Symbol=:eurovisiontv)
	if source == :eurovisiontv
		adf = by(votingdf, :To_country, df -> sum(df[:Televote_Points]))
		names!(adf, [:entrant, :televote])
	else
		error("Unknown source: $source")
	end	
end

# returns aggregate vote with columns :entrant and :televote
function aggregate_televote_by_entrant(year::Int, source::Symbol=:eurovisiontv)
	votingdf = load_voting_data(year, source)
	if source == :eurovisiontv
		adf = by(votingdf, :To_country, df -> sum(df[:Televote_Points]))
		names!(adf, [:country, :televote])
	else
		error("Unknown source: $source")
	end	
end


