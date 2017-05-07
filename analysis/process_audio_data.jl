using DataFrames
using JSON

function load_audio_features_data(year::Int)
	
   yearsdict = open(joinpath("..", "out", "playlistsTreatedWithAudioFeatures.json"), "r") do f
	         	JSON.parse(f)
			 end
			 
   if haskey(yearsdict, string(year))
	   load_audio_features_data(yearsdict[string(year)])
   else
	   error("Data is not available for year $(year)")
   end
   
end


function load_audio_features_data(yeardict::Dict)
	
	title = Vector{AbstractString}()
	artist = Vector{AbstractString}()
	tempo = Vector{Float64}()
	liveness = Vector{Float64}()
	mode = Vector{Float64}()
	energy = Vector{Float64}()
	speechiness = Vector{Float64}()
	danceability = Vector{Float64}()
	key = Vector{Float64}()
	loudness = Vector{Float64}()
	duration_ms = Vector{Float64}()
	acousticness = Vector{Float64}()
	instrumentalness = Vector{Float64}()
	valence = Vector{Float64}()
	time_signature = Vector{Float64}()

	for track in yeardict["tracks"]
		
		push!(title, track["name"])
		push!(artist, track["artists"][1]["name"])
		af = track["audio-features"]
		push!(tempo, af["tempo"])
		push!(liveness, af["liveness"])
		push!(mode, af["mode"])
		push!(energy, af["energy"])
		push!(speechiness, af["speechiness"])
		push!(danceability, af["danceability"])
		push!(key, af["key"])
		push!(loudness, af["loudness"])
		push!(duration_ms, af["duration_ms"])
		push!(acousticness, af["acousticness"])
		push!(instrumentalness, af["instrumentalness"])
		push!(valence, af["valence"])
		push!(time_signature, af["time_signature"])

	end
	
	DataFrame(title=title, artist=artist, tempo=tempo, liveness=liveness, mode=mode, energy=energy, speechiness=speechiness, 
				danceability=danceability, key=key, loudness=loudness, duration_ms=duration_ms, acousticness=acousticness,
				instrumentalness=instrumentalness, valence=valence, time_signature=time_signature)
	
end
