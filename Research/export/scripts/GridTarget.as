package
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol643")]
   public dynamic class GridTarget extends MovieClip
   {
      
      public var base:MovieClip;
      
      public function GridTarget()
      {
         super();
         addFrameScript(0,this.frame1,24,this.frame25);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame25() : *
      {
         stop();
      }
   }
}

