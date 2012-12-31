import javax.swing.*;
class TestUI extends JFrame{
	
	public TestUI(){
		setSize(400,400);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setLayout(new BoxLayout(getContentPane(),BoxLayout.Y_AXIS));
		add(new JButton("abc"));
		add(new JScrollBar());
		setVisible(true);
		System.out.println(this.getLayout());
		JSplitPane sp = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT,new JButton(),new JSplitPane(JSplitPane.VERTICAL_SPLIT,new JButton(),new JButton()));
		add(sp);
	}
	/**
	 * Method main
	 *
	 *
	 * @param args
	 *
	 */
	public static void main(String[] args) {
		// TODO: Add your code here
		try {
			UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
		}
		catch (Exception ex) {
			ex.printStackTrace();
		}
		
		new TestUI();
	}	
}
