package com.main
{
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.tracking.Tracker;
   import com.main.ui.Button;
   import com.main.ui.CustomComboBox;
   import fl.controls.ComboBox;
   import fl.data.DataProvider;
   import fl.data.SimpleCollectionItem;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol323")]
   public class MainMenu extends MovieClip
   {
      
      public var helpButton:Button;
      
      public var levelSelector:LevelSelector;
      
      public var linkButton:SimpleButton;
      
      public var modeCombo:CustomComboBox;
      
      public var modeDescription:TextField;
      
      public var newGameButton:Button;
      
      public var scoresButton:Button;
      
      public var versionButton:SimpleButton;
      
      protected var filePath:String;
      
      protected var descriptionRefs:Object;
      
      protected var modeSelector:ComboBox;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function MainMenu()
      {
         super();
         SimpleDispatcher.initialize(this);
         this.scoresButton.addEventListener(MouseEvent.CLICK,this.showHighScores);
         this.helpButton.addEventListener(MouseEvent.CLICK,this.showHelp);
         this.newGameButton.addEventListener(MouseEvent.CLICK,this.onLevelSelected);
         this.modeSelector = this.modeCombo;
         this.modeSelector.addEventListener(Event.CHANGE,this.updateGameMode);
         cacheAsBitmap = true;
         this.linkButton.addEventListener(MouseEvent.CLICK,this.onLinkClicked);
         this.versionButton.addEventListener(MouseEvent.CLICK,this.onVersionClicked);
         this.__setProp_modeCombo_MainMenu_Layer1_0();
         this.__setProp_newGameButton_MainMenu_Layer1_0();
         this.__setProp_scoresButton_MainMenu_Layer1_0();
         this.__setProp_helpButton_MainMenu_Layer1_0();
      }
      
      public function setFilePath(path:String) : void
      {
         this.filePath = path;
         this.levelSelector.setFilePath(path);
      }
      
      public function initializeModeList(modeList:Array, modeDescriptions:Object) : void
      {
         var mode:Object = null;
         this.descriptionRefs = modeDescriptions;
         for each(mode in modeList)
         {
            this.modeSelector.addItem(mode);
         }
         this.updateDescription(modeList[0].data);
      }
      
      public function initializeLevelSelector(levList:Array) : void
      {
         this.levelSelector.initialize(levList);
      }
      
      protected function onLevelSelected(event:MouseEvent) : void
      {
         this.dispatchSimpleEvent("onLevelSelected",[this.levelSelector.getSelectedLevelName(),this.levelSelector.getSelectedLevelDirectory()]);
      }
      
      protected function showHighScores(event:MouseEvent) : void
      {
         this.dispatchSimpleEvent("onShowHighScores");
      }
      
      protected function showHelp(event:MouseEvent) : void
      {
         this.dispatchSimpleEvent("onShowHelp");
      }
      
      protected function updateGameMode(event:Event = null) : void
      {
         var mode:String = null;
         if(this.modeSelector.selectedItem != null)
         {
            mode = this.modeSelector.selectedItem.data;
            this.updateDescription(mode);
            this.dispatchSimpleEvent("updateGameMode",[mode]);
         }
      }
      
      protected function updateDescription(mode:String) : void
      {
         if(this.descriptionRefs["mode_" + mode] != null)
         {
            this.modeDescription.text = this.descriptionRefs["mode_" + mode];
         }
         else
         {
            this.modeDescription.text = "";
         }
      }
      
      protected function onLinkClicked(event:Event) : void
      {
         Tracker.trackEvent("main link clicked");
         navigateToURL(new URLRequest("http://www.madcowinteractive.com"),"_blank");
      }
      
      protected function onVersionClicked(event:Event) : void
      {
         navigateToURL(new URLRequest("http://www.madcowinteractive.com/BB/viewtopic.php?f=4&t=20"),"_blank");
      }
      
      internal function __setProp_modeCombo_MainMenu_Layer1_0() : *
      {
         var itemObj1:SimpleCollectionItem = null;
         var collProps1:Array = null;
         var collProp1:Object = null;
         var i1:int = 0;
         var j1:* = undefined;
         try
         {
            this.modeCombo["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         var collObj1:DataProvider = new DataProvider();
         collProps1 = [];
         for(i1 = 0; i1 < collProps1.length; i1++)
         {
            itemObj1 = new SimpleCollectionItem();
            collProp1 = collProps1[i1];
            for(j1 in collProp1)
            {
               itemObj1[j1] = collProp1[j1];
            }
            collObj1.addItem(itemObj1);
         }
         this.modeCombo.dataProvider = collObj1;
         this.modeCombo.editable = false;
         this.modeCombo.enabled = true;
         this.modeCombo.prompt = "";
         this.modeCombo.restrict = "";
         this.modeCombo.rowCount = 7;
         this.modeCombo.visible = true;
         try
         {
            this.modeCombo["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_newGameButton_MainMenu_Layer1_0() : *
      {
         try
         {
            this.newGameButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.newGameButton.emphasized = false;
         this.newGameButton.enabled = true;
         this.newGameButton.label = "play level";
         this.newGameButton.labelPlacement = "right";
         this.newGameButton.selected = false;
         this.newGameButton.toggle = false;
         this.newGameButton.visible = true;
         try
         {
            this.newGameButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_scoresButton_MainMenu_Layer1_0() : *
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
         this.scoresButton.label = "highscores";
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
      
      internal function __setProp_helpButton_MainMenu_Layer1_0() : *
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
         this.helpButton.label = "instructions";
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
   }
}

