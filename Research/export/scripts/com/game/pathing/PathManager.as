package com.game.pathing
{
   import com.jgp.math.geom.GPoint;
   
   public class PathManager
   {
      
      protected static const NEIGHBOR_CHECK:Array = [new GPoint(0,-1),new GPoint(0,1),new GPoint(-1,0),new GPoint(1,0),new GPoint(1,-1),new GPoint(1,1),new GPoint(-1,-1),new GPoint(-1,1)];
      
      protected static var MAX_ALT_PATH_STEPS:Number = 8;
      
      protected static var GOAL_CHECK_DISTANCE:Number = 2;
      
      protected var pathFinder:SimplePath;
      
      protected var defaultValidationFunct:Function;
      
      protected var activePaths:Array;
      
      protected var fromPoints:Array;
      
      public function PathManager(defaultValidation:Function, costFunction:Function)
      {
         super();
         this.defaultValidationFunct = defaultValidation;
         this.pathFinder = new SimplePath(costFunction);
      }
      
      public function generatePathing(fromPoints:Array, reqPoints:Array, validate:Function = null) : Boolean
      {
         var pathFound:Object = null;
         this.fromPoints = fromPoints;
         if(validate == null)
         {
            validate = this.defaultValidationFunct;
         }
         var tempPaths:Array = new Array();
         for(var i:Number = 0; i < fromPoints.length; i++)
         {
            pathFound = this.pathFinder.findPath(fromPoints[i],null,validate);
            if(pathFound == null)
            {
               return false;
            }
            tempPaths.push(pathFound);
         }
         if(!this.validateReqPoints(tempPaths,reqPoints))
         {
            return false;
         }
         this.activePaths = tempPaths;
         return true;
      }
      
      protected function validateReqPoints(tempPaths:Array, reqPoints:Array) : Boolean
      {
         var point:GPoint = null;
         var path:Object = null;
         for each(point in reqPoints)
         {
            for each(path in tempPaths)
            {
               if(path[point.toString()] == null)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function checkIfGoalPoint(point:GPoint) : Boolean
      {
         var goalPoint:GPoint = null;
         var xDif:Number = NaN;
         var yDif:Number = NaN;
         for each(goalPoint in this.fromPoints)
         {
            xDif = Math.abs(point.x - goalPoint.x);
            yDif = Math.abs(point.y - goalPoint.y);
            if(xDif <= GOAL_CHECK_DISTANCE && yDif <= GOAL_CHECK_DISTANCE)
            {
               return true;
            }
         }
         return false;
      }
      
      public function getConnectionPoints(point:GPoint, validateFunct:Function) : Array
      {
         var connectNode:Object = null;
         var previousPointCost:Number = Number(this.getLowestValuedNode(point,"cost").node.cost);
         var excludeRefs:Object = new Object();
         var initNode:Object = this.getLowestValuedNode(point,"cost").node;
         var pathedNodes:Array = this.getPathedNodeList([initNode],validateFunct,excludeRefs);
         var connectChain:Array = new Array();
         while(pathedNodes.length > 0)
         {
            pathedNodes.sortOn("cost",Array.NUMERIC);
            connectNode = pathedNodes[0];
            connectChain.push(pathedNodes[0]);
            if(connectNode.cost < previousPointCost)
            {
               return connectChain;
            }
            pathedNodes = this.getPathedNodeList([connectNode],validateFunct,excludeRefs);
            if(connectChain.length >= MAX_ALT_PATH_STEPS)
            {
               break;
            }
         }
         return [initNode];
      }
      
      protected function getPathedNodeList(checkNodeList:Array, validateFunct:Function, excludeRefs:Object) : Array
      {
         var node:Object = null;
         var pathedNodes:Array = new Array();
         for each(node in checkNodeList)
         {
            if(excludeRefs[node.point.toString()] == null)
            {
               excludeRefs[node.point.toString()] = 1;
               this.getNeighbors(node.point,pathedNodes,validateFunct,excludeRefs);
            }
         }
         return pathedNodes;
      }
      
      protected function getNeighbors(point:GPoint, pathedNodes:Array, validateFunct:Function, excludeRefs:Object) : void
      {
         var connectNode:Object = null;
         var connectNodeName:String = null;
         var neighborPoint:GPoint = null;
         var pathNode:Object = null;
         var path:Object = null;
         var connectPoint:GPoint = new GPoint();
         var nodeName:String = point.toString();
         for each(path in this.activePaths)
         {
            pathNode = path[nodeName];
            for each(neighborPoint in NEIGHBOR_CHECK)
            {
               if(pathNode != null)
               {
                  connectPoint.x = point.x + neighborPoint.x;
                  connectPoint.y = point.y + neighborPoint.y;
                  connectNodeName = connectPoint.toString();
                  connectNode = path[connectNodeName];
                  if(Boolean(connectNode != null) && Boolean(validateFunct(point,connectPoint)) && excludeRefs[connectNodeName] == null)
                  {
                     pathedNodes.push(connectNode);
                  }
               }
            }
         }
      }
      
      public function getLowestValuedNode(point:GPoint, sortOn:String) : Object
      {
         var node:Object = null;
         var path:Object = null;
         var index:Number = NaN;
         var lowestCost:Number = Infinity;
         var nodeName:String = point.toString();
         for(var p:Number = 0; p < this.activePaths.length; p++)
         {
            path = this.activePaths[p];
            if(path[nodeName][sortOn] < lowestCost)
            {
               lowestCost = Number(path[nodeName][sortOn]);
               node = path[nodeName];
               index = p;
            }
         }
         return {
            "node":node,
            "pathIndex":index
         };
      }
      
      public function getLowestCostForPoint(point:GPoint) : Number
      {
         return this.getLowestValuedNode(point,"cost").node.cost;
      }
      
      public function getActivePaths() : Array
      {
         return this.activePaths;
      }
   }
}

