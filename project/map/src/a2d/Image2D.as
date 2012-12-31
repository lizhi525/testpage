package a2d 
{
	import flash.display3D.Context3DProgramType;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class Image2D extends Display2D
	{
		private var texture:Texture2D;
		public function Image2D(texture:Texture2D) 
		{
			this.texture = texture;
			
		}
		
		override public function update():void {
			if (texture.texture==null) {
				texture.update();
			}
			matrix[0] = texture.width / A2D.width*scaleX;
			matrix[1] = texture.height / A2D.height * scaleY;
			matrix[2] = (x+texture.offsetX+A2D.offsetX) / A2D.width * 2;
			matrix[3] = -(y+texture.offsetY+A2D.offsetY) / A2D.height * 2;
			
			matrix[4] = texture.tw;
			matrix[5] = texture.th;
			matrix[6] = texture.tx;
			matrix[7] = texture.ty;
			
			A2D.c3d.setVertexBufferAt(0, A2D.vbuff, 0, "float3");
			A2D.c3d.setVertexBufferAt(1, A2D.vbuff, 3, "float2");
			A2D.c3d.setProgram(A2D.progrom);
			A2D.c3d.setTextureAt(0, texture.texture);
			A2D.c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, matrix);
			A2D.c3d.drawTriangles(A2D.indexbuff);
		}
		
	}

}