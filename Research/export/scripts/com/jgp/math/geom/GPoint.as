package com.jgp.math.geom
{
   import flash.geom.Point;
   
   public class GPoint extends Point
   {
      
      public function GPoint(initX:Number = 0, initY:Number = 0)
      {
         super();
         x = initX;
         y = initY;
      }
      
      public static function getDistance(p1:GPoint, p2:GPoint) : Number
      {
         var a:Number = (p1.x - p2.x) * (p1.x - p2.x);
         var b:Number = (p1.y - p2.y) * (p1.y - p2.y);
         return Math.sqrt(a + b);
      }
      
      public static function getAngle(p1:GPoint, p2:GPoint) : Object
      {
         var x:Number = p2.x - p1.x;
         var y:Number = p1.y - p2.y;
         var angle:Number = Math.atan2(x,y);
         var converted:Number = angle * 180 / Math.PI;
         return {
            "radians":angle,
            "degrees":converted
         };
      }
      
      public static function checkEquality(V1:GPoint, V2:GPoint) : Boolean
      {
         return V1.x == V2.x && V1.y == V2.y;
      }
      
      public static function pointFromString(pointString:String) : GPoint
      {
         var vals:Array = pointString.split(",");
         return new GPoint(Number(vals[0]),Number(vals[1]));
      }
      
      public static function getPointArray(refs:Object) : Array
      {
         var i:String = null;
         var pointArray:Array = new Array();
         for(i in refs)
         {
            pointArray.push(pointFromString(i));
         }
         return pointArray;
      }
      
      public function cloneMe() : GPoint
      {
         return new GPoint(x,y);
      }
      
      override public function toString() : String
      {
         return x + "," + y;
      }
   }
}

