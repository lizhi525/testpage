package vpath 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class VPoint extends Point
	{
		public var line:VLine;
		public var g:Number;
		public var h:Number;
		public var f:Number;
		public var version:int = -1;
		public var parent:VPoint;
		public var links:Vector.<VPoint> = new Vector.<VPoint>;
		public var linkCosts:Vector.<Number> = new Vector.<Number>;
		public function VPoint() 
		{
			
		}
		
	}

}