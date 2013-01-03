package a2d 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi http://game-develop.net/
	 */
	public class TileLayer extends Layer
	{
		private var width:int;
		private var height:int;
		public var tiles:Array = [];
		public function TileLayer(width:int,height:int) 
		{
			this.height = height;
			this.width = width;
			resize();
		}
		
		private function resize():void {
			var w:int = Math.ceil(A2D.width / width) + 1;
			var h:int = Math.ceil(A2D.height / height) + 1;
			var tw:int = w;
			var th:int = h;
			
			for (var i:int =Math.max(tw*th, tiles.length); i >=0;i-- ) {
				var tile:Tile = tiles[i] as Tile;
				if (i<tw*th) {
					if (tile==null) {//初始化
						tile =new Tile;
						tile.tileX = int(i % tw);
						tile.tileY = int(i / tw);
						tile.width = width;
						tile.height = height;
						tiles[i] = tile;
					}else {//重置
						tile.bytes = null;
					}
				}else {//释放
					if (tile) {
						tile.dispose();
					}
					tiles.splice(i, 1);
					delete tiles[i];
				}
			}
		}
		override public function update():void {
			A2D.c3d.setVertexBufferAt(0, A2D.vbuff, 0, "float3");
			A2D.c3d.setVertexBufferAt(1, A2D.vbuff, 3, "float2");
			A2D.c3d.setProgram(A2D.progrom);
			/*var addx:Number = mapM.tx % csize;
			var addy:Number = mapM.ty % csize;
			scaleX = csize / stage.stageWidth;
			scaleY = csize / stage.stageHeight;
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
						var tile:Tile = tiles[(gdx % tw) + (gdy % th) * tw];
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
			}*/
			A2D.c3d.setVertexBufferAt(0,null, 0, "float3");
			A2D.c3d.setVertexBufferAt(1,null, 3, "float2");
			A2D.c3d.setTextureAt(0, null);
		}
	}

}