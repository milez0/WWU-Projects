import java.util.Properties;
import java.util.Scanner;
import java.util.ArrayDeque;
import java.util.Deque;
import java.util.Iterator;
import java.io.FileInputStream;
import java.sql.*;
import java.lang.Math;

public class Assignment1 {
	static Connection conn = null;
	static double RE = 0.00000001; // rounding error
	
	public static void main(String[] args) throws Exception {
		
		// 1
		try {
			String paramsFile;
			if(args.length > 0) {
				paramsFile = args[0];
			} else {
				paramsFile = "ConnectionParameters.txt";
			}
			
			if(connect(paramsFile)) {
				System.out.println("Failure to establish database connection.");
				if (conn != null) {
					conn.close();
				}
				return;
			}
			// 2
			boolean rep;
			Scanner userIn = new Scanner(System.in);
			do {
				rep = false;
				// 2.1
				System.out.print("Enter a ticker (start/end dates [yyyy.MM.dd]): ");
				String input = userIn.nextLine().trim();
				if (input.length() > 0) {
					rep = true;
					String[] ins = input.split(" ", 3); // ticker[, startDate, endDate]
					// 2.2
					if(dispCompanyName(ins[0])) {
						// 2.3
						ResultSet pv = getPriceVolume(ins);
						// 2.4, 2.5
						Deque<StockRow> dpv = stockSplit(pv);
						// everything else
						investmentStrategy(dpv);
					}
				}
			} while (rep);
			userIn.close();
		} finally {
			if (conn != null) {
				conn.close();
				System.out.println("Database connection closed.");
			}
		}
		return;
	}
	
	private static boolean connect(String paramsFile) throws Exception {
		Properties connectProps = new Properties();
		connectProps.load(new FileInputStream(paramsFile));
		try {
			Class.forName("com.mysql.jdbc.Driver");
			String dburl = connectProps.getProperty("dburl");
			String username = connectProps.getProperty("user");
			conn = DriverManager.getConnection(dburl, connectProps);
			System.out.printf("Database connection %s %s established.%n", dburl, username);
		} catch (Exception e) {
			return true;
		}
		return false;
	}
	
	private static boolean dispCompanyName(String ticker) throws SQLException {
		PreparedStatement pstmt = conn.prepareStatement(
				"select Name " +
				"from Company " +
				"where Ticker = ?");
		pstmt.setString(1, ticker);
		ResultSet rs = pstmt.executeQuery();
		if (rs.next()) {
			System.out.println(rs.getString(1));
		} else {
			System.out.printf("%s not in database.\n", ticker);
			return false;
		}
		return true;
	}
	
	private static ResultSet getPriceVolume(String[] pars) throws SQLException {
		PreparedStatement pstmt;
		if (pars.length == 1) {
			pstmt = conn.prepareStatement(
					"select TransDate, OpenPrice, HighPrice, LowPrice, ClosePrice " +
					"from PriceVolume " +
					"where Ticker = ? " +
					"order by TransDate DESC");
		} else {
			pstmt = conn.prepareStatement(
					"select * " +
					"from PriceVolume " +
					"where Ticker = ? " +
					"and TransDate between ? and ? " +
					"order by TransDate DESC");
			pstmt.setString(2, pars[1]);
			pstmt.setString(3, pars[2]);
		}
		pstmt.setString(1, pars[0]);
		ResultSet rs = pstmt.executeQuery();
		return rs;
	}

	private static Deque<StockRow> stockSplit(ResultSet pv) throws SQLException {
		Deque<StockRow> dpv = new ArrayDeque<StockRow>();
		double splitFactor = 1;
		String date = "";
		double open = 1;
		double close = 1;
		int splitC = 0; // split counter
		int tradingDayC = 0; // trading day counter
		if(pv.next()) {
			open = pv.getDouble("OpenPrice");
			dpv.push(new StockRow(pv.getString("TransDate"), open, pv.getDouble("ClosePrice")));
			tradingDayC++;
		}
		while(pv.next()) {
			close = pv.getDouble("ClosePrice");
			date = pv.getString("TransDate");
			if (Math.abs(close/open - 2.0) < .20 + RE) {
				System.out.printf("2:1 split on %s %.2f -> %.2f\n", date, close, open);
				splitFactor *= 2.0;
				splitC++;
			} else if (Math.abs(close/open - 3.0) < .30 + RE) {
				System.out.printf("3:1 split on %s %.2f -> %.2f\n", date, close, open);
				splitFactor *= 3.0;
				splitC++;
			} else if (Math.abs(close/open - 1.5) < .15 + RE) {
				System.out.printf("3:2 split on %s %.2f -> %.2f\n", date, close, open);
				splitFactor *= 1.5;
				splitC++;
			}
			open = pv.getDouble("OpenPrice");
			dpv.push(new StockRow(date, open/splitFactor, close/splitFactor));
			tradingDayC++;
		}
		System.out.printf("%d splits in %d trading days.\n", splitC, tradingDayC);
		return dpv;
	}
	
	private static void investmentStrategy(Deque<StockRow> dpv) {
		double runAvg = 0;
		Iterator<StockRow> iter = dpv.iterator(); // day d
		// 2.7, 2.8
		if (!iter.hasNext()) {
			System.out.println("Net gain 0. Return.");
			return;
		}
		for (int d = 0; d < 49; d++) {
			runAvg += iter.next().ClosePrice;
			if (!iter.hasNext()) {
				System.out.println("Net gain 0. Return.");
				return;
			}
		}
		StockRow sr = iter.next();
		runAvg += sr.ClosePrice;
		if (!iter.hasNext()) {
			System.out.println("Net gain 0. Return.");
			return;
		}
		// 2.9
		// 2.9.1
		double cash = 0;
		int shares = 0;
		int transActC = 0;
		Iterator<StockRow> avgIter = dpv.iterator(); // at day d-50
		runAvg /= 50; // sum -> average
		double pclose = sr.ClosePrice;
		sr = iter.next();
		boolean buy = (sr.ClosePrice < runAvg) && (sr.ClosePrice < 0.97 * sr.OpenPrice + RE);
		while(iter.hasNext()) {
			// 2.9.2
			if (buy) {
				// buy
				shares += 100;
				cash -= 100*sr.OpenPrice + 8;
				// DEBUG LOGS
				// System.out.printf("Buy: %s 100 shares @ %.2f, total shares = %d, cash = %.2f, avg = %.2f\n", sr.TransDate, sr.OpenPrice, shares, cash, runAvg);
				transActC++;
			} /* 2.9.3 */ else if ((shares >= 100) && (sr.OpenPrice > runAvg) && (sr.OpenPrice/pclose > 1.01 - RE)) { 
				// sell
				shares -= 100;
				cash += 50*(sr.OpenPrice + sr.ClosePrice) - 8;
				// DEBUG LOGS
				// System.out.printf("Sell: %s 100 shares @ %.2f, total shares = %d, cash = %.2f, avg = %.2f\n", sr.TransDate, (sr.OpenPrice+sr.ClosePrice)/2, shares, cash, runAvg);
				transActC++;
			}
			// 2.9.6
			runAvg += (sr.ClosePrice - avgIter.next().ClosePrice)/50;
			buy = (sr.ClosePrice < runAvg) && (sr.ClosePrice < 0.97 * sr.OpenPrice + RE);
			pclose = sr.ClosePrice;
			sr = iter.next();
		}
		// 2.10 final day
		cash += sr.OpenPrice*shares;
		System.out.printf("Transactions executed: %d\nNet cash: %.2f\n", transActC, cash);
		return;
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
