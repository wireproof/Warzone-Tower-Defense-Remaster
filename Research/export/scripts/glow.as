package
{
   import flash.display.BitmapData;
   
   [Embed(source="/_assets/63_glow.png")]
   public dynamic class glow extends BitmapData
   {
      
      public function glow(w:int = 37, h:int = 37)
      {
         super(w,h);
      }
   }
}

