using HttpServer
using JSON
include(joinpath("..","analysis", "regression_audio_features.jl"))


http = HttpHandler() do req::Request, res::Response

	if ismatch(r"^/api/[0-9]{4}", req.resource)
		
		year = parse(Int, req.resource[6:end])

		if year == 2014
	
			prediction = [
				Dict("country"=>"Serbia", "song"=>"Fire, Desire", "artist"=>"The Flobberworms", "predicted"=>149, "placement"=>2, "actual"=>138, "difference"=>11,),
				Dict("country"=>"UK", "song"=>"Leaving Europe", "artist"=>"The Government", "predicted"=>2, "placement"=>25, "actual"=>5, "difference"=>-3,),
				]
			
		else

			prediction = [
				Dict("country"=>"Serbia", "song"=>"Fire, Desire", "artist"=>"The Flobberworms", "predicted"=>149, "placement"=>2, "actual"=>138, "difference"=>11,),
				Dict("country"=>"France", "song"=>"Election Today", "artist"=>"Emmanual Macron", "predicted"=>67, "placement"=>10, "actual"=>67, "difference"=>0,),
				]
				
		end
		
		sourceyears = filter(y -> y != year, 2014:2016)
		df = get_prediction(year, sourceyears)
		
		prediction = map(1:length(df)) do i
			Dict("country"=>df[i,:country],
				 "song"=>df[i,:title], 
				 "artist"=>df[i,:artist], 
				 "predicted"=>df[i,:predictedtelevote], 
				 "placement"=>0, 
				 "actual"=>0, 
				 "difference"=>0,)
		end
		
		Response(200, Dict{AbstractString,AbstractString}("Access-Control-Allow-Origin"=>"*"), string(JSON.json(prediction)))
	
	else
	
		404
		
	end
end


server = Server( http )
run( server, 4200 )