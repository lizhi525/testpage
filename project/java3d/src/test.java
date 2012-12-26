/**
 * @(#)test.java
 *
 * Sample Applet application
 *
 * @author 
 * @version 1.00 12/12/26
 */
 
import java.awt.*;
import java.applet.*;
import javax.swing.*;

public class test extends Applet {
	
	public void init() {
		JFrame frame = new JFrame();
   		frame.setSize(400,400);
   		frame.add(new TestJava());
   		//frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
   		frame.setVisible(true);
   		setSize(400,400);
	}

	//public void paint(Graphics g) {
		//g.drawString("Welcome to Java!!", 50, 60 );
	//}
}

class TestJava extends JPanel implements Runnable{

	private Thread thread;
	private int c=5000;
	private Vector3D[] vs=new Vector3D[c];
    public TestJava() {
    	(thread = new Thread(this)).start();
    	setBackground(new Color(0xffffff));
    	setSize(400,400);
    	for (int i=0; i < c;i++ ) {
			Vector3D v=new Vector3D();
			v.x=0;
			v.y=0;
			v.z=100+i*10;
			vs[i]=v;
		}
    }
    @Override
    public void paintComponent(Graphics g){
    	super.paintComponent(g);
    	Graphics2D g2d = (Graphics2D)g;
    	Point m= getMousePosition();
    	Vector3D lv = vs[0];
    	try {
			lv.x=m.x-200;
    		lv.y=m.y-200;
		}
		catch (Exception ex) {
		}
		
		g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);
    	
		for (int i=0;i<c;i++){
			Vector3D v = vs[i];
			v.x += (lv.x - v.x) * .6;
			v.y += (lv.y - v.y) * .6;
			lv = v;
			float fz = 100 / v.z;
			float r = 30*fz;
			g2d.drawArc((int)(v.x*fz+200-r),(int)(v.y*fz+200-r),(int)r*2,(int)r*2,0,360);
		}
    }
    
    public void run(){
    	while(true){
	    	repaint();
	    	try{
	    		thread.sleep(1000/60);
	    	}catch(Exception e){
	    	}
    	}
    }
    
   	public static void main (String[] args) {
   		JFrame frame = new JFrame();
   		frame.setSize(400,400);
   		frame.add(new TestJava());
   		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
   		frame.setVisible(true);
	}
}

class Vector3D{
	public float x;
	public float y;
	public float z;
}