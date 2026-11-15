package com.jgp.particles
{
   import com.jgp.helpers.ArrayHelper;
   import com.jgp.math.geom.*;
   import com.jgp.utils.TimeTicker;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.*;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   
   public class ParticleSystem extends MovieClip
   {
      
      protected var bmd:BitmapData;
      
      protected var bmp:Bitmap;
      
      protected var pGRect:GRectangle;
      
      protected var spawnGPoint:GPoint;
      
      protected var bgColor:Number = 0;
      
      protected var colorTransform:ColorTransform;
      
      protected var started:Boolean = false;
      
      protected var activeParticles:Array;
      
      protected var particleID:Number = 0;
      
      protected var particleClass:Class;
      
      protected var fadeRate:Number = 0.8;
      
      protected var fadeEnabled:Boolean = true;
      
      protected var fillEnabled:Boolean = false;
      
      protected var drawPoint:GPoint;
      
      public function ParticleSystem(pGRect:GRectangle)
      {
         super();
         this.pGRect = pGRect;
         mouseEnabled = false;
         mouseChildren = false;
         if(this.fadeEnabled)
         {
            this.createFadeTransform();
         }
         this.createDrawPlane();
         this.initializeSystem();
      }
      
      public function dispose() : void
      {
         var i:String = null;
         this.bmd.dispose();
         for(i in this.activeParticles)
         {
            this.activeParticles[i].dispose();
         }
      }
      
      protected function createDrawPlane() : void
      {
         if(this.bmd != null)
         {
            this.bmd.dispose();
         }
         var bmdWidth:Number = this.pGRect.xMax - this.pGRect.xMin;
         var bmdHeight:Number = this.pGRect.yMax - this.pGRect.yMin;
         this.bmd = new BitmapData(bmdWidth,bmdHeight,true,this.bgColor);
         this.bmp = new Bitmap(this.bmd);
         this.bmp.smoothing = false;
         addChild(this.bmp);
      }
      
      protected function fillBackground() : void
      {
         this.bmd.fillRect(this.bmd.rect,this.bgColor);
      }
      
      protected function createFadeTransform() : void
      {
         this.colorTransform = new ColorTransform(1,1,1,this.fadeRate);
      }
      
      protected function fadeBackground() : void
      {
         var rect:Rectangle = this.bmd.getColorBoundsRect(4278190080,this.bgColor,false);
         if(rect.width > 0)
         {
            this.bmd.colorTransform(rect,this.colorTransform);
         }
      }
      
      protected function initializeSystem() : void
      {
         this.activeParticles = new Array();
      }
      
      public function spawnParticles(point:GPoint, minSpawn:Number, maxSpawn:Number, particleParams:Object, sourceBMDs:Array) : void
      {
         var spawnCount:Number = minSpawn + Math.round(maxSpawn * Math.random());
         while(spawnCount > 0)
         {
            this.spawnParticle(point,particleParams,sourceBMDs);
            spawnCount--;
         }
      }
      
      public function spawnParticle(point:GPoint, particleParams:Object, sourceBMDs:Array) : void
      {
         this.activeParticles.push(new Particle(point,this.pGRect,particleParams,ArrayHelper.getRandomElement(sourceBMDs).clone(),this.bmd));
         ++this.particleID;
      }
      
      public function update(ticker:TimeTicker) : void
      {
         var expired:Boolean = false;
         if(this.fillEnabled)
         {
            this.fillBackground();
         }
         var tempList:Array = new Array();
         for(var p:Number = 0; p < this.activeParticles.length; p++)
         {
            expired = Boolean(this.activeParticles[p].update(ticker));
            if(!expired)
            {
               tempList.push(this.activeParticles[p]);
            }
         }
         this.activeParticles = tempList;
         if(this.fadeEnabled)
         {
            this.fadeBackground();
         }
      }
      
      public function drawDisplayObject(drawObj:DisplayObject) : *
      {
         this.bmd.draw(drawObj,drawObj.transform.matrix,null,"layer");
      }
      
      public function drawBMD(sourceBMD:BitmapData, point:GPoint) : *
      {
         if(this.drawPoint == null)
         {
            this.drawPoint = new GPoint();
         }
         this.drawPoint.x = point.x - sourceBMD.width / 2;
         this.drawPoint.y = point.y - sourceBMD.height / 2;
         this.bmd.copyPixels(sourceBMD,sourceBMD.rect,this.drawPoint,null,null,true);
      }
   }
}

