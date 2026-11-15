package com.game.projectiles
{
   import com.game.ai.creeps.Creep;
   import com.jgp.functions.*;
   import com.jgp.helpers.ObjectHelper;
   import com.jgp.math.geom.GPoint;
   import com.jgp.math.geom.GVector;
   import com.jgp.math.helpers.RotationHelper;
   import com.jgp.utils.TimeTicker;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.utils.getDefinitionByName;
   
   public class Projectile extends Sprite
   {
      
      protected var skinName:String;
      
      protected var skin:MovieClip;
      
      protected var collectorRef:Sprite;
      
      protected var currentLocation:GPoint;
      
      protected var target:Creep;
      
      protected var targeting:String;
      
      protected var targetLocation:GPoint;
      
      protected var trackingShot:Boolean = true;
      
      protected var reaquireTarget:Boolean = false;
      
      protected var maxRotation:Number = Infinity;
      
      protected var velocity:Number;
      
      protected var life:Number = Infinity;
      
      protected var explosionRadius:Number = 0;
      
      protected var useFallOff:Boolean = false;
      
      protected var activeDamageCheck:Boolean = false;
      
      protected var explodeOnFirstImpact:Boolean = false;
      
      protected var directDamage:Number = 0;
      
      protected var indirectDamage:Number = 0;
      
      protected var explosionRefName:String = "";
      
      protected var bounceRangeLimit:Number = Infinity;
      
      protected var matchAngle:Boolean = false;
      
      protected var trailConfig:Object;
      
      protected var trailScaleRate:Number = 1;
      
      protected var trailLoc:GPoint;
      
      protected var moveVector:GVector;
      
      protected var angleDegrees:Number;
      
      protected var angleRads:Number = -1;
      
      protected var instanceName:String;
      
      protected const MIN_ROTATE_DISTANCE:Number = 0;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function Projectile(collectorRef:Sprite, from:GPoint, target:*, targeting:String, projectileParams:Object, instanceName:String, dispatcher:SimpleDispatcher)
      {
         super();
         SimpleDispatcher.initialize(this,dispatcher);
         this.collectorRef = collectorRef;
         this.instanceName = instanceName;
         this.applyParamObject(projectileParams);
         this.setInitialTarget(target);
         this.targeting = targeting;
         this.currentLocation = from.cloneMe();
         this.setSkin();
         this.pointToNewTarget();
         if(this.trailScaleRate != 1)
         {
            this.trailConfig = ObjectHelper.cloneObject(this.trailConfig);
         }
         if(!this.trackingShot)
         {
            this.target = null;
         }
         this.updateScreenLocation();
         if(this.explodeOnFirstImpact && this.checkForImpact())
         {
            this.targetHit();
         }
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
      
      protected function setSkin() : void
      {
         var skinClass:Class = null;
         if(this.skinName != null && this.skinName.length > 0)
         {
            skinClass = getDefinitionByName(this.skinName) as Class;
            this.skin = new skinClass();
         }
         else
         {
            this.skin = new MovieClip();
         }
         addChild(this.skin);
      }
      
      protected function setInitialTarget(target:*) : *
      {
         if(target is Creep)
         {
            this.target = target;
         }
         else
         {
            this.targetLocation = target.cloneMe();
         }
      }
      
      public function update(ticker:TimeTicker) : void
      {
         var movedDistance:Number = NaN;
         var targetDistance:Number = NaN;
         if(this.life != Infinity)
         {
            this.life -= ticker.getTickDuration();
         }
         if(this.life > 0)
         {
            movedDistance = this.updateMovement();
            targetDistance = GPoint.getDistance(this.currentLocation,this.targetLocation);
            if(movedDistance < ProjectileCollector.MIN_COLLSION_RADIUS)
            {
               movedDistance = ProjectileCollector.MIN_COLLSION_RADIUS;
            }
            if(targetDistance >= movedDistance)
            {
               if(this.trackingShot)
               {
                  this.updateMoveVector();
               }
               if(this.matchAngle && targetDistance > this.MIN_ROTATE_DISTANCE)
               {
                  this.skin.rotation = this.angleDegrees;
               }
               if(this.activeDamageCheck && !this.explodeOnFirstImpact)
               {
                  this.applyIndirectDamage();
               }
               else if(this.explodeOnFirstImpact)
               {
                  if(this.checkForImpact())
                  {
                     this.targetHit();
                  }
               }
            }
            else
            {
               this.targetHit();
            }
            if(this.trailConfig != null)
            {
               this.drawTrail(this.trailConfig);
            }
         }
         else
         {
            this.remove();
         }
      }
      
      protected function updateMovement() : Number
      {
         if(this.trackingShot)
         {
            this.updateTargetLocation();
         }
         var moveDistance:Number = this.velocity;
         this.currentLocation.x += this.moveVector.x * moveDistance;
         this.currentLocation.y += this.moveVector.y * moveDistance;
         this.updateScreenLocation();
         return moveDistance;
      }
      
      protected function updateMoveVector() : void
      {
         var angleObj:Object = GPoint.getAngle(this.currentLocation,this.targetLocation);
         if(this.angleRads == -1)
         {
            this.angleRads = angleObj.radians;
         }
         var angleDiff:Number = RotationHelper.findShortestRotationRads(angleObj.radians - this.angleRads);
         angleDiff = RotationHelper.limitRotationIntensity(angleDiff,this.maxRotation);
         this.angleRads += angleDiff;
         this.angleDegrees = RotationHelper.radsToDeg(this.angleRads);
         this.moveVector = GVector.getAngularUnitVector(this.angleRads);
      }
      
      protected function updateScreenLocation() : void
      {
         x = this.currentLocation.x;
         y = this.currentLocation.y;
      }
      
      protected function targetHit() : void
      {
         var destroyed:Boolean = false;
         if(this.target != null)
         {
            if(!this.target.wasRemoved() && this.getDirectDamage() > 0)
            {
               destroyed = this.target.applyDamage(this.getDirectDamage());
            }
            this.remove();
         }
         else
         {
            this.remove();
         }
         if(this.getIndirectDamage() > 0)
         {
            this.applyIndirectDamage();
         }
      }
      
      public function remove() : void
      {
         this.dispatchSimpleEvent("setProjectileExplosion",[this]);
         this.dispatchSimpleEvent("remove",[this]);
      }
      
      protected function updateTargetLocation() : void
      {
         if(this.reaquireTarget)
         {
            if(this.target != null)
            {
               if(this.target.wasRemoved())
               {
                  this.findNewTarget();
               }
            }
         }
         if(this.target != null)
         {
            this.targetLocation = this.target.getScreenCenterLocation().cloneMe();
         }
      }
      
      protected function findNewTarget() : Boolean
      {
         this.target = this.dispatchSimpleEvent("getClosestTarget",[this.getCurrentScreenLocation(),this.targeting,this.bounceRangeLimit]);
         return this.target != null;
      }
      
      protected function pointToNewTarget() : void
      {
         this.updateTargetLocation();
         this.updateMoveVector();
         this.skin.rotation = this.angleDegrees;
      }
      
      public function checkExplode(creep:Creep) : Boolean
      {
         var distance:Number = GPoint.getDistance(creep.getScreenCenterLocation(),this.getCurrentScreenLocation());
         var inRadius:Boolean = distance <= this.getExplosionRadius() + ProjectileCollector.MIN_COLLSION_RADIUS;
         if(inRadius)
         {
            if(!this.activeDamageCheck || this.explodeOnFirstImpact)
            {
               if(creep.checkPointInBounds(this.collectorRef,this.getCurrentScreenLocation()))
               {
                  distance = 0;
               }
            }
            creep.applyDamage(this.getExplosionDamage(distance));
            return true;
         }
         return false;
      }
      
      public function checkDirectHit(creep:Creep) : Boolean
      {
         var distance:Number = GPoint.getDistance(creep.getScreenCenterLocation(),this.getCurrentScreenLocation());
         var inRadius:Boolean = distance <= ProjectileCollector.MIN_COLLSION_RADIUS;
         if(inRadius)
         {
            return true;
         }
         return false;
      }
      
      protected function drawTrail(trailConfig:Object) : *
      {
         if(this.trailScaleRate != 1)
         {
            trailConfig.width *= this.trailScaleRate;
            trailConfig.height *= this.trailScaleRate;
         }
         this.dispatchSimpleEvent("drawTrail",[trailConfig,this.getTrailScreenLocation()]);
      }
      
      public function getCurrentScreenLocation() : GPoint
      {
         return this.currentLocation;
      }
      
      public function getTrailScreenLocation() : GPoint
      {
         var screenLoc:GPoint = this.getCurrentScreenLocation();
         if(this.trailLoc == null)
         {
            this.trailLoc = new GPoint();
         }
         this.trailLoc.x = screenLoc.x - this.moveVector.x * this.trailConfig.offset;
         this.trailLoc.y = screenLoc.y - this.moveVector.y * this.trailConfig.offset;
         return this.trailLoc;
      }
      
      public function getExplosionDamage(distance:Number) : Number
      {
         var fallOffMultiplier:Number = NaN;
         var damage:Number = this.getIndirectDamage();
         if(this.useFallOff)
         {
            fallOffMultiplier = 1 - distance / (this.getExplosionRadius() + ProjectileCollector.MIN_COLLSION_RADIUS);
            damage *= fallOffMultiplier;
         }
         return damage;
      }
      
      protected function applyIndirectDamage() : void
      {
         this.dispatchSimpleEvent("applyIndirectDamage",[this]);
      }
      
      protected function checkForImpact(simpleCheck:Boolean = false) : Boolean
      {
         return this.dispatchSimpleEvent("checkForImpact",[this,simpleCheck]);
      }
      
      public function getDirectDamage() : Number
      {
         return this.directDamage;
      }
      
      public function getIndirectDamage() : Number
      {
         return this.indirectDamage;
      }
      
      public function getInstanceName() : String
      {
         return this.instanceName;
      }
      
      public function getExplosionRadius() : Number
      {
         return this.explosionRadius;
      }
      
      public function getExplosionRefName() : String
      {
         return this.explosionRefName;
      }
      
      public function getTargetingType() : String
      {
         return this.targeting;
      }
      
      public function canReaquire() : Boolean
      {
         return this.reaquireTarget;
      }
   }
}

