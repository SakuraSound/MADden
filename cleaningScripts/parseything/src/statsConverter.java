import java.io.*;
import java.util.Iterator;
import java.util.List;

import static java.text.Format.*;
import static java.lang.System.out;
import org.jsoup.*;
import org.jsoup.nodes.*;
import org.jsoup.select.*;

public class statsConverter {

	/**
	 * @author mhb
	 * /sarcasm/ best code ev@r!!!
	 */
	public static void main(String[] args) throws Exception 
	{
		System.out.print("Hello, World!\n");
		File basedir = new File("/cise/tmp/datascience/dataset/blags");
		
		int procs = Runtime.getRuntime().availableProcessors();
		System.out.format("%d processors available\n", procs);

		long start = System.nanoTime();
		
		String stat = "recievers";
		
		File f = new File("/cise/homes/mhb/Desktop/stats/"+stat+".html");
		
		Document doc = Jsoup.parse(f, null);
		
		Element table = doc.select("table[class]").first();
		
		
		Elements rows = table.children().first().children();

		
		
//		Element e = rows.first();
		
		//System.out.println(e);
		
		
		for(int i = 0; i <= 3; i++)
		{
			Element row = rows.get(i);
			
			//out.println(row.children().text());
			for(Element e :row.children())
			{
				out.println(e.text());
			}
			out.println();
		}
		
		out.println();		out.println();		out.println();
		
		File outF = new File("/cise/tmp/datascience/dataset/NFL/stats/"+stat+"stats.txt");
		outF.delete();
		outF.createNewFile();
		BufferedWriter bw = new BufferedWriter(new FileWriter(outF));
		{
		Element row;
		for (Iterator<Element> itr = rows.iterator(); itr.hasNext();)
		{
			row = itr.next();
			if(itr.hasNext())
			{
				//out.println(row.children().text());
				Elements r = row.children();
				for(Iterator<Element> itrr = r.iterator(); itrr.hasNext();)
				{
					Element e = itrr.next();
					out.println(e.text());
					bw.write(e.text()); 
					if(itrr.hasNext())
						{
						bw.write(",");
						}
						
				}
				bw.newLine();
			}
		}
		}
		bw.flush();
		bw.close();

		System.out.println(rows.size());
		
		
		
		
		long end = System.nanoTime();
		long duration = end - start;
		System.out.format("Completed in %d ns\n", duration);		
		System.out.println("Also known as " + duration/1000000000.0 + "sec");
		out.format("asrt\n");
	}
}
