package a2d 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Tile extends Image2D
	{
		public var tileX:int;
		public var tileY:int;
		public var width:int;
		public var height:int;
		public var bytes:ByteArray;
		public function Tile() 
		{
			super(null);
			
		}
		
		public function dispose():void {
			
		}
		
	}

}