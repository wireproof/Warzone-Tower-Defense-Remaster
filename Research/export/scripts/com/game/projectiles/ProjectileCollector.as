package com.game.projectiles
{
   import com.game.ai.creeps.Creep;
   import com.jgp.audio.AudioControl;
   import com.jgp.bitmap.loading.BitmapArchive;
   import com.jgp.functions.*;
   import com.jgp.math.geom.GPoint;
   import com.jgp.math.geom.GRectangle;
   import com.jgp.math.geom.GVector;
   import com.jgp.particles.ParticleSystem;
   import com.jgp.utils.TimeTicker;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.utils.getDefinitionByName;
   
   public class ProjectileCollector extends Sprite
   {
      
      internal static const MIN_COLLSION_RADIUS:Number = 8;
      
      protected var particleSystem:ParticleSystem;
      
      protected var activeProjectileRefs:Object;
      
      protected var projectileInstanceNum:Number = 0;
      
      protected var areaWidth:Number;
      
      protected var areaHeight:Number;
      
      protected var creepExplodeRefName:String;
      
      protected var creepExplodeQueue:Array;
      
      protected var projectileDisatcher:SimpleDispatcher;
      
      protected var bitmapArchive:BitmapArchive;
      
      protected var particleParamsRefs:Object;
      
      protected var particleEmitterRefs:Object;
      
      protected var projectileRefs:Object;
      
      protected var drawClipInstanceNum:Number = 0;
      
      protected var activeDrawClips:Object;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function ProjectileCollector(areaWidth:Number, areaHeight:Number, bmpArchive:BitmapArchive, config:Object)
      {
         super();
         this.areaWidth = areaWidth;
         this.areaHeight = areaHeight;
         this.bitmapArchive = bmpArchive;
         this.creepExplodeQueue = new Array();
         this.activeDrawClips = new Object();
         this.applyParamObject(config);
         SimpleDispatcher.initialize(this);
         this.setProctileDispatcher();
         this.activeProjectileRefs = new Object();
         this.initParticleSystem();
      }
      
      public function dispose() : void
      {
         this.particleSystem.dispose();
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
      
      protected function initParticleSystem() : void
      {
         this.particleSystem = new ParticleSystem(new GRectangle(new GPoint(0,0),new GPoint(this.areaWidth,this.areaHeight)));
         addChild(this.particleSystem);
      }
      
      protected function setProctileDispatcher() : void
      {
         this.projectileDisatcher = new SimpleDispatcher();
         this.projectileDisatcher.registerSimpleEvent("remove",new Callback(this,this.removeProjectile));
         this.projectileDisatcher.registerSimpleEvent("getClosestTarget",new Callback(this,this.getClosestTarget));
         this.projectileDisatcher.registerSimpleEvent("applyIndirectDamage",new Callback(this,this.applyIndirectDamage));
         this.projectileDisatcher.registerSimpleEvent("drawTrail",new Callback(this,this.drawProjectileTrail));
         this.projectileDisatcher.registerSimpleEvent("setProjectileExplosion",new Callback(this,this.setProjectileExplosion));
         this.projectileDisatcher.registerSimpleEvent("checkForImpact",new Callback(this,this.checkForImpact));
      }
      
      public function fireProjectile(from:GPoint, target:*, targeting:String, projectileParams:Object) : void
      {
         var instanceNum:Number = NaN;
         var instanceName:String = null;
         var projectile:Projectile = null;
         if(projectileParams.weaponType == "projectile")
         {
            instanceNum = this.projectileInstanceNum++;
            instanceName = "P_" + instanceNum;
            projectile = new Projectile(this,from,target,targeting,projectileParams,instanceName,this.projectileDisatcher);
            this.activeProjectileRefs[instanceName] = projectile;
            addChild(projectile);
         }
         else if(projectileParams.weaponType == "beam")
         {
            this.fireBeam(from,target,targeting,projectileParams);
         }
         else if(projectileParams.weaponType == "bomb")
         {
            this.fireAreaEffectWeapon(projectileParams,from,targeting);
         }
      }
      
      protected function fireBeam(from:GPoint, target:*, targeting:String, projectileParams:Object) : void
      {
         var targetPoint:GPoint = null;
         var creepTarget:Creep = null;
         if(target is Creep)
         {
            creepTarget = target as Creep;
            targetPoint = creepTarget.getScreenCenterLocation();
         }
         else
         {
            if(!(target is GPoint))
            {
               return;
            }
            targetPoint = target;
         }
         var angleObj:Object = GPoint.getAngle(from,targetPoint);
         var unitVector:GVector = GVector.getAngularUnitVector(angleObj.radians);
         var beamClip:MovieClip = this.setActiveDrawClip(projectileParams.skinName,from,-1,projectileParams.beamLength);
         beamClip.rotation = angleObj.degrees;
         this.applyBeamDamage(targeting,from,unitVector,projectileParams.beamLength,projectileParams.directDamage);
      }
      
      protected function applyBeamDamage(targeting:String, from:GPoint, unitVector:GVector, beamLength:Number, damage:Number) : void
      {
         var creepDistance:Number = NaN;
         var inBounds:Boolean = false;
         var creep:Creep = null;
         var creepList:Array = this.dispatchSimpleEvent("getTargets",[targeting,null]);
         var projectionPoint:GPoint = new GPoint();
         for each(creep in creepList)
         {
            creepDistance = GPoint.getDistance(from,creep.getScreenCenterLocation());
            if(creepDistance <= beamLength)
            {
               projectionPoint.x = from.x + creepDistance * unitVector.x;
               projectionPoint.y = from.y + creepDistance * unitVector.y;
               inBounds = creep.checkPointInBounds(this,projectionPoint);
               if(inBounds)
               {
                  creep.applyDamage(damage);
               }
            }
         }
      }
      
      public function setBomb(bombId:String, screenLoc:GPoint, targeting:String) : *
      {
         var bombParamsObj:Object = this.getProjectileParamsObj(bombId);
         this.fireAreaEffectWeapon(bombParamsObj,screenLoc,targeting);
      }
      
      public function fireAreaEffectWeapon(bombParamsObj:Object, screenLoc:GPoint, targeting:String) : void
      {
         var distance:Number = NaN;
         var fallOffMultiplier:Number = NaN;
         var creep:Creep = null;
         var creepList:Array = this.dispatchSimpleEvent("getTargets",[targeting,null]);
         var useFallOff:Boolean = true;
         if(bombParamsObj.useFallOff != null)
         {
            useFallOff = Boolean(bombParamsObj.useFallOff);
         }
         for each(creep in creepList)
         {
            distance = GPoint.getDistance(creep.getScreenCenterLocation(),screenLoc);
            if(distance < bombParamsObj.explosionRadius + MIN_COLLSION_RADIUS)
            {
               if(bombParamsObj.indirectDamage > 0 && useFallOff)
               {
                  fallOffMultiplier = 1 - distance / (bombParamsObj.explosionRadius + MIN_COLLSION_RADIUS);
                  creep.applyDamage(bombParamsObj.indirectDamage * fallOffMultiplier);
               }
               else
               {
                  creep.applyDamage(bombParamsObj.indirectDamage);
               }
               if(bombParamsObj.slow != null)
               {
                  creep.setSlowDown(bombParamsObj.slow.ratio,bombParamsObj.slow.duration);
               }
            }
         }
         if(bombParamsObj.explosionRefName != null)
         {
            this.emitParticles(bombParamsObj.explosionRefName,screenLoc);
         }
         if(bombParamsObj.explodeSkin != null)
         {
            this.setActiveDrawClip(bombParamsObj.explodeSkin,screenLoc,bombParamsObj.explosionRadius * 2,bombParamsObj.explosionRadius * 2);
         }
      }
      
      public function update(timeTicker:TimeTicker) : void
      {
         var projectile:Projectile = null;
         var instanceId:String = null;
         for(instanceId in this.activeProjectileRefs)
         {
            projectile = this.activeProjectileRefs[instanceId];
            projectile.update(timeTicker);
         }
         this.triggerCreepExplodeQueue();
         this.updateActiveDrawClips();
         this.particleSystem.update(timeTicker);
      }
      
      protected function removeProjectile(projectile:Projectile) : void
      {
         delete this.activeProjectileRefs[projectile.getInstanceName()];
         if(contains(projectile))
         {
            removeChild(projectile);
         }
      }
      
      public function checkProjectileInRange(projectile:Projectile) : Boolean
      {
         var projectileLocation:GPoint = projectile.getCurrentScreenLocation();
         if(projectileLocation.x >= 0 && projectileLocation.x <= this.areaWidth && projectileLocation.y >= 0 && projectileLocation.y <= this.areaHeight)
         {
            return true;
         }
         return false;
      }
      
      public function applyIndirectDamage(projectile:Projectile) : void
      {
         var creep:Creep = null;
         var creepList:Array = this.dispatchSimpleEvent("getTargets",[projectile.getTargetingType(),null]);
         for each(creep in creepList)
         {
            projectile.checkExplode(creep);
         }
      }
      
      public function checkForImpact(projectile:Projectile, partialCheck:Boolean = false) : Boolean
      {
         var creepList:Array = null;
         var creep:Creep = null;
         var impacted:Boolean = this.dispatchSimpleEvent("checkForImpact",[projectile.getTargetingType(),projectile.getCurrentScreenLocation()]);
         if(impacted)
         {
            if(partialCheck)
            {
               return true;
            }
            creepList = this.dispatchSimpleEvent("getTargets",[projectile.getTargetingType(),null]);
            for each(creep in creepList)
            {
               if(projectile.checkDirectHit(creep))
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      public function getClosestTarget(projectileLocation:GPoint, targeting:String, rangeLimit:Number = Infinity) : Creep
      {
         var distance:Number = NaN;
         var closestCreep:Creep = null;
         var creep:Creep = null;
         var creepList:Array = this.dispatchSimpleEvent("getTargets",[targeting,null]);
         var lowestDistance:Number = Infinity;
         for each(creep in creepList)
         {
            distance = GPoint.getDistance(creep.getScreenCenterLocation(),projectileLocation);
            if(distance < lowestDistance && distance < rangeLimit)
            {
               lowestDistance = distance;
               closestCreep = creep;
            }
         }
         return closestCreep;
      }
      
      public function setCreepExplosion(point:GPoint) : void
      {
         this.creepExplodeQueue.push(point);
      }
      
      protected function triggerCreepExplodeQueue() : void
      {
         while(this.creepExplodeQueue.length > 0)
         {
            this.emitParticles(this.creepExplodeRefName,this.creepExplodeQueue.pop());
         }
      }
      
      public function setBaseExplosion(point:GPoint, ticker:TimeTicker) : void
      {
         for(var i:Number = 1; i <= 3; i++)
         {
            ticker.addQueuedFunction(new Callback(this,this.baseExplosion,[point]),i * 6);
         }
         this.baseExplosion(point);
      }
      
      protected function baseExplosion(point:GPoint) : *
      {
         var explodePoint:GPoint = new GPoint();
         for(var i:Number = 0; i < 1; i++)
         {
            explodePoint.x = point.x + (Math.random() * 20 - 10);
            explodePoint.y = point.y + (Math.random() * 20 - 10);
            this.emitParticles("bomb_explosion_smoke|bomb_explosion_flare",explodePoint);
         }
      }
      
      public function setProjectileExplosion(projectile:Projectile) : void
      {
         this.emitParticles(projectile.getExplosionRefName(),projectile.getCurrentScreenLocation());
      }
      
      protected function updateActiveDrawClips() : void
      {
         var drawClip:MovieClip = null;
         var activeDrawObj:Object = null;
         var d:String = null;
         for(d in this.activeDrawClips)
         {
            activeDrawObj = this.activeDrawClips[d];
            drawClip = activeDrawObj.clip;
            drawClip.gotoAndStop(activeDrawObj.frame);
            this.particleSystem.drawDisplayObject(drawClip);
            if(activeDrawObj.frame == activeDrawObj.finalFrame)
            {
               delete this.activeDrawClips[d];
            }
            else
            {
               ++activeDrawObj.frame;
            }
         }
      }
      
      public function setActiveDrawClip(cacheName:String, screenLoc:GPoint, width:Number = -1, height:Number = -1) : MovieClip
      {
         var clip:* = this.getCachedClip(cacheName);
         clip.x = screenLoc.x;
         clip.y = screenLoc.y;
         if(width != -1)
         {
            clip.width = width;
         }
         if(height != -1)
         {
            clip.height = height;
         }
         this.addActiveDrawClip(clip);
         return clip;
      }
      
      protected function addActiveDrawClip(clip:MovieClip) : void
      {
         ++this.drawClipInstanceNum;
         clip.stop();
         this.activeDrawClips["c_" + this.drawClipInstanceNum] = {
            "clip":clip,
            "frame":1,
            "finalFrame":clip.totalFrames,
            "width":clip.width,
            "height":clip.height
         };
      }
      
      protected function getCachedClip(skinName:String) : MovieClip
      {
         var SkinClass:Class = getDefinitionByName(skinName) as Class;
         var tempClip:MovieClip = new SkinClass() as MovieClip;
         tempClip.cacheAsBitmap = true;
         return tempClip;
      }
      
      public function getCachedBMD(bmdName:String, bmdWidth:Number = 0, bmdHeight:Number = 0) : BitmapData
      {
         var sourceBMP:Bitmap = null;
         var bmd:BitmapData = null;
         var cacheName:String = bmdName;
         if(bmdWidth > 0 && bmdHeight > 0)
         {
            cacheName = "|" + cacheName + "|" + bmdWidth + "x" + bmdHeight;
         }
         if(!this.bitmapArchive.nameRegistered(cacheName))
         {
            sourceBMP = this.bitmapArchive.getBitmap(bmdName);
            sourceBMP.width = bmdWidth;
            sourceBMP.height = bmdHeight;
            bmd = new BitmapData(bmdWidth,bmdHeight,true,0);
            bmd.draw(sourceBMP,sourceBMP.transform.matrix);
            this.bitmapArchive.setBitmapData(cacheName,bmd);
         }
         return this.bitmapArchive.getBitmapData(cacheName);
      }
      
      public function emitParticles(emitterRefNames:String, point:GPoint) : void
      {
         var emitter:Object = null;
         var emitterRefName:String = null;
         var emitterNameList:Array = emitterRefNames.split("|");
         for each(emitterRefName in emitterNameList)
         {
            emitter = this.getParticleEmitter(emitterRefName);
            if(emitter != null)
            {
               if(emitter.sound != null)
               {
                  this.playProjectileSound(emitter.sound);
               }
               this.particleSystem.spawnParticles(point,emitter.minSpawn,emitter.maxSpawn,this.getParticleParamObject(emitter.particleRefName),[this.getCachedBMD(emitter.bmdName,emitter.width,emitter.height)]);
            }
         }
      }
      
      public function removeAllProjectiles() : void
      {
         var projectile:Projectile = null;
         var i:String = null;
         for(i in this.activeProjectileRefs)
         {
            projectile = this.activeProjectileRefs[i];
            this.setProjectileExplosion(projectile);
            this.removeProjectile(projectile);
         }
      }
      
      public function removeTrackingProjectiles() : void
      {
         var projectile:Projectile = null;
         var i:String = null;
         for(i in this.activeProjectileRefs)
         {
            projectile = this.activeProjectileRefs[i];
            if(projectile.canReaquire())
            {
               this.setProjectileExplosion(projectile);
               this.removeProjectile(projectile);
            }
         }
      }
      
      public function drawProjectileTrail(trailConfig:Object, point:GPoint) : void
      {
         this.particleSystem.drawBMD(this.getCachedBMD(trailConfig.bmdName,Math.ceil(trailConfig.width),Math.ceil(trailConfig.height)),point);
      }
      
      public function getParticleEmitter(emitterName:String) : Object
      {
         return this.particleEmitterRefs[emitterName];
      }
      
      public function getParticleParamObject(objName:String) : Object
      {
         return this.particleParamsRefs[objName];
      }
      
      public function getProjectileParamsObj(projectileRefName:String) : Object
      {
         return this.projectileRefs[projectileRefName];
      }
      
      protected function playProjectileSound(soundClassName:String) : *
      {
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.playSound(soundClassName);
      }
   }
}

