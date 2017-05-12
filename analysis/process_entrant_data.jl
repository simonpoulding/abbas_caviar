using DataFrames
using JSON

function load_entrant_data(year::Int)
	
   yearsdict = open(joinpath("..", "output.json"), "r") do f
	         	JSON.parse(f)
			 end
	
   for yeardict in yearsdict
	   if yeardict["year"] == year
		   entrantdf = load_entrant_data(yeardict["finals"])
		   if size(entrantdf,1) < 10
			  # assume semi-finals have not happened yet
			  entrantdf = vcat(entrantdf, load_entrant_data(yeardict["semiFinals1"]), load_entrant_data(yeardict["semiFinals2"]))
			  # entrantdf = load_entrant_data(yeardict["semiFinals1"])
		   end
		   return entrantdf
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
