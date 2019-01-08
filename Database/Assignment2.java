import java.util.Properties;
import java.util.ArrayDeque;
import java.util.Deque;
import java.io.FileInputStream;
import java.sql.*;
import java.lang.Math;

public class Assignment2 {
	
	static Connection[] conn = {null, null}; // {read, write}
	final static double RE = .00000001;
	static String insertStatement = "insert into performance values ";
	static PreparedStatement prepStat;
	
	public static void main(String[] args) throws Exception {
		try {
			String[] paramsFile = new String[2];
			if(args.length > 0) {
				paramsFile[0] = args[0];
				if(args.length > 1) {
					paramsFile[1] = args[1];
				} else {
					paramsFile[1] = "writerparams.txt";
				}
			} else {
				paramsFile[0] = "readerparams.txt";
				paramsFile[1] = "writerparams.txt";
			}
			
			if(connect(paramsFile)) {
				if (conn[0] != null) {
					conn[0].close();
				}
				if (conn[1] != null) {
					conn[1].close();
				}
				return;
			} // CONNECTIONS ESTABLISHED
			
			conn[1].setAutoCommit(false); // keep atomic changes
			
			performanceSetup(); // drop/create table. atomized above with later inserts
			Industry[] industries = findIndustries(); // grab industries from database
			for (int i = 0; i < industries.length; i++) {
				System.out.printf("\nProcessing %s\n", industries[i].industry);
				getIntervals(industries[i]); // add interval size to elements of industries
				if (computeReturn(industries[i])) { // find open/close for each interval/ticker
					recordReturn(industries[i]); // use calculated fractions to determine result
				} else { // 0 complete trading intervals
					System.out.printf("Infsufficient data for %s => no analysis\n", industries[i].industry);
				}
			}
			
			conn[1].commit();
			
		} finally { // close connection
			if (conn[0] != null) {
				conn[0].close();
				System.out.println("\nReader database connection closed.");
			}
			if (conn[1] != null) {
				conn[1].close();
				System.out.println("Writer database connection closed.");
			}
		}
		return;
	}
	
	private static boolean connect(String[] paramsFile) throws Exception {
		Properties[] connectProps = {new Properties(), new Properties()};
		connectProps[0].load(new FileInputStream(paramsFile[0]));
		connectProps[1].load(new FileInputStream(paramsFile[1]));
		try {
			Class.forName("com.mysql.jdbc.Driver");
			String[] dburl = {connectProps[0].getProperty("dburl"), connectProps[1].getProperty("dburl")};
			String[] username = {connectProps[0].getProperty("user"), connectProps[1].getProperty("user")};
			conn[0] = DriverManager.getConnection(dburl[0], connectProps[0]);
			System.out.printf("Database connection %s %s established.%n", dburl[0], username[0]);
			conn[1] = DriverManager.getConnection(dburl[1], connectProps[1]);
			System.out.printf("Database connection %s %s established.%n", dburl[1], username[1]);
		} catch (Exception e) {
			return true;
		}
		return false;
	}
	
	private static void performanceSetup() throws SQLException {
		Statement stmt = conn[1].createStatement();
		try {
			stmt.executeUpdate("drop table if exists Performance;");
			stmt.executeUpdate(
					"create table Performance ( " + 
					"	Industry CHAR(30), " + 
					"   Ticker CHAR(6), " + 
					"	StartDate CHAR(10), " + 
					"	EndDate CHAR(10), " + 
					"	TickerReturn CHAR(12), " + 
					"	IndustryReturn CHAR(12));");
		} finally {
			if (stmt != null) {
				stmt.close();
			}
		}
		return;
	}
	
	private static Industry[] findIndustries() throws SQLException {
		Industry[] industries = null;
		Statement stmt = conn[0].createStatement();
		try {
			ResultSet indrs = stmt.executeQuery(
					"select industry, min(ticker), count(distinct ticker), max(mindate), min(maxdate) " + 
					"from (select ticker, industry, min(transdate) as mindate, max(transdate) as maxdate " + 
					"	from company natural join pricevolume " + 
					"    group by ticker " + 
					"    having count(distinct transdate) >= 150) as tik " + 
					"group by industry " + 
					"having count(ticker) > 0 " + 
					"order by industry desc;");
			indrs.afterLast();
			if (indrs.previous()) {
				industries = new Industry[indrs.getRow()];
				int i = 0;
				do {
					String mindate = indrs.getString(4);
					String maxdate = indrs.getString(5);
					industries[i] = new Industry(indrs.getString(1), mindate, maxdate);
					industries[i].tickers = new Ticker[indrs.getInt(3)];
					industries[i].tickers[0] = new Ticker(indrs.getString(2), mindate, maxdate);
					i++;
				} while (indrs.previous());
			}
		} finally {
			if (stmt != null) {
				stmt.close();
			}
		}
		System.out.printf("%d industries found\n", industries.length);
		for (int i = 0; i < industries.length; i++) {
			System.out.printf("%s\n", industries[i].industry);
		}
		return industries;
	}
	
	private static void getIntervals(Industry industry) throws SQLException {
		PreparedStatement pstmt = conn[0].prepareStatement(
				"select transdate " + 
				"from pricevolume " + 
				"where ticker = ? and transdate >= ? and transdate <= ? " + 
				"order by transdate;");
		try {
			pstmt.setString(1, industry.tickers[0].ticker);
			pstmt.setString(2, industry.mindate);
			pstmt.setString(3, industry.maxdate);
			ResultSet indrs = pstmt.executeQuery();
			try {
				indrs.afterLast();
				if (indrs.previous()) {
					industry.intervals = new String[indrs.getRow()/60];
				}
				indrs.beforeFirst();
				int i = 1;
				while (indrs.next()) {
					if (i%60 == 1) {
						industry.intervals[i/60] = indrs.getString(1);
					} else if (i/60 == industry.intervals.length) {
						industry.end = indrs.getString(1);
						break;
					}
					i++;
				}
			} finally {
				if (indrs != null) {
					indrs.close();
				}
			}
		} finally {
			if (pstmt != null) {
				pstmt.close();
			}
		}
	}
		
	private static boolean computeReturn(Industry industry) throws SQLException {
		if (industry.intervals == null) {
			return false;
		}
		System.out.printf("%d accepted tickers for %s (%s - %s)\n", industry.tickers.length, industry.industry, industry.mindate, industry.maxdate);
		PreparedStatement pstmt = conn[0].prepareStatement(
				"select ticker, industry " + 
				"from company natural join pricevolume " + 
				"group by ticker " + 
				"having count(distinct transdate) >= 150 and industry = ? " + 
				"order by ticker;");
		try {
			pstmt.setString(1, industry.industry);
			ResultSet rs = pstmt.executeQuery();
			try {
				int i = 0;
				while (rs.next()) {
					industry.tickers[i] = new Ticker(rs.getString(1), industry.intervals[0], industry.end);
					i++;
				}
			} finally {
				if (rs != null) {
					rs.close();
				}
			}
		} finally {
			if (pstmt != null) {
				pstmt.close();
			}
		}
		pstmt = conn[0].prepareStatement(
				"select transdate, openprice, closeprice " + 
				"from pricevolume " + 
				"where ticker = ? and transdate >= ? and transdate <= ? " + 
				"order by TransDate desc;");
		try {
			for (int i = 0; i < industry.tickers.length; i++) {
				pstmt.setString(1, industry.tickers[i].ticker);
				pstmt.setString(2, industry.intervals[0]);
				pstmt.setString(3, industry.end);
				ResultSet rs = pstmt.executeQuery();
				Deque<StockRow> dpv = stockSplit(rs);
				StockRow temp2 = dpv.peek();
				StockRow temp = dpv.pop();
				industry.tickers[i].returnFrac = new double[industry.intervals.length];
				industry.tickers[i].startDate = new String[industry.intervals.length];
				industry.tickers[i].endDate = new String[industry.intervals.length];
				for (int j = 0; j < industry.intervals.length - 1; j++) {
					while (dpv.peek().TransDate.compareTo(industry.intervals[j+1]) < 0) {
						temp = dpv.pop();
					}
					industry.tickers[i].returnFrac[j] = temp.ClosePrice/temp2.OpenPrice;
					industry.tickers[i].startDate[j] = temp2.TransDate;
					industry.tickers[i].endDate[j] = temp.TransDate;
					temp2 = dpv.peek();
					temp = dpv.pop();
				}
				industry.tickers[i].returnFrac[industry.intervals.length - 1] = temp.ClosePrice/temp2.OpenPrice;
				industry.tickers[i].startDate[industry.intervals.length - 1] = temp2.TransDate;
				industry.tickers[i].endDate[industry.intervals.length - 1] = temp.TransDate;
			}
		} finally {
			if (pstmt != null) {
				pstmt.close();
			}
		}
		return true;
	}
	
	private static Deque<StockRow> stockSplit(ResultSet pv) throws SQLException {
		Deque<StockRow> dpv = new ArrayDeque<StockRow>();
		double splitFactor = 1;
		String date = "";
		double open = 1;
		double close = 1;
		if(pv.next()) {
			open = pv.getDouble("OpenPrice");
			dpv.push(new StockRow(pv.getString("TransDate"), open, pv.getDouble("ClosePrice")));
		}
		while(pv.next()) {
			close = pv.getDouble("ClosePrice");
			date = pv.getString("TransDate");
			if (Math.abs(close/open - 2.0) < .20 + RE) {
				splitFactor *= 2.0;
			} else if (Math.abs(close/open - 3.0) < .30 + RE) {
				splitFactor *= 3.0;
			} else if (Math.abs(close/open - 1.5) < .15 + RE) {
				splitFactor *= 1.5;
			}
			open = pv.getDouble("OpenPrice");
			dpv.push(new StockRow(date, open/splitFactor, close/splitFactor));
		}
		return dpv;
	}

	private static void recordReturn(Industry industry) throws SQLException {
		PreparedStatement pstmt = conn[1].prepareStatement(
				"insert into performance " + 
				"values (?, ?, ?, ?, ?, ?);");
		try {
			pstmt.setString(1, industry.industry);
			for (int j = 0; j < industry.intervals.length - 1; j++) {
				double indsum = indRetSum(industry, j);
				for (int k = 0; k < industry.tickers.length; k++) {
					pstmt.setString(2, industry.tickers[k].ticker);
					pstmt.setString(3, industry.tickers[k].startDate[j]);
					pstmt.setString(4, industry.tickers[k].endDate[j]);
					pstmt.setString(5, String.format("%10.7f", industry.tickers[k].returnFrac[j] - 1));
					pstmt.setString(6, String.format("%10.7f", (indsum - industry.tickers[k].returnFrac[j])/(industry.tickers.length - 1) - 1));
					pstmt.executeUpdate();
				}
			}
			double indsum = indRetSum(industry, industry.intervals.length - 1);
			pstmt.setString(3, industry.intervals[industry.intervals.length - 1]);
			pstmt.setString(4, industry.end);
			for (int k = 0; k < industry.tickers.length; k++) {
				pstmt.setString(2, industry.tickers[k].ticker);
				pstmt.setString(3, industry.tickers[k].startDate[industry.intervals.length - 1]);
				pstmt.setString(4, industry.tickers[k].endDate[industry.intervals.length - 1]);
				pstmt.setString(5, String.format("%10.7f", industry.tickers[k].returnFrac[industry.intervals.length - 1] - 1));
				pstmt.setString(6, String.format("%10.7f", (indsum - industry.tickers[k].returnFrac[industry.intervals.length - 1])/(industry.tickers.length - 1) - 1));
				pstmt.executeUpdate();
			}
		} finally {
			if (pstmt != null) {
				pstmt.close();
			}
		}
		return;
	}
	
	private static double indRetSum(Industry ind, int j) {
		double sum = 0;
		for (int i = 0; i < ind.tickers.length; i++) {
			sum += ind.tickers[i].returnFrac[j];
		}
		return sum;
	}
}

class Industry {
	String industry;
	String mindate;
	String maxdate;
	String[] intervals;
	Ticker[] tickers;
	String end;
	
	Industry(String ind, String mnd, String mxd) {
		this.industry = ind;
		this.mindate = mnd;
		this.maxdate = mxd;
	}
}

class Ticker {
	String ticker;
	String mindate;
	String maxdate;
	String[] startDate;
	String[] endDate;
	double[] returnFrac;
	
	Ticker(String tik, String mnd, String mxd) {
		this.ticker = tik;
		this.mindate = mnd;
		this.maxdate = mxd;
	}
}

class StockRow {
	String TransDate;
	double OpenPrice;
	double ClosePrice;
		
	StockRow(String date, double open, double close){
		this.TransDate = date;
		this.OpenPrice = open;
		this.ClosePrice = close;
	}
}
