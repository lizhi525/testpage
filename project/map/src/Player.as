package  
{
	import flash.geom.Point;
	import flash.utils.getTimer;
	import vpath.VPoint;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Player extends Point{
		public var name:String;
		public var label:String;
		public var sname:String;
		public var frame:int = 0;
		public var delay:int = 5;
		public var scaleX:Number = 1;
		public var scaleY:Number = 1;
		public var path:Vector.<VPoint>;
		
		public var startTime:int = 0;
		public var endTime:int = 0;
		public var dt:int = 0;
		public var startX:int = 0;
		public var startY:int = 0;
		public var dx:int = 0;
		public var dy:int = 0;
		public var speed:Number = 5 * 60 / 1000;
		public var walking:Boolean = false;
		public function onPathChange(stime:int):void {
			if (path && path.length >= 2) {
				startTime = stime;
				var node:VPoint = path[1];
				dt = Point.distance(new Point(x, y), node) / speed;
				endTime = dt + startTime;
				startX = x;
				startY = y;
				dx = node.x - startX;
				dy = node.y - startY;
				if (x<node.x) {
					scaleX = -1;
				}else if (x>node.x) {
					scaleX = 1;
				}
				var walkNum:String;
				if (y<node.y) {
					walkNum = "1";
				}else {
					walkNum = "2";
				}
				var label:String = "walk_"+walkNum;
				if (this.label!=label) {
					Main.instance.play(this, name, label);
				}
				walking = true;
			}else {
				if (this.label.indexOf("walk")!=-1) {
					var labels:Array = ["dance_a_1","dance_a_2","dance_b_1","dance_b_2","dance_c_1","dance_c_2","free_1","free_2","free_dj_1","mixdrink_1","sit_a_1","sit_a_2","sit_b_1","sit_b_2","stand_1","stand_2","stand_dj_1","stand_w_1","stand_w_2","talk_1","talk_2","walk_1","walk_2","walk_w_1","walk_w_2"];
					label = labels[int(labels.length * Math.random())];
					if (this.label!=label) {
						Main.instance.play(this, name, label);
					}
				}
				walking = false;
			}
		}
		
		public function update(time:int):void {
			if (path&&path.length>=2) {//有路可走
				var node:VPoint = path[1];
				if (time<=endTime) {
					var v:Number = (time-startTime) / dt;
					x = startX + dx * v;
					y = startY + dy * v;
				}else {
					x = node.x;
					y = node.y;
					path.splice(1, 1);
					onPathChange(endTime);
				}
			}
		}
		
		public function getServerPath():Object {
			var arr:Array = [x,y];
			if (path) {
				for each(var vp:VPoint in path) {
					arr.push(vp.x, vp.y);
				}
			}
			return arr;
		}
		
		public function setFromServerPath(obj:Object):void {
			var arr:Array = obj as Array;
			x = arr[0];
			y = arr[1];
			if (path == null) path = new Vector.<VPoint>;
			path.length = 0;
			for (var i:int = 2; i < arr.length;i+=2 ) {
				var vp:VPoint = new VPoint;
				vp.x = arr[i];
				vp.y = arr[i + 1];
				path.push(vp);
			}
			onPathChange(getTimer());
		}
	}

}