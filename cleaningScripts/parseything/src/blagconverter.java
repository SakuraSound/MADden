import java.io.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

import org.jsoup.*;
import org.jsoup.nodes.*;

/*
 * @author mhb
 */
// This code is terrible ~mhb


class HTMLFilter implements FilenameFilter {
    public boolean accept(File dir, String name) {
        return (name.endsWith(".html"));
    }
}

public class blagconverter {
	static AtomicInteger blogcount = new AtomicInteger();
	public static void main (String args[]) throws Exception
	{
		System.out.print("Hello, World!\n\n\n\n\n");
		long d = 28918;
		System.out.format("Completed in %d ns\n", d);
	
		/*
		File file = new File("/cise/homes/mhb/blags/blags/" +
				"neworleanssaints/2011-09-12payton-on-siriusxm.html");
		Document doc = Jsoup.parse(file, null);
		
		//Element content = doc.select("#content").first();
		Element article = doc.select("div.post").first();
		Element a = doc.select("div.post").select(".sharedaddy").first();
		a.remove();
		
		System.out.println(article.text());
		
			Element link = doc.select(".commentlist").select("a[href*=respond]").first();
			System.out.println(link);
			link.remove();
		
		Element comments = doc.select(".commentlist").first();
		System.out.println(comments.text());
		*/
		
		//File basedir = new File("/cise/homes/mhb/blags/blags/");
		File basedir = new File("/cise/tmp/datascience/dataset/blags");

		long start = System.nanoTime();
		
		int procs = Runtime.getRuntime().availableProcessors();
		System.out.format("%d processors available", procs);
		
		//Thread.sleep(2119237918);
		
		File[] blagdirs = basedir.listFiles();
		for(File f : blagdirs){
			System.out.println(f.getName());
			if(f.isDirectory())
			{
				File[] htmls = f.listFiles(new HTMLFilter());
				
				ExecutorService exec = Executors.newFixedThreadPool(4);
			    try {
			        for (File h : htmls) {
						final File obj = h;

						System.out.println(obj.getName());
			            exec.submit(new Runnable() {
			                @Override
			                public void run()  {
			                	try{
			                    doShit(obj);
			                	}catch (Exception e)
			                	{
			                		// ignoring the exception is bad, mmkay?
			                	}
			                }
			            });
			        }
			    } finally {
			        exec.shutdown();
			    }
			    /*
				for(File h: htmls){
					System.out.println(h.getName());
					System.out.println(blogcount);
					doShit(h);
				}
				*/
			}
		}
		
		long end = System.nanoTime();
		long duration = end - start;
		System.out.format("Completed in %d ns", duration);
		
		System.out.println("Also known as " + duration/100000000 + "sec"
				);
	}
	private static final void doShit(File f) throws Exception
	{
	Document doc = Jsoup.parse(f, null);
		
		//Element content = doc.select("#content").first();
		Element article = doc.select("div.post").first();
		if (null == article){ // there is no article for some reason ?!??!?
			return;
		}
		Element a = doc.select("div.post").select(".sharedaddy").first();
		if(a != null){
			a.remove();
		}
		
		//System.out.println(article.text());
		
			Element link = doc.select(".commentlist").select("a[href*=respond]").first();
			
			if (link != null) { //System.out.println(link)
				; link.remove();}
		
		Element comments = doc.select(".commentlist").first();
		String commentText = "";
		if (comments != null) { 
			//System.out.println(comments.text()); 
			commentText = comments.text();
 }
		
		File team = f.getParentFile();
		String teamAbbr = team.getName();
		String oldName = f.getName();
		String newName = oldName.replace(".html", ".txt");
		String date = oldName.substring(0,10);
		String articleTitle = oldName.substring(10,oldName.length()-5);
		String articleText = article.text();
		
		//System.out.format(" old %s\n new %s\n TeamAbbr %s\n date %s\n title %s\n article %s\n comments %s\n",
		//					oldName, newName, teamAbbr, date, articleTitle, articleText, commentText);
		
		File teamdir = f.getParentFile();
		File basedir = teamdir.getParentFile();
		
		File out = new File(basedir.getAbsolutePath()+"/txtall2/" + teamAbbr +newName);
		//System.out.println(out.getAbsolutePath());

		out.delete();
		out.createNewFile();
		
		
		if(true)

		{
			
		System.out.println(blogcount.incrementAndGet());
            
		BufferedWriter bw = new BufferedWriter(new FileWriter(out));
		bw.write(teamAbbr); bw.newLine();
		bw.write(date); bw.newLine();
		bw.write(articleTitle); bw.newLine();
		bw.write(articleText); bw.newLine();
		bw.write(commentText); bw.newLine();
		bw.flush();
		}
	}
}
