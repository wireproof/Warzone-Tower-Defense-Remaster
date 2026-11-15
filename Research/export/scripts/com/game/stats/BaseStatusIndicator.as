package com.game.stats
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol467")]
   public class BaseStatusIndicator extends StatusIndicator
   {
      
      public var healthBar:MovieClip;
      
      public function BaseStatusIndicator()
      {
         super();
         bar = this.healthBar.bar;
      }
   }
}

