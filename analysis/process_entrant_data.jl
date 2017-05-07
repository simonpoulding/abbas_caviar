using DataFrames
using JSON

function load_entrant_data(year::Int)
	
   yearsdict = open(joinpath("..", "output.json"), "r") do f
	         	JSON.parse(f)
			 end
	
   for yeardict in yearsdict
	   if yeardict["year"] == year
		   return load_entrant_data(yeardict["finals"])
	   end
   end
  
   error("Year $year not found")
   
end


function load_entrant_data(entrants::Vector)
	
	title = Vector{AbstractString}()
	artist = Vector{AbstractString}()
	country = Vector{AbstractString}()

	for entrant in entrants
		
		push!(title, entrant["song"])
		push!(artist, entrant["performer"])
		push!(country, entrant["name"])

	end
	
	DataFrame(title=title, artist=artist, country=country)
	
end
