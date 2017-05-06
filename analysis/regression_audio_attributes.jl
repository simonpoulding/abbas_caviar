using DataFrames
include(joinpath("..", "voting_data", "process_voting_data.jl"))
include("normalise_data.jl")

year = 2016


# returns aggregate vote with columns :country and :televote
televotedf = aggregate_televote_by_entrant(year)

# clean data
televotedf[:country] = map(c -> normalise_country(c), televotedf[:country])

