package com.game.stats
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol466")]
   public class CreepStatusIndicator extends StatusIndicator
   {
      
      public var healthBar:MovieClip;
      
      public function CreepStatusIndicator()
      {
         super();
         bar = this.healthBar.bar;
      }
   }
}

