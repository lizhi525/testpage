package  
{
	import a2d.A2D;
	import a2d.Display2D;
	import a2d.Image2D;
	import a2d.Layer;
	import a2d.Texture2D;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Main extends Sprite
	{
		private var d2:A2D;
		private var image:Image2D;
		public function Main() 
		{
			d2 = new A2D;
			d2.init(stage, init);
			var layer:Layer = d2.createLayer();
			var bmd:BitmapData = new BitmapData(100, 100, false);
			bmd.perlinNoise(100, 100, 10, 2, true, true);
			[Embed(source = "t.png")]var c:Class;
			var texture:Texture2D = new Texture2D((new c as Bitmap).bitmapData, 320/2, 328);
			texture.tw = .5;
			texture.tx = .5;
			texture.offsetX = 320 / 4;
			texture.offsetY = 328 / 2;
			image = new Image2D(texture);
			//image.scaleX = 2;
			layer.children.push(image);
		}
		
		private function init():void 
		{
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			image.x = mouseX;
			image.y = mouseY;
			d2.update();
		}
		
	}

}