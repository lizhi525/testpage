package a2d 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class A2D 
	{
		public  var children:Vector.<Layer> = new Vector.<Layer>;
		public static var c3d:Context3D;
		public static var indexbuff:IndexBuffer3D;
		public static var progrom:Program3D;
		public static var vbuff:VertexBuffer3D;
		public static var width:Number=400;
		public static var height:Number = 400;
		public static var offsetX:Number = -200;
		public static var offsetY:Number = -200;
		public function init(stage:Stage,calbak:Function):void {
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, function():void {
				c3d = stage.stage3Ds[0].context3D;
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.NO_SCALE;
				c3d.configureBackBuffer(width, height, 0, false);
				
				vbuff = c3d.createVertexBuffer(4, 5);
				vbuff.uploadFromVector(Vector.<Number>([
				-1, 1,0, 0, 0, 
				1, 1 ,0, 1, 0,
				-1, -1,0, 0, 1,
				1, -1,0,1,1]), 0, 4);
				indexbuff = c3d.createIndexBuffer(6);
				indexbuff.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 2, 3]), 0, 6);
				progrom = c3d.createProgram();
				var vagal:AGALMiniAssembler = new AGALMiniAssembler(false);
				var fagal:AGALMiniAssembler = new AGALMiniAssembler(false);
				fagal.assemble(Context3DProgramType.FRAGMENT, "tex oc,v0,fs0<>");
				vagal.assemble(Context3DProgramType.VERTEX, 
				<![CDATA[
					mov vt0, va0
					mul vt0.xy, vt0.xy, vc0.xy
					add vt0.xy, vt0.xy, vc0.zw
					mov op, vt0
					mov vt0, va1
					mul vt0.xy, vt0.xy, vc1.xy
					add vt0.xy, vt0.xy, vc1.zw
					mov v0,vt0
				]]>);
				progrom.upload(vagal.agalcode, fagal.agalcode);
				
				calbak()
			});
			stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO,Context3DProfile.BASELINE_EXTENDED);
		}
		
		public function update():void {
			c3d.clear();
			for each(var layer:Layer in children) {
				if (layer.before != null) layer.before();
				layer.update();
				if (layer.affter != null) layer.affter();
			}
			c3d.present();
		}
		
		public function createLayer():Layer {
			var layer:Layer = new Layer;
			children.push(layer);
			return layer;
		}
	}

}