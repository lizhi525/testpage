package test 
{
	import a2d.A2D;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class TestLoad extends Sprite
	{
		private var tasks:Array;
		private var size:int = 15;
		private var log:TextField;
		public function TestLoad() 
		{
			tasks = [];
			for (var x:int = 0; x < size; x++ ) {
				for (var y:int = 0; y < size; y++ ) {
					tasks.push(new Point(x,y));
				}
			}
			log = new TextField;
			log.defaultTextFormat = new TextFormat("宋体");
			log.appendText("1\n");
			log.width = 400;
			log.height = 400;
			addChild(log);
			loadnext();
			
		}
		
		private function loadnext():void {
			if (tasks.length == 0) {
				log.appendText("over\n");
				log.scrollV = log.maxScrollV;
			}else {
				var p:Point = tasks.shift();
				var loader:MYLoad = new MYLoad;
				loader.loadingX = p.x;
				loader.loadingY = p.y;
				loader.addEventListener(Event.COMPLETE, loader_complete);
				loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loader_httpStatus);
				loader.addEventListener(IOErrorEvent.IO_ERROR, loader_ioError);
				loader.dataFormat = URLLoaderDataFormat.BINARY;
				loader.addEventListener("MYERROR", loader_myerror);
				loader.load(new URLRequest("map/jiayuanatf/" + loader.loadingX + "_" + loader.loadingY + ".atf"));
				if (MYLoad.loading<3) {
					loadnext();
				}
			}
			
		}
		
		private function loader_myerror(e:Event):void 
		{
			var myl:MYLoad = e.currentTarget as MYLoad;
			tasks.push(new Point(myl.loadingX, myl.loadingY));
			log.appendText("MYERROR:"+" x:"+myl.loadingX+" y:"+myl.loadingY+"\n");
			loadnext();
		}
		
		private function loader_ioError(e:IOErrorEvent):void 
		{
			var myl:MYLoad = e.currentTarget as MYLoad;
			log.appendText("IOErrorEvent:"+" x:"+myl.loadingX+" y:"+myl.loadingY+"\n");
		}
		
		private function loader_httpStatus(e:HTTPStatusEvent):void 
		{
			var myl:MYLoad = e.currentTarget as MYLoad;
			log.appendText("HTTPStatusEvent:"+e.status+" x:"+myl.loadingX+" y:"+myl.loadingY+"\n");
		}
		
		private function loader_complete(e:Event):void 
		{
			var myl:MYLoad = e.currentTarget as MYLoad;
			log.appendText("comp x:"+myl.loadingX+" y:"+myl.loadingY+" 剩余 "+tasks.length+"\n");
			log.scrollV = log.maxScrollV;
			loadnext();
		}
		
	}

}
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.utils.Timer;
class MYLoad extends URLLoader {
	public static var loading:int = 0;
	public var loadCount:int = 0;
	public var loadingX:int;
	public var loadingY:int;
	private var lastBytesLoaded:int = 0;
	private var timer:Timer;
	private var erroring:Boolean = false;
	public function MYLoad() {
		addEventListener(IOErrorEvent.IO_ERROR, ioError);
		addEventListener(Event.COMPLETE, complete);
		addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatus);
	}
	
	private function httpStatus(e:HTTPStatusEvent):void 
	{
		//if (e.status == 0) {
		//	onError();
		//}
	}
	
	private function complete(e:Event):void 
	{
		loading--;
		timer.stop();
	}
	
	private function ioError(e:IOErrorEvent):void 
	{
		onError();
	}
	
	override public function load (request:URLRequest) : void {
		loading++;
		lastBytesLoaded = bytesLoaded;
		timer = new Timer(10 * 1000);
		timer.addEventListener(TimerEvent.TIMER, timer_timer);
		timer.start();
		super.load(request);
	}
	
	private function timer_timer(e:TimerEvent):void 
	{
		//10秒 没有动 说明下载链接已经坏掉
		if (lastBytesLoaded == bytesLoaded) {
			onError();
		}
		lastBytesLoaded = bytesLoaded;
		
	}
	
	private function onError():void {
		if (!erroring) {
			loading--;
			timer.stop();
			loadCount++;
			erroring = true;
			dispatchEvent(new Event("MYERROR"));
		}
	}
	
	override public function addEventListener (type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void {
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}
}