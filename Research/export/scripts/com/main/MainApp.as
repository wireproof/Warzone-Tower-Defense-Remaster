package com.main
{
   import com.game.*;
   import com.game.level.LevelLayoutData;
   import com.jgp.audio.AudioControl;
   import com.jgp.bitmap.loading.BitmapArchive;
   import com.jgp.functions.*;
   import com.jgp.math.geom.GPoint;
   import com.jgp.text.BadWordFilter;
   import com.jgp.tracking.Tracker;
   import com.jgp.user.HighScoresDisplay;
   import com.jgp.user.ScoreSubmission;
   import com.jgp.user.UserManagement;
   import com.jgp.xml.XMLEmbeded;
   import com.jgp.xml.XMLFetch;
   import flash.display.InteractiveObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.net.URLLoader;
   import flash.utils.Timer;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol324")]
   public class MainApp extends MovieClip
   {
      
      public var mainLevelSelector:MainMenu;
      
      protected var configLoader:XMLFetch;
      
      protected var levelLayout:LevelLayoutData;
      
      protected var levelConfig:XMLFetch;
      
      protected var game:GameMain;
      
      protected var activeLevelId:String;
      
      protected var activeLevelDirectory:String;
      
      protected var bmpArchive:BitmapArchive;
      
      protected var gameContainer:MovieClip;
      
      protected var submitPrompt:ScoreSubmission;
      
      protected var highScoresDisplay:HighScoresDisplay;
      
      protected var helpDisplay:HelpDisplay;
      
      protected var filePath:String;
      
      protected var gameMode:String = "default";
      
      protected var inGameMenu:InGameMenu;
      
      protected var mainMenu:MainMenu;
      
      protected var popupMenu:InGamePopupMenu;
      
      protected var phpConnect:URLLoader;
      
      protected var keepAliveTimer:Timer;
      
      public function MainApp(filePath:String, bmpArchive:BitmapArchive, gameContainer:MovieClip)
      {
         super();
         this.filePath = filePath;
         mouseEnabled = false;
         mouseChildren = false;
         this.bmpArchive = bmpArchive;
         this.gameContainer = gameContainer;
         this.mainMenu = this.mainLevelSelector;
         this.phpConnect = new URLLoader();
         this.phpConnect.addEventListener(Event.COMPLETE,this.onConnected);
         this.loadMainConfig();
      }
      
      protected function onConnected(event:Event) : void
      {
      }
      
      protected function loadMainConfig() : void
      {
         this.configLoader = XMLEmbeded.getInstance().getMainConfigXML();
         this.initialize();
      }
      
      protected function initialize() : void
      {
         BadWordFilter.setWordList(this.configLoader.fetch("config.main.badWordFilter"));
         this.mainMenu.setFilePath(this.filePath);
         this.mainMenu.registerSimpleEvent("updateGameMode",new Callback(this,this.updateGameMode));
         this.mainMenu.registerSimpleEvent("onLevelSelected",new Callback(this,this.createGameInstance));
         this.mainMenu.registerSimpleEvent("onShowHighScores",new Callback(this,this.showHighScores,[new Callback(this,this.showMainMenu)]));
         this.mainMenu.registerSimpleEvent("onShowHelp",new Callback(this,this.showHelp,[new Callback(this,this.showMainMenu)]));
         this.mainMenu.initializeLevelSelector(this.configLoader.fetch("config.main.levelList"));
         this.mainMenu.initializeModeList(this.configLoader.fetch("config.main.modeList"),this.configLoader.fetch("config.main.modeDescriptions"));
         this.inGameMenu = new InGameMenu();
         this.inGameMenu.registerSimpleEvent("onShowMain",new Callback(this,this.showPopupMenu));
         var menuLoc:GPoint = GPoint.pointFromString(this.configLoader.fetch("config.main.inGameMenu.screenLoc"));
         this.inGameMenu.x = menuLoc.x;
         this.inGameMenu.y = menuLoc.y;
         this.hideInGameMenu();
         this.showMainMenu();
         mouseEnabled = true;
         mouseChildren = true;
      }
      
      protected function showMainMenu() : void
      {
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.stopSounds(["ClickSound"]);
         audioController.stopMusic();
         this.clearGameInstance();
         this.clearHighScoresDisplay();
         this.clearHelpDisplay();
         this.clearSubmitPrompt();
         this.hideInGameMenu();
         this.mainMenu.mouseEnabled = true;
         this.mainMenu.mouseChildren = true;
         this.mainMenu.visible = true;
      }
      
      protected function hideMainMenu() : void
      {
         this.mainMenu.visible = false;
         this.mainMenu.mouseEnabled = false;
         this.mainMenu.mouseChildren = false;
      }
      
      protected function showInGameMenu() : void
      {
         if(!contains(this.inGameMenu))
         {
            addChild(this.inGameMenu);
         }
         this.mainMenu.visible = false;
      }
      
      protected function hideInGameMenu() : void
      {
         if(contains(this.inGameMenu))
         {
            removeChild(this.inGameMenu);
         }
      }
      
      protected function showPopupMenu() : void
      {
         if(this.popupMenu != null)
         {
            return;
         }
         this.game.pause();
         this.popupMenu = new InGamePopupMenu();
         var menuLoc:GPoint = GPoint.pointFromString(this.configLoader.fetch("config.main.popupMenu.screenLoc"));
         this.popupMenu.x = menuLoc.x;
         this.popupMenu.y = menuLoc.y;
         this.popupMenu.registerSimpleEvent("onExitToMain",new Callback(this,this.clearPopupMenuAndExitToMain));
         this.popupMenu.registerSimpleEvent("onReturnToGame",new Callback(this,this.clearPopupMenuAndReturnToGame));
         this.popupMenu.registerSimpleEvent("onShowHighScores",new Callback(this,this.showHighScores,[new Callback(this,this.clearHighScoresDisplay)]));
         this.popupMenu.registerSimpleEvent("onShowHelp",new Callback(this,this.showHelp,[new Callback(this,this.clearHelpDisplay)]));
         this.popupMenu.registerSimpleEvent("onResetLevel",new Callback(this,this.clearPopupAndResetLevel));
         addChild(this.popupMenu);
         this.setFocus(this.popupMenu);
      }
      
      protected function clearPopupMenu() : void
      {
         removeChild(this.popupMenu);
         this.popupMenu = null;
         this.setFocus(this);
      }
      
      protected function clearPopupMenuAndReturnToGame() : void
      {
         this.clearPopupMenu();
         this.game.unpause();
      }
      
      protected function clearPopupMenuAndExitToMain() : void
      {
         this.clearPopupMenu();
         this.showMainMenu();
      }
      
      protected function clearPopupAndResetLevel() : void
      {
         this.clearPopupMenu();
         this.retryLevel();
      }
      
      protected function updateGameMode(mode:String) : void
      {
         this.gameMode = mode;
      }
      
      protected function configureGameMode() : void
      {
         var generalConfig:Object = this.configLoader.fetch("config");
         generalConfig.gameMain.towerLimit = Infinity;
         var levelConfig:Object = this.levelConfig.fetch("config");
         if(this.gameMode == "limit_10")
         {
            generalConfig.gameMain.towerLimit = 10;
         }
         if(this.gameMode == "limit_20")
         {
            generalConfig.gameMain.towerLimit = 20;
         }
         else if(this.gameMode == "quick_cash")
         {
            levelConfig.gameStats.initialCash *= 1;
            levelConfig.gameStats.initCashPerKill *= 1.5;
            levelConfig.gameStats.cashWaveIncrease *= 1.5;
         }
         else if(this.gameMode == "2x")
         {
            levelConfig.gameStats.initialCash *= 2;
            levelConfig.gameStats.initCashPerKill *= 2;
            levelConfig.gameStats.cashWaveIncrease *= 2;
            levelConfig.gameStats.initHpWaveIncrease *= 2;
            levelConfig.gameStats.hpWaveIncreaseMultiplier = (levelConfig.gameStats.hpWaveIncreaseMultiplier - 1) * 2 + 1;
            levelConfig.gameStats.creepInitialHitPoints *= 2;
         }
         else if(this.gameMode == "cash_5k")
         {
            levelConfig.gameStats.initialCash = 5000;
            levelConfig.gameStats.initCashPerKill *= 2;
            levelConfig.gameStats.creepInitialHitPoints *= 10;
         }
         else if(this.gameMode == "20k_fixed")
         {
            levelConfig.gameStats.initialCash = 20000;
            levelConfig.gameStats.initCashPerKill = 0;
            levelConfig.gameStats.cashWaveIncrease = 0;
         }
         else if(this.gameMode == "50k_fixed")
         {
            levelConfig.gameStats.initialCash = 50000;
            levelConfig.gameStats.initCashPerKill = 0;
            levelConfig.gameStats.cashWaveIncrease = 0;
         }
         else if(this.gameMode == "100k_fixed")
         {
            levelConfig.gameStats.initialCash = 100000;
            levelConfig.gameStats.initCashPerKill = 0;
            levelConfig.gameStats.cashWaveIncrease = 0;
         }
         else if(this.gameMode == "quickPlay")
         {
            levelConfig.gameStats.speedMultiplier = 2;
            levelConfig.gameStats.hpMultiplier = 0.5;
            levelConfig.gameStats.insertIntervalMultiplier = 0.5;
            levelConfig.gameStats.waitTimerMultiplier = 0.5;
         }
         else if(this.gameMode == "unlimited")
         {
            levelConfig.gameStats.initialCash = Infinity;
            levelConfig.gameStats.initCashPerKill = 0;
            levelConfig.gameStats.cashWaveIncrease = 0;
            levelConfig.gameStats.creepInitialHitPoints *= 500;
            levelConfig.gameStats.baseInitialHitPoints = Infinity;
         }
      }
      
      protected function clearGameInstance() : void
      {
         if(this.game != null)
         {
            if(this.gameContainer.contains(this.game))
            {
               this.gameContainer.removeChild(this.game);
               this.game = null;
            }
         }
      }
      
      protected function createGameInstance(levelId:String, directory:String) : void
      {
         this.setFocus(this);
         mouseChildren = false;
         mouseEnabled = false;
         Tracker.trackEvent("level: " + levelId);
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.stopSounds(["ClickSound"]);
         audioController.stopMusic();
         this.activeLevelDirectory = directory;
         this.activeLevelId = levelId;
         var levelName:String = "_" + this.activeLevelDirectory.split("/")[1];
         this.levelLayout = XMLEmbeded.getInstance().getLevelLayoutXML(levelName);
         this.levelConfig = XMLEmbeded.getInstance().getLevelConfigXML(levelName);
         this.initGameInstance();
      }
      
      protected function initGameInstance() : void
      {
         var groundOnly:Boolean = this.activeLevelId.indexOf("ground only") >= 0;
         this.clearHighScoresDisplay();
         this.clearSubmitPrompt();
         this.clearGameInstance();
         this.configureGameMode();
         this.game = new GameMain(this.levelLayout,this.levelConfig.fetch("config"),this.configLoader.fetch("config"),this.bmpArchive,stage.frameRate,groundOnly);
         this.game.registerSimpleEvent("onRetryPressed",new Callback(this,this.retryLevel));
         this.game.registerSimpleEvent("onGameOver",new Callback(this,this.attachSubmitScoresPrompt));
         this.gameContainer.addChild(this.game);
         this.hideMainMenu();
         this.showInGameMenu();
         mouseChildren = true;
         mouseEnabled = true;
         dispatchEvent(new Event("onGameStarted"));
      }
      
      protected function onKeepAlive(event:TimerEvent) : void
      {
      }
      
      protected function retryLevel() : void
      {
         this.createGameInstance(this.activeLevelId,this.activeLevelDirectory);
      }
      
      protected function attachSubmitScoresPrompt(scoreValue:Number) : void
      {
         Tracker.trackEvent("level completed");
         var scoresLoc:GPoint = GPoint.pointFromString(this.configLoader.fetch("config.main.scoresPrompt.screenLoc"));
         var mode:String = this.activeLevelId;
         if(this.gameMode.length > 0)
         {
            mode += "_" + this.gameMode;
         }
         this.submitPrompt = UserManagement.getScoreSubmissionPrompt(scoreValue,mode,new Callback(this,this.retryLevel));
         this.submitPrompt.registerSimpleEvent("showHighScores",new Callback(this,this.showHighScores,[new Callback(this,this.clearHighScoresDisplay)]));
         this.submitPrompt.registerSimpleEvent("showMainMenu",new Callback(this,this.showMainMenu));
         this.submitPrompt.x = scoresLoc.x;
         this.submitPrompt.y = scoresLoc.y;
         addChild(this.submitPrompt);
         this.setFocus(this.submitPrompt);
      }
      
      protected function clearSubmitPrompt() : void
      {
         if(this.submitPrompt != null)
         {
            if(contains(this.submitPrompt))
            {
               removeChild(this.submitPrompt);
            }
         }
      }
      
      protected function showHighScores(exitCallback:Callback = null) : void
      {
         var levelList:Array = null;
         var modeList:Array = null;
         if(this.highScoresDisplay == null)
         {
            levelList = this.configLoader.fetch("config.main.levelList");
            modeList = this.configLoader.fetch("config.main.modeList");
            this.highScoresDisplay = UserManagement.getHighScoresDisplay(levelList,modeList,exitCallback);
         }
         if(!contains(this.highScoresDisplay))
         {
            addChild(this.highScoresDisplay);
         }
         addChild(this.highScoresDisplay);
         this.setFocus(this.highScoresDisplay);
      }
      
      protected function clearHighScoresDisplay() : void
      {
         if(this.highScoresDisplay != null)
         {
            if(contains(this.highScoresDisplay))
            {
               removeChild(this.highScoresDisplay);
            }
            this.highScoresDisplay = null;
         }
      }
      
      protected function showHelp(exitCallback:Callback) : *
      {
         if(this.helpDisplay == null)
         {
            this.helpDisplay = new HelpDisplay(exitCallback);
         }
         if(!contains(this.helpDisplay))
         {
            addChild(this.helpDisplay);
         }
         this.setFocus(this.helpDisplay);
      }
      
      protected function clearHelpDisplay() : void
      {
         if(this.helpDisplay != null)
         {
            if(contains(this.helpDisplay))
            {
               removeChild(this.helpDisplay);
            }
            this.helpDisplay = null;
         }
      }
      
      protected function setFocus(focusItem:InteractiveObject) : void
      {
         focusItem.focusRect = false;
         stage.focus = focusItem;
      }
      
      protected function getNoCacheString() : String
      {
         var date:Date = null;
         if(this.filePath.length > 0)
         {
            date = new Date();
            return "?noCache=" + date.time;
         }
         return "";
      }
   }
}

