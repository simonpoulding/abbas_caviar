const NORMALISED_COUNTRIES = [
	"Netherlands" => ["The Netherlands",],
	"United Kingdom" => ["The United Kingdom",],
]

const NORMALISED_CHARACTERS = [
"a" => ["å","á","ä","â","æ","ã","ā"],
"e" => ["è","é","ë","ê","ē","ė","ę"],
"i" => ["î","ï","í","ī","ī","ì"],
"o" => ["ô","ö","ò","ó","œ","ø","ō","õ"],
"u" => ["û","ü","ù","ú","ū"],
"n" => ["ñ","ń"],
"s" => ["ß","ś","š"],
"c" => ["ç","ć","č"],
"l" => ["ł"],
"z" => ["ž","ź","ż"],
"y" => ["ÿ"],
]

function normalise_country(country::AbstractString)
	for (norm, others) in NORMALISED_COUNTRIES
		for other in others 
			if country == other
				return norm
			end
		end
	end
	country
end

function normalise_characters(str::AbstractString)
	for (norm, others) in NORMALISED_CHARACTERS
		for other in others
			str = replace(str, other, norm)
			str = replace(str, uppercase(other), uppercase(norm))
		end
	end
	str
end

# join(a,b, on = [:id1, :id2], kind=:left)

