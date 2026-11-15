package com.game.ai.creeps
{
   import com.game.grid.*;
   import com.game.stats.CreepStatusIndicator;
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.helpers.ArrayHelper;
   import com.jgp.math.geom.GPoint;
   import com.jgp.utils.TimeTicker;
   import flash.display.Sprite;
   import flash.events.*;
   
   public class CreepCollector extends Sprite
   {
      
      protected var gridRef:GameGrid;
      
      protected var activeCreeps:Array;
      
      protected var creepDispatcher:SimpleDispatcher;
      
      protected var creepDisplayLayer:Sprite;
      
      protected var overlayDisplayLayer:Sprite;
      
      protected var spawnPoints:Array;
      
      protected var spawnInterval:Number;
      
      protected var toSpawn:Number = 0;
      
      protected var lastSpawnedAt:Number = -Infinity;
      
      protected var creepConfig:Object;
      
      protected var worldLayer:String;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function CreepCollector(gridRef:GameGrid, worldLayer:String)
      {
         super();
         this.worldLayer = worldLayer;
         this.gridRef = gridRef;
         SimpleDispatcher.initialize(this);
      }
      
      public function initialize(spawnPoints:Array) : void
      {
         this.spawnPoints = spawnPoints;
         this.setCreepDispatcher();
         this.activeCreeps = new Array();
         this.creepDisplayLayer = new Sprite();
         addChild(this.creepDisplayLayer);
         this.overlayDisplayLayer = new Sprite();
         addChild(this.overlayDisplayLayer);
      }
      
      public function update(ticker:TimeTicker) : void
      {
         var creep:Creep = null;
         for each(creep in this.activeCreeps)
         {
            creep.update(ticker);
         }
         this.updateSpawnTimer(ticker);
         this.activeCreeps.sortOn("currentPointCost",Array.NUMERIC);
      }
      
      protected function getNextMove(creep:Creep) : Array
      {
         return this.dispatchSimpleEvent("getConnectionPoints",[creep.getCurrentLocation(),this.validatePossibleMove]);
      }
      
      protected function getStepsToGoal(creep:Creep) : Number
      {
         return this.dispatchSimpleEvent("getLowestCostForPoint",[creep.getCurrentLocation()]);
      }
      
      protected function validatePossibleMove(point:GPoint, connectPoint:GPoint) : Boolean
      {
         return !this.gridRef.checkLocked(connectPoint) && !this.gridRef.checkIfCornerCut(point,connectPoint,this.gridRef.checkLocked);
      }
      
      protected function checkIfFinalMovement(creep:Creep) : Boolean
      {
         return this.dispatchSimpleEvent("checkIfGoalPoint",[creep.getCurrentLocation()]);
      }
      
      public function setSpawn(spawnCount:Number, interval:Number, creepConfig:Object) : void
      {
         this.spawnInterval = interval;
         this.toSpawn = spawnCount;
         creepConfig.worldLayer = this.worldLayer;
         this.creepConfig = creepConfig;
      }
      
      protected function updateSpawnTimer(ticker:TimeTicker) : void
      {
         var spawnSuccess:Boolean = false;
         if(this.toSpawn > 0)
         {
            if(ticker.getTime() - this.spawnInterval > this.lastSpawnedAt)
            {
               spawnSuccess = this.spawnCreep();
               if(spawnSuccess)
               {
                  --this.toSpawn;
               }
               this.lastSpawnedAt = ticker.getTime();
               if(this.toSpawn == 0)
               {
                  this.dispatchSimpleEvent("onWaveComplete");
               }
            }
         }
      }
      
      protected function setCreepDispatcher() : void
      {
         this.creepDispatcher = new SimpleDispatcher();
         this.creepDispatcher.registerSimpleEvent("getNextMove",new Callback(this,this.getNextMove));
         this.creepDispatcher.registerSimpleEvent("checkIfFinalMovement",new Callback(this,this.checkIfFinalMovement));
         this.creepDispatcher.registerSimpleEvent("reachedGoal",new Callback(this,this.creepReachedGoal));
         this.creepDispatcher.registerSimpleEvent("creepKilled",new Callback(this,this.creepKilled));
         this.creepDispatcher.registerSimpleEvent("getStepsToGoal",new Callback(this,this.getStepsToGoal));
      }
      
      public function spawnCreep() : Boolean
      {
         var spawnPoint:GPoint = null;
         var creep:Creep = null;
         var statusIndicator:CreepStatusIndicator = null;
         var possibleSpawnPoints:Array = ArrayHelper.jumbleElements(this.spawnPoints);
         for each(spawnPoint in possibleSpawnPoints)
         {
            if(!this.gridRef.checkLocked(spawnPoint))
            {
               statusIndicator = new CreepStatusIndicator();
               creep = new Creep(this.gridRef,spawnPoint,this.creepConfig,statusIndicator,this.creepDispatcher,this.validatePossibleMove);
               this.overlayDisplayLayer.addChild(statusIndicator);
               this.activeCreeps.push(creep);
               this.creepDisplayLayer.addChild(creep);
               return true;
            }
         }
         return false;
      }
      
      protected function removeStatusIndicator(statusIndicator:CreepStatusIndicator) : void
      {
         this.overlayDisplayLayer.removeChild(statusIndicator);
      }
      
      public function collectTargets(appendList:Array, validateFunct:Function = null, limit:Number = Infinity) : Array
      {
         var collectCount:Number = NaN;
         var creep:Creep = null;
         if(validateFunct != null)
         {
            collectCount = 0;
            for each(creep in this.activeCreeps)
            {
               if(validateFunct(creep))
               {
                  appendList.push(creep);
                  collectCount++;
                  if(collectCount == limit)
                  {
                     return appendList;
                  }
               }
            }
            return appendList;
         }
         return appendList.concat(this.activeCreeps);
      }
      
      protected function creepReachedGoal(creep:Creep) : void
      {
         var screenLoc:GPoint = creep.getScreenCenterLocation();
         this.dispatchSimpleEvent("setCreepExplosion",[screenLoc]);
         this.removeCreep(creep);
         this.dispatchSimpleEvent("creepReachedGoal",[creep]);
      }
      
      public function clearCachedMoves() : void
      {
         var creep:Creep = null;
         for each(creep in this.activeCreeps)
         {
            creep.clearMoveList();
         }
      }
      
      protected function creepKilled(creep:Creep) : void
      {
         this.removeCreep(creep);
         this.dispatchSimpleEvent("setCreepExplosion",[creep.getScreenCenterLocation()]);
         this.dispatchSimpleEvent("creepKilled",[creep]);
      }
      
      protected function removeCreep(creep:Creep) : void
      {
         this.removeStatusIndicator(creep.getStatusIndicator());
         var removeIndex:Number = this.activeCreeps.indexOf(creep);
         this.activeCreeps.splice(removeIndex,1);
         if(this.creepDisplayLayer.contains(creep))
         {
            this.creepDisplayLayer.removeChild(creep);
         }
      }
   }
}

