package a2d 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Display2D
	{
		public var changed:Boolean = true;
		private var _x:Number=0;
		private var _y:Number=0;
		private var _scaleX:Number=1;
		private var _scaleY:Number = 1;
		public var matrix:Vector.<Number> = Vector.<Number>([1, 1, 0, 0, 1, 1, 0, 0]);
		public function Display2D() 
		{
		}
		
		public function update():void {
			
		}
		
		public function get x():Number 
		{
			return _x;
		}
		
		public function set x(value:Number):void 
		{
			_x = value;
			changed = true;
		}
		
		public function get y():Number 
		{
			return _y;
		}
		
		public function set y(value:Number):void 
		{
			_y = value;
			changed = true;
		}
		
		public function get scaleX():Number 
		{
			return _scaleX;
		}
		
		public function set scaleX(value:Number):void 
		{
			_scaleX = value;
			changed = true;
		}
		
		public function get scaleY():Number 
		{
			return _scaleY;
		}
		
		public function set scaleY(value:Number):void 
		{
			_scaleY = value;
			changed = true;
		}
		
	}

}