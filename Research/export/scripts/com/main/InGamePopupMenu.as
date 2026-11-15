package com.main
{
   import com.jgp.audio.AudioControl;
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import com.main.ui.Button;
   import fl.transitions.Tween;
   import fl.transitions.TweenEvent;
   import fl.transitions.easing.Regular;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol286")]
   public class InGamePopupMenu extends MovieClip
   {
      
      public var bg:MovieClip;
      
      public var exitButton:SimpleButton;
      
      public var helpButton:Button;
      
      public var mainButton:Button;
      
      public var resetButton:Button;
      
      public var returnButton:Button;
      
      public var scoresButton:Button;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      protected var fadeCallback:Callback;
      
      protected var tween:Tween;
      
      public function InGamePopupMenu()
      {
         super();
         SimpleDispatcher.initialize(this);
         this.mainButton.addEventListener(MouseEvent.CLICK,this.exitToMainPressed);
         this.scoresButton.addEventListener(MouseEvent.CLICK,this.scoresPressed);
         this.helpButton.addEventListener(MouseEvent.CLICK,this.helpPressed);
         this.resetButton.addEventListener(MouseEvent.CLICK,this.resetPressed);
         this.returnButton.addEventListener(MouseEvent.CLICK,this.returnToGamePressed);
         this.exitButton.addEventListener(MouseEvent.CLICK,this.returnToGamePressed);
         this.fadeIn();
         this.__setProp_scoresButton_PopupMenu_Layer1_0();
         this.__setProp_mainButton_PopupMenu_Layer1_0();
         this.__setProp_resetButton_PopupMenu_Layer1_0();
         this.__setProp_helpButton_PopupMenu_Layer1_0();
         this.__setProp_returnButton_PopupMenu_Layer1_0();
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
      
      protected function returnToGamePressed(event:MouseEvent) : void
      {
         this.fadeOut(new Callback(this,this.dispatchSimpleEvent,["onReturnToGame"]));
      }
      
      protected function exitToMainPressed(event:MouseEvent) : void
      {
         this.mainButton.removeEventListener(MouseEvent.CLICK,this.exitToMainPressed);
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.stopSounds(["ClickSound"]);
         audioController.stopMusic();
         this.dispatchSimpleEvent("onExitToMain");
      }
      
      protected function scoresPressed(event:MouseEvent) : void
      {
         this.dispatchSimpleEvent("onShowHighScores");
      }
      
      protected function resetPressed(event:MouseEvent) : void
      {
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.stopSounds();
         audioController.stopMusic();
         this.fadeOut(new Callback(this,this.dispatchSimpleEvent,["onResetLevel"]));
      }
      
      protected function helpPressed(event:MouseEvent) : void
      {
         this.dispatchSimpleEvent("onShowHelp");
      }
      
      internal function __setProp_scoresButton_PopupMenu_Layer1_0() : *
      {
         try
         {
            this.scoresButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.scoresButton.emphasized = false;
         this.scoresButton.enabled = true;
         this.scoresButton.label = "HIGHSCORES";
         this.scoresButton.labelPlacement = "right";
         this.scoresButton.selected = false;
         this.scoresButton.toggle = false;
         this.scoresButton.visible = true;
         try
         {
            this.scoresButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_mainButton_PopupMenu_Layer1_0() : *
      {
         try
         {
            this.mainButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.mainButton.emphasized = false;
         this.mainButton.enabled = true;
         this.mainButton.label = "QUIT GAME";
         this.mainButton.labelPlacement = "right";
         this.mainButton.selected = false;
         this.mainButton.toggle = false;
         this.mainButton.visible = true;
         try
         {
            this.mainButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_resetButton_PopupMenu_Layer1_0() : *
      {
         try
         {
            this.resetButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.resetButton.emphasized = false;
         this.resetButton.enabled = true;
         this.resetButton.label = "RESET LEVEL";
         this.resetButton.labelPlacement = "right";
         this.resetButton.selected = false;
         this.resetButton.toggle = false;
         this.resetButton.visible = true;
         try
         {
            this.resetButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_helpButton_PopupMenu_Layer1_0() : *
      {
         try
         {
            this.helpButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.helpButton.emphasized = false;
         this.helpButton.enabled = true;
         this.helpButton.label = "INSTRUCTIONS";
         this.helpButton.labelPlacement = "right";
         this.helpButton.selected = false;
         this.helpButton.toggle = false;
         this.helpButton.visible = true;
         try
         {
            this.helpButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_returnButton_PopupMenu_Layer1_0() : *
      {
         try
         {
            this.returnButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.returnButton.emphasized = false;
         this.returnButton.enabled = true;
         this.returnButton.label = "RETURN TO GAME";
         this.returnButton.labelPlacement = "right";
         this.returnButton.selected = false;
         this.returnButton.toggle = false;
         this.returnButton.visible = true;
         try
         {
            this.returnButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

