package a2d 
{
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Layer
	{
		public var children:Vector.<Display2D> = new Vector.<Display2D>;
		public var affter:Function;
		public var before:Function;
		public function Layer() 
		{
			
		}
		public function update():void {
			A2D.c3d.setVertexBufferAt(0, A2D.vbuff, 0, "float3");
			A2D.c3d.setVertexBufferAt(1, A2D.vbuff, 3, "float2");
			A2D.c3d.setProgram(A2D.progrom);
			for each(var child:Display2D in children) {
				child.update();
			}
			A2D.c3d.setVertexBufferAt(0,null, 0, "float3");
			A2D.c3d.setVertexBufferAt(1,null, 3, "float2");
			A2D.c3d.setTextureAt(0, null);
		}
	}

}