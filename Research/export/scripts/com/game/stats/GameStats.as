package com.game.stats
{
   import com.game.ai.creeps.Creep;
   import com.jgp.functions.SimpleDispatcher;
   
   public class GameStats extends SimpleDispatcher
   {
      
      protected var baseInitialHitPoints:Number;
      
      protected var baseCurrentHitPoints:Array;
      
      protected var creepInitialHitPoints:Number;
      
      protected var creepCurrentHitPoints:Number;
      
      protected var initHpWaveIncrease:Number;
      
      protected var currentHpWaveIncrease:Number;
      
      protected var hpWaveIncreaseMultiplier:Number;
      
      protected var initSpawnCount:Number;
      
      protected var toSpawnCount:Number;
      
      protected var maxSpawnCount:Number;
      
      protected var spawnWaveMultiplier:Number;
      
      protected var creepInsertInterval:Number;
      
      protected var timeUntilFirstWave:Number;
      
      protected var waveWaitTime:Number;
      
      protected var currentCash:Number = 0;
      
      protected var initialCash:Number;
      
      protected var cashWaveIncrease:Number;
      
      protected var initCashPerKill:Number;
      
      protected var cashValueMultiplier:Number;
      
      protected var speedMultiplier:Number = 1;
      
      protected var hpMultiplier:Number = 1;
      
      protected var insertIntervalMultiplier:Number = 1;
      
      protected var waitTimerMultiplier:Number = 1;
      
      protected var currentScore:Number;
      
      protected var initKillPoints:Number;
      
      protected var killWaveIncrease:Number;
      
      protected var baseStatusIndicators:Array;
      
      public function GameStats(paramObj:Object)
      {
         super();
         this.applyParamObject(paramObj);
         this.baseCurrentHitPoints = new Array();
         this.baseStatusIndicators = new Array();
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
      
      public function initialize() : void
      {
         this.currentHpWaveIncrease = this.initHpWaveIncrease;
         this.creepCurrentHitPoints = this.creepInitialHitPoints;
         this.currentScore = 0;
         this.toSpawnCount = this.initSpawnCount;
         this.addCash(this.initialCash);
      }
      
      public function setBaseStatusIndicator(statusIndicator:BaseStatusIndicator) : void
      {
         this.baseCurrentHitPoints.push(this.baseInitialHitPoints);
         this.baseStatusIndicators.push(statusIndicator);
      }
      
      public function onBaseDamaged(baseIndex:Number, damageMutli:Number) : void
      {
         this.baseCurrentHitPoints[baseIndex] -= Math.round(damageMutli);
         if(this.baseCurrentHitPoints[baseIndex] < 0)
         {
            this.baseCurrentHitPoints[baseIndex] = 0;
         }
         var baseStatusIndicator:BaseStatusIndicator = this.baseStatusIndicators[baseIndex];
         baseStatusIndicator.setHealth(this.baseCurrentHitPoints[baseIndex],this.baseInitialHitPoints);
         if(this.gameIsOver())
         {
            this.onGameOver();
         }
      }
      
      public function getBaseHitPoints(baseIndex:Number) : Number
      {
         return this.baseCurrentHitPoints[baseIndex];
      }
      
      public function onGameOver() : void
      {
         dispatchSimpleEvent("onGameOver");
      }
      
      public function gameIsOver() : Boolean
      {
         var hitPoints:Number = NaN;
         for each(hitPoints in this.baseCurrentHitPoints)
         {
            if(hitPoints == 0)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getCreepConfig(waveObj:Object, waveNum:Number) : Object
      {
         this.currentHpWaveIncrease *= this.hpWaveIncreaseMultiplier;
         this.creepCurrentHitPoints += this.currentHpWaveIncrease;
         var creepConfig:Object = {
            "hitPoints":this.creepCurrentHitPoints * waveObj.hpMultiplier * this.hpMultiplier,
            "speed":waveObj.creepSpeed * this.speedMultiplier,
            "waveSpawned":waveNum
         };
         if(waveObj.damageMultiplier != null)
         {
            creepConfig.damageMultiplier = waveObj.damageMultiplier;
         }
         if(waveObj.bonusMultiplier != null)
         {
            creepConfig.bonusMultiplier = waveObj.bonusMultiplier;
         }
         if(waveObj.skinName != null)
         {
            creepConfig.skinName = waveObj.skinName;
         }
         return creepConfig;
      }
      
      public function getSpawnCount(waveObj:Object, waveNum:Number) : Number
      {
         this.toSpawnCount *= this.spawnWaveMultiplier;
         if(this.toSpawnCount > this.maxSpawnCount)
         {
            this.toSpawnCount = this.maxSpawnCount;
         }
         var creepsToSpawn:Number = Math.ceil(this.toSpawnCount * waveObj.spawnRatio);
         if(creepsToSpawn < 1)
         {
            creepsToSpawn = 1;
         }
         return creepsToSpawn;
      }
      
      public function getWaveWaitTime(waveObj:Object, waveNum:Number) : Number
      {
         if(waveNum == 0)
         {
            return this.timeUntilFirstWave;
         }
         if(waveObj.timeOverride != null)
         {
            return waveObj.timeOverride * this.waitTimerMultiplier;
         }
         return this.waveWaitTime * this.waitTimerMultiplier;
      }
      
      public function getSpawnInterval() : Number
      {
         return Math.round(this.creepInsertInterval * this.insertIntervalMultiplier);
      }
      
      public function onCreepKilled(creep:Creep) : void
      {
         var bonusMulti:Number = creep.getBonusMultiplier();
         var waveNum:Number = creep.getWaveSpawned();
         var cashToAdd:Number = Math.round((this.initCashPerKill + Math.floor(waveNum * this.cashWaveIncrease)) * bonusMulti);
         this.addCash(cashToAdd);
         this.addToScore(Math.round((this.initKillPoints + (waveNum - 1) * this.killWaveIncrease) * bonusMulti));
      }
      
      public function addToScore(addVal:Number) : *
      {
         if(!this.gameIsOver())
         {
            this.currentScore += addVal;
            dispatchSimpleEvent("updateScoreDisplay",[this.currentScore]);
         }
      }
      
      public function addCash(cashAmmount:Number) : void
      {
         if(!this.gameIsOver())
         {
            this.currentCash += cashAmmount;
            dispatchSimpleEvent("updateCashDisplay",[this.currentCash]);
         }
      }
      
      public function subtractCash(cashAmmount:Number) : void
      {
         this.currentCash -= cashAmmount;
         dispatchSimpleEvent("updateCashDisplay",[this.currentCash]);
      }
      
      public function checkIfEnoughCash(cashAmmount:Number) : Boolean
      {
         return this.currentCash >= cashAmmount;
      }
      
      public function getCurrentScore() : Number
      {
         return this.currentScore;
      }
      
      public function getCashValueMultiplier() : Number
      {
         return this.cashValueMultiplier;
      }
   }
}

