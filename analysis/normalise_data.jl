const NORMALISED_COUNTRIES = [
	"Netherlands" => ["The Netherlands",],
	"United Kingdom" => ["The United Kingdom",],
	"Switzerland" => [" Switzerland",],
]

const NORMALISED_ARTISTS = [
	"Minus One" => ["Minus-One",],
	"Nika Kocharov & Young Georgian Lolitaz" =>["Nika Kocharov And Young Georgian Lolitaz",],
	"Sanja Vucic ZAA" => ["ZAA Sanja Vucic",],
	"Justs Sirmais" => ["Justs"],
	"Polina Gagarina" => ["Полина Гагарина",],
	"Morland & Debrah Scarlett" => ["Morland",],
	"Monika Linkyte & Vaidas Baumila" => ["Monika Linkyte",],
	"Twin Twin" => ["TWIN TWIN",],
	"Freaky Fortune" => ["Freaky Fortune feat. RiskyKidd",],
	"Andras Kallay Saunders" => ["Andras Kallay-Saunders",],
	"Firelight" => ["FireLight",],
	"Donatan - Cleo" => ["Donatan & Cleo",],
	"Paula Seling & Ovi" => ["Paula Seling",],
	"Anja Nissen" => ["Anja",],
	"Ilinca and Alex Florea" => ["Ilinca",],
	"JOWST5" => ["JOWST",],
	"Jana Burceska" => ["Jana Burcheska",],
	"Papai Joci" => ["Joci Papai",],
	"Koit Toome and Laura" => ["KOIT TOOME",],
	"Naviband" => ["NAVIBAND",],
	"OG3NE" => ["O'G3NE",],
	"Valentina Monetta and Jimmie Wilson" => ["Valentina Monetta",],
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
	ncountry = ((length(country) > 1) && (Int(country[1]) == 160)) ? country[3:end] : country
	for (norm, others) in NORMALISED_COUNTRIES
		for other in others 
			if ncountry == other
				return norm
			end
		end
	end
	ncountry
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

function normalise_artist(artist::AbstractString)
	ncartist = normalise_characters(artist)
	for (norm, others) in NORMALISED_ARTISTS
		for other in others 
			if ncartist == other
				return norm
			end
		end
	end
	ncartist
end

function normalise_instrumentalness(value::Float64)
	value < 0.005 ? 0.00 : value
end

function normalise_duration(value::Float64)
	value > 180e3 ? 180e3 : value
end
