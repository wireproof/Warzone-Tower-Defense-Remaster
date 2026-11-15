package
{
   import flash.display.BitmapData;
   
   [Embed(source="/_assets/64_flare.png")]
   public dynamic class flare extends BitmapData
   {
      
      public function flare(w:int = 24, h:int = 24)
      {
         super(w,h);
      }
   }
}

