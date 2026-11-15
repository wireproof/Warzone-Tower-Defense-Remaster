package com.game.ui.displays
{
   import com.jgp.functions.SimpleDispatcher;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol250")]
   public class ScoreBoard extends MovieClip
   {
      
      public var scoreText:TextField;
      
      protected var currentScore:Number;
      
      protected var initLength:Number;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function ScoreBoard()
      {
         super();
         SimpleDispatcher.initialize(this);
         this.initLength = this.scoreText.length;
         this.scoreText.text = "0";
      }
      
      public function updateScoreDisplay(scoreVal:Number) : void
      {
         this.scoreText.text = String(scoreVal);
      }
   }
}

