package com.jgp.particles
{
   import com.jgp.math.geom.*;
   import com.jgp.utils.TimeTicker;
   import flash.display.BitmapData;
   import flash.geom.ColorTransform;
   
   public class Particle
   {
      
      protected static var colorTransform:ColorTransform;
      
      protected var sourceBMD:BitmapData;
      
      protected var drawBMD:BitmapData;
      
      protected var pParams:Object;
      
      protected var currentPoint:GPoint;
      
      protected var viewRect:GRectangle;
      
      protected var moveVector:GVector;
      
      protected var elapsedTime:Number;
      
      protected var initTime:Number;
      
      protected var endTime:Number;
      
      protected var alphaOffset:Number = 255;
      
      protected var alphaShift:Number;
      
      protected var delay:Number = 0;
      
      protected var BORDER_SIZE:Number = 100;
      
      public function Particle(spawnPoint:GPoint, vRect:GRectangle, pParams:Object, sourceBMD:BitmapData, drawBMD:BitmapData)
      {
         super();
         this.viewRect = vRect;
         this.sourceBMD = sourceBMD;
         this.drawBMD = drawBMD;
         this.pParams = pParams;
         if(pParams.delay != null)
         {
            this.delay = pParams.delay;
         }
         this.initialize(spawnPoint);
      }
      
      protected static function getParamVariance(varVal:Number) : Number
      {
         return Math.random() * varVal * 2 - varVal;
      }
      
      protected function initialize(spawnPoint:GPoint) : void
      {
         this.alphaShift = -Math.abs(this.pParams.alphaFadeMin + (this.pParams.alphaFadeMax - this.pParams.alphaFadeMin) * Math.random());
         if(colorTransform == null)
         {
            colorTransform = new ColorTransform(1,1,1,1,0,0,0,0);
         }
         this.currentPoint = spawnPoint.cloneMe();
         this.currentPoint.x -= this.sourceBMD.width / 2;
         this.currentPoint.y -= this.sourceBMD.height / 2;
         this.currentPoint.x += getParamVariance(this.pParams.spawnXVariance);
         this.currentPoint.y += getParamVariance(this.pParams.spawnYVariance);
         var initAngle:Number = this.pParams.angle + getParamVariance(this.pParams.angleVariance);
         this.moveVector = GVector.getAngularUnitVector(initAngle);
         var initVelocity:Number = this.pParams.velocityMin + (this.pParams.velocityMax - this.pParams.velocityMin) * Math.random();
         this.moveVector.x *= initVelocity;
         this.moveVector.y *= initVelocity;
         this.initTime = this.delay;
         this.elapsedTime = 0;
         this.endTime = this.pParams.life + getParamVariance(this.pParams.lifeVariance) + this.initTime;
      }
      
      internal function update(ticker:TimeTicker) : Boolean
      {
         var expired:Boolean = false;
         this.elapsedTime += ticker.getTickDuration();
         if(this.elapsedTime > this.initTime)
         {
            this.moveVector.y += this.pParams.gravity;
            this.currentPoint.x += this.moveVector.x;
            this.currentPoint.y += this.moveVector.y;
            if(this.elapsedTime > this.endTime)
            {
               colorTransform.alphaOffset = this.alphaShift;
               this.alphaOffset += colorTransform.alphaOffset;
               this.sourceBMD.colorTransform(this.sourceBMD.rect,colorTransform);
            }
            this.redraw();
            expired = !this.inViewRect() || this.alphaOffset <= 0;
            if(expired)
            {
               this.dispose();
            }
            return expired;
         }
         return false;
      }
      
      internal function inViewRect() : Boolean
      {
         return this.currentPoint.x >= this.viewRect.xMin - this.BORDER_SIZE && this.currentPoint.x <= this.viewRect.xMax + this.BORDER_SIZE && this.currentPoint.y >= this.viewRect.yMin - this.BORDER_SIZE && this.currentPoint.y <= this.viewRect.yMax + this.BORDER_SIZE;
      }
      
      internal function redraw() : void
      {
         this.drawBMD.copyPixels(this.sourceBMD,this.sourceBMD.rect,this.currentPoint,null,null,true);
      }
      
      internal function dispose() : void
      {
         this.sourceBMD.dispose();
      }
   }
}

