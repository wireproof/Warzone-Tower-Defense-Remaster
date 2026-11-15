package com.main
{
   import com.jgp.functions.SimpleDispatcher;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol329")]
   public class InGameMenu extends MovieClip
   {
      
      public var mainButton:SimpleButton;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function InGameMenu()
      {
         super();
         SimpleDispatcher.initialize(this);
         this.mainButton.addEventListener(MouseEvent.CLICK,this.showMain);
      }
      
      protected function showMain(event:MouseEvent) : void
      {
         this.dispatchSimpleEvent("onShowMain");
      }
   }
}

