using HttpServer
using JSON
include(joinpath("..","analysis", "regression_audio_features.jl"))

function get_prediction_as_json(year::Int, votetype::Symbol=:combined, granularity::Symbol=:aggregate, modeltype::Symbol=:audiofeatures)
	
	sourceyears = filter(y -> y != year, 2014:2016)
	df = get_prediction(year, sourceyears, votetype, granularity, modeltype)
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

	prediction = map(1:size(df,1)) do i
		Dict("country"=>df[i,:country],
			 "song"=>df[i,:title], 
			 "artist"=>df[i,:artist], 
			 "predicted"=>(granularity == :votingcountry) ? df[i,:predictedvote] : df[i,:predictedrank], 
			 "placement"=>i, 
			 "actual"=>df[i,:rank], 
			 "difference"=>df[i,:predictedrank] - df[i,:rank],)
		 end
	
	string(JSON.json(prediction))
	
end

http = HttpHandler() do req::Request, res::Response

	if ismatch(r"^/api/[0-9]{4}", req.resource)
		
		year = parse(Int, req.resource[6:end])

		Response(200,
			Dict{AbstractString,AbstractString}("Access-Control-Allow-Origin"=>"*"), 
			get_prediction_as_json(year))
					
	elseif ismatch(r"^/.*/.*/.*/[0-9]{4}", req.resource)
		
		params = split(req.resource, "/", keep=false)
		
		year = parse(Int, params[4])

		Response(200,
			Dict{AbstractString,AbstractString}("Access-Control-Allow-Origin"=>"*"), 
			get_prediction_as_json(year, Symbol(params[1]), Symbol(params[2]), Symbol(params[3])))
			
	else
	
		404
		
	end
end


server = Server( http )
run( server, 4200 )