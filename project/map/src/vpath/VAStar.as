package vpath 
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class VAStar 
	{
		// TODO : add grid support
		public var start:VPoint = new VPoint;
		public var end:VPoint = new VPoint;
		public var lines:Vector.<VLine> = new Vector.<VLine>;
		public var lps:Vector.<VPoint> = new Vector.<VPoint>;
		private var nowVersion:int = 1;
		private var open:BinaryHeap;
		public var path:Vector.<VPoint>;
		public function VAStar() 
		{
			
		}
		
		public function findPath():Boolean {
			nowVersion++;
			open = new BinaryHeap(justMin);
			start.g = 0;
			countLink(start);
			var node:VPoint = start;
			node.version = nowVersion;
			path = new Vector.<VPoint>;
			while (!passable(node,end)) {
				for (var i:int = 0, len:int = node.links.length; i < len; i++ ) {
					var test:VPoint = node.links[i];
					var cost:Number = node.linkCosts[i];
					var g:Number = node.g + cost;
					if (test.version == nowVersion) {
						var f:Number = g + test.h;
						if (test.f>f) {
							test.f = f;
							test.g = g;
							test.parent = node;
						}
					}else {
						test.h = Point.distance(end, test);
						test.g = g;
						test.f = g+test.h;
						test.parent = node;
						open.ins(test);
						test.version = nowVersion;
					}
				}
				if (open.a.length==1) {
					return false;
				}
				node = open.pop() as VPoint;
			}
			end.parent = node;
			node = end;
			path.push(node);
			while (node != start){
				node = node.parent;
				path.unshift(node);
			}
			return true;
		}
		
		private function countLink(node:VPoint):void {
			node.links.length = 0;
			node.linkCosts.length = 0;
			for each(var test:VPoint in lps) {
				if (test != node&&passable(node,test)) {
					node.links.push(test);
					var cost:Number = Point.distance(node, test);
					node.linkCosts.push(cost);
				}
			}
		}
		
		public function countLinks():void {
			for each(var test:VPoint in lps) {
				countLink(test);
			}
		}
		
		private function justMin(x:Object, y:Object):Boolean {
			return x.f < y.f;
		}
		
		public static function intersect(p1:Point,p2:Point,p3:Point,p4:Point):Boolean {
			return(((p1.x>p2.x?p1.x:p2.x)>=(p3.x<p4.x?p3.x:p4.x))&&   
					((p3.x>p4.x?p3.x:p4.x)>=(p1.x<p2.x?p1.x:p2.x))&&   
					((p1.y>p2.y?p1.y:p2.y)>=(p3.y<p4.y?p3.y:p4.y))&&   
					((p3.y>p4.y?p3.y:p4.y)>=(p1.y<p2.y?p1.y:p2.y))&&   
					(multiply(p3,p2,p1)*multiply(p2,p4,p1)>0)&&   
					(multiply(p1,p4,p3)*multiply(p4,p2,p3)>0));  
		}
		
		public static function multiply(sp:Point,ep:Point,op:Point):int {
			return((sp.x-op.x)*(ep.y-op.y)-(ep.x-op.x)*(sp.y-op.y)); 
		}
		
		private function passable(p0:VPoint, p1:VPoint):Boolean {
			for each(var line:VLine in lines) {
				if (intersect(p0,p1,line.p0,line.p1)) {
					return false;
				}
			}
			return true;
		}
	}

}