package com.jgp.math.helpers
{
   public class RotationHelper
   {
      
      public static var PI2:Number = Math.PI * 2;
      
      public static var PI:Number = Math.PI;
      
      public function RotationHelper()
      {
         super();
      }
      
      public static function limitAngleRads(angle:Number) : Number
      {
         if(angle < 0)
         {
            angle += PI2;
         }
         else if(angle > PI2)
         {
            angle -= PI2;
         }
         while(angle < 0 || angle > PI2)
         {
            angle = limitAngleRads(angle);
         }
         return angle;
      }
      
      public static function findShortestRotationRads(angle:Number) : Number
      {
         if(angle > PI)
         {
            angle = -(PI2 - angle);
         }
         else if(angle < -PI)
         {
            angle = PI2 + angle;
         }
         return angle;
      }
      
      public static function limitRotationIntensity(angle:Number, maxIntensity:Number) : Number
      {
         if(angle > maxIntensity)
         {
            angle = maxIntensity;
         }
         else if(angle < -maxIntensity)
         {
            angle = -maxIntensity;
         }
         return angle;
      }
      
      public static function degToRads(degrees:Number) : Number
      {
         return degrees / 180 * PI;
      }
      
      public static function radsToDeg(radians:Number) : *
      {
         return radians * 180 / PI;
      }
   }
}

