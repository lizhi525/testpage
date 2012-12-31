package test
{
	import adobe.utils.CustomActions;
	import com.adobe.utils.AGALMiniAssembler;
	import com.bit101.components.CheckBox;
	import com.bit101.components.ComboBox;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.bit101.components.RadioButton;
	import com.bit101.components.Style;
	import com.bit101.components.Window;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.JPEGEncoderOptions;
	import flash.display.JPEGXREncoderOptions;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PNGEncoderOptions;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import net.hires.debug.Stats;
	import realtimelib.Logger;
	import vpath.VPathEdit;
	import vpath.VPoint;
	
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	[SWF(frameRate=60)]
	public class Main extends Sprite 
	{
		private static const rendMode:int = 2;//0 cpu 1 gpuMarge 2 gpuGrid 
		private static const useDep:Boolean = false;
		private static const size:int = rendMode==0?20:15;
		private static const csize:int = rendMode==0?200:256;
		
		//cpu
		private var bmd:BitmapData;
		//gpu
		private var c3d:Context3D;
		private var bytelib:Array = [];
		private var tiles:Array=[];
		private var pen:Texture;
		private var indexbuff:IndexBuffer3D;
		private var progrom:Program3D;
		private var alphaProgrom:Program3D;
		private var alphaUvProgrom:Program3D;
		private var vbuff:VertexBuffer3D;
		private var formats:Array = [Context3DTextureFormat.BGRA,Context3DTextureFormat.COMPRESSED,Context3DTextureFormat.COMPRESSED_ALPHA];
		private var w:int;
		private var h:int;
		private var tw:int;
		private var th:int;
		
		private var bmds:Array = [];
		private var loader:Loader = new Loader;
		private var loader2:URLLoader = new URLLoader;
		private var loadingX:int;
		private var loadingY:int;
		private var tasks:Array = [];
		public var player:Player;
		private var v:Point = new Point;
		private var t:Point = new Point;
		private var mapM:Matrix = new Matrix;
		private var mapChanged:Boolean = true;
		private var map:String = "jiayuan";
		private var matrix:Vector.<Number> = Vector.<Number>([1, 1, 1, 1, 0, 0, 0, 0]);
		private var playerMatrix:Vector.<Number> = Vector.<Number>([1, 1, 1, 1, 0, 0, 0, 0,1, 1, 1, 1, 0, 0, 0, 0]);
		private var ptexture:Texture;
		
		private var spriteSheets:Object = { };
		private var pngloaded:Object = { };
		private var pngloaders:Dictionary = new Dictionary;
		private var conloaders:Dictionary = new Dictionary;
		private var players:Array = [];
		private var skills:Array = [];
		
		private var debug:TextField = new TextField;
		private var isMouseDown:Boolean = false;
		
		private var vpathEdit:VPathEdit;
		private var server:Server;
		private var lastFindPathTime:int = 0;
		public static var instance:Main;
		public function Main():void 
		{
			instance = this;
			if (rendMode==0) {
				init();
			}
			else {stage.stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, init);
			stage.stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO,Context3DProfile.BASELINE_EXTENDED);
			}
		}
		
		private function stage_mouseUp(e:MouseEvent):void 
		{
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			isMouseDown = false;
		}
		
		private function findPath(isMouseDown:Boolean):void 
		{
			lastFindPathTime = getTimer();
			var x:Number = mouseX - mapM.tx
			var y:Number = mouseY - mapM.ty;
			vpathEdit.astar.start.x = player.x;
			vpathEdit.astar.start.y = player.y;
			vpathEdit.astar.end.x = x;
			vpathEdit.astar.end.y = y;
			t.x = x;
			t.y = y;
			x -= player.x;
			y -= player.y;
			var a:Number = Math.atan2(y, x);
			v.x = 5 * Math.cos(a);
			v.y = 5 * Math.sin(a);
			if (vpathEdit.astar.findPath()) {
				if (player.path == null) player.path = new Vector.<VPoint>;
				player.path.length = 0;
				player.path = player.path.concat(vpathEdit.astar.path);
				var e:VPoint = player.path[player.path.length - 1];
				var ec:VPoint = new VPoint;
				ec.x = e.x;
				ec.y = e.y;
				player.path[player.path.length - 1] = ec;
				player.onPathChange(getTimer());
				server.p2p.sendObject([3,player.getServerPath()]);
				//广播路径
			}else if(isMouseDown){
				if (player.path) {
					player.path.length = 0;
					player.onPathChange(getTimer());
					server.p2p.sendObject([3,player.getServerPath()]);
					//广播位置
				}
			}
		}
		
		private function stage_mouseDown(e:MouseEvent):void 
		{
			//stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMove);
			if (e.target == stage) {
				isMouseDown = true;
				findPath(true);
				lastFindPathTime = getTimer();
			}
		}
		
		private function changeMap(e:Event):void {
			var radio:RadioButton = e.currentTarget as RadioButton;
			map = radio.label;
			bmd.fillRect(bmd.rect, 0);
			player.x = stage.stageWidth / 2;
			player.y = stage.stageHeight / 2;
			mapM.tx = mapM.ty = 0;
			mapChanged = true;
			start();
		}
		
		private function start():void {
			loader.unloadAndStop();
			tasks = [];
			
			for (var x:int = 0; x < size; x++ ) {
				for (var y:int = 0; y < size; y++ ) {
					tasks.push(new Point(x,y));
				}
			}
			loadnext();
		}
		
		public function createPlayer(x:Number, y:Number):Player {
			var player:Player = new Player;
			player.x = x;
			player.y = y;
			play(player, "player_f0005", "walk_1");
			player.onPathChange(getTimer());
			players.push(player);
			return player;
		}
		
		public function createSkill(x:Number, y:Number):Skill {
			var skill:Skill = new Skill;
			skill.x = x;
			skill.y = y;
			playSkill(skill, SkillConfig.skills[int(Math.random()*(SkillConfig.skills.length/2))*2]);
			skills.push(skill);
			return skill;
		}
		
		public function removePlayer(player:Player):void {
			var i:int = players.indexOf(player);
			if (i != -1) players.splice(i, 1);
		}
		
		public function playSkill(skill:Skill,name:String):void {
			skill.name = name;
			player.frame = 0;
			if(pngloaded[name]==null){
				var pngloader:Loader = new Loader;
				pngloader.contentLoaderInfo.addEventListener(Event.COMPLETE, pngloader_complete);
				var spriteSheet:SpriteSheet = new SpriteSheet;
				spriteSheet.name = name;
				spriteSheets[spriteSheet.name] = spriteSheet;
				pngloaders[pngloader.contentLoaderInfo] = spriteSheet;
				pngloader.load(new URLRequest("battle/" + spriteSheet.name + ".png"));
				pngloaded[name] = true;
				spriteSheet.type = 2;
			}
		}
		
		public function play(player:Player,name:String,label:String):void {
			player.name = name;
			player.label = label;
			player.frame = 100 * Math.random();
			var sname:String = player.name + "_" + player.label;
			player.sname = sname;
			if(pngloaded[sname]==null){
				var pngloader:Loader = new Loader;
				pngloader.contentLoaderInfo.addEventListener(Event.COMPLETE, pngloader_complete);
				var spriteSheet:SpriteSheet = new SpriteSheet;
				spriteSheet.name = sname;
				spriteSheet.type = 1;
				spriteSheets[spriteSheet.name] = spriteSheet;
				pngloaders[pngloader.contentLoaderInfo] = spriteSheet;
				pngloader.load(new URLRequest("players/" + spriteSheet.name + ".png"));
				pngloaded[sname] = true;
			}
		}
		
		private function pngloader_complete(e:Event):void 
		{
			var bmd:BitmapData = ((e.currentTarget as LoaderInfo).content as Bitmap).bitmapData;
			var spriteSheet:SpriteSheet = pngloaders[e.currentTarget];
			spriteSheet.width = bmd.width;
			spriteSheet.height = bmd.height;
			spriteSheet.texture = c3d.createRectangleTexture(bmd.width, bmd.height, Context3DTextureFormat.BGRA, false);
			spriteSheet.texture.uploadFromBitmapData(bmd);
			bmd.dispose();
			
			if(spriteSheet.type==1){
				var conloader:URLLoader = new URLLoader;
				conloader.dataFormat = URLLoaderDataFormat.BINARY;
				conloader.load(new URLRequest("players/" + spriteSheet.name + "con.bin"));
				conloaders[conloader] = spriteSheet;
				conloader.addEventListener(Event.COMPLETE, conloader_complete);
			}else if (spriteSheet.type==2) {
				spriteSheet.frameLength = SkillConfig.skills[SkillConfig.skills.indexOf(spriteSheet.name) + 1];
			}
			
			pngloaders[e.currentTarget] = null;
			delete pngloaders[e.currentTarget];
		}
		
		private function conloader_complete(e:Event):void 
		{
			var bytes:ByteArray = (e.currentTarget as URLLoader).data as ByteArray;
			var spriteSheet:SpriteSheet = conloaders[e.currentTarget];
			spriteSheet.con = new YDCON(bytes);
			conloaders[e.currentTarget] = null;
			delete conloaders[e.currentTarget];
		}
		
		private function loader_complete(e:Event):void 
		{
			var lbmd:BitmapData = (loader.content as Bitmap).bitmapData;
			bmd.draw(lbmd,new Matrix(1,0,0,1,200 * loadingX, 200 * loadingY));
			lbmd.dispose();
			mapChanged = true;
			loadnext();
		}
		
		private function loader2_complete(e:Event):void 
		{
			var bytes:ByteArray = loader2.data as ByteArray;
			if(rendMode==1){
				pen.uploadCompressedTextureFromByteArray(bytes, 0);
				for each(var tile:Tile in tiles) {
					if (int(tile.x/2048)==int(loadingX/8)&&int(tile.y/2048)==int(loadingY/8)) {
						c3d.setRenderToTexture(tile.pen, false);
						c3d.clear();
						var matrix:Vector.<Number> = Vector.<Number>([1, 1, 1, 1, 0,0, 0, 0]);
						c3d.setTextureAt(0, tile.texture);
						c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, matrix);
						c3d.drawTriangles(indexbuff);
						c3d.setTextureAt(0, pen);
						var tw:Number = 256 / tile.width;
						var th:Number = 256 / tile.height;
						matrix[0] = 256 / tile.width;
						matrix[1] = 256 / tile.height;
						matrix[4] = -1+matrix[0]+(loadingX*256-tile.x)*2/tile.width;
						matrix[5] = 1-matrix[1]-(loadingY*256-tile.y)*2/tile.height;
						c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, matrix);
						c3d.drawTriangles(indexbuff);
						c3d.present();
						
						var temp:Texture = tile.pen;
						tile.pen = tile.texture;
						tile.texture = temp;
						break;
					}
				}
			}else {
				bytelib[loadingX + 10000 * loadingY] = bytes;
			}
			
			loadnext();
			mapChanged = true;
		}
		
		private function init(e:Event = null):void 
		{
			//Logger.txtArea = new TextField;
			server = new Server(this);
			//addChild(Logger.txtArea);
			//Logger.txtArea.x = 300;
			vpathEdit = new VPathEdit(this, 100, 20,
			//"{\"ballss\":[[{\"y\":361.1,\"x\":392.55},{\"y\":418.6,\"x\":219.5},{\"y\":673.4,\"x\":313.9},{\"y\":436.25,\"x\":795.85},{\"y\":104.6,\"x\":647.05},{\"y\":725.9,\"x\":634.45},{\"y\":407.7,\"x\":423.3}]],\"sx\":702.4,\"ex\":200,\"sy\":655.6,\"ey\":200}"
			//"{\"ballss\":[[{\"y\":931.1,\"x\":317.55},{\"y\":887.6,\"x\":288.5},{\"y\":867.4,\"x\":308.9},{\"y\":734.25,\"x\":519.85},{\"y\":697.6,\"x\":606.05},{\"y\":853.9,\"x\":784.45},{\"y\":935.7,\"x\":684.3}]],\"sx\":702.4,\"ex\":308,\"sy\":655.6,\"ey\":726}"
			//"{\"ballss\":[[{\"y\":866.1,\"x\":457.55},{\"y\":921.6,\"x\":345.5},{\"y\":858.4,\"x\":287.9},{\"y\":689.25,\"x\":612.85},{\"y\":743.6,\"x\":703.05},{\"y\":786.9,\"x\":612.45},{\"y\":958.9,\"x\":761.45},{\"y\":948.9,\"x\":791.45},{\"y\":1046.9,\"x\":1003.45},{\"y\":642.9,\"x\":1811.45},{\"y\":442.9,\"x\":1470.45},{\"y\":294.9,\"x\":1759.45},{\"y\":233.9,\"x\":1745.45},{\"y\":166.9,\"x\":1835.45},{\"y\":147.9,\"x\":2007.45},{\"y\":208.9,\"x\":2155.45},{\"y\":286.9,\"x\":2152.45},{\"y\":351.9,\"x\":2030.45},{\"y\":341.9,\"x\":1891.45},{\"y\":450.9,\"x\":1685.45},{\"y\":580.9,\"x\":1932.45},{\"y\":555.9,\"x\":1981.45},{\"y\":663.9,\"x\":2182.45},{\"y\":988.9,\"x\":1542.45},{\"y\":1232.9,\"x\":2037.45},{\"y\":1420.9,\"x\":2183.45},{\"y\":927.9,\"x\":1530.45}]],\"sx\":636.4,\"ex\":804,\"sy\":1003.6,\"ey\":1002}"
			//"{\"ballss\":[[{\"y\":866.1,\"x\":457.55},{\"y\":921.6,\"x\":345.5},{\"y\":858.4,\"x\":287.9},{\"y\":689.25,\"x\":612.85},{\"y\":743.6,\"x\":703.05},{\"y\":786.9,\"x\":612.45},{\"y\":958.9,\"x\":761.45},{\"y\":948.9,\"x\":791.45},{\"y\":1046.9,\"x\":1003.45},{\"y\":642.9,\"x\":1811.45},{\"y\":442.9,\"x\":1470.45},{\"y\":294.9,\"x\":1759.45},{\"y\":233.9,\"x\":1745.45},{\"y\":166.9,\"x\":1835.45},{\"y\":147.9,\"x\":2007.45},{\"y\":208.9,\"x\":2155.45},{\"y\":286.9,\"x\":2152.45},{\"y\":351.9,\"x\":2030.45},{\"y\":341.9,\"x\":1891.45},{\"y\":450.9,\"x\":1685.45},{\"y\":580.9,\"x\":1932.45},{\"y\":555.9,\"x\":1981.45},{\"y\":663.9,\"x\":2182.45},{\"y\":988.9,\"x\":1542.45},{\"y\":1232.9,\"x\":2037.45},{\"y\":1420.9,\"x\":2183.45},{\"y\":1537.9,\"x\":2413.45},{\"y\":1612.9,\"x\":2392.45},{\"y\":1649.9,\"x\":2447.45},{\"y\":1610.9,\"x\":2611.45},{\"y\":1280.9,\"x\":2862.45},{\"y\":1243.9,\"x\":2831.45},{\"y\":1179.9,\"x\":2926.45},{\"y\":1230.9,\"x\":3029.45},{\"y\":936.9,\"x\":3256.45},{\"y\":845.9,\"x\":3112.45},{\"y\":800.9,\"x\":3175.45},{\"y\":578.9,\"x\":2813.45},{\"y\":434.9,\"x\":2811.45},{\"y\":234.9,\"x\":3183.45},{\"y\":114.9,\"x\":3062.45},{\"y\":24.9,\"x\":3193.45},{\"y\":183.9,\"x\":3499.45},{\"y\":375.9,\"x\":3179.45},{\"y\":513.9,\"x\":3201.45},{\"y\":535.9,\"x\":3333.45},{\"y\":680.9,\"x\":3634.45},{\"y\":816.9,\"x\":3602.45},{\"y\":835.9,\"x\":3637.45},{\"y\":659.9,\"x\":3805.45},{\"y\":1094.9,\"x\":3800.45},{\"y\":994.9,\"x\":3576.45},{\"y\":1427.9,\"x\":3234.45},{\"y\":1383.9,\"x\":3132.45},{\"y\":1749.9,\"x\":2867.45},{\"y\":1891.9,\"x\":2911.45},{\"y\":1914.9,\"x\":3010.45},{\"y\":1856.9,\"x\":3069.45},{\"y\":2094.9,\"x\":3539.45},{\"y\":1850.9,\"x\":3768.45},{\"y\":1880.9,\"x\":3828.45},{\"y\":2208.9,\"x\":3827.45},{\"y\":2407.9,\"x\":3432.45},{\"y\":2728.9,\"x\":3825.45},{\"y\":3313.9,\"x\":3826.45},{\"y\":3060.9,\"x\":3436.45},{\"y\":2912.9,\"x\":3665.45},{\"y\":2527.9,\"x\":3228.45},{\"y\":2756.9,\"x\":2792.45},{\"y\":2728.9,\"x\":2629.45},{\"y\":3022.9,\"x\":2242.45},{\"y\":2886.9,\"x\":1926.45},{\"y\":2801.9,\"x\":1730.45}]],\"sx\":636.4,\"ex\":804,\"sy\":1003.6,\"ey\":1002}"
			//"{\"ballss\":[[{\"y\":866.1,\"x\":457.55},{\"y\":921.6,\"x\":345.5},{\"y\":858.4,\"x\":287.9},{\"y\":689.25,\"x\":612.85},{\"y\":743.6,\"x\":703.05},{\"y\":786.9,\"x\":612.45},{\"y\":958.9,\"x\":761.45},{\"y\":948.9,\"x\":791.45},{\"y\":1046.9,\"x\":1003.45},{\"y\":642.9,\"x\":1811.45},{\"y\":442.9,\"x\":1470.45},{\"y\":294.9,\"x\":1759.45},{\"y\":233.9,\"x\":1745.45},{\"y\":166.9,\"x\":1835.45},{\"y\":147.9,\"x\":2007.45},{\"y\":208.9,\"x\":2155.45},{\"y\":286.9,\"x\":2152.45},{\"y\":351.9,\"x\":2030.45},{\"y\":341.9,\"x\":1891.45},{\"y\":450.9,\"x\":1685.45},{\"y\":580.9,\"x\":1932.45},{\"y\":555.9,\"x\":1981.45},{\"y\":663.9,\"x\":2182.45},{\"y\":988.9,\"x\":1542.45},{\"y\":1232.9,\"x\":2037.45},{\"y\":1420.9,\"x\":2183.45},{\"y\":1537.9,\"x\":2413.45},{\"y\":1612.9,\"x\":2392.45},{\"y\":1649.9,\"x\":2447.45},{\"y\":1610.9,\"x\":2611.45},{\"y\":1280.9,\"x\":2862.45},{\"y\":1243.9,\"x\":2831.45},{\"y\":1179.9,\"x\":2926.45},{\"y\":1230.9,\"x\":3029.45},{\"y\":936.9,\"x\":3256.45},{\"y\":845.9,\"x\":3112.45},{\"y\":800.9,\"x\":3175.45},{\"y\":578.9,\"x\":2813.45},{\"y\":434.9,\"x\":2811.45},{\"y\":234.9,\"x\":3183.45},{\"y\":114.9,\"x\":3062.45},{\"y\":24.9,\"x\":3193.45},{\"y\":183.9,\"x\":3499.45},{\"y\":375.9,\"x\":3179.45},{\"y\":513.9,\"x\":3201.45},{\"y\":535.9,\"x\":3333.45},{\"y\":680.9,\"x\":3634.45},{\"y\":816.9,\"x\":3602.45},{\"y\":835.9,\"x\":3637.45},{\"y\":659.9,\"x\":3805.45},{\"y\":1094.9,\"x\":3800.45},{\"y\":994.9,\"x\":3576.45},{\"y\":1427.9,\"x\":3234.45},{\"y\":1383.9,\"x\":3132.45},{\"y\":1749.9,\"x\":2867.45},{\"y\":1891.9,\"x\":2911.45},{\"y\":1914.9,\"x\":3010.45},{\"y\":1856.9,\"x\":3069.45},{\"y\":2094.9,\"x\":3539.45},{\"y\":1850.9,\"x\":3768.45},{\"y\":1880.9,\"x\":3828.45},{\"y\":2208.9,\"x\":3827.45},{\"y\":2407.9,\"x\":3432.45},{\"y\":2728.9,\"x\":3825.45},{\"y\":3313.9,\"x\":3826.45},{\"y\":3060.9,\"x\":3436.45},{\"y\":2912.9,\"x\":3665.45},{\"y\":2527.9,\"x\":3228.45},{\"y\":2756.9,\"x\":2792.45},{\"y\":2728.9,\"x\":2629.45},{\"y\":3022.9,\"x\":2242.45},{\"y\":2886.9,\"x\":1926.45},{\"y\":3561.9,\"x\":842.45},{\"y\":3613.9,\"x\":905.45},{\"y\":3614.9,\"x\":1243.45},{\"y\":3783.9,\"x\":1226.45},{\"y\":3682.9,\"x\":971.45},{\"y\":3818.9,\"x\":653.45},{\"y\":3823.9,\"x\":59.45},{\"y\":3662.9,\"x\":159.45},{\"y\":3322.9,\"x\":41.45},{\"y\":3299.9,\"x\":190.45},{\"y\":3194.9,\"x\":150.45},{\"y\":2998.9,\"x\":454.45},{\"y\":3087.9,\"x\":642.45},{\"y\":3209.9,\"x\":490.45},{\"y\":3399.9,\"x\":497.45},{\"y\":3432.9,\"x\":552.45},{\"y\":3248.9,\"x\":724.45},{\"y\":2787.9,\"x\":1611.45},{\"y\":2248.9,\"x\":663.45},{\"y\":2054.9,\"x\":1039.45},{\"y\":1804.9,\"x\":906.45},{\"y\":1634.9,\"x\":610.45},{\"y\":1833.9,\"x\":427.45},{\"y\":1930.9,\"x\":604.45},{\"y\":2068.9,\"x\":306.45},{\"y\":1572.9,\"x\":80.45},{\"y\":1412.9,\"x\":251.45},{\"y\":1278.9,\"x\":147.45},{\"y\":1027.9,\"x\":605.45},{\"y\":860.9,\"x\":449.45}]],\"sx\":656.4,\"ex\":650,\"sy\":946.6,\"ey\":972}"
			"{\"ballss\":[[{\"y\":866.1,\"x\":457.55},{\"y\":921.6,\"x\":345.5},{\"y\":858.4,\"x\":287.9},{\"y\":689.25,\"x\":612.85},{\"y\":743.6,\"x\":703.05},{\"y\":786.9,\"x\":612.45},{\"y\":958.9,\"x\":761.45},{\"y\":948.9,\"x\":791.45},{\"y\":1046.9,\"x\":1003.45},{\"y\":642.9,\"x\":1811.45},{\"y\":442.9,\"x\":1470.45},{\"y\":294.9,\"x\":1759.45},{\"y\":233.9,\"x\":1745.45},{\"y\":166.9,\"x\":1835.45},{\"y\":147.9,\"x\":2007.45},{\"y\":208.9,\"x\":2155.45},{\"y\":286.9,\"x\":2152.45},{\"y\":351.9,\"x\":2030.45},{\"y\":341.9,\"x\":1891.45},{\"y\":450.9,\"x\":1685.45},{\"y\":580.9,\"x\":1932.45},{\"y\":555.9,\"x\":1981.45},{\"y\":663.9,\"x\":2182.45},{\"y\":985.9,\"x\":1552.45},{\"y\":1232.9,\"x\":2037.45},{\"y\":1420.9,\"x\":2183.45},{\"y\":1537.9,\"x\":2413.45},{\"y\":1612.9,\"x\":2392.45},{\"y\":1649.9,\"x\":2447.45},{\"y\":1610.9,\"x\":2611.45},{\"y\":1280.9,\"x\":2862.45},{\"y\":1243.9,\"x\":2831.45},{\"y\":1179.9,\"x\":2926.45},{\"y\":1230.9,\"x\":3029.45},{\"y\":936.9,\"x\":3256.45},{\"y\":845.9,\"x\":3112.45},{\"y\":800.9,\"x\":3175.45},{\"y\":578.9,\"x\":2813.45},{\"y\":434.9,\"x\":2811.45},{\"y\":234.9,\"x\":3183.45},{\"y\":114.9,\"x\":3062.45},{\"y\":24.9,\"x\":3193.45},{\"y\":183.9,\"x\":3499.45},{\"y\":375.9,\"x\":3179.45},{\"y\":513.9,\"x\":3201.45},{\"y\":535.9,\"x\":3333.45},{\"y\":680.9,\"x\":3634.45},{\"y\":816.9,\"x\":3602.45},{\"y\":835.9,\"x\":3637.45},{\"y\":659.9,\"x\":3805.45},{\"y\":1094.9,\"x\":3800.45},{\"y\":994.9,\"x\":3576.45},{\"y\":1427.9,\"x\":3234.45},{\"y\":1383.9,\"x\":3132.45},{\"y\":1749.9,\"x\":2867.45},{\"y\":1891.9,\"x\":2911.45},{\"y\":1914.9,\"x\":3010.45},{\"y\":1856.9,\"x\":3069.45},{\"y\":2094.9,\"x\":3539.45},{\"y\":1850.9,\"x\":3768.45},{\"y\":1880.9,\"x\":3828.45},{\"y\":2208.9,\"x\":3827.45},{\"y\":2407.9,\"x\":3432.45},{\"y\":2728.9,\"x\":3825.45},{\"y\":3313.9,\"x\":3826.45},{\"y\":3060.9,\"x\":3436.45},{\"y\":2912.9,\"x\":3665.45},{\"y\":2527.9,\"x\":3228.45},{\"y\":2756.9,\"x\":2792.45},{\"y\":2728.9,\"x\":2629.45},{\"y\":3022.9,\"x\":2242.45},{\"y\":2886.9,\"x\":1926.45},{\"y\":3561.9,\"x\":842.45},{\"y\":3613.9,\"x\":905.45},{\"y\":3614.9,\"x\":1243.45},{\"y\":3783.9,\"x\":1226.45},{\"y\":3682.9,\"x\":971.45},{\"y\":3818.9,\"x\":653.45},{\"y\":3823.9,\"x\":59.45},{\"y\":3662.9,\"x\":159.45},{\"y\":3322.9,\"x\":41.45},{\"y\":3299.9,\"x\":190.45},{\"y\":3194.9,\"x\":150.45},{\"y\":2998.9,\"x\":454.45},{\"y\":3087.9,\"x\":642.45},{\"y\":3209.9,\"x\":490.45},{\"y\":3399.9,\"x\":497.45},{\"y\":3432.9,\"x\":552.45},{\"y\":3248.9,\"x\":724.45},{\"y\":2787.9,\"x\":1611.45},{\"y\":2248.9,\"x\":663.45},{\"y\":2054.9,\"x\":1039.45},{\"y\":1804.9,\"x\":906.45},{\"y\":1634.9,\"x\":610.45},{\"y\":1833.9,\"x\":427.45},{\"y\":1930.9,\"x\":604.45},{\"y\":2068.9,\"x\":306.45},{\"y\":1572.9,\"x\":80.45},{\"y\":1412.9,\"x\":251.45},{\"y\":1278.9,\"x\":147.45},{\"y\":1027.9,\"x\":605.45},{\"y\":860.9,\"x\":449.45}],[{\"y\":1173.85,\"x\":1432},{\"y\":1330.85,\"x\":1760},{\"y\":1555.85,\"x\":1913},{\"y\":1884,\"x\":1296},{\"y\":1687.7,\"x\":1135},{\"y\":1508.8,\"x\":833},{\"y\":1175.15,\"x\":1441}]],\"sx\":1595.4,\"ex\":1495,\"sy\":1065.6,\"ey\":1110}"
			);
			addChild(vpathEdit);
			
			debug.autoSize = "left";
			debug.text = "debug";
			debug.textColor = 0xff0000;
			addChild(debug);
			debug.x = 70;
			debug.mouseEnabled = debug.mouseWheelEnabled = false;
			debug.scaleX = debug.scaleY = 5;
			
			//stage.addEventListener(MouseEvent.CLICK, stage_click);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			addChild(new Stats);
			Style.embedFonts = false;
			Style.fontSize = 12;
			if(rendMode==0){
				new RadioButton(this, 70, 0, "caixiashan",true,changeMap);
				new RadioButton(this, 70, 20, "jiayuan", true, changeMap);
			}
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.quality = "low";
			
			if(rendMode==0){
				bmd = new BitmapData(csize * size, csize * size, false, 0);
				player = new Player;
				player.x = stage.stageWidth / 2;
				player.y = stage.stageHeight / 2;
			}else {
				player = createPlayer(vpathEdit.startBall.x,vpathEdit.startBall.y);// stage.stageWidth / 2, stage.stageHeight / 2);
				vpathEdit.enterFrame(null);
				
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
				alphaProgrom = c3d.createProgram();
				alphaUvProgrom = c3d.createProgram();
				var vagal:AGALMiniAssembler = new AGALMiniAssembler(false);
				var fagal:AGALMiniAssembler = new AGALMiniAssembler(false);
				var afagal:AGALMiniAssembler = new AGALMiniAssembler(false);
				var auvvagal:AGALMiniAssembler = new AGALMiniAssembler(false);
				vagal.assemble(Context3DProgramType.VERTEX, "mul vt0.xyz,va0.xyz,vc0.xyz\nadd op,vt0.xyz,vc1.xyz\nmov v0,va1");
				fagal.assemble(Context3DProgramType.FRAGMENT, "tex oc,v0,fs0<>");
				auvvagal.assemble(Context3DProgramType.VERTEX, "mul vt0.xyzw,va0.xyzw,vc0.xyzw\nadd op,vt0.xyzw,vc1.xyzw\nmul vt1,vc2,va1\nadd v0,vt1,vc3");
				if (useDep) {
					afagal.assemble(Context3DProgramType.FRAGMENT, "tex ft0,v0,fs0<>\nsub ft0.w,ft0.w,fc0.x\nkil ft0.w\nmov oc,ft0");
				}else {
					afagal = fagal;
				}
				progrom.upload(vagal.agalcode, fagal.agalcode);
				alphaProgrom.upload(auvvagal.agalcode, afagal.agalcode);
				
				
				stage_resize(null);
				stage.addEventListener(Event.RESIZE, stage_resize);
				if (rendMode == 1) {
					var tile:Tile = new Tile;
					tiles.push(tile);
					tile.x = tile.y = 0;
					tile.width = tile.height = 2048;
					tile.texture = c3d.createTexture(tile.width, tile.height, Context3DTextureFormat.BGRA, true);
					tile.pen = c3d.createTexture(tile.width, tile.height, Context3DTextureFormat.BGRA, true);
					
					tile = new Tile;
					tiles.push(tile);
					tile.y = 0;
					tile.x = 2048;
					tile.width = 2048; 
					tile.height = 2048;
					tile.texture = c3d.createTexture(tile.width, tile.height, Context3DTextureFormat.BGRA, true);
					tile.pen = c3d.createTexture(tile.width, tile.height, Context3DTextureFormat.BGRA, true);
					
					tile = new Tile;
					tiles.push(tile);
					tile.x = tile.y = 0;
					tile.y = 2048;
					tile.width = tile.height = 2048;
					tile.texture = c3d.createTexture(tile.width, tile.height, Context3DTextureFormat.BGRA, true);
					tile.pen = c3d.createTexture(tile.width, tile.height, Context3DTextureFormat.BGRA, true);
					
					tile = new Tile;
					tiles.push(tile);
					tile.x = tile.y = 2048;
					tile.width = tile.height = 2048;
					tile.texture = c3d.createTexture(tile.width, tile.height, Context3DTextureFormat.BGRA, true);
					tile.pen = c3d.createTexture(tile.width, tile.height, Context3DTextureFormat.BGRA, true);
					
					pen = c3d.createTexture(csize, csize, Context3DTextureFormat.BGRA, true);
				}else {
					new PushButton(this, 100, 0, "addskill", addSkill);
					onResizeRender2();
				}
			}
			start();
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function addSkill(e:Event):void 
		{
			var a:Number = Math.PI * 2 * Math.random();
			createSkill(player.x+100*Math.cos(a), player.y+100*Math.sin(a));
		}
		
		private function stage_resize(e:Event):void 
		{
			c3d.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, useDep);
			if (rendMode == 2) onResizeRender2();
		}
		
		private function onResizeRender2():void {
			w = Math.ceil(stage.stageWidth / csize) + 1;
			h = Math.ceil(stage.stageHeight / csize) + 1;
			tw = w + 5;
			th = h + 5;
			
			for (var i:int =Math.max(tw*th, tiles.length); i >=0;i-- ) {
				var tile:Tile = tiles[i];
				if (i<tw*th) {
					if (tile==null) {//初始化
						tile =new Tile;
						tile.x = int(i % tw);
						tile.y = int(i / tw);
						tile.width = tile.height = csize;
						tiles[i] = tile;
					}else {//重置
						tile.bytes = null;
					}
				}else {//释放
					if (tile&&tile.texture) {
						tile.texture.dispose();
					}
					tiles.splice(i, 1);
					delete tiles[i];
				}
			}
		}
		
		private function enterFrame(e:Event):void 
		{
			var time:int = getTimer();
			if (isMouseDown&&(Point.distance(player,new Point(mouseX-mapM.tx,mouseY-mapM.ty))>100)&&(time-lastFindPathTime)>500) {
				findPath(false);
			}
			for each(var pl:Player in players) {
				pl.update(time);
			}
			
			var x:int = -int(player.x - stage.stageWidth / 2);
			var y:int = -int(player.y - stage.stageHeight / 2);
			if (x > 0) x = 0;
			if (y > 0) y = 0;
			if (x < -4000 + stage.stageWidth ) x = -4000 + stage.stageWidth ;
			if (y < -4000 + stage.stageHeight ) y = -4000 + stage.stageHeight ;
			if (x != mapM.tx || y != mapM.ty) {
				mapM.tx = mapM.tx+(x-mapM.tx)*.2;
				mapM.ty = mapM.ty+(y-mapM.ty)*.2;
				mapChanged = true;
			}
			
			debug.text = players.length + "";
			vpathEdit.x = mapM.tx;
			vpathEdit.y = mapM.ty;
			//if(mapChanged)
			draw();
		}
		
		private function draw():void {
			if(rendMode==0){
				graphics.clear();
				graphics.beginBitmapFill(bmd,mapM,true);
				graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
				mapChanged = false;
			}else {
				c3d.clear();
				c3d.setVertexBufferAt(0, vbuff, 0, "float3");
				c3d.setVertexBufferAt(1, vbuff, 3, "float2");
				if (rendMode == 1) {
					c3d.setProgram(progrom);
					var c:int = 1000;
					//while(c-->0)
					for each(var tile:Tile in tiles) {
						if(!((tile.x+tile.width+mapM.tx)<0||(tile.x+mapM.tx)>stage.stageWidth||(tile.y+tile.height+mapM.ty)<0||(tile.y+mapM.ty)>stage.stageHeight)){
							c3d.setTextureAt(0, tile.texture);
							var scaleX:Number = tile.width / stage.stageWidth;
							var scaleY:Number = tile.height / stage.stageHeight;
							matrix = Vector.<Number>([scaleX,scaleY,1,1,scaleX-1+(mapM.tx+tile.x)*2/stage.stageWidth,1-scaleY-(mapM.ty+tile.y)*2/stage.stageHeight,0,0]);
							c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, matrix);
							c3d.drawTriangles(indexbuff);
						}
					}
				}else {
					if (useDep) {
						drawSkills();
						drawPlayers();
					}
					c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO);
					c3d.setProgram(progrom);
					var addx:Number = mapM.tx % csize;
					var addy:Number = mapM.ty % csize;
					scaleX = csize / stage.stageWidth;
					scaleY = csize / stage.stageHeight;
					var counter:int = 0;
					c = 1000;
					//while(c-->0)
					for (var x:int = 0; x < w;x++ ) {
						for (var y:int = 0; y < h; y++ ) {
							var sx:Number = x * csize + addx;//开始渲染的x坐标
							var sy:Number = y * csize + addy;//开始渲染的y坐标
							var dx:Number = sx - mapM.tx;//纹理坐标
							var dy:Number = sy - mapM.ty;//纹理坐标
							if (dx < 0 || dy < 0 || sx > stage.stageWidth || sy > stage.stageHeight) {
								
							}else {
								var gdx:int = int(dx / csize);//纹理格子坐标
								var gdy:int = int(dy / csize);//纹理格子坐标
								tile = tiles[(gdx % tw) + (gdy % th) * tw];
								var bytes:ByteArray = bytelib[gdx + gdy * 10000];
								if (bytes && bytes != tile.bytes) {
									if (tile.texture == null) tile.texture = c3d.createTexture(csize, csize, Context3DTextureFormat.BGRA, false);
									tile.texture.uploadCompressedTextureFromByteArray(bytes, 0, false);
									counter++;
									tile.bytes = bytes;
								}
								if (bytes) {
									c3d.setTextureAt(0, tile.texture);
									matrix = Vector.<Number>([scaleX,scaleY,1,1,scaleX-1+sx*2/stage.stageWidth,1-scaleY-sy*2/stage.stageHeight,.99999,0]);
									c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, matrix);
									c3d.drawTriangles(indexbuff);
								}
							}
						}
					}
					if (counter) trace(counter);
					
					if (!useDep) {
						drawPlayers();
						drawSkills();
					}
				}
				c3d.present();
			}
		}
		
		private function drawPlayers():void {
			c3d.setProgram(alphaProgrom);
			if(useDep){
				c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0, Vector.<Number>([.9999999,0,0,0]));
				players.sortOn("y", Array.NUMERIC | Array.DESCENDING);
			}else {
				players.sortOn("y", Array.NUMERIC);
				c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			}
			for each(var pl:Player in players) {
				var ss:SpriteSheet = spriteSheets[pl.sname];
				if (ss && ss.con) {
					pl.delay--; 
					if (pl.delay <= 0) {
						pl.delay = 6;
						pl.frame++;	
					}
					if (pl.frame >= ss.con.frames.length) pl.frame = 0;
					var ydFrame:YDFrame = ss.con.frames[pl.frame];
					playerMatrix[0] = pl.scaleX * ydFrame.widht / stage.stageWidth;
					playerMatrix[1] = pl.scaleY * ydFrame.height / stage.stageHeight;
					playerMatrix[4] = -1 + playerMatrix[0] + (pl.scaleX * (ydFrame.offsetX - ss.con.hotX) + pl.x + mapM.tx) * 2 / stage.stageWidth;
					playerMatrix[5] = 1 - playerMatrix[1] -(pl.scaleY * (ydFrame.offsetY - ss.con.hotY) + pl.y + mapM.ty) * 2  / stage.stageHeight;
					
					playerMatrix[8] = ydFrame.widht / ss.width;//uv
					playerMatrix[9] = ydFrame.height / ss.height;
					playerMatrix[12] = ydFrame.px / ss.width;
					playerMatrix[13] = ydFrame.py / ss.height;
					c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, playerMatrix);
					c3d.setTextureAt(0, ss.texture);
					c3d.drawTriangles(indexbuff);
				}
			}
		}
		
		private function drawSkills():void {
			c3d.setProgram(alphaProgrom);
			if(useDep){
				c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT,0, Vector.<Number>([.9999999,0,0,0]));
				skills.sortOn("y", Array.NUMERIC | Array.DESCENDING);
			}else {
				skills.sortOn("y", Array.NUMERIC);
				c3d.setBlendFactors(Context3DBlendFactor.ONE, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			}
			for (var i:int = skills.length-1; i >=0;i-- ) {
				var sk:Skill = skills[i];
				var ss:SpriteSheet = spriteSheets[sk.name];
				if (ss && ss.texture) {
					sk.delay--; 
					if (sk.delay <= 0) {
						sk.delay = 6;
						sk.frame++;	
					}
					if (sk.frame >= ss.frameLength) {
						sk.frame = 0;
						skills.splice(i, 1);
						continue;
					}
					playerMatrix[0] = sk.scaleX * ss.width/ss.frameLength / stage.stageWidth;
					playerMatrix[1] = sk.scaleY * ss.height / stage.stageHeight;
					playerMatrix[4] = -1 + playerMatrix[0] + (sk.scaleX * (-ss.width/ss.frameLength/2) + sk.x + mapM.tx) * 2 / stage.stageWidth;
					playerMatrix[5] = 1 - playerMatrix[1] -(sk.scaleY*(-ss.height)+sk.y + mapM.ty) * 2  / stage.stageHeight;
					
					playerMatrix[8] = 1 / ss.frameLength;//uv
					playerMatrix[9] = 1;
					playerMatrix[12] = sk.frame/ss.frameLength;
					playerMatrix[13] = 0;
					c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, playerMatrix);
					c3d.setTextureAt(0, ss.texture);
					c3d.drawTriangles(indexbuff);
				}
			}
		}
		
		private function loadnext():void {
			if (tasks.length == 0) {
				if (rendMode==1) {
					pen.dispose();
					for each(var tile:Tile in tiles){
						tile.pen.dispose();
					}
				}
				trace("over");
				//var file:FileReference = new FileReference;
				//file.save(PNGEncoder.encode(bmd));
			}else {
				tasks.sort(sort);
				var p:Point = tasks.shift();
				loadingX = p.x;
				loadingY = p.y;
				if(rendMode==0){
					loader = new Loader;
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loader_complete);
					loader.load(new URLRequest(map + "/" + loadingX + "_" + loadingY + ".jpg"));
				}else{
					loader2 = new URLLoader;
					loader2.addEventListener(Event.COMPLETE, loader2_complete);
					loader2.dataFormat = URLLoaderDataFormat.BINARY;
					loader2.load(new URLRequest("map/jiayuanatf/" + loadingX + "_" + loadingY + ".atf"));
					//loader2.load(new URLRequest("http://sliz.github.com/testpage/project/map/mbin/map/jiayuanatf/" + loadingX + "_" + loadingY + ".atf"));
				}
			}
		}
		
		
		private function sort(a:Point, b:Point):int {
			return 10000*(getPower(a)-getPower(b));
		}
		
		//得到权重
		private function getPower(a:Point):Number {
			var dx:Number = Math.abs((a.x+.5) * csize +mapM.tx-stage.stageWidth/2)/stage.stageWidth*2;
			var dy:Number = Math.abs((a.y +.5)* csize +mapM.ty-stage.stageHeight/2)/stage.stageHeight*2;
			return dx + dy;
		}
		
		private function getATFFormat(atf:ByteArray):String {
			return formats[int(atf[atf.position + 6] / 2)];
		}
	}
	
}

import flash.display3D.textures.RectangleTexture;
import flash.display3D.textures.Texture;
import flash.utils.Endian;
class Tile {
	public var texture:Texture;
	public var bytes:flash.utils.ByteArray;
	public var pen:Texture;
	public var width:Number;
	public var height:Number;
	public var x:Number;
	public var y:Number;
}

class SpriteSheet {
	public var width:int;
	public var height:int;
	public var name:String;
	//public var bmd:flash.display.BitmapData;
	public var texture:RectangleTexture;
	public var con:YDCON;
	public var type:int = 0;
	public var frameLength:int = 1;
}
class YDCON {
	public var hotX:int;
	public var hotY:int;
	public var frames:Vector.<YDFrame> = new Vector.<YDFrame>;
	public function YDCON(con:flash.utils.ByteArray) {
		con.endian = Endian.LITTLE_ENDIAN;
		con.position = 4;
		hotX = con.readInt();
		hotY = con.readInt();
		var numFrames:int = con.readInt();
		while (numFrames-->0) {
			var frame:YDFrame = new YDFrame;
			frame.delay = con.readInt();
			frame.stay = con.readInt();
			frame.offsetX = con.readInt();
			frame.offsetY = con.readInt();
			frame.widht = con.readInt();
			frame.height = con.readInt();
			frame.px = con.readInt();
			frame.py = con.readInt();
			frames.push(frame);
		}
	}
}
class YDFrame {
	public var delay:int;
	public var stay:int ;
	public var offsetX:int ;
	public var offsetY:int ;
	public var widht:int ;
	public var height:int ;
	public var px:int ;
	public var py:int ; 
}