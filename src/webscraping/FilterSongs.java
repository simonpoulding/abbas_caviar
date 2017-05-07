package webscraping;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;

import com.google.gson.Gson;

public class FilterSongs {

	 private static List<Country> findOrder(int kind, int year){
	        List<Country> res = new ArrayList<Country>();
	        //LOAD PAGE
	        try {
	           
	            Document doc = Jsoup.connect("https://en.wikipedia.org/wiki/Eurovision_Song_Contest_"+year).get();
	        //RETRIEVE SONGS
	            int tab = kind; //if final
//				Kind is the index of the table in wikipedia... by default: i= 3 is semifinals1, i=4 is semifinals2, i=5 is FINALS,	            
//	            if (kind==1) tab=3;
//	            if (kind==2) tab=4;
	            Element table = doc.body().getElementsByTag("tbody").get(tab);
	        //loop through rows
	            final int COUNTRY = 1;
	            final int PERFORMER = 2;
	            final int TITLE = 3;
	            for(int i = 1; i<table.getElementsByTag("tr").size(); i++){
	            	Element row = table.getElementsByTag("tr").get(i);
	            	if(row.child(0).tagName().equals("td")){	            		
		                String countrySTR = getCleanedInfo(row, COUNTRY);
		                String performerSTR = getCleanedInfo(row, PERFORMER);
		                String titleSTR = getCleanedInfo(row, TITLE).replaceAll("\"", "");
		                
		                Country country = new Country(countrySTR, performerSTR, titleSTR);
		                res.add(country);
	            	}
	            }
	        } catch (IOException e) {
	            e.printStackTrace();
	        }
	        
	        return res;
	    }
	
	private static String getCleanedInfo(Element row, int index) {
		String rawValue = row.child(index).text();			
		rawValue = rawValue.replaceAll(" ", "");
		return rawValue;
	}

	public static void main(String[] args) throws Exception {
		System.out.println("Extacting from Wikipedia...");
		List<Competition> competitions = new ArrayList<>();
		for(int i = 0; i < 8; i++){
			int year = 2010 + i;
			Competition esc = new Competition(year);
			
			int tableIndex = 5;
			
			List<Country> finalsList = findOrder(tableIndex, year);
			for(Country country : finalsList){
				esc.addCountryFinal(country);	
			}
			
			List<Country> semiFinals1List = findOrder(tableIndex-1, year);
			for(Country country : semiFinals1List){
				esc.addCountrySemiFinal1(country);	
			}
			
			List<Country> semiFinals2List = findOrder(tableIndex-2, year);
			for(Country country : semiFinals2List){
				esc.addCountrySemiFinals2(country);	
			}
			competitions.add(esc);
			System.out.println(year+" done.");
		}
		
		// Serialization
		System.out.println("Creating json files...");
		Gson gson = new Gson();
		String fileContent = gson.toJson(competitions);
				
		FileWriter writer = new FileWriter(new File("output.json"));
		writer.write(fileContent);
		writer.close();
		System.out.println("Complete!");
//		gson.toJson(1);            // ==> 1
//		gson.toJson("abcd");       // ==> "abcd"
//		gson.toJson(new Long(10)); // ==> 10
//		int[] values = { 1 };
//		gson.toJson(values);       // ==> [1]
				
	}
}
