package com.jgp.ui
{
   import com.jgp.functions.SimpleDispatcher;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol162")]
   public class RadioButton extends MovieClip
   {
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      protected var selected:Boolean = false;
      
      public function RadioButton()
      {
         addFrameScript(0,this.frame1,1,this.frame2);
         super();
         SimpleDispatcher.initialize(this);
         buttonMode = true;
         useHandCursor = true;
         this.setDeselectState();
         addEventListener(MouseEvent.MOUSE_DOWN,this.onSelected);
      }
      
      protected function setSelectState() : void
      {
         gotoAndStop("down");
      }
      
      protected function setDeselectState() : void
      {
         gotoAndStop("up");
      }
      
      protected function onSelected(event:MouseEvent) : void
      {
         this.select();
      }
      
      public function select() : void
      {
         if(!this.selected)
         {
            this.selected = true;
            this.setSelectState();
            this.dispatchSimpleEvent("onSelected");
         }
      }
      
      public function deselect() : void
      {
         this.selected = false;
         this.setDeselectState();
         this.dispatchSimpleEvent("onDeselected");
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame2() : *
      {
         stop();
      }
   }
}

