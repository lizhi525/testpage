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
	public class TextureCreator 
	{
		public var texture:TextureBase;
		public var image:BitmapData;
		public function TextureCreator() 
		{
			
		}
		
		public function create():void {
			if(texture==null){
				texture = A2D.c3d.createRectangleTexture(image.width, image.height,Context3DTextureFormat.BGRA, false);
				(texture as RectangleTexture).uploadFromBitmapData(image);
			}
		}
		
	}

}