using HttpServer
include(joinpath("..","analysis", "regression_audio_attributes.jl"))


http = HttpHandler() do req::Request, res::Response

	if ismatch(r"^/sample\?params=[0-9.+]*", req.resource)
	
		if length(req.resource)>=16
		
			# get params from request
			reqparams = map(p->parse(Float64, p), split(req.resource[16:end], "+"))
		
			# merge with existing params
			oldparams = getparams(choicemodel(gn))
			newparams = map(i -> (i<=length(reqparams)) ? reqparams[i] : oldparams[i], 1:length(oldparams))
		
			# set the new params
			setparams!(choicemodel(gn), newparams)
		
			println("New Params: $getparams(choicemodel(gn)))")
			
		end
		
		sample_behaviour(gn, behaviourfn)
		
	else
	
		404
		
	end
end


server = Server( http )
run( server, 8000 )