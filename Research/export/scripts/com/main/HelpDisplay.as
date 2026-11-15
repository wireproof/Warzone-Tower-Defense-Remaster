package com.main
{
   import com.jgp.functions.Callback;
   import com.jgp.tracking.Tracker;
   import com.main.ui.Button;
   import fl.transitions.Tween;
   import fl.transitions.TweenEvent;
   import fl.transitions.easing.Regular;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol334")]
   public class HelpDisplay extends MovieClip
   {
      
      public var exitButton:Button;
      
      protected var exitCallback:Callback;
      
      protected var fadeCallback:Callback;
      
      protected var tween:Tween;
      
      public function HelpDisplay(exitCallback:Callback)
      {
         super();
         this.exitCallback = exitCallback;
         this.exitButton.addEventListener(MouseEvent.CLICK,this.exit);
         this.fadeIn();
         Tracker.trackEvent("open help");
         this.__setProp_exitButton_HelpDisplay_button_0();
      }
      
      protected function fadeIn() : void
      {
         blendMode = "layer";
         this.tween = new Tween(this,"alpha",Regular.easeOut,0,1,10,false);
      }
      
      protected function fadeOut(callback:Callback) : void
      {
         this.fadeCallback = callback;
         mouseChildren = false;
         mouseEnabled = false;
         this.tween.stop();
         this.tween = new Tween(this,"alpha",Regular.easeOut,this.alpha,0,10,false);
         this.tween.addEventListener(TweenEvent.MOTION_FINISH,this.onFadedOut);
      }
      
      protected function onFadedOut(event:Event) : void
      {
         if(this.fadeCallback != null)
         {
            this.fadeCallback.call();
         }
      }
      
      protected function exit(event:MouseEvent = null) : void
      {
         this.fadeOut(this.exitCallback);
      }
      
      internal function __setProp_exitButton_HelpDisplay_button_0() : *
      {
         try
         {
            this.exitButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.exitButton.emphasized = false;
         this.exitButton.enabled = true;
         this.exitButton.label = "Back";
         this.exitButton.labelPlacement = "right";
         this.exitButton.selected = false;
         this.exitButton.toggle = false;
         this.exitButton.visible = true;
         try
         {
            this.exitButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

