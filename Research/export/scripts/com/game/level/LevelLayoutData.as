package com.game.level
{
   import com.jgp.functions.Callback;
   import com.jgp.math.geom.GPoint;
   import com.jgp.xml.XMLFetch;
   import flash.net.URLVariables;
   
   public class LevelLayoutData extends XMLFetch
   {
      
      public function LevelLayoutData(fileName:String = null, loadCallback:Callback = null, urlVar:URLVariables = null, urlReqMeth:String = null)
      {
         super(fileName,loadCallback,urlVar,urlReqMeth);
      }
      
      public function getBlockList(gridName:String, listName:String) : Array
      {
         var obj:Object = null;
         var rawPoints:Array = fetch("level.gridRefs." + gridName + "." + listName);
         var processedPoints:Array = new Array();
         for each(obj in rawPoints)
         {
            processedPoints.push(GPoint.pointFromString(obj.point));
         }
         return processedPoints;
      }
      
      public function getBlockRefs(gridName:String, listName:String) : Object
      {
         var obj:Object = null;
         var rawPoints:Array = fetch("level.gridRefs." + gridName + "." + listName);
         var refObj:Object = new Object();
         for each(obj in rawPoints)
         {
            refObj[obj.point] = obj.value;
         }
         return refObj;
      }
   }
}

