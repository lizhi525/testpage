package vpath 
{
	import adobe.utils.CustomActions;
	import com.bit101.components.HUISlider;
	import com.bit101.components.InputText;
	import com.bit101.components.PushButton;
	import com.bit101.components.Slider;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.system.System;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import net.hires.debug.Stats;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	[SWF(frameRate=60)]
	public class VPathEdit extends Sprite
	{
		private var ballss:Vector.<Vector.<Sprite>> =new Vector.<Vector.<Sprite>>();
		public var startBall:Sprite;
		public var endBall:Sprite;
		public var silder:HUISlider;
		private var currentBall:Sprite;
		public var astar:VAStar;
		public function VPathEdit(parent:DisplayObjectContainer = null, x:int = 0,y:int=0 ,initer:String=null) 
		{
			startBall = createBall(0);
			endBall = createBall(0);
			if (initer) {
				var obj:Object = JSON.parse(initer);
				startBall.x = Number(obj.sx);
				startBall.y = Number(obj.sy);
				endBall.x = Number(obj.ex);
				endBall.y = Number(obj.ey);
				
				for each(var balls:Array in obj.ballss) {
					ballss.push(new Vector.<Sprite>);
					for each(var ball:Object in balls) {
						var sprite:Sprite = createBall(0);
						sprite.x = ball.x;
						sprite.y = ball.y;
						ballss[ballss.length - 1].push( sprite);
					}
				}
			}
			var button:PushButton= new PushButton(parent||this, x, y, "add lines", createLines);
			silder = new HUISlider(parent||this, x, y+20, "num");
			silder.tick = 1;
			silder.setSliderParams(3, 10, 5);
			new PushButton(parent || this, x, y + 40, "save", saveLines);
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function saveLines(event:Event):void 
		{
			var obj:Object = { };
			obj.sx = startBall.x;
			obj.sy = startBall.y;
			obj.ex = endBall.x;
			obj.ey = endBall.y;
			obj.ballss = [];
			for each(var balls:Vector.<Sprite> in ballss) {
				obj.ballss.push([]);
				for each(var ball:Sprite in balls)
				obj.ballss[obj.ballss.length - 1].push({x:ball.x,y:ball.y});
			}
			var str:String = JSON.stringify(obj).replace(/\"/g,"\\\"");
			trace(str);
			System.setClipboard(str);
		}
		
		private function addedToStage(e:Event):void 
		{
			
			//addEventListener(Event.ENTER_FRAME, enterFrame);
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
			stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
		}
		
		private function stage_keyUp(e:KeyboardEvent):void 
		{
			if (currentBall) {
				for each(var balls:Vector.<Sprite> in ballss) {
					var index:int = balls.indexOf(currentBall);
					if (index != -1) {
						if (e.keyCode == Keyboard.NUMBER_1) {//删除
							balls.splice(index, 1);
							if (currentBall.parent) currentBall.parent.removeChild(currentBall);
							currentBall = null;
							if (balls.length < 2) {
								index = ballss.indexOf(balls);
								if (balls[0].parent) balls[0].parent.removeChild(balls[0]);
								ballss.splice(index, 1);
							}
						}else if (e.keyCode==Keyboard.NUMBER_2) {//增加
							var b:Sprite = createBall(0);
							b.x = currentBall.x + 100;
							b.y = currentBall.y + 100;
							balls.splice(index, 0, b);
						}
						break;
					}
				}
			}
		}
		
		private function createLines(e:Event):void {
			ballss.push(new Vector.<Sprite>);
			for (var i:int = 0; i < silder.value; i++ ) {
				var s:Sprite = createBall(i);
				s.x = i * 100 + 100;
				s.y = 100+50*Math.random();
				ballss[ballss.length-1].push(s);
			}
		}
		
		public function enterFrame(e:Event):void 
		{
			graphics.clear();
			graphics.lineStyle(5,0xff0000,.5);
			
			astar = new VAStar;
			astar.lines.length = 0;
			astar.lps.length = 0;
			for each(var balls:Vector.<Sprite> in ballss){
				for (var i:int = 0; i < balls.length-1; i++ ) {
					var line:VLine = new VLine;
					var p0:VPoint = new VPoint;
					p0.x = balls[i].x;
					p0.y = balls[i].y;
					var p1:VPoint = new VPoint;
					p1.x = balls[i+1].x;
					p1.y = balls[i + 1].y;
					
					var d:Point = p1.subtract(p0);
					d.normalize(1);
					p1.x += d.x;
					p1.y += d.y;
					p0.x -= d.x;
					p0.y -= d.y;
					
					line.p0 = p0;
					line.p1 = p1;
					astar.lines.push(line);
					astar.lps.push(p0,p1);
				}
			}
			
			astar.start.x = startBall.x;
			astar.start.y = startBall.y;
			astar.end.x = endBall.x;
			astar.end.y = endBall.y;
			for each(line in astar.lines) {
				dline(line.p0, line.p1);
			}
			
			astar.countLinks();
			if(astar.findPath()){
				graphics.lineStyle(3, 0xffff, .5);
				for (i = 0; i < astar.path.length-1;i++ ) {
					dline(astar.path[i], astar.path[i+1]);
				}
			}
		}
		
		private function dline(b1:VPoint, b2:VPoint):void {
			graphics.moveTo(b1.x, b1.y);
			graphics.lineTo(b2.x, b2.y);
		}
		
		private function stage_mouseUp(e:MouseEvent):void 
		{
			stopDrag();
			if (currentBall) {
				currentBall.filters = [];
				currentBall = null;
			}
		}
		
		private function createBall(i:int):Sprite {
			var b:Sprite = new Sprite;
			var tf:TextField = new TextField;
			tf.mouseEnabled = tf.mouseWheelEnabled = false;
			b.addChild(tf);
			tf.autoSize = "left";
			tf.text = "" + i;
			tf.x = -tf.width / 2;
			tf.y = -tf.height / 2;
			b.graphics.beginFill(0xffffff * Math.random(), .7);
			b.graphics.drawCircle(0, 0, 10);
			b.addEventListener(MouseEvent.MOUSE_DOWN, onMD);
			addChild(b);
			return b;
		}
		
		private function onMD(e:Event):void {
			currentBall = e.currentTarget as Sprite;
			currentBall.filters = [new GlowFilter];
			currentBall.startDrag();
		}
		
		
		
	}

}

