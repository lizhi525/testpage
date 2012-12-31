package a2d 
{
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Layer
	{
		public var children:Vector.<Display2D> = new Vector.<Display2D>;
		public var affter:Function;
		public var before:Function;
		public function Layer() 
		{
			
		}
		public function update():void {
			for each(var child:Display2D in children) {
				child.update();
			}
		}
	}

}