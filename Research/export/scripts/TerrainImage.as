package
{
   import flash.display.BitmapData;
   
   [Embed(source="/_assets/17_TerrainImage.jpg")]
   public dynamic class TerrainImage extends BitmapData
   {
      
      public function TerrainImage(w:int = 866, h:int = 526)
      {
         super(w,h);
      }
   }
}

