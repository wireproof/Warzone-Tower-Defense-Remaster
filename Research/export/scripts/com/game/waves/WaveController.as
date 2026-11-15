package com.game.waves
{
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.helpers.ArrayHelper;
   import com.jgp.helpers.ObjectHelper;
   import com.jgp.math.geom.GPoint;
   import com.jgp.utils.TimeTicker;
   import com.main.ui.Button;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol112")]
   public class WaveController extends MovieClip
   {
      
      protected static const SEND_NOW_BUTTON_OFF_ALPHA:Number = 0.3;
      
      protected static const SEND_NOW_BUTTON_ON_ALPHA:Number = 1;
      
      protected static const PREVIEW_COUNT:Number = 5;
      
      protected static const PREVIEW_LOC:GPoint = new GPoint(10,10);
      
      public var sendNowButton:Button;
      
      public var timeTextField:TextField;
      
      public var waveText:TextField;
      
      protected var currentWave:Number;
      
      protected var waveList:Array;
      
      protected var nextWaveAt:Number = 0;
      
      protected var unlimitedLevels:Boolean;
      
      protected var ticker:TimeTicker;
      
      protected var previewClip:MovieClip;
      
      protected var nextWaveObj:Object;
      
      protected var wavePreview:WavePreview;
      
      protected var waveTypeRefs:Object;
      
      protected var introLength:Number;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function WaveController(dispatcher:SimpleDispatcher, waveTypeRefs:Object, introWaveList:Array, waveList:Array, ticker:TimeTicker, unlimitedLevels:Boolean = true)
      {
         super();
         this.currentWave = 0;
         this.ticker = ticker;
         SimpleDispatcher.initialize(this,dispatcher);
         this.waveTypeRefs = waveTypeRefs;
         this.unlimitedLevels = unlimitedLevels;
         this.introLength = introWaveList.length;
         this.setInitWaveList(introWaveList,waveList);
         this.waveText.text = String(this.currentWave);
         this.sendNowButton.alpha = SEND_NOW_BUTTON_OFF_ALPHA;
         mouseChildren = true;
         dispatcher = new SimpleDispatcher();
         this.wavePreview = new WavePreview(dispatcher,PREVIEW_COUNT,this.waveList);
         this.wavePreview.x = PREVIEW_LOC.x;
         this.wavePreview.y = PREVIEW_LOC.y;
         addChild(this.wavePreview);
         this.__setProp_sendNowButton_WaveController_Layer1_0();
      }
      
      protected function setInitWaveList(introWaveList:Array, continueWaveList:Array) : void
      {
         var tempObj:Object = null;
         this.waveList = ArrayHelper.merge(introWaveList,continueWaveList);
         for(var i:Number = 0; i < this.waveList.length; i++)
         {
            tempObj = ObjectHelper.cloneObject(this.waveTypeRefs[this.waveList[i].AIType]);
            ObjectHelper.copyProps(tempObj,this.waveList[i]);
            this.waveList[i] = tempObj;
         }
      }
      
      protected function updateTimer(event:Event) : void
      {
         this.updateClockDisplay();
         if(this.ticker.getTime() > this.nextWaveAt)
         {
            this.sendWave();
         }
      }
      
      protected function updateClockDisplay() : void
      {
         var timeUntilWave:Number = Math.ceil((this.nextWaveAt - this.ticker.getTime()) * 100 / 1000) / 100;
         if(timeUntilWave < 0)
         {
            timeUntilWave = 0;
         }
         var timeText:String = String(timeUntilWave);
         var decimalIndex:Number = timeText.indexOf(".");
         var decimalPlaces:Number = timeText.length - decimalIndex - 1;
         if(decimalIndex == -1)
         {
            timeText += ".00";
         }
         else if(decimalPlaces < 2)
         {
            timeText += "0";
         }
         this.timeTextField.text = timeText;
      }
      
      protected function sendWave(event:Event = null) : void
      {
         var skinName:String = null;
         ++this.currentWave;
         this.waveText.text = String(this.currentWave);
         this.timeTextField.text = "0.00";
         this.removeEvents();
         mouseChildren = false;
         this.nextWaveObj = this.waveList.shift();
         if(this.unlimitedLevels && this.currentWave > this.introLength)
         {
            this.waveList.push(this.nextWaveObj);
         }
         if(this.waveList.length > 0)
         {
            skinName = this.waveList[PREVIEW_COUNT - 1].skinName;
            this.wavePreview.setPreviewIcon(skinName);
            this.dispatchSimpleEvent("sendWave",[this.nextWaveObj,this.currentWave]);
         }
      }
      
      public function setWaveTimer(milliseconds:Number) : void
      {
         if(this.waveList.length > 0)
         {
            this.nextWaveAt = this.ticker.getTime() + milliseconds;
            addEventListener(Event.ENTER_FRAME,this.updateTimer);
            this.sendNowButton.alpha = SEND_NOW_BUTTON_ON_ALPHA;
            this.sendNowButton.addEventListener(MouseEvent.CLICK,this.sendWave,false,0,true);
            mouseChildren = true;
         }
      }
      
      public function getCurrentWave() : Number
      {
         return this.currentWave;
      }
      
      public function getCurrentWaveObj() : Object
      {
         return this.nextWaveObj;
      }
      
      public function removeEvents() : void
      {
         this.sendNowButton.alpha = SEND_NOW_BUTTON_OFF_ALPHA;
         this.sendNowButton.removeEventListener(MouseEvent.CLICK,this.sendWave);
         removeEventListener(Event.ENTER_FRAME,this.updateTimer);
      }
      
      public function pause() : void
      {
         this.wavePreview.pause();
      }
      
      public function unpause() : void
      {
         this.wavePreview.unpause();
      }
      
      internal function __setProp_sendNowButton_WaveController_Layer1_0() : *
      {
         try
         {
            this.sendNowButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.sendNowButton.emphasized = false;
         this.sendNowButton.enabled = true;
         this.sendNowButton.label = "SEND NOW";
         this.sendNowButton.labelPlacement = "right";
         this.sendNowButton.selected = false;
         this.sendNowButton.toggle = false;
         this.sendNowButton.visible = true;
         try
         {
            this.sendNowButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

