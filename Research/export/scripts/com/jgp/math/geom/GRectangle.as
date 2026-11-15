package com.jgp.math.geom
{
   public class GRectangle
   {
      
      public var xMin:Number;
      
      public var xMax:Number;
      
      public var yMin:Number;
      
      public var yMax:Number;
      
      public function GRectangle(p1:GPoint, p2:GPoint)
      {
         super();
         this.setBounds(p1,p2);
      }
      
      public function setBounds(p1:GPoint, p2:GPoint) : void
      {
         if(p1.x <= p2.x)
         {
            this.xMin = p1.x;
            this.xMax = p2.x;
         }
         else
         {
            this.xMin = p2.x;
            this.xMax = p2.x;
         }
         if(p1.y <= p2.y)
         {
            this.yMin = p1.y;
            this.yMax = p2.y;
         }
         else
         {
            this.yMin = p2.y;
            this.yMax = p2.y;
         }
      }
      
      public function get topRight() : GPoint
      {
         return new GPoint(this.xMax,this.yMin);
      }
      
      public function get topLeft() : GPoint
      {
         return new GPoint(this.xMin,this.yMin);
      }
      
      public function get bottomRight() : GPoint
      {
         return new GPoint(this.xMax,this.yMax);
      }
      
      public function get bottomLeft() : GPoint
      {
         return new GPoint(this.xMin,this.yMax);
      }
   }
}

