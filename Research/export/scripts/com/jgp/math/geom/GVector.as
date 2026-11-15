package com.jgp.math.geom
{
   public class GVector extends GPoint
   {
      
      public function GVector(initX:Number = 0, initY:Number = 0)
      {
         super(initX,initY);
      }
      
      public static function getAngularUnitVector(angle:Number) : GVector
      {
         return new GVector(Math.sin(angle),-Math.cos(angle));
      }
      
      public static function add(addTo:GVector, add:GVector) : void
      {
         addTo.x += add.x;
         addTo.y += add.y;
      }
      
      public static function subtract(addTo:GVector, add:GVector) : void
      {
         addTo.x -= add.x;
         addTo.y -= add.y;
      }
      
      override public function cloneMe() : GPoint
      {
         return new GVector(x,y);
      }
   }
}

