/*
 * Miles Keppler
 * Alex Derocco
 * 
 */

import java.awt.*;
import java.util.Hashtable;
//import java.util.*;
//import static java.lang.Math.pow;

public class Tromino{


   public static boolean thegame = false;
   static int[][] board;

   public static void main(String args[]){
      
      
   	//Check the command line arguments. 
	   
	   /*
	    * arg0 = power of 2 for board size [1 , 5]
	    * arg1 = row coordinate of initial blank spot [0 , 2^arg0 - 1]
	    * arg2 = column coordinate of ^^^ spot [0 , 2^arg0 - 1]
	    */
	   
      if(!checkArgs(args)){
         System.out.println("hello");
         return;
      }
      
      int size = (int)Math.pow(2, Integer.parseInt(args[0]));
      myBoard(size, size);
      int pRow = (Integer.parseInt(args[1]));
      int pCol = (Integer.parseInt(args[2]));
      board[pRow][pCol] = 0;
      recurse(pRow, pCol, size, size, 1);
      printBoard(board);
      printBoardGUI(board);
      
   }
   
   public static void myBoard(int x, int y){
      board = new int[x][y];
   }
   
      //Solve the puzzle. Need to define a recursive method solve and call it here.

   /*
    * startRow + startCol tell the spot to create the next tromino around
    * size is the size of the board. no placing trominos outside the bounds of the array
    * frame is a tool to look at only ( n x n ) squares at a time
    * COLOR goes up one unit per use of the recurse method. each recurse method creates only one tromino.
    */
   static int COLOR;
   
   public static void recurse(int startRow, int startCol, int size, int frame, int color) {
	   COLOR = color + 1;
	   // grabbing the large frames of view. making sure the frame does not extend past the array
	   for (int r = 0; r < size; r = r + frame) {
		   for (int c = 0; c < size; c = c + frame) {
			   // check frame for start square
			   if (startRow >= r && startRow < r + frame && startCol >= c && startCol < c + frame) {
				   if (frame == 2) {
					   // finalize smaller squares / frames
					   for (int i = r; i < r + frame; i = i + frame / 2) {
						   for (int j = c; j < c + frame; j = j + frame / 2) {
							   if (i != startRow || j != startCol) {
								   board[i][j] = color;
							   }
						   }
					   }
				   } else {
					   // move into 4 corners of frame and reduce the frame size
					   for (int i = r; i < r + frame; i = i + frame / 2) {
						   for (int j = c; j < c + frame; j = j + frame / 2) {
							   if (startRow < i || startRow >= i + frame / 2 || startCol < j || startCol >= j + frame / 2) {
								   // look at center 4 squares in each large frame. this is where we place a tromino.
								   int n = i;
								   int m = j;
								   if (i < r + frame / 2) {
									   n = r + frame / 2 - 1;
								   }
								   if (j < c + frame / 2) {
									   m = c + frame / 2 - 1;
								   }
								   board[n][m] = color;
								   recurse(n, m, size, frame / 2, COLOR);
								   recurse(startRow, startCol, size, frame / 2, COLOR);
							   }
						   }
					   }
				   }
			   }
		   }
	   }
   }

   /**
	 * Check if the string is a valid number format.
	 * @param s
	 * @return True if s is a valid double.
    * a ready-to-use method
	 */
   public static boolean isNumber(String s) {  
      return s.matches("[-+]?\\d*\\.?\\d+");
        
   } 


	/**
	 * Check for the required command line arguments.
	 * @param args - The command line args.
	 * @return True if required command line args are present and valid.
    * need to complete
	 */
   public static boolean checkArgs(String[] args){ 
     
      if (!isNumber(args[0]) || !isNumber(args[1]) || !isNumber(args[2])){
         return false;
         
      }   
      int arg0 = (Integer.parseInt(args[0]));
      int arg1 = (Integer.parseInt(args[1]));
      int arg2 = (Integer.parseInt(args[2]));     
      if (arg0 >=5 && arg0 <=1){
         return false;
      }  
      int n  = arg0; 
      double power = Math.pow(2, n);
      if ((arg1 >= 0) && (arg1 <= power - 1)){
         if ((arg2 >= 0) && (arg2 <= power - 1)){
            return true;
         }          
     }
     return false;
              
   }
   
   	
	/**
	 * An utility method of finding the mid-point of a sub-board of 2^n x 2^n
	 * @param n, k. k is the row (or column) index of a given cell
	 * @return the row (or column) index of the mid-point of the sub-board
    * a ready-to-use method
	 */

   public static int getIndex(int n, int k){
      return (int)  (Math.pow(2, n-1) - 1 +(int) (k/Math.pow(2, n)) * Math.pow(2,n));
   } 
   
   /**
	 * Draw Board using print.
	 * @param chessBoard
    * a ready-to-use method
	 */
   public static void printBoard(int[][] board){
      int boardLength = board.length;
   
      for(int i=0; i<boardLength; i++){
         System.out.print(" ");
         for(int j=0; j<boardLength; j++){
            System.out.print("----"); 
         }
         System.out.println();
         for(int j=0; j<boardLength; j++){
            System.out.print(" | " + board[i][j]); 
         }
         System.out.println(" |");
      }
      System.out.print(" ");
      for(int j=0; j<boardLength; j++){
         System.out.print("----"); 
      } 
      System.out.println();
   }
   
   
	/**
	 * Display Board in GUI.
	 * @param chessBoard
    * a ready-to-use method
	 */
    
   public static void printBoardGUI(int[][] board){
      int boardLength = board.length;
      int width = 50;
      int boardLengthPx = boardLength * width;
      Hashtable<Integer, Color> colors = new Hashtable<Integer, Color>();
      DrawingPanel panel = new DrawingPanel(boardLengthPx, boardLengthPx);
      panel.setBackground(Color.darkGray);
   
      colors.put(0, Color.white);
   	
      Graphics g = panel.getGraphics();
      for(int i = 0; i < boardLength; i++) {
         for(int j = 0; j < boardLength; j++) {
            if (!colors.containsKey(board[i][j])){
               colors.put(board[i][j],
                                                   Color.getHSBColor((float)Math.random(),
                                                                     (float)(.4 + Math.random()*0.6),
                                                                     (float)(.2 + Math.random()*0.8)));
            }
            g.setColor((Color)colors.get(board[i][j]));				
            g.fillRect(j * width, i * width, width, width);
            g.setColor(Color.black);
         	
            g.drawLine(j * width, i * width, j * width, (i * width) + width);
            g.drawLine(j * width, i * width, (j * width) + width, i * width);
         }
      }
   }
}