package a2d 
{
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.TextureBase;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Texture2D 
	{
		public var image:BitmapData;
		public var texture:TextureBase;
		public var width:Number;
		public var height:Number;
		
		public var tx:Number = 0;
		public var ty:Number = 0;
		public var tw:Number = 1;
		public var th:Number = 1;
		
		public var offsetX:Number = 0;
		public var offsetY:Number = 0;
		public function Texture2D(image:BitmapData,width:Number,height:Number) 
		{
			this.height = height;
			this.width = width;
			this.image = image;
		}
		public function update():void {
			texture = A2D.c3d.createRectangleTexture(image.width, image.height,Context3DTextureFormat.BGRA, false);
			(texture as RectangleTexture).uploadFromBitmapData(image);
		}
		
	}

}