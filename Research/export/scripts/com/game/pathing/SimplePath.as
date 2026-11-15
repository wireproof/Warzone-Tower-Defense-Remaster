package com.game.pathing
{
   import com.jgp.math.geom.*;
   import flash.utils.*;
   
   public class SimplePath
   {
      
      protected static const NEIGHBOR_CHECK:Array = [new GPoint(0,-1),new GPoint(0,1),new GPoint(-1,0),new GPoint(1,0),new GPoint(1,-1),new GPoint(1,1),new GPoint(-1,-1),new GPoint(-1,1)];
      
      protected static const MOVEMENT_COSTS:Array = [1,1,1,1,1.4,1.4,1.4,1.4];
      
      protected var prevPathedNodes:Object;
      
      protected var tempPoint:GPoint;
      
      protected var goalPoint:GPoint;
      
      protected var costFunction:Function;
      
      public function SimplePath(costFunction:Function)
      {
         super();
         this.costFunction = costFunction;
         this.prevPathedNodes = new Object();
         this.tempPoint = new GPoint();
      }
      
      public function findPath(startPoint:GPoint, endPoint:GPoint, validateFunct:Function) : Object
      {
         this.prevPathedNodes = new Object();
         var endOnPoint:Boolean = endPoint != null;
         if(endOnPoint)
         {
            if(GPoint.checkEquality(startPoint,endPoint))
            {
               return new Object();
            }
            this.goalPoint = endPoint.cloneMe();
         }
         else
         {
            this.goalPoint = startPoint.cloneMe();
         }
         var firstNode:Object = new Object();
         firstNode.point = startPoint;
         firstNode.parent = null;
         firstNode.cost = 0;
         firstNode.steps = 0;
         var nodeList:Array = [firstNode];
         return this.checkNodes(nodeList,endOnPoint,endPoint,validateFunct);
      }
      
      private function checkNodes(nodeList:Array, endOnPoint:Boolean, endPoint:GPoint, validateFunct:Function) : Object
      {
         var tNList:Array = null;
         var cN:Object = null;
         var n:uint = 0;
         var gLoc:GPoint = null;
         var nodeName:String = null;
         var nRef:Object = new Object();
         while(nodeList.length > 0)
         {
            tNList = new Array();
            n = 0;
            while(n < nodeList.length)
            {
               cN = nodeList[n];
               gLoc = cN.point;
               nodeName = cN.point.toString();
               if(nRef[nodeName] == null)
               {
                  nRef[nodeName] = cN;
                  if(endPoint != null)
                  {
                     if(GPoint.checkEquality(gLoc,endPoint))
                     {
                        return nRef;
                     }
                  }
                  this.getNeighbors(gLoc,cN,tNList,nRef,endPoint,validateFunct);
               }
               n++;
            }
            nodeList = tNList;
            nodeList.sortOn("cost",Array.NUMERIC);
         }
         return nRef;
      }
      
      private function getNeighbors(cP:GPoint, pN:Object, tempNodeList:Array, nRef:Object, endPoint:GPoint, validateFunct:Function) : void
      {
         var tN:Object = null;
         var nodeName:String = null;
         var ckP:GPoint = this.tempPoint;
         var n:uint = 0;
         var connectCount:Number = 0;
         while(n < NEIGHBOR_CHECK.length)
         {
            ckP.x = cP.x + NEIGHBOR_CHECK[n].x;
            ckP.y = cP.y + NEIGHBOR_CHECK[n].y;
            nodeName = ckP.toString();
            if(validateFunct(cP,ckP))
            {
               connectCount++;
               if(nRef[nodeName] == null)
               {
                  if(this.prevPathedNodes[nodeName] == null)
                  {
                     this.prevPathedNodes[nodeName] = new Object();
                     this.prevPathedNodes[nodeName].point = ckP.cloneMe();
                  }
                  tN = this.prevPathedNodes[nodeName];
                  tN.parent = pN;
                  tN.cost = pN.cost + this.costFunction(tN.point) * this.getMovementMultiplier(cP,tN.point);
                  tN.steps = pN.steps + 1;
                  tempNodeList.push(tN);
               }
               else if(nRef[nodeName] != null)
               {
                  tN = nRef[nodeName];
                  if(tN.cost < pN.parent.cost)
                  {
                     if(validateFunct(tN.point,pN.point))
                     {
                        pN.parent = tN;
                        tempNodeList.push(pN);
                        delete nRef[pN.point.toString()];
                        pN.cost = tN.cost + this.costFunction(pN.point) * this.getMovementMultiplier(pN.point,pN.parent.point);
                     }
                  }
               }
            }
            n++;
         }
      }
      
      protected function getMovementMultiplier(p1:GPoint, p2:GPoint) : Number
      {
         if(!(p1.x == p2.x || p1.y == p2.y))
         {
            return 1.4;
         }
         return 1;
      }
   }
}

