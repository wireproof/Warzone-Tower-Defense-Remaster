package com.game.ui.menus.panels
{
   import com.jgp.functions.SimpleDispatcher;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol369")]
   public class UpgradePanel extends MovieClip
   {
      
      public var bg:MovieClip;
      
      public var buyButton:SimpleButton;
      
      public var cashText:TextField;
      
      public var currentText:TextField;
      
      public var sellButton:SimpleButton;
      
      public var titleText:TextField;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function UpgradePanel()
      {
         super();
         this.buyButton.visible = false;
         this.sellButton.visible = false;
         SimpleDispatcher.initialize(this);
         this.buyButton.addEventListener(MouseEvent.MOUSE_DOWN,this.onSelected,false,0,true);
         this.sellButton.addEventListener(MouseEvent.MOUSE_DOWN,this.onSelected,false,0,true);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
         cacheAsBitmap = true;
      }
      
      protected function onAddedToStage(event:Event) : void
      {
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPressed);
      }
      
      protected function onRemovedFromStage(event:Event) : void
      {
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPressed);
      }
      
      protected function onKeyPressed(event:KeyboardEvent) : void
      {
      }
      
      public function setActionButtonLabel(label:String) : void
      {
         this.buyButton.visible = label == "BUY";
         this.sellButton.visible = label == "SELL";
      }
      
      public function setText(textObj:Object) : void
      {
         this.titleText.htmlText = textObj.titleText;
         this.cashText.htmlText = textObj.cashText;
         this.currentText.htmlText = textObj.bodyText;
      }
      
      protected function onSelected(event:MouseEvent = null) : void
      {
         this.dispatchSimpleEvent("onActionSelected");
      }
      
      public function showButton() : void
      {
         this.buyButton.visible = true;
         this.sellButton.visible = true;
      }
      
      public function hideButton() : void
      {
         this.buyButton.visible = false;
         this.sellButton.visible = false;
      }
   }
}

