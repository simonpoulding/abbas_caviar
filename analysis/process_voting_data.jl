using DataFrames

function load_voting_data(filename::AbstractString)
	readtable(joinpath("..", "voting_data", "eurovision_tv", filename))
end

function load_voting_data(year::Int)
	load_voting_data("grand_final_votes_" * string(year) * ".csv")
end



# returns aggregate vote with columns :entrant and :televote
function aggregate_rank_by_country(votingdf::DataFrame, votetype::Symbol=:televote)
	adf = by(votingdf, :country, 
		df -> sum(
			votetype == :televote ? df[:televoterank] : 
			votetype == :jury ? df[:juryrank] :
			votetype == :combined ? df[:televoterank] + df[:juryrank]
			: 0)
		)
	names!(adf, [:country, :rank])
end

# returns aggregate vote with columns :entrant and :televote
function aggregate_rank_by_country(year::Int, votetype::Symbol=:televote)
	votingdf = load_voting_data(year)
	aggregate_rank_by_country(votingdf, votetype)
end


function rank_by_votingcountry(votingdf::DataFrame, votetype::Symbol=:televote)
	adf = by(votingdf, [:_votingcountry,:country], 
		df -> sum(
			votetype == :televote ? df[:televoterank] : 
			votetype == :jury ? df[:juryrank] :
			votetype == :combined ? df[:televoterank] + df[:juryrank]
			: 0)
		)	
	names!(adf, [:votingcountry, :country, :rank])
end

function rank_by_votingcountry(year::Int, votetype::Symbol=:televote)
	votingdf = load_voting_data(year)
	rank_by_votingcountry(votingdf, votetype)
end

