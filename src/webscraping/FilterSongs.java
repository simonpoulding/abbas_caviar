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
	            String query = "";
	            switch(kind){
	                case 0:
	                    query = "Final";
	                    break;
	                case 1:
	                    query = "Semi-final 1";
	                    break;
	                case 2:
	                    query = "Semi-final 2";
	                    break;
	            }
	            Document doc = Jsoup.connect("https://en.wikipedia.org/wiki/Eurovision_Song_Contest_"+year).get();
	        //RETRIEVE SONGS
	            int tab = 5; //if final
	            if (kind==1) tab=3;
	            if (kind==2) tab=4;
	            Element table = doc.body().getElementsByTag("tbody").get(tab);
	        //loop through rows
	            final int COUNTRY = 1;
	            final int PERFORMER = 2;
	            final int TITLE = 3;
	            for(int i = 1; i<table.getElementsByTag("tr").size(); i++){
	                Element row = table.getElementsByTag("tr").get(i);
	                String countrySTR = getCleanedInfo(row, COUNTRY);
	                String performerSTR = getCleanedInfo(row, PERFORMER);
	                String titleSTR = getCleanedInfo(row, TITLE).replaceAll("\"", "");
	                
	                Country country = new Country(countrySTR, performerSTR, titleSTR);
	                res.add(country);
}
	        } catch (IOException e) {
	            e.printStackTrace();
	        }
	        
	        return res;
	    }
	
	private static String getCleanedInfo(Element row, int index) {
		return row.child(index).text();
	}

	public static void main(String[] args) throws Exception {
		System.out.println("Extacting from Wikipedia...");
		List<Competition> competitions = new ArrayList<>();
		for(int i = 0; i < 7; i++){
			int year = 2010 + i;
			Competition esc = new Competition(year);
			List<Country> finalsList = findOrder(0, year);
			for(Country country : finalsList){
				esc.addCountryFinal(country);	
			}
			
			List<Country> semiFinals1List = findOrder(1, year);
			for(Country country : semiFinals1List){
				esc.addCountrySemiFinal1(country);	
			}
			
			List<Country> semiFinals2List = findOrder(2, year);
			for(Country country : semiFinals2List){
				esc.addCountrySemiFinals2(country);	
			}
			competitions.add(esc); 
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
