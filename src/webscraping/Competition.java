package webscraping;

import java.util.ArrayList;
import java.util.List;

public class Competition {

	private int year;
	private String hostCountry;
	private List<Country> finals;
	private List<Country> semiFinals1;
	private List<Country> semiFinals2;
	
	public Competition(int year){
		this(year,"");
	}

	public Competition(int year, String hostCountry){
		this.year = year;
		this.hostCountry = hostCountry;
		this.finals = new ArrayList<Country>();
		this.semiFinals1 = new ArrayList<Country>();
		this.semiFinals2 = new ArrayList<Country>();
	}
	
	public void addCountryFinal(Country country){
		this.finals.add(country);
	}

	public void addCountrySemiFinal1(Country country){
		this.semiFinals1.add(country);
	}

	public void addCountrySemiFinals2(Country country){
		this.semiFinals2.add(country);
	}
	
	public List<Country> getFinals() {
		return finals;
	}

	public void setFinals(List<Country> finals) {
		this.finals = finals;
	}

	public List<Country> getSemiFinals1() {
		return semiFinals1;
	}

	public void setSemiFinals1(List<Country> semiFinals1) {
		this.semiFinals1 = semiFinals1;
	}

	public List<Country> getSemiFinals2() {
		return semiFinals2;
	}

	public void setSemiFinals2(List<Country> semiFinals2) {
		this.semiFinals2 = semiFinals2;
	}

	public int getYear() {
		return year;
	}

	public void setYear(int year) {
		this.year = year;
	}

	public String getHostCountry() {
		return hostCountry;
	}

	public void setHostCountry(String hostCountry) {
		this.hostCountry = hostCountry;
	}
}
