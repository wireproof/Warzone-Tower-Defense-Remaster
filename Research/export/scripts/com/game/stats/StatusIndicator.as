package com.game.stats
{
   import flash.display.MovieClip;
   
   public class StatusIndicator extends MovieClip
   {
      
      protected var bar:MovieClip;
      
      public function StatusIndicator()
      {
         super();
      }
      
      public function setHealth(currentHealth:Number, initialHealth:Number) : *
      {
         if(this.bar != null)
         {
            this.bar.scaleX = currentHealth / initialHealth;
         }
      }
   }
}

