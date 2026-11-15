package com.game.ai.towers
{
   import com.game.grid.GameGrid;
   import com.game.ui.grid.GridSelectableItem;
   import com.jgp.functions.*;
   import com.jgp.math.geom.GPoint;
   import com.jgp.utils.TimeTicker;
   import flash.display.Sprite;
   import flash.events.*;
   
   public class TowerCollector extends Sprite
   {
      
      protected var gridRef:GameGrid;
      
      protected var activeTowers:Array;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      protected var cachedTargets:Object;
      
      public function TowerCollector(gridRef:GameGrid)
      {
         super();
         SimpleDispatcher.initialize(this);
         this.gridRef = gridRef;
         this.activeTowers = new Array();
      }
      
      public function placeTower(screenLoc:GPoint, towerConfig:Object) : GridSelectableItem
      {
         var dispatcher:SimpleDispatcher = new SimpleDispatcher();
         dispatcher.registerSimpleEvent("getTargets",new Callback(this,this.getTargets));
         dispatcher.registerSimpleEvent("fireShot",new Callback(this,this.fireShot));
         dispatcher.registerSimpleEvent("getProjectileParamsObj",new Callback(this,this.getProjectileParamsObj));
         var tower:* = new Tower(screenLoc,towerConfig,dispatcher);
         tower.x = screenLoc.x;
         tower.y = screenLoc.y;
         addChild(tower);
         this.activeTowers.push(tower);
         return tower;
      }
      
      public function removeTower(tower:Tower) : void
      {
         removeChild(tower);
         var removeIndex:Number = this.activeTowers.indexOf(tower);
         this.activeTowers.splice(removeIndex,1);
      }
      
      protected function getProjectileParamsObj(refName:String) : Object
      {
         return this.dispatchSimpleEvent("getProjectileParamsObj",[refName]);
      }
      
      protected function getTargets(tower:Tower, trackingFunct:Function = null, limit:Number = 1) : Array
      {
         var targets:Array = this.dispatchSimpleEvent("getTargets",[tower.getTargetingType(),trackingFunct,limit]);
         if(targets == null)
         {
            return null;
         }
         if(targets.length > 1)
         {
            targets.sortOn("currentPointCost",Array.NUMERIC);
         }
         return targets;
      }
      
      protected function fireShot(from:GPoint, target:*, targeting:String, projectileParamsObj:Object) : void
      {
         this.dispatchSimpleEvent("fireShot",[from,target,targeting,projectileParamsObj]);
      }
      
      public function update(ticker:TimeTicker) : void
      {
         var tower:Tower = null;
         this.cachedTargets = null;
         for each(tower in this.activeTowers)
         {
            tower.update(ticker);
         }
      }
   }
}

