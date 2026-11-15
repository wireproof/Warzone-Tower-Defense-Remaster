package com.game
{
   import com.game.ai.creeps.*;
   import com.game.ai.towers.*;
   import com.game.grid.*;
   import com.game.level.LevelLayoutData;
   import com.game.pathing.PathManager;
   import com.game.projectiles.ProjectileCollector;
   import com.game.stats.BaseStatusIndicator;
   import com.game.stats.GameStats;
   import com.game.ui.*;
   import com.game.ui.grid.*;
   import com.game.waves.WaveController;
   import com.jgp.audio.AudioControl;
   import com.jgp.bitmap.loading.BitmapArchive;
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.helpers.ArrayHelper;
   import com.jgp.math.geom.GPoint;
   import com.jgp.utils.TimeTicker;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DropShadowFilter;
   
   public class GameMain extends Sprite
   {
      
      protected var tileSize:Number;
      
      protected var gridWidth:Number;
      
      protected var gridHeight:Number;
      
      protected var defaultTileName:String;
      
      protected var themes:Object;
      
      protected var airGrid:GameGrid;
      
      protected var groundGrid:GameGrid;
      
      protected var airCreepCollector:CreepCollector;
      
      protected var groundCreepCollector:CreepCollector;
      
      protected var towerCollector:TowerCollector;
      
      protected var projectileCollector:ProjectileCollector;
      
      protected var activePaths:Array;
      
      protected var activeLevelLayoutData:LevelLayoutData;
      
      protected var activeLevelConfig:Object;
      
      protected var goalListRefs:Object;
      
      protected var spawnListRefs:Object;
      
      protected var groundPathManager:PathManager;
      
      protected var airPathManager:PathManager;
      
      protected var baseStatusIndicators:Array;
      
      protected var waveController:WaveController;
      
      protected var gamePlayClip:MovieClip;
      
      protected var gameUI:GameUI;
      
      protected var gameStats:GameStats;
      
      protected var ticker:TimeTicker;
      
      protected var generalConfig:Object;
      
      protected var bmpArchive:BitmapArchive;
      
      protected var gameOverDelayFrames:Number = 90;
      
      protected var towerLimit:Number = Infinity;
      
      protected var tempPoint:GPoint = new GPoint();
      
      protected var creepTypeRefs:Object;
      
      protected var groundOnly:Boolean;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function GameMain(levelLayoutData:LevelLayoutData, levelConfig:Object, generalConfig:Object, bmpArchive:BitmapArchive, frameRate:Number, groundOnly:Boolean)
      {
         super();
         SimpleDispatcher.initialize(this);
         this.groundOnly = groundOnly;
         this.generalConfig = generalConfig;
         this.activeLevelLayoutData = levelLayoutData;
         this.activeLevelConfig = levelConfig;
         this.bmpArchive = bmpArchive;
         this.applyParamObject(generalConfig.gameMain);
         this.goalListRefs = new Object();
         this.goalListRefs["ground"] = this.activeLevelLayoutData.getBlockList("ground","goalPoints");
         this.goalListRefs["air"] = this.activeLevelLayoutData.getBlockList("air","goalPoints");
         this.spawnListRefs = new Object();
         this.spawnListRefs["ground"] = this.activeLevelLayoutData.getBlockList("ground","spawnPoints");
         this.spawnListRefs["air"] = this.activeLevelLayoutData.getBlockList("air","spawnPoints");
         this.initGame(frameRate);
         addEventListener(Event.REMOVED_FROM_STAGE,this.dispose,false,0,true);
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.playMusic("GameLoop");
      }
      
      public function dispose(event:Event) : void
      {
         this.ticker.pause();
         this.groundGrid.dispose();
         this.airGrid.dispose();
         this.projectileCollector.dispose();
         this.clearPauseGraphic();
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
      
      protected function initGame(frameRate:Number) : void
      {
         this.ticker = new TimeTicker(this,frameRate);
         this.gameStats = new GameStats(this.activeLevelConfig.gameStats);
         this.initGrids();
         this.initPathManagers();
         this.initProjectileCollector();
         this.initCreepCollectors();
         this.initTowerCollector();
         this.initWaveController();
         this.initGameUserInterface();
         this.gameStats.registerSimpleEvent("updateCashDisplay",new Callback(this.gameUI,this.gameUI.updateCashDisplay));
         this.gameStats.registerSimpleEvent("updateScoreDisplay",new Callback(this.gameUI,this.gameUI.updateScoreDisplay));
         this.gameStats.registerSimpleEvent("onGameOver",new Callback(this,this.onGameOver));
         this.gameStats.initialize();
         this.ticker.registerSimpleEvent("update",new Callback(this,this.updateEvent));
         this.attachDisplays();
      }
      
      protected function onGameOver() : void
      {
         this.waveController.removeEvents();
         this.projectileCollector.removeTrackingProjectiles();
         this.ticker.clearSimpleEvent("update");
         this.ticker.registerSimpleEvent("update",new Callback(this.projectileCollector,this.projectileCollector.update));
         this.gameUI.disable();
         this.gameUI.hideGridUI();
         this.setGameOverAnimation();
         this.ticker.addQueuedFunction(new Callback(this,this.dispatchSimpleEvent,["onGameOver",[this.gameStats.getCurrentScore()]]),this.gameOverDelayFrames);
      }
      
      protected function setGameOverAnimation() : void
      {
         var point:GPoint = null;
         var baseClip:MovieClip = null;
         var explodePoint:GPoint = null;
         var goalList:Array = this.activeLevelLayoutData.getBlockList("ground","goalPoints");
         for each(point in goalList)
         {
            baseClip = this.groundGrid.getAttachedObject(point);
            baseClip.base.stop();
            if(this.gameStats.getBaseHitPoints(goalList.indexOf(point)) == 0)
            {
               explodePoint = new GPoint(baseClip.x + baseClip.width / 2,baseClip.y + baseClip.height / 2);
               this.projectileCollector.setBaseExplosion(explodePoint,this.ticker);
               baseClip.play();
            }
         }
      }
      
      protected function updateEvent(ticker:TimeTicker) : *
      {
         this.groundCreepCollector.update(ticker);
         this.airCreepCollector.update(ticker);
         this.towerCollector.update(ticker);
         this.projectileCollector.update(ticker);
      }
      
      protected function initGrids() : void
      {
         var statusIndicator:BaseStatusIndicator = null;
         var point:GPoint = null;
         var targetClip:MovieClip = null;
         var statusLoc:GPoint = null;
         this.groundGrid = new GameGrid(this.gridWidth,this.gridHeight,this.tileSize,this.bmpArchive,[""],this.themes[this.activeLevelConfig.theme].groundGridConfig);
         this.groundGrid.opaqueBackground = 16777215;
         var terrainBMD:BitmapData = this.bmpArchive.getBitmapData(this.themes[this.activeLevelConfig.theme].terrain);
         this.groundGrid.drawToBg(new GPoint(),terrainBMD,terrainBMD.rect);
         this.groundGrid.drawGrid(this.activeLevelLayoutData.getBlockRefs("ground","blockPoints"));
         this.airGrid = new GameGrid(this.gridWidth,this.gridHeight,this.tileSize,this.bmpArchive,[""],this.themes[this.activeLevelConfig.theme].airGridConfig);
         this.airGrid.drawGrid(this.activeLevelLayoutData.getBlockRefs("air","blockPoints"));
         var airGridBMD:BitmapData = this.airGrid.getBgBMD();
         this.groundGrid.drawToBg(new GPoint(),airGridBMD,airGridBMD.rect);
         var goalList:Array = this.activeLevelLayoutData.getBlockList("ground","goalPoints");
         this.baseStatusIndicators = new Array();
         for each(point in goalList)
         {
            targetClip = new GridTarget();
            this.groundGrid.attachGridObject(point,targetClip);
            statusIndicator = new BaseStatusIndicator();
            this.baseStatusIndicators.push(statusIndicator);
            statusLoc = this.groundGrid.gridToScreenLoc(point);
            statusIndicator.x = statusLoc.x;
            statusIndicator.y = statusLoc.y;
            this.gameStats.setBaseStatusIndicator(statusIndicator);
         }
      }
      
      protected function initPathManagers() : void
      {
         this.groundPathManager = new PathManager(this.groundGrid.validatePoint,this.groundGrid.getTileCost);
         this.generateGroundPathing();
         this.airPathManager = new PathManager(this.airGrid.validatePoint,this.airGrid.getTileCost);
         this.generateAirPathing();
      }
      
      protected function initCreepCollectors() : void
      {
         this.groundCreepCollector = new CreepCollector(this.groundGrid,"ground");
         this.groundCreepCollector.registerSimpleEvent("getConnectionPoints",new Callback(this.groundPathManager,this.groundPathManager.getConnectionPoints));
         this.groundCreepCollector.registerSimpleEvent("checkIfGoalPoint",new Callback(this.groundPathManager,this.groundPathManager.checkIfGoalPoint));
         this.groundCreepCollector.registerSimpleEvent("onWaveComplete",new Callback(this,this.onWaveComplete));
         this.groundCreepCollector.registerSimpleEvent("getLowestCostForPoint",new Callback(this.groundPathManager,this.groundPathManager.getLowestCostForPoint));
         this.groundCreepCollector.registerSimpleEvent("creepReachedGoal",new Callback(this,this.onBasedDamaged));
         this.groundCreepCollector.registerSimpleEvent("creepKilled",new Callback(this.gameStats,this.gameStats.onCreepKilled));
         this.groundCreepCollector.registerSimpleEvent("setCreepExplosion",new Callback(this,this.onSetGroundCreepExplosion));
         this.groundCreepCollector.initialize(this.spawnListRefs["ground"]);
         this.airCreepCollector = new CreepCollector(this.airGrid,"air");
         this.airCreepCollector.registerSimpleEvent("getConnectionPoints",new Callback(this.airPathManager,this.airPathManager.getConnectionPoints));
         this.airCreepCollector.registerSimpleEvent("checkIfGoalPoint",new Callback(this.airPathManager,this.airPathManager.checkIfGoalPoint));
         this.airCreepCollector.registerSimpleEvent("onWaveComplete",new Callback(this,this.onWaveComplete));
         this.airCreepCollector.registerSimpleEvent("getLowestCostForPoint",new Callback(this.airPathManager,this.airPathManager.getLowestCostForPoint));
         this.airCreepCollector.registerSimpleEvent("creepReachedGoal",new Callback(this,this.onBasedDamaged));
         this.airCreepCollector.registerSimpleEvent("creepKilled",new Callback(this.gameStats,this.gameStats.onCreepKilled));
         this.airCreepCollector.registerSimpleEvent("setCreepExplosion",new Callback(this.projectileCollector,this.projectileCollector.setCreepExplosion));
         this.airCreepCollector.initialize(this.spawnListRefs["air"]);
         var shadow:DropShadowFilter = new DropShadowFilter();
         shadow.distance = 10;
         shadow.angle = 45;
         shadow.quality = 1;
         shadow.alpha = 0.25;
         shadow.blurX = 1;
         shadow.blurY = 1;
         this.airCreepCollector.filters = [shadow];
      }
      
      protected function onBasedDamaged(creep:Creep) : void
      {
         var point:GPoint = null;
         var damageLoc:GPoint = creep.getCurrentLocation();
         var goalList:Array = this.activeLevelLayoutData.getBlockList("ground","goalPoints");
         for each(point in goalList)
         {
            if(Math.abs(point.x - damageLoc.x) <= 2 || Math.abs(point.y - damageLoc.y) <= 2)
            {
               this.gameStats.onBaseDamaged(goalList.indexOf(point),creep.getDamageMultiplier());
            }
         }
      }
      
      protected function onSetGroundCreepExplosion(point:GPoint) : void
      {
         var drawBMD:BitmapData = this.bmpArchive.getBitmapData(ArrayHelper.getRandomElement(["crater_1","crater_2","crater_3"]));
         var drawPoint:GPoint = point.cloneMe();
         drawPoint.x -= drawBMD.width / 2;
         drawPoint.y -= drawBMD.height / 2;
         this.groundGrid.drawToBg(drawPoint,drawBMD,drawBMD.rect);
         this.projectileCollector.setCreepExplosion(point);
      }
      
      protected function initProjectileCollector() : void
      {
         this.projectileCollector = new ProjectileCollector(this.groundGrid.width,this.groundGrid.height,this.bmpArchive,this.generalConfig.projectileCollector);
         this.projectileCollector.registerSimpleEvent("getTargets",new Callback(this,this.getTargets));
         this.projectileCollector.registerSimpleEvent("checkForImpact",new Callback(this,this.checkForImpact));
      }
      
      protected function initTowerCollector() : void
      {
         this.towerCollector = new TowerCollector(this.groundGrid);
         this.towerCollector.registerSimpleEvent("getTargets",new Callback(this,this.getTargets));
         this.towerCollector.registerSimpleEvent("fireShot",new Callback(this.projectileCollector,this.projectileCollector.fireProjectile));
         this.towerCollector.registerSimpleEvent("getProjectileParamsObj",new Callback(this.projectileCollector,this.projectileCollector.getProjectileParamsObj));
      }
      
      protected function getTargets(targeting:String, validateFunct:Function = null, limit:Number = Infinity) : Array
      {
         var possibleTargets:Array = new Array();
         if(targeting == "ground" || targeting == "all")
         {
            possibleTargets = this.groundCreepCollector.collectTargets(possibleTargets,validateFunct,limit);
         }
         if(targeting == "air" || targeting == "all")
         {
            possibleTargets = this.airCreepCollector.collectTargets(possibleTargets,validateFunct,limit);
         }
         if(possibleTargets.length > 0)
         {
            return possibleTargets;
         }
         return null;
      }
      
      protected function checkForImpact(targeting:String, checkPoint:GPoint) : *
      {
         this.tempPoint.x = checkPoint.x;
         this.tempPoint.y = checkPoint.y;
         var gridLoc:GPoint = this.groundGrid.screenToGridLoc(this.tempPoint,true);
         if(!this.groundGrid.checkPointInGrid(gridLoc))
         {
            return false;
         }
         if(targeting == "ground" || targeting == "all")
         {
            if(this.groundGrid.checkLocked(gridLoc))
            {
               return true;
            }
         }
         if(targeting == "air" || targeting == "all")
         {
            if(this.airGrid.checkLocked(gridLoc))
            {
               return true;
            }
         }
         return false;
      }
      
      protected function initWaveController() : void
      {
         var dispatcher:SimpleDispatcher = new SimpleDispatcher();
         dispatcher.registerSimpleEvent("sendWave",new Callback(this,this.onSendWave));
         this.waveController = new WaveController(dispatcher,this.creepTypeRefs,this.activeLevelConfig.introWaveList,this.activeLevelConfig.waveList,this.ticker);
         this.waveController.setWaveTimer(this.gameStats.getWaveWaitTime(this.waveController.getCurrentWaveObj(),this.waveController.getCurrentWave()));
      }
      
      protected function onSendWave(waveObj:Object, waveNum:Number) : *
      {
         var waveType:String = waveObj.type;
         var collector:CreepCollector = this[waveObj.type + "CreepCollector"];
         var interval:Number = this.gameStats.getSpawnInterval();
         var creepsToSpawn:Number = this.gameStats.getSpawnCount(waveObj,waveNum);
         var creepConfig:Object = this.gameStats.getCreepConfig(waveObj,waveNum);
         collector.setSpawn(creepsToSpawn,interval,creepConfig);
      }
      
      protected function onWaveComplete() : void
      {
         this.waveController.setWaveTimer(this.gameStats.getWaveWaitTime(this.waveController.getCurrentWaveObj(),this.waveController.getCurrentWave()));
      }
      
      protected function generateGroundPathing() : Boolean
      {
         var reqList:Array = this.groundGrid.getLockedPoints();
         reqList = reqList.concat(this.spawnListRefs["ground"],this.goalListRefs["ground"]);
         var generationSuccess:Boolean = this.groundPathManager.generatePathing(this.goalListRefs["ground"],reqList);
         if(this.groundCreepCollector != null)
         {
            this.groundCreepCollector.clearCachedMoves();
         }
         return generationSuccess;
      }
      
      protected function generateAirPathing() : Boolean
      {
         return this.airPathManager.generatePathing(this.goalListRefs["air"],[]);
      }
      
      protected function initGameUserInterface() : void
      {
         var gridUI:GridUI = new GridUI(this.groundGrid,this.towerLimit);
         gridUI.registerSimpleEvent("generatePathing",new Callback(this,this.generateGroundPathing));
         gridUI.registerSimpleEvent("placeTower",new Callback(this.towerCollector,this.towerCollector.placeTower));
         gridUI.registerSimpleEvent("removeTower",new Callback(this.towerCollector,this.towerCollector.removeTower));
         gridUI.registerSimpleEvent("getTargets",new Callback(this,this.getTargets));
         gridUI.registerSimpleEvent("setBomb",new Callback(this.projectileCollector,this.projectileCollector.setBomb));
         gridUI.registerSimpleEvent("setRemoveExplosion",new Callback(this.projectileCollector,this.projectileCollector.setCreepExplosion));
         gridUI.x -= this.tileSize;
         gridUI.y -= this.tileSize;
         this.gameUI = new GameUI(gridUI,this.generalConfig.gameUI,this.waveController,this.groundOnly);
         this.gameUI.registerSimpleEvent("getProjectileParamsObj",new Callback(this.projectileCollector,this.projectileCollector.getProjectileParamsObj));
         this.gameUI.registerSimpleEvent("checkIfEnoughCash",new Callback(this.gameStats,this.gameStats.checkIfEnoughCash));
         this.gameUI.registerSimpleEvent("subtractCash",new Callback(this.gameStats,this.gameStats.subtractCash));
         this.gameUI.registerSimpleEvent("addCash",new Callback(this.gameStats,this.gameStats.addCash));
         this.gameUI.registerSimpleEvent("getBombParams",new Callback(this.projectileCollector,this.projectileCollector.getProjectileParamsObj));
         GridSelectableItem.setCashValueMultiplier(this.gameStats.getCashValueMultiplier());
      }
      
      protected function attachDisplays() : void
      {
         var statusIndicator:BaseStatusIndicator = null;
         this.gamePlayClip = new MovieClip();
         this.gamePlayClip.x = -this.tileSize;
         this.gamePlayClip.y = -this.tileSize;
         this.gamePlayClip.addChild(this.groundGrid);
         this.gamePlayClip.addChild(this.towerCollector);
         this.gamePlayClip.addChild(this.groundCreepCollector);
         for each(statusIndicator in this.baseStatusIndicators)
         {
            this.gamePlayClip.addChild(statusIndicator);
         }
         this.gamePlayClip.addChild(this.airCreepCollector);
         this.gamePlayClip.addChild(this.projectileCollector);
         addChild(this.gamePlayClip);
         addChild(this.gameUI);
      }
      
      public function pause() : void
      {
         var point:GPoint = null;
         var baseClip:MovieClip = null;
         this.waveController.pause();
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.pause();
         mouseChildren = false;
         mouseEnabled = false;
         this.ticker.pause();
         if(!this.gameStats.gameIsOver())
         {
            this.gameUI.disable();
         }
         var goalList:Array = this.activeLevelLayoutData.getBlockList("ground","goalPoints");
         for each(point in goalList)
         {
            baseClip = this.groundGrid.getAttachedObject(point);
            baseClip.base.stop();
         }
      }
      
      protected function createPauseGraphic() : void
      {
         var pauseBMD:BitmapData = this.bmpArchive.getBitmapData("pauseImage");
         if(pauseBMD != null)
         {
            this.bmpArchive.dispose("pauseImage");
         }
         pauseBMD = new BitmapData(width,height);
         pauseBMD.draw(this);
         this.bmpArchive.setBitmapData("pauseImage",pauseBMD);
         this.addChild(this.bmpArchive.getBitmap("pauseImage"));
         this.gamePlayClip.visible = false;
      }
      
      protected function clearPauseGraphic() : void
      {
         this.gamePlayClip.visible = true;
         var pauseBMD:BitmapData = this.bmpArchive.getBitmapData("pauseImage");
         if(pauseBMD != null)
         {
            if(contains(this.bmpArchive.getBitmap("pauseImage")))
            {
               removeChild(this.bmpArchive.getBitmap("pauseImage"));
            }
            this.bmpArchive.dispose("pauseImage");
         }
      }
      
      public function unpause() : void
      {
         var goalList:Array = null;
         var point:GPoint = null;
         var baseClip:MovieClip = null;
         this.waveController.unpause();
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.unpause();
         mouseChildren = true;
         mouseEnabled = true;
         this.ticker.unpause();
         if(!this.gameStats.gameIsOver())
         {
            this.gameUI.enable();
         }
         if(!this.gameStats.gameIsOver())
         {
            goalList = this.activeLevelLayoutData.getBlockList("ground","goalPoints");
            for each(point in goalList)
            {
               baseClip = this.groundGrid.getAttachedObject(point);
               baseClip.base.play();
            }
         }
      }
   }
}

