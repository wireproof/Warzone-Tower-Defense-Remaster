package com.game.ui.menus.buttons
{
   import com.jgp.audio.AudioControl;
   import com.jgp.functions.SimpleDispatcher;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.getDefinitionByName;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol340")]
   public class ItemSelectButton extends MovieClip
   {
      
      public var iconHolder:MovieClip;
      
      public var label:TextField;
      
      protected var itemId:String;
      
      protected var labelText:String = "";
      
      protected var icon:String;
      
      protected var iconClip:MovieClip;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function ItemSelectButton(buttonConfig:Object, dispatcher:SimpleDispatcher)
      {
         super();
         stop();
         this.applyParamObject(buttonConfig);
         SimpleDispatcher.initialize(this,dispatcher);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onSelected,false,0,true);
         this.setLabel();
         buttonMode = true;
         useHandCursor = true;
         mouseChildren = false;
         if(this.icon != null)
         {
            this.setIcon();
         }
      }
      
      protected function setLabel() : void
      {
         this.label.htmlText = this.labelText.toUpperCase();
      }
      
      protected function setIcon() : void
      {
         var iconClass:Class = getDefinitionByName(this.icon) as Class;
         this.iconClip = new iconClass() as MovieClip;
         this.iconClip.cacheAsBitmap = true;
         this.iconHolder.addChild(this.iconClip);
      }
      
      protected function applyParamObject(paramObject:Object) : void
      {
         var p:String = null;
         for(p in paramObject)
         {
            try
            {
               this[p] = paramObject[p];
            }
            catch(error:Error)
            {
            }
         }
      }
      
      protected function onSelected(event:MouseEvent = null) : *
      {
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.playSound("ClickSound",0,null,false);
         this.dispatchSimpleEvent("onSelected",[this]);
      }
      
      public function getItemId() : String
      {
         return this.itemId;
      }
      
      public function setSelectState() : void
      {
         gotoAndStop(2);
      }
      
      public function setUnselectState() : void
      {
         gotoAndStop(1);
      }
      
      public function disable() : void
      {
         alpha = 0.25;
         enabled = false;
         mouseEnabled = false;
      }
      
      public function isEnabled() : Boolean
      {
         return enabled;
      }
   }
}

