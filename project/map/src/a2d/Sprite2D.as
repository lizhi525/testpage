package a2d 
{
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Sprite2D extends Image2D
	{
		private var sprites:Object = { };
		private var lastFrame:int = -1;
		private var frame:Number = -1;
		public var adder:Number = 1;
		private var spriteName:String;
		public function Sprite2D() 
		{
			super(null);
		}
		
		override public function update():void {
			var sprite:SpriteData = sprites[spriteName];
			if(sprite){
				frame += adder;
				frame %= sprite.frames.length;
				var iframe:int = frame;
				if (iframe != lastFrame) {
					texture = sprite.frames[iframe].texture;
					changed = true;
				}
				lastFrame = iframe;
			}
			super.update();
		}
		
		public function addSprite(data:SpriteData):void {
			sprites[data.name] = data;
		}
		
		public function play(spriteName:String):void {
			lastFrame = -1;
			frame = -adder;
			this.spriteName = spriteName;
		}
		
	}

}