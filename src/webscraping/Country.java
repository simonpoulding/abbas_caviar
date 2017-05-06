package webscraping;

public class Country {

	private String name;
	private String performer;
	private String song;
	
	
	public Country(String countryName, String countryPerformer, String countrySong) {
		this.name = countryName;
		this.performer = countryPerformer;
		this.song = countrySong;
	}
	
	public Country(String[] countryInfoArray) {
		this.name = countryInfoArray[0];
		this.performer = countryInfoArray[1];
		this.song = countryInfoArray[2];
	}

	@Override
	public String toString() {
		return name+" \t "+performer+" \t "+song;
	}

}
