package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Program3D;
	import flash.display3D.textures.RectangleTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class BlurTest extends Stage3dTester
	{
		private var texture:TextureBase;
		private var textureC:TextureBase;
		private var textureC2:TextureBase;
		private var blurP:Program3D;
		public function BlurTest() 
		{
			
		}
		
		override public function enterFrame(e:Event):void 
		{
			c3d.clear();
			c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([.5, .5, 1, 1, 0, 0, 0, 0]));
			c3d.setTextureAt(0, texture);
			c3d.setRenderToTexture(textureC2);
			c3d.clear();
			c3d.setProgram(progrom);
			c3d.drawTriangles(indexbuff);
			c3d.present();
			
			var temp:Vector.<Number> = new Vector.<Number>;
			var size:Vector.<Number> = Vector.<Number>([ -4, -3, -2, -1, 0, 1, 2, 3, 4]);
			var bsizen:Number = mouseX/50;
			var bsize:Number = bsizen / 256;
			var m:Vector.<Number> = Vector.<Number>([.05, .09, .12, .15, .16, .15, .12, .09, .05]);
			
			for (var i:int = 0; i < 9; i++ ) {
				temp.push(bsize*size[i],0,m[i],0);
			}
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, temp);
			c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([1, 1, 1, 1, 0, 0, 0, 0]));
			c3d.setTextureAt(0, textureC2);
			c3d.clear();
			c3d.setRenderToTexture(textureC);
			c3d.clear();
			c3d.setProgram(blurP);
			c3d.drawTriangles(indexbuff);
			c3d.present();
			
			//vertical blur
			bsize = bsizen / 256;
			c3d.clear();
			temp.length = 0;
			for (i = 0; i < 9; i++ ) {
				temp.push(0,bsize*size[i],m[i],0);
			}
			c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([1,1,1,1,0,0,0,0]));
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, temp);
			c3d.setTextureAt(0, textureC);
			c3d.setProgram(blurP);
			c3d.drawTriangles(indexbuff);
			c3d.present();
		}
		
		override public function init():void {
			super.init();
			c3d.enableErrorChecking = true;
			
			texture = c3d.createRectangleTexture(100, 200, Context3DTextureFormat.BGRA, false);
			//texture = c3d.createTexture(256, 256, Context3DTextureFormat.BGRA, false);
			
			textureC = c3d.createTexture(512, 512, Context3DTextureFormat.BGRA, true);
			textureC2 = c3d.createTexture(512, 512, Context3DTextureFormat.BGRA, true);
			var bmd:BitmapData = new BitmapData(100, 200, false, 0xff0000);
			bmd.perlinNoise(20, 20, 2, 1, true, true);
			(texture as Object).uploadFromBitmapData(bmd);
			
			var fcode:String = "";
			for (var i:int = 0; i < 9; i++ ) {
				fcode += "add ft0,fc" + i + ".xy,v0\n" +
						 "tex ft1,ft0,fs0<>\n" +
						 "mul ft1,ft1,fc"+i+".z\n"+
						 (i == 0?"mov ft2,ft1\n":"add ft2,ft2,ft1\n");
			}
			fcode += "mov oc,ft2";
			
			//horizontal blur
			fagal.assemble(Context3DProgramType.FRAGMENT, fcode);
			blurP = c3d.createProgram();
			blurP.upload(vagal.agalcode, fagal.agalcode);
			c3d.setProgram(progrom);
		}
		
	}

}