using HttpServer
using JSON
include(joinpath("..","analysis", "regression_audio_features.jl"))


http = HttpHandler() do req::Request, res::Response

	if ismatch(r"^/api/[0-9]{4}", req.resource)
		
		year = parse(Int, req.resource[6:end])
		
		if 2014 <= year <= 2017

			sourceyears = filter(y -> y != year, 2014:2016)
			df = get_prediction(year, sourceyears)
		
			prediction = map(1:size(df,1)) do i
				Dict("country"=>df[i,:country],
					 "song"=>df[i,:title], 
					 "artist"=>df[i,:artist], 
					 "predicted"=>df[i,:predictedrank], 
					 "placement"=>0, 
					 "actual"=>df[i,:rank], 
					 "difference"=>df[i,:predictedrank] - df[i,:rank],)
			end
		
			Response(200, Dict{AbstractString,AbstractString}("Access-Control-Allow-Origin"=>"*"), string(JSON.json(prediction)))
			
		else
			
			404
			
		end
	
	else
	
		404
		
	end
end


server = Server( http )
run( server, 4200 )