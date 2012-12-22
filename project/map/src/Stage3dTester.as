package  
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Sprite;
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
	public class Stage3dTester extends Sprite
	{
		public var vagal:AGALMiniAssembler;
		public var fagal:AGALMiniAssembler;
		public var c3d:Context3D;
		public var progrom:Program3D;
		public var indexbuff:IndexBuffer3D;
		public var vbuff:VertexBuffer3D;
		
		public function Stage3dTester() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, stage3Ds_context3dCreate);
			stage.stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO,Context3DProfile.BASELINE_EXTENDED);
		}
		
		private function stage3Ds_context3dCreate(e:Event):void 
		{
			addEventListener(Event.ENTER_FRAME, enterFrame);
			init();
		}
		
		public function enterFrame(e:Event):void 
		{
			c3d.clear();
			c3d.drawTriangles(indexbuff);
			c3d.present();
		}
		
		public function init():void {
			c3d = stage.stage3Ds[0].context3D;
				
			vbuff = c3d.createVertexBuffer(4, 5);
			vbuff.uploadFromVector(Vector.<Number>([
			-1, 1,0, 0, 0, 
			1, 1 ,0, 1, 0,
			-1, -1,0, 0, 1,
			1, -1,0,1,1]), 0, 4);
			indexbuff = c3d.createIndexBuffer(6);
			indexbuff.uploadFromVector(Vector.<uint>([0, 1, 2, 1, 2, 3]), 0, 6);
			progrom = c3d.createProgram();
			vagal = new AGALMiniAssembler(true);
			fagal = new AGALMiniAssembler(true);
			vagal.assemble(Context3DProgramType.VERTEX, "mul vt0,va0,vc0\nadd op,vt0,vc1\nmov v0,va1");
			fagal.assemble(Context3DProgramType.FRAGMENT, "tex oc,v0,fs0<>");
			progrom.upload(vagal.agalcode, fagal.agalcode);
			
			c3d.setVertexBufferAt(0, vbuff, 0, "float3");
			c3d.setVertexBufferAt(1, vbuff, 3, "float2");
			c3d.setProgram(progrom);
			c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, Vector.<Number>([1,1,1,1,0,0,0,0]));
			
			c3d.configureBackBuffer(512, 512, 0, false);
		}
		
	}

}