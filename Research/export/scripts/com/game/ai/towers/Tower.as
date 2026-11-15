package com.game.ai.towers
{
   import com.game.ai.creeps.Creep;
   import com.game.ui.grid.GridSelectableItem;
   import com.jgp.audio.AudioControl;
   import com.jgp.functions.*;
   import com.jgp.helpers.ObjectHelper;
   import com.jgp.math.geom.GPoint;
   import com.jgp.math.geom.GVector;
   import com.jgp.math.helpers.RotationHelper;
   import com.jgp.utils.TimeTicker;
   
   public class Tower extends GridSelectableItem
   {
      
      protected static var TARGET_RETRY_INTERVAL:Number = 3;
      
      protected var screenLocation:GPoint;
      
      protected var screenCenterLocation:GPoint;
      
      public var footPrintSize:Number;
      
      public var targeting:String;
      
      protected var currentTarget:Creep;
      
      protected var targetLocked:Boolean;
      
      protected var lastTracked:Creep;
      
      public var projectileRefName:String;
      
      public var projectileParamsObj:Object;
      
      public var range:Number;
      
      public var shotsAtOnce:Number = 1;
      
      public var turretRotation:Number = Math.random() * 2 * Math.PI;
      
      protected var rotationSpeed:Number = 0;
      
      public var rotationAccel:Number = 0.0125;
      
      public var turretLength:Number = 17;
      
      public var lastShotAt:Number = 0;
      
      public var reloadTime:Number = 0;
      
      public var shootAtTime:Number = -1;
      
      protected var retargetAllowTime:Number = 0;
      
      public var aimAtTarget:Boolean = true;
      
      public var angleRandomness:Number = 0;
      
      public var angleSpread:Number = 0;
      
      public var targetOverride:Creep;
      
      public var manualTargetingEnabled:Boolean = true;
      
      public var simTargets:Number = 1;
      
      public var maxTurretRotation:Number = 0.5;
      
      public var shotSound:String;
      
      public var shotSoundId:String;
      
      public var useShotSoundLoop:Boolean = false;
      
      public function Tower(screenLocation:GPoint, towerConfig:Object, dispatcher:SimpleDispatcher)
      {
         this.screenLocation = screenLocation.cloneMe();
         super(dispatcher,towerConfig);
         this.setProjectileParamsObj();
      }
      
      override protected function setSkin(skinLibName:String) : void
      {
         super.setSkin(skinLibName);
         skin.turret.rotation = RotationHelper.radsToDeg(this.turretRotation);
         this.screenCenterLocation = this.screenLocation.cloneMe();
         this.screenCenterLocation.x += this.footPrintSize / 2;
         this.screenCenterLocation.y += this.footPrintSize / 2;
      }
      
      protected function setProjectileParamsObj() : void
      {
         var toCloneObj:Object = dispatchSimpleEvent("getProjectileParamsObj",[this.projectileRefName]);
         this.projectileParamsObj = ObjectHelper.cloneObject(toCloneObj);
      }
      
      public function update(ticker:TimeTicker) : void
      {
         if(this.shootAtTime == -1)
         {
            this.resetShotTime(ticker.getTime());
         }
         if(this.targetOverride != null && this.currentTarget != this.targetOverride)
         {
            if(this.targetOverride.wasRemoved())
            {
               this.targetOverride = null;
            }
            else if(this.checkCreepInRange(this.targetOverride))
            {
               this.switchTarget(this.targetOverride);
            }
            else
            {
               this.attemptTargetLock(ticker);
            }
         }
         else
         {
            this.attemptTargetLock(ticker);
         }
         if(this.currentTarget != null)
         {
            this.updateTurret(ticker,this.currentTarget);
            if(this.targetLocked && this.checkCreepInRange(this.currentTarget) && !this.checkCreepToClose(this.currentTarget))
            {
               this.updateFiring(ticker);
            }
         }
         else if(this.targetOverride != null)
         {
            this.updateTurret(ticker,this.targetOverride);
         }
      }
      
      protected function switchTarget(target:Creep = null) : void
      {
         if(this.currentTarget != target)
         {
            this.targetLocked = false;
            this.currentTarget = target;
         }
      }
      
      protected function attemptTargetLock(ticker:TimeTicker) : void
      {
         var newTargets:Array = null;
         if(this.currentTarget != null)
         {
            if(this.currentTarget.wasRemoved() || !this.checkCreepInRange(this.currentTarget))
            {
               if(this.useShotSoundLoop)
               {
                  this.stopShotSoundLoop();
               }
               this.currentTarget = null;
            }
         }
         if(this.currentTarget == null && ticker.getTime() > this.retargetAllowTime)
         {
            newTargets = dispatchSimpleEvent("getTargets",[this,this.checkCreepInRange]);
            if(newTargets != null)
            {
               if(this.checkCreepInRange(newTargets[0]))
               {
                  this.switchTarget(newTargets[0]);
                  return;
               }
            }
            this.retargetAllowTime = ticker.getTime() + TARGET_RETRY_INTERVAL * ticker.getTickDuration();
         }
      }
      
      protected function updateFiring(ticker:TimeTicker) : void
      {
         var targetList:Array = null;
         var target:Creep = null;
         var i:Number = NaN;
         var currentTime:Number = ticker.getTime();
         var shotFired:Boolean = false;
         if(currentTime >= this.shootAtTime)
         {
            if(this.simTargets > 1)
            {
               targetList = dispatchSimpleEvent("getTargets",[this,this.checkCreepInRange,this.simTargets]);
               for(i = 0; i < this.simTargets; i++)
               {
                  target = targetList.shift();
                  this.startFiringSequence(target);
                  if(targetList.length == 0)
                  {
                     break;
                  }
               }
            }
            else
            {
               this.startFiringSequence(this.currentTarget);
            }
            this.resetShotTime(currentTime);
         }
      }
      
      protected function resetShotTime(currentTime:Number) : void
      {
         this.lastShotAt = currentTime;
         this.shootAtTime = currentTime + this.reloadTime;
      }
      
      protected function startFiringSequence(target:Creep) : void
      {
         var arcShiftRatio:Number = NaN;
         var angleShift:Number = NaN;
         var i:Number = NaN;
         if(this.shotsAtOnce > 1)
         {
            for(i = 0; i < this.shotsAtOnce; i++)
            {
               arcShiftRatio = i / (this.shotsAtOnce - 1) * 2 - 1;
               angleShift = this.angleSpread * arcShiftRatio;
               this.fireShot(target,angleShift);
            }
         }
         else
         {
            this.fireShot(target);
         }
         this.playShotSound();
      }
      
      protected function playShotSound() : void
      {
         var audioController:AudioControl = null;
         if(this.shotSound != null)
         {
            audioController = AudioControl.getInstance();
            if(this.useShotSoundLoop && this.shotSoundId == null)
            {
               this.shotSoundId = audioController.playSound(this.shotSound,Infinity);
            }
            else if(!this.useShotSoundLoop)
            {
               audioController.playSound(this.shotSound);
            }
         }
      }
      
      protected function stopShotSoundLoop() : void
      {
         var audioController:AudioControl = null;
         if(this.shotSoundId != null)
         {
            audioController = AudioControl.getInstance();
            audioController.clearLoop(this.shotSoundId);
            this.shotSoundId = null;
         }
      }
      
      protected function fireShot(target:Creep, angleShift:Number = 0) : void
      {
         var fireAngle:Number = NaN;
         var fireVector:GVector = null;
         var firePoint:GPoint = null;
         if(!this.aimAtTarget)
         {
            fireAngle = Number(GPoint.getAngle(this.getTurretFireLocation(),target.getScreenCenterLocation()).radians);
            fireAngle += angleShift;
            if(this.angleRandomness != 0)
            {
               fireAngle += Math.random() * (this.angleRandomness * 2) - this.angleRandomness;
            }
            fireVector = GVector.getAngularUnitVector(fireAngle);
            firePoint = this.getTurretFireLocation().cloneMe();
            firePoint.x += fireVector.x * (this.range - this.turretLength);
            firePoint.y += fireVector.y * (this.range - this.turretLength);
            dispatchSimpleEvent("fireShot",[this.getTurretFireLocation(),firePoint,this.getTargetingType(),this.projectileParamsObj]);
         }
         else
         {
            dispatchSimpleEvent("fireShot",[this.getTurretFireLocation(),target,this.getTargetingType(),this.projectileParamsObj]);
         }
      }
      
      protected function updateTurret(ticker:TimeTicker, target:Creep) : void
      {
         if(target != this.lastTracked)
         {
            this.rotationSpeed = 0;
            this.targetLocked = false;
         }
         var targetPoint:GPoint = target.getScreenCenterLocation();
         this.updateTurretRotation(targetPoint);
         this.lastTracked = target;
      }
      
      protected function updateTurretRotation(targetPoint:GPoint) : void
      {
         var turretCenterPoint:GPoint = this.getScreenCenterLocation();
         var goalRotation:Number = RotationHelper.limitAngleRads(GPoint.getAngle(turretCenterPoint,targetPoint).radians);
         var currentRotation:Number = RotationHelper.limitAngleRads(this.turretRotation);
         var angleDifference:Number = goalRotation - currentRotation;
         var fullRotation:Number = RotationHelper.findShortestRotationRads(angleDifference);
         var toRotate:Number = RotationHelper.limitRotationIntensity(fullRotation,this.maxTurretRotation);
         var signVal:Number = toRotate;
         if(signVal == 0)
         {
            signVal = 1;
         }
         var rotationSign:Number = Math.round(signVal / Math.abs(signVal));
         if(!this.targetLocked)
         {
            this.rotationSpeed += rotationSign * this.rotationAccel;
            this.rotationSpeed = RotationHelper.limitRotationIntensity(this.rotationSpeed,Math.abs(toRotate));
            this.rotationSpeed = RotationHelper.limitRotationIntensity(this.rotationSpeed,this.maxTurretRotation);
            toRotate = this.rotationSpeed;
            if(toRotate == fullRotation)
            {
               this.rotationSpeed = 0;
               this.targetLocked = true;
            }
         }
         this.turretRotation += toRotate;
         skin.turret.rotation = RotationHelper.radsToDeg(this.turretRotation);
      }
      
      public function checkCreepInRange(creep:Creep) : Boolean
      {
         var creepCenterLocation:GPoint = creep.getScreenCenterLocation();
         var towerCenterLocation:GPoint = this.getScreenCenterLocation();
         return GPoint.getDistance(creepCenterLocation,towerCenterLocation) <= this.range;
      }
      
      public function checkCreepToClose(creep:Creep) : Boolean
      {
         var creepCenterLocation:GPoint = creep.getScreenCenterLocation();
         var towerCenterLocation:GPoint = this.getScreenCenterLocation();
         return GPoint.getDistance(creepCenterLocation,towerCenterLocation) <= this.turretLength;
      }
      
      public function getScreenLocaction() : GPoint
      {
         return this.screenLocation;
      }
      
      public function getTargetingType() : String
      {
         return this.targeting;
      }
      
      public function getRange() : Number
      {
         return this.range;
      }
      
      public function getTurretFireLocation() : GPoint
      {
         var fireLocation:GPoint = this.getScreenCenterLocation().cloneMe();
         fireLocation.x += Math.sin(this.turretRotation) * this.turretLength;
         fireLocation.y -= Math.cos(this.turretRotation) * this.turretLength;
         return fireLocation;
      }
      
      public function getScreenCenterLocation() : GPoint
      {
         return this.screenCenterLocation;
      }
      
      public function getProjectileObj() : Object
      {
         return this.projectileParamsObj;
      }
      
      public function getCurrentTarget() : Creep
      {
         return this.currentTarget;
      }
      
      public function getTargetOverride() : Creep
      {
         return this.targetOverride;
      }
      
      public function setCurrentTarget(target:Creep) : void
      {
         this.targetOverride = target;
         if(this.checkCreepInRange(target))
         {
            this.switchTarget(target);
         }
      }
      
      public function manualTargetOk() : Boolean
      {
         return this.manualTargetingEnabled;
      }
      
      override public function getStatsObj() : Object
      {
         var statsObj:Object = super.getStatsObj();
         statsObj.range = this.range;
         statsObj.reloadTime = this.reloadTime;
         statsObj.targeting = this.targeting;
         statsObj.shotsAtOnce = this.shotsAtOnce;
         return statsObj;
      }
      
      override public function applyUpgrade(upgradeObj:Object) : void
      {
         super.applyUpgrade(upgradeObj);
         ObjectHelper.copyProps(this.projectileParamsObj,upgradeObj.projectile);
         this.rotationSpeed = 0;
         this.currentTarget = null;
      }
   }
}

