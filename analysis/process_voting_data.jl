using DataFrames

function load_voting_data(filename::AbstractString)
	readtable(joinpath("..", "voting_data", "eurovision_tv", filename))
end

function load_voting_data(year::Int)
	load_voting_data("grand_final_votes_" * string(year) * ".csv")
end

# returns aggregate vote with columns :entrant and :televote
function aggregate_rank_by_entrant(votingdf::DataFrame, votetype::Symbol=:televote)
	adf = by(votingdf, :To_country, 
		df -> sum(
			votetype == :televote ? df[:Televote_Rank] : 
			votetype == :jury ? df[:Jury_Rank] :
			votetype == :combined ? df[:Televote_Rank] + df[:Jury_Rank]
			: 0)
		)
	names!(adf, [:country, :rank])
end

# returns aggregate vote with columns :entrant and :televote
function aggregate_rank_by_entrant(year::Int, votetype::Symbol=:televote)
	votingdf = load_voting_data(year)
	aggregate_rank_by_entrant(votingdf, votetype)
end


