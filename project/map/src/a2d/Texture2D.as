package a2d 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Texture2D 
	{
		//正在下在的材质 key url
		private static var loading:Object = { };
		private static var load2Url:Dictionary = new Dictionary;
		//等待处理的texture
		private static var willUrl2Textures:Object = { };
		private static var url2TextureCreator:Object = { };
		
		//材质创建器，多个材质可共享一个创建器
		public var texture:TextureCreator;
		//材质宽度
		public var width:Number;
		//材质高度
		public var height:Number;
		
		//材质相对于textureBase的ui偏移
		public var tx:Number = 0;
		public var ty:Number = 0;
		//材质相对于textureBase的缩放
		public var tw:Number = 1;
		public var th:Number = 1;
		
		//材质的自身坐标偏移 单位像素
		public var offsetX:Number = 0;
		public var offsetY:Number = 0;
		public function Texture2D(width:Number,height:Number) 
		{
			this.height = height;
			this.width = width;
		}
		
		public static function fromBmd(bitmapData:BitmapData, width:Number, height:Number):Texture2D {
			var texture:Texture2D = new Texture2D(width, height);
			texture.texture = new TextureCreator;
			texture.texture.image = bitmapData;
			texture.texture.create();
			return texture;
		}
		
		public static function fromURL(url:String, width:Number, height:Number):Texture2D {
			var texture:Texture2D = new Texture2D(width, height);
			if (url2TextureCreator[url]) {
				texture.texture = url2TextureCreator[url] as TextureCreator;
			}else if (!loading[url]) {
				loading[url] = true;
				var loader:Loader = new Loader;
				load2Url[loader] = url;
				if (willUrl2Textures[url] == null) willUrl2Textures[url] = [];
				willUrl2Textures[url].push(texture);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
				loader.load(new URLRequest(url));
			}
			return texture;
		}
		
		static private function loader_complete(e:Event):void 
		{
			var loader:Loader = (e.currentTarget as LoaderInfo).loader;
			var url:String = load2Url[loader];
			var bitmapData:BitmapData = ((e.currentTarget as LoaderInfo).content as Bitmap).bitmapData;
			var create:TextureCreator = new TextureCreator;
			create.image = bitmapData;
			create.create();
			loading[url] = false;
			url2TextureCreator[url] = create;
			for each(var texture:Texture2D in willUrl2Textures[url]) {
				texture.texture = create;
			}
		}
		
		public function clone():Texture2D {
			var texture:Texture2D = new Texture2D(width, height);
			texture.texture = this.texture;
			texture.tx = tx;
			texture.ty = ty;
			texture.tw = tw;
			texture.th = th;
			texture.offsetX = offsetX;
			texture.offsetY = offsetY;
			return texture;
		}
		
	}

}