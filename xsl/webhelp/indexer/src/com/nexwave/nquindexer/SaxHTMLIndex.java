package com.nexwave.nquindexer;

import java.io.File;
import java.io.IOException;
import java.io.Reader;
import java.util.*;
import java.io.StringReader;

// specific dita ot
import com.nexwave.nsidita.DocFileInfo;

//Stemmers
import com.nexwave.stemmer.snowball.SnowballStemmer;
import com.nexwave.stemmer.snowball.ext.EnglishStemmer;
import com.nexwave.stemmer.snowball.ext.FrenchStemmer;
import com.nexwave.stemmer.snowball.ext.GermanStemmer;

//CJK Tokenizing
import org.apache.lucene.analysis.Token;
import org.apache.lucene.analysis.TokenStream;
import org.apache.lucene.analysis.cjk.CJKAnalyzer;
import org.apache.lucene.analysis.cjk.CJKTokenizer;
import org.apache.lucene.analysis.tokenattributes.OffsetAttribute;
import org.apache.lucene.analysis.tokenattributes.TermAttribute;


/**
 * Parser for the html files generated by DITA-OT.
 * Extracts the title, the shortdesc and the text within the "content" div tag. <div id="content">
 *
 * @version 1.1 2010
 *
 * @author N. Quaine
 * @author Kasun Gajasinghe <http://kasunbg.blogspot.com>
 */
public class SaxHTMLIndex extends SaxDocFileParser{

    //KasunBG: apparently tempDico stores all the keywords and a pointer to the files containing the index in a Map
    //example: ("keyword1", "0,2,4"), ("docbook", "1,2,5") 
	private Map<String,String> tempDico;
	private int i = 0;
	private ArrayList <String> cleanUpList = null;
	private ArrayList <String> cleanUpPunctuation = null;

	//methods
	/**
	 * Constructor
	 */
	public SaxHTMLIndex () {
		super();
	}
	/**
	 * Constructor
	 */
	public SaxHTMLIndex (ArrayList <String> cleanUpStrings) {
		super();
		cleanUpList = cleanUpStrings;
	}
	/**
	 * Constructor
	 */
	public SaxHTMLIndex (ArrayList <String> cleanUpStrings, ArrayList <String> cleanUpChars) {
		super();
		cleanUpList = cleanUpStrings;
		cleanUpPunctuation = cleanUpChars;
	}

	/**
	 * Initializer
	 */
	public int init(Map<String,String> tempMap){
		tempDico = tempMap;
		return 0;
	}

	/**
	 * Parses the file to extract all the words for indexing and
	 * some data characterizing the file.
	 * @param file contains the fullpath of the document to parse
     * @param indexerLanguage this will be used to tell the program which stemmer to be used.
	 * @return a DitaFileInfo object filled with data describing the file
	 */
	public DocFileInfo runExtractData(File file, String indexerLanguage) {
		//initialization
		fileDesc = new DocFileInfo(file);
		strbf = new StringBuffer("");

		// Fill strbf by parsing the file
		parseDocument(file);

		String str = cleanBuffer(strbf);
        str = str.replaceAll("\\s+"," ");   //there's still redundant spaces in the middle
//		System.out.println(file.toString()+" "+ str +"\n");
		String[] items = str.split("\\s");      //contains all the words in the array

        //get items one-by-one, tunnel through the stemmer, and get the stem.
        //Then, add them to tempSet
        //Do Stemming for words in items
        //TODO currently, stemming support is for english and german only. Add support for other languages as well.

        String[] tokenizedItems;
        if(indexerLanguage.equalsIgnoreCase("ja") || indexerLanguage.equalsIgnoreCase("zh")
                || indexerLanguage.equalsIgnoreCase("ko")){
                LinkedList<String> tokens = new LinkedList<String>();
            try{
                CJKAnalyzer analyzer = new CJKAnalyzer(org.apache.lucene.util.Version.LUCENE_30);
                Reader reader = new StringReader(str);
                TokenStream stream = analyzer.tokenStream("", reader);
                TermAttribute termAtt = (TermAttribute) stream.addAttribute(TermAttribute.class);
                OffsetAttribute offAtt = (OffsetAttribute) stream.addAttribute(OffsetAttribute.class);

                while (stream.incrementToken()) {
                    String term = termAtt.term();
                    tokens.add(term);
//                    System.out.println(term + " " + offAtt.startOffset() + " " + offAtt.endOffset());
                }

                tokenizedItems = tokens.toArray(new String[tokens.size()]);

            }catch (IOException ex){
                tokenizedItems = items;
                System.out.println("Error tokenizing content using CJK Analyzer. IOException");
                ex.printStackTrace();
            }

        } else {
            SnowballStemmer stemmer;
            if(indexerLanguage.equalsIgnoreCase("en")){
                 stemmer = new EnglishStemmer();
            } else if (indexerLanguage.equalsIgnoreCase("de")){
                stemmer= new GermanStemmer();
            } else if (indexerLanguage.equalsIgnoreCase("fr")){
                stemmer= new FrenchStemmer();
            } else {
                stemmer = null;//Languages which stemming is not yet supproted.So, No stemmers will be used.
            }
            if(stemmer != null)             //If a stemmer available
                tokenizedItems = stemmer.doStem(items);
            else                            //if no stemmer available for the particular language
                tokenizedItems = items;

        }

       /* for(String stemmedItem: tokenizedItems){
            System.out.print(stemmedItem+"| ");
        }*/

		//items: remove the duplicated strings first
		HashSet <String> tempSet = new HashSet<String>();
        tempSet.addAll(Arrays.asList(tokenizedItems));
		Iterator it = tempSet.iterator();
		String s;
        while (it.hasNext()) {
        	s = (String)it.next();
        	if (tempDico.containsKey(s)) {
        		String temp = tempDico.get(s);
        		temp = temp.concat(",").concat(Integer.toString(i));
        		//System.out.println("temp="+s+"="+temp);
        		tempDico.put(s, temp);
        	}else {
        		tempDico.put(s, Integer.toString(i));
        	}
        }

        i++;
		return fileDesc;
	}

	/**
	 * Cleans the string buffer containing all the text retrieved from
	 * the html file:  remove punctuation, clean white spaces, remove the words
	 * which you do not want to index.
	 * NOTE: You may customize this function:
	 * This version takes into account english and japanese. Depending on your
	 * needs,
	 * you may have to add/remove some characters/words through props files
	 *    or by modifying tte default code,
	 * you may want to separate the language processing (doc only in japanese,
	 * doc only in english, check the language metadata ...).
	 */
	private String cleanBuffer (StringBuffer strbf) {
		String str = strbf.toString().toLowerCase();
		StringBuffer tempStrBuf = new StringBuffer("");
		StringBuffer tempCharBuf = new StringBuffer("");
		if ((cleanUpList == null) || (cleanUpList.isEmpty())){
			// Default clean-up

			// Should perhaps eliminate the words at the end of the table?
			tempStrBuf.append("(?i)\\bthe\\b|\\ba\\b|\\ban\\b|\\bto\\b|\\band\\b|\\bor\\b");//(?i) ignores the case
			tempStrBuf.append("|\\bis\\b|\\bare\\b|\\bin\\b|\\bwith\\b|\\bbe\\b|\\bcan\\b");
			tempStrBuf.append("|\\beach\\b|\\bhas\\b|\\bhave\\b|\\bof\\b|\\b\\xA9\\b|\\bnot\\b");
			tempStrBuf.append("|\\bfor\\b|\\bthis\\b|\\bas\\b|\\bit\\b|\\bhe\\b|\\bshe\\b");
			tempStrBuf.append("|\\byou\\b|\\bby\\b|\\bso\\b|\\bon\\b|\\byour\\b|\\bat\\b");
			tempStrBuf.append("|\\b-or-\\b|\\bso\\b|\\bon\\b|\\byour\\b|\\bat\\b");
            tempStrBuf.append("|\\bI\\b|\\bme\\b|\\bmy\\b");

			str = str.replaceFirst("Copyright � 1998-2007 NexWave Solutions.", " ");


			//nqu 25.01.2008 str = str.replaceAll("\\b.\\b|\\\\", " ");
			// remove contiguous white charaters
			//nqu 25.01.2008 str = str.replaceAll("\\s+", " ");
		}else {
			// Clean-up using the props files
			tempStrBuf.append("\\ba\\b");
			Iterator it = cleanUpList.iterator();
			while (it.hasNext()){
				tempStrBuf.append("|\\b"+it.next()+"\\b");
			}
		}
		if ((cleanUpPunctuation != null) && (!cleanUpPunctuation.isEmpty())){
			tempCharBuf.append("\\u3002");
			Iterator it = cleanUpPunctuation.iterator();
			while (it.hasNext()){
				tempCharBuf.append("|"+it.next());
			}
		}

		str = minimalClean(str, tempStrBuf, tempCharBuf);
		return str;
	}

	private String minimalClean(String str, StringBuffer tempStrBuf, StringBuffer tempCharBuf) {
		String tempPunctuation = new String(tempCharBuf);

		str = str.replaceAll("\\s+", " ");
		str = str.replaceAll("->", " ");
		str = str.replaceAll(IndexerConstants.EUPUNCTUATION1, " ");
		str = str.replaceAll(IndexerConstants.EUPUNCTUATION2, " ");
		str = str.replaceAll(IndexerConstants.JPPUNCTUATION1, " ");
		str = str.replaceAll(IndexerConstants.JPPUNCTUATION2, " ");
		str = str.replaceAll(IndexerConstants.JPPUNCTUATION3, " ");
		if (tempPunctuation.length() > 0)
		{
			str = str.replaceAll(tempPunctuation, " ");
		}

		//remove useless words
		str = str.replaceAll(tempStrBuf.toString(), " ");

		// Redo punctuation after removing some words: (TODO: useful?)
		str = str.replaceAll(IndexerConstants.EUPUNCTUATION1, " ");
		str = str.replaceAll(IndexerConstants.EUPUNCTUATION2, " ");
		str = str.replaceAll(IndexerConstants.JPPUNCTUATION1, " ");
		str = str.replaceAll(IndexerConstants.JPPUNCTUATION2, " ");
		str = str.replaceAll(IndexerConstants.JPPUNCTUATION3, " ");
		if (tempPunctuation.length() > 0)
		{
			str = str.replaceAll(tempPunctuation, " ");
		}		return str;
	}

}
