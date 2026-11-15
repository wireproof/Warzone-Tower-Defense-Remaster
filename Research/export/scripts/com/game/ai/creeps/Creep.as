package com.game.ai.creeps
{
   import com.game.grid.GameGrid;
   import com.game.stats.CreepStatusIndicator;
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.math.geom.GPoint;
   import com.jgp.math.geom.GVector;
   import com.jgp.utils.TimeTicker;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.utils.getDefinitionByName;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol671")]
   public class Creep extends Sprite
   {
      
      public var bg:MovieClip;
      
      protected var gridRef:GameGrid;
      
      protected var currentLocation:GPoint;
      
      protected var screenLocation:GPoint;
      
      protected var screenCenterLocation:GPoint;
      
      protected var moveToLocation:GPoint;
      
      protected var moveToScreenLocation:GPoint;
      
      protected var moveFromScreenLocation:GPoint;
      
      protected var speed:Number;
      
      protected var currentSpeed:Number;
      
      protected var skinName:String = "creep_test";
      
      protected var creepSkin:MovieClip;
      
      protected var bgWidth:Number;
      
      protected var bgHeight:Number;
      
      protected var toMoveDistance:Number;
      
      protected var movedDistance:Number = 0;
      
      protected var moveVector:GVector;
      
      protected var altPath:Object;
      
      protected var removed:Boolean = false;
      
      protected var initHitPoints:Number;
      
      protected var hitPoints:Number = 0;
      
      protected var statusIndicator:CreepStatusIndicator;
      
      protected var lastUpdateTime:Number;
      
      protected var slowUntilTime:Number = -1;
      
      protected var waveSpawned:Number;
      
      protected var validateMoveFunct:Function;
      
      protected var moveList:Array;
      
      protected var worldLayer:String;
      
      protected var bonusMultiplier:Number = 1;
      
      protected var damageMultiplier:Number = 1;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function Creep(gridRef:GameGrid, initPoint:GPoint, creepConfig:Object, statusIndicator:CreepStatusIndicator, dispatcher:SimpleDispatcher, validateMoveFunct:Function)
      {
         super();
         SimpleDispatcher.initialize(this,dispatcher);
         this.applyParamObject(creepConfig);
         this.gridRef = gridRef;
         this.statusIndicator = statusIndicator;
         this.validateMoveFunct = validateMoveFunct;
         this.currentSpeed = this.speed;
         this.currentLocation = initPoint.cloneMe();
         this.screenLocation = gridRef.gridToScreenLoc(this.currentLocation);
         this.screenCenterLocation = new GPoint();
         this.updateScreenCenterLocation();
         this.initHitPoints = this.hitPoints;
         this.moveVector = new GVector(0,0);
         gridRef.getTile(this.currentLocation).lock();
         this.setCreepSkin();
         this.update();
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
      
      protected function setCreepSkin() : void
      {
         var skinClass:Class = getDefinitionByName(this.skinName) as Class;
         this.creepSkin = new skinClass();
         this.bgWidth = Math.round(this.bg.width / 2);
         this.bgHeight = Math.round(this.bg.height / 2);
         this.creepSkin.x = this.bgWidth;
         this.creepSkin.y = this.bgHeight;
         addChild(this.creepSkin);
      }
      
      protected function setNextMove() : Boolean
      {
         if(this.moveList == null)
         {
            this.moveList = this.dispatchSimpleEvent("getNextMove",[this]);
         }
         if(this.moveList.length == 0)
         {
            this.moveList = this.dispatchSimpleEvent("getNextMove",[this]);
         }
         var nextMove:GPoint = this.moveList.shift().point;
         if(!GPoint.checkEquality(this.currentLocation,nextMove))
         {
            if(this.validateMoveFunct(this.currentLocation,nextMove))
            {
               this.setNextMovement(nextMove);
               return true;
            }
         }
         this.clearMoveList();
         return false;
      }
      
      public function setNextMovement(nextMove:GPoint) : void
      {
         this.moveToLocation = nextMove;
         this.moveToScreenLocation = this.gridRef.gridToScreenLoc(this.moveToLocation);
         this.moveFromScreenLocation = this.gridRef.gridToScreenLoc(this.currentLocation);
         this.gridRef.getTile(this.moveToLocation).lock();
         this.toMoveDistance = GPoint.getDistance(this.screenLocation,this.moveToScreenLocation);
         var angleObj:Object = GPoint.getAngle(this.screenLocation,this.moveToScreenLocation);
         this.moveVector = GVector.getAngularUnitVector(angleObj.radians);
         this.creepSkin.rotation = angleObj.degrees;
      }
      
      public function clearMoveList() : void
      {
         this.moveList = null;
      }
      
      public function update(ticker:TimeTicker = null) : void
      {
         if(this.moveToLocation != null)
         {
            this.movedDistance += this.currentSpeed;
         }
         this.updateMovement();
         x = this.screenLocation.x;
         y = this.screenLocation.y;
         this.statusIndicator.x = x;
         this.statusIndicator.y = y;
         if(ticker != null)
         {
            this.updateTimings(ticker);
         }
      }
      
      protected function updateTimings(ticker:TimeTicker) : void
      {
         this.lastUpdateTime = ticker.getTime();
         if(this.currentSpeed < this.speed)
         {
            if(this.slowUntilTime <= this.lastUpdateTime)
            {
               this.clearSlowDown();
            }
         }
      }
      
      protected function updateMovement() : void
      {
         var moveCompleted:Boolean = false;
         if(this.moveToLocation == null)
         {
            this.setNextMove();
         }
         if(this.moveToLocation != null)
         {
            moveCompleted = this.updateLineMovement();
            if(moveCompleted)
            {
               this.onMovementCompleted();
            }
         }
      }
      
      protected function updateLineMovement() : Boolean
      {
         var linePos:Number = this.movedDistance;
         if(linePos > this.toMoveDistance)
         {
            linePos = this.toMoveDistance;
         }
         this.screenLocation.x = this.moveFromScreenLocation.x + this.moveVector.x * linePos;
         this.screenLocation.y = this.moveFromScreenLocation.y + this.moveVector.y * linePos;
         this.updateScreenCenterLocation();
         if(this.movedDistance >= this.toMoveDistance)
         {
            this.movedDistance -= this.toMoveDistance;
            return true;
         }
         return false;
      }
      
      protected function updateScreenCenterLocation() : void
      {
         this.screenCenterLocation.x = this.screenLocation.x + this.bgWidth;
         this.screenCenterLocation.y = this.screenLocation.y + this.bgHeight;
      }
      
      protected function onMovementCompleted() : void
      {
         this.gridRef.getTile(this.currentLocation).unlock();
         this.currentLocation.x = this.moveToLocation.x;
         this.currentLocation.y = this.moveToLocation.y;
         this.moveToLocation = null;
         var isFinalLocation:Boolean = this.dispatchSimpleEvent("checkIfFinalMovement",[this]);
         if(!isFinalLocation)
         {
            this.updateMovement();
         }
         else
         {
            this.removed = true;
            this.gridRef.getTile(this.currentLocation).unlock();
            this.dispatchSimpleEvent("reachedGoal",[this]);
         }
      }
      
      public function applyDamage(damage:Number) : Boolean
      {
         this.hitPoints -= damage;
         this.statusIndicator.setHealth(this.hitPoints,this.initHitPoints);
         if(this.hitPoints <= 0)
         {
            this.removed = true;
            this.gridRef.getTile(this.currentLocation).unlock();
            if(this.moveToLocation != null)
            {
               this.gridRef.getTile(this.moveToLocation).unlock();
            }
            this.dispatchSimpleEvent("creepKilled",[this]);
            return true;
         }
         return false;
      }
      
      public function setSlowDown(slowRatio:Number, slowForTime:Number) : void
      {
         this.currentSpeed = this.speed * slowRatio;
         this.slowUntilTime = this.lastUpdateTime + slowForTime;
         var cT:ColorTransform = this.transform.colorTransform;
         cT.redOffset = 30;
         cT.blueOffset = 100;
         cT.greenOffset = 30;
         this.transform.colorTransform = cT;
      }
      
      protected function clearSlowDown() : void
      {
         this.slowUntilTime = -1;
         this.currentSpeed = this.speed;
         var cT:ColorTransform = this.transform.colorTransform;
         cT.redOffset = 0;
         cT.blueOffset = 0;
         cT.greenOffset = 0;
         this.transform.colorTransform = cT;
      }
      
      public function getCurrentLocation() : GPoint
      {
         return this.currentLocation;
      }
      
      public function getScreenLocation() : GPoint
      {
         return this.screenLocation;
      }
      
      public function getScreenCenterLocation() : GPoint
      {
         return this.screenCenterLocation;
      }
      
      public function checkPointInBounds(boundLevel:DisplayObject, point:GPoint) : Boolean
      {
         var bounds:Object = getBounds(boundLevel);
         if(point.x >= bounds.x && point.x <= bounds.x + bounds.width)
         {
            if(point.y >= bounds.y && point.y <= bounds.y + bounds.height)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get currentPointCost() : Number
      {
         return this.dispatchSimpleEvent("getStepsToGoal",[this]);
      }
      
      public function wasRemoved() : Boolean
      {
         return this.removed;
      }
      
      public function getStatusIndicator() : CreepStatusIndicator
      {
         return this.statusIndicator;
      }
      
      public function getWaveSpawned() : Number
      {
         return this.waveSpawned;
      }
      
      public function getBonusMultiplier() : Number
      {
         return this.bonusMultiplier;
      }
      
      public function getDamageMultiplier() : Number
      {
         return this.damageMultiplier;
      }
   }
}

