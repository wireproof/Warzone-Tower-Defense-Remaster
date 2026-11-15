package com.jgp.user
{
   import com.jgp.functions.Callback;
   import com.jgp.functions.DelayedCallback;
   import com.jgp.php.HighScores;
   import com.jgp.text.BadWordFilter;
   import com.jgp.ui.RadioButton;
   import com.main.ui.Button;
   import com.main.ui.CustomComboBox;
   import fl.controls.UIScrollBar;
   import fl.transitions.Tween;
   import fl.transitions.TweenEvent;
   import fl.transitions.easing.Regular;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol244")]
   public class HighScoresDisplay extends MovieClip
   {
      
      public var InstanceName_0:MovieClip;
      
      public var allTimeButton:RadioButton;
      
      public var connectMessage:MovieClip;
      
      public var exitButton:SimpleButton;
      
      public var filterButton:Button;
      
      public var levelSelectBox:CustomComboBox;
      
      public var levelSelectModBox:CustomComboBox;
      
      public var refreshButton:SimpleButton;
      
      public var scoresText:TextField;
      
      public var scrollBar:UIScrollBar;
      
      public var thisMonthButton:RadioButton;
      
      public var thisWeekButton:RadioButton;
      
      public var todayButton:RadioButton;
      
      public var userNameFilterText:TextField;
      
      protected var connection:HighScores;
      
      protected var buttonList:Array;
      
      protected var scoresURL:String;
      
      protected var gameId:Number;
      
      protected var filterButtonList:Array;
      
      protected var levelSelector:LevelSelectListBox;
      
      protected var modSelector:LevelSelectListBox;
      
      protected var dayCount:Number;
      
      protected var exitCallback:Callback;
      
      protected var tween:Tween;
      
      public function HighScoresDisplay(scoresURL:String, gameId:Number, levelList:Array, modeList:Array, exitCallback:Callback = null)
      {
         super();
         this.scoresURL = scoresURL;
         this.gameId = gameId;
         this.exitCallback = exitCallback;
         mouseChildren = false;
         this.initLevelSelector(levelList);
         this.initModeSelector(modeList);
         this.connectMessage.visible = false;
         this.setEvents();
         this.fadeIn();
         this.__setProp_scrollBar_HighScoresDisplay_Layer4_0();
         this.__setProp_filterButton_HighScoresDisplay_Layer5_0();
      }
      
      protected function fadeIn() : void
      {
         blendMode = "layer";
         this.tween = new Tween(this,"alpha",Regular.easeOut,0,1,10,false);
      }
      
      protected function fadeOut() : void
      {
         mouseChildren = false;
         mouseEnabled = false;
         this.tween.stop();
         this.tween = new Tween(this,"alpha",Regular.easeOut,this.alpha,0,10,false);
         this.tween.addEventListener(TweenEvent.MOTION_FINISH,this.onFadedOut);
      }
      
      protected function onFadedOut(event:Event) : void
      {
         if(this.exitCallback != null)
         {
            this.exitCallback.call();
         }
      }
      
      protected function initLevelSelector(levelList:Array) : void
      {
         var levItem:Object = null;
         this.levelSelector = new LevelSelectListBox();
         this.levelSelector.registerSimpleEvent("onListSelectionChanged",new Callback(this,this.onLevelSelected));
         var levItemList:Array = new Array();
         for each(levItem in levelList)
         {
            levItemList.push({
               "label":levItem.name,
               "data":""
            });
         }
         this.levelSelector.initialize(this.levelSelectBox,levItemList);
      }
      
      protected function initModeSelector(modeList:Array) : void
      {
         var modeItem:Object = null;
         this.modSelector = new LevelSelectListBox();
         this.modSelector.registerSimpleEvent("onListSelectionChanged",new Callback(this,this.getUpdatedTable));
         var modItemList:Array = new Array();
         for each(modeItem in modeList)
         {
            modItemList.push({
               "label":modeItem.label,
               "data":modeItem.data
            });
         }
         this.modSelector.initialize(this.levelSelectModBox,modItemList);
      }
      
      protected function setEvents() : void
      {
         this.todayButton.registerSimpleEvent("onSelected",new Callback(this,this.viewScoresToday));
         this.thisWeekButton.registerSimpleEvent("onSelected",new Callback(this,this.viewScoresThisWeek));
         this.thisMonthButton.registerSimpleEvent("onSelected",new Callback(this,this.viewScoresThisMonth));
         this.allTimeButton.registerSimpleEvent("onSelected",new Callback(this,this.viewScoresAllTime));
         this.filterButtonList = [this.todayButton,this.thisWeekButton,this.thisMonthButton,this.allTimeButton];
         this.refreshButton.addEventListener(MouseEvent.MOUSE_DOWN,this.refreshTable);
         this.filterButton.addEventListener(MouseEvent.MOUSE_DOWN,this.filterTable);
         this.exitButton.addEventListener(MouseEvent.MOUSE_DOWN,this.exitHighScores);
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
      }
      
      protected function onAddedToStage(event:Event) : void
      {
         this.scoresText.text = "";
         this.userNameFilterText.text = "";
         this.viewScoresThisMonth();
      }
      
      protected function exitHighScores(event:MouseEvent = null) : void
      {
         this.fadeOut();
      }
      
      protected function selectFilterButton(buttonInstance:*) : void
      {
         var button:* = undefined;
         for each(button in this.filterButtonList)
         {
            if(button != buttonInstance)
            {
               button.deselect();
            }
            else
            {
               button.select();
            }
         }
      }
      
      protected function viewScoresToday(event:MouseEvent = null) : void
      {
         this.selectFilterButton(this.todayButton);
         this.dayCount = 1;
         this.getUpdatedTable();
      }
      
      protected function viewScoresThisWeek(event:MouseEvent = null) : void
      {
         this.selectFilterButton(this.thisWeekButton);
         this.dayCount = 7;
         this.getUpdatedTable();
      }
      
      protected function viewScoresThisMonth(event:MouseEvent = null) : void
      {
         this.selectFilterButton(this.thisMonthButton);
         this.dayCount = 30;
         this.getUpdatedTable();
      }
      
      protected function viewScoresAllTime(event:MouseEvent = null) : void
      {
         this.selectFilterButton(this.allTimeButton);
         this.dayCount = 0;
         this.getUpdatedTable();
      }
      
      protected function getUpdatedTable(nameFilter:String = "*") : void
      {
         this.scoresText.text = "";
         mouseChildren = false;
         this.connectMessage.visible = true;
         if(nameFilter.length == 0)
         {
            nameFilter = "*";
         }
         var levelName:String = this.levelSelector.getSelectedLabel();
         var modType:String = this.modSelector.getSelectedData();
         if(modType.length > 1)
         {
            levelName += "_" + modType;
         }
         this.connection = new HighScores(this.scoresURL,this.gameId,levelName,this.dayCount,nameFilter,new DelayedCallback(this,this.onTableLoaded,200));
      }
      
      protected function filterTable(event:Event = null) : *
      {
         this.getUpdatedTable(this.userNameFilterText.text);
      }
      
      protected function refreshTable(event:Event = null) : *
      {
         this.getUpdatedTable();
      }
      
      protected function onTableLoaded(success:Boolean) : void
      {
         var scoreObj:Object = null;
         this.connectMessage.visible = false;
         mouseChildren = true;
         var scoresList:Array = this.connection.getReturnedVar("scoreTable");
         var outputString:String = new String();
         var rowNum:Number = 0;
         for each(scoreObj in scoresList)
         {
            rowNum++;
            outputString += " #" + this.addSpaces(String(rowNum),11) + " " + this.addSpaces(scoreObj.user,12) + " " + this.addSpaces(String(scoreObj.score),14) + " " + scoreObj.date;
            outputString += "\n";
         }
         if(scoresList.length == 0)
         {
            outputString += " No entries were found.";
         }
         this.scoresText.text = BadWordFilter.filterBadWords(outputString);
         var scroller:UIScrollBar = this.scrollBar;
         scroller.scrollTarget = this.scoresText;
      }
      
      protected function onLevelSelected() : void
      {
         this.getUpdatedTable();
      }
      
      protected function addSpaces(addTo:String, desiredLength:Number) : String
      {
         while(addTo.length < desiredLength)
         {
            addTo += " ";
         }
         return addTo;
      }
      
      internal function __setProp_scrollBar_HighScoresDisplay_Layer4_0() : *
      {
         try
         {
            this.scrollBar["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.scrollBar.direction = "vertical";
         this.scrollBar.scrollTargetName = "scoresText";
         this.scrollBar.visible = true;
         try
         {
            this.scrollBar["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_filterButton_HighScoresDisplay_Layer5_0() : *
      {
         try
         {
            this.filterButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.filterButton.emphasized = false;
         this.filterButton.enabled = true;
         this.filterButton.label = "FILTER";
         this.filterButton.labelPlacement = "right";
         this.filterButton.selected = false;
         this.filterButton.toggle = false;
         this.filterButton.visible = true;
         try
         {
            this.filterButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

