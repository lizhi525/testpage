package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IGraphicsData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Test extends Sprite
	{
		[Embed(source="../mbin/players/player_f0005_dance_a_1.png")]private var c1:Class;
		[Embed(source="../mbin/players/player_f0005_dance_a_1con.bin", mimeType="application/octet-stream")]private var c2:Class;
		//[Embed(source = "player_f_d02_02.bin", mimeType = "application/octet-stream")]private var c2:Class;
		private var ydcon:YDCON;
		private var bmd:BitmapData;
		private var frame:int = 0;
		private var player:Shape = new Shape;
		public function Test() 
		{
			bmd = (new c1 as Bitmap).bitmapData;
			var con:ByteArray = new c2 as ByteArray;
			ydcon = new YDCON(con);
			var timer:Timer = new Timer(100);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, timer_timer);
			addChild(player);
			
		}
		
		private function timer_timer(e:TimerEvent):void 
		{
			var ydFrame:YDFrame = ydcon.frames[frame % ydcon.frames.length];
			player.graphics.clear();
			player.graphics.beginBitmapFill(bmd,new Matrix(1,0,0,1,-ydFrame.px,-ydFrame.py));
			player.graphics.drawRect(0, 0, ydFrame.widht, ydFrame.height);
			player.x = ydFrame.offsetX;
			player.y = ydFrame.offsetY;
			frame++;
			var gd:Vector.<IGraphicsData>=  graphics.readGraphicsData();
		}
	}

}
import flash.utils.Endian;
class YDCON {
	public var hotX:int;
	public var hotY:int;
	public var frames:Vector.<YDFrame>=new Vector.<YDFrame>;
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