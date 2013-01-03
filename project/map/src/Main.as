package  
{
	import a2d.A2D;
	import a2d.Display2D;
	import a2d.Frame;
	import a2d.Image2D;
	import a2d.Layer;
	import a2d.Sprite2D;
	import a2d.SpriteData;
	import a2d.Texture2D;
	import a2d.TextureCreator;
	import a2d.TileLayer;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import net.hires.debug.Stats;
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
			A2D.width = stage.stageWidth;
			A2D.height = stage.stageHeight;
			A2D.offsetX = -A2D.width / 2;
			A2D.offsetY = -A2D.height / 2;
			d2.init(stage, init);
			addChild(new Stats);
		}
		
		private function init():void 
		{
			var tileLayer:Layer = d2.createLayer(new TileLayer(40, 40));
			var layer:Layer = d2.createLayer();
			var bmd:BitmapData = new BitmapData(320, 328, false);
			bmd.perlinNoise(100, 100, 10, 2, true, true);
			
			//var texture:Texture2D = Texture2D.fromBmd(bmd,320 / 2, 328);
			var texture:Texture2D = Texture2D.fromURL("map/caixiashan/0_0.jpg",320 / 2, 328);
			texture.tw = .5;
			texture.tx = .5;
			texture.offsetX = 320 / 4;
			texture.offsetY = 328 / 2;
			
			var c1:int = 1;
			while(c1-->0){
				image = new Image2D(texture);
				image.x = stage.stageWidth*Math.random();
				image.y = stage.stageHeight * Math.random();
				layer.children.push(image);
			}
			
			//sprite
			var sprite:Sprite2D = new Sprite2D;
			var data:SpriteData = new SpriteData;
			data.name = "test";
			
			var frame:Frame = new Frame;
			frame.texture = texture;
			data.frames.push(frame);
			
			texture = texture.clone();
			texture.tw = .5;
			texture.tx = 0;
			texture.offsetX = 320 / 4;
			texture.offsetY = 328 / 2;
			frame = new Frame;
			frame.texture = texture;
			data.frames.push(frame);
			
			sprite.addSprite(data);
			sprite.adder = .1;
			sprite.play("test");
			layer.children.push(sprite);
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			c1 = 50000;
			while(c1-->0){
				sprite = new Sprite2D;
				sprite.x = stage.stageWidth*Math.random();
				sprite.y = stage.stageHeight * Math.random();
				sprite.addSprite(data);
				sprite.adder = Math.random();
				sprite.play("test");
				layer.children.push(sprite);
			}
		}
		
		private function enterFrame(e:Event):void 
		{
			image.x = mouseX;
			image.y = mouseY;
			d2.update();
		}
		
	}

}