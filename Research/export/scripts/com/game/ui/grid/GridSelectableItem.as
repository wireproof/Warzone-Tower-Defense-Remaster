package com.game.ui.grid
{
   import com.jgp.functions.*;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.utils.getDefinitionByName;
   
   public class GridSelectableItem extends MovieClip
   {
      
      private static var cashValueMultiplier:Number = 1;
      
      protected var skin:MovieClip;
      
      protected var skinName:String;
      
      private var info:String;
      
      private var blockSize:Number;
      
      private var selectObj:MovieClip;
      
      private var itemName:String = "unamed item";
      
      private var upgradePaths:String = "";
      
      private var cashValue:Number = 0;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function GridSelectableItem(dispatcher:SimpleDispatcher, paramObj:Object)
      {
         super();
         SimpleDispatcher.initialize(this,dispatcher);
         this.applyParamObject(paramObj);
         this.setSkin(this.skinName);
      }
      
      public static function setCashValueMultiplier(multiplier:Number) : void
      {
         cashValueMultiplier = multiplier;
      }
      
      protected function applyParamObject(paramObject:Object) : void
      {
         var p:String = null;
         for(p in paramObject)
         {
            try
            {
               this[p] = paramObject[p];
            }
            catch(error:Error)
            {
            }
         }
      }
      
      protected function setSkin(skinLibName:String) : void
      {
         var skinClass:Class = getDefinitionByName(skinLibName) as Class;
         this.skin = new skinClass();
         addChild(this.skin);
      }
      
      public function setSelectArea(selectObj:MovieClip, blockSize:Number) : void
      {
         this.blockSize = blockSize;
         this.selectObj = selectObj;
         selectObj.addEventListener(MouseEvent.MOUSE_DOWN,this.onSelected,false,0,true);
      }
      
      public function setUpgradePaths(upgradePaths:String) : void
      {
         this.upgradePaths = upgradePaths;
      }
      
      public function getUpgradePaths() : String
      {
         return this.upgradePaths;
      }
      
      public function applyUpgrade(upgradeObj:Object) : void
      {
         this.addToCashValue(upgradeObj.cost);
         this.applyParamObject(upgradeObj.item);
         removeChild(this.skin);
         this.setSkin(this.skinName);
      }
      
      protected function onSelected(event:MouseEvent) : void
      {
         this.dispatchSimpleEvent("onSelected",[this]);
      }
      
      public function addToCashValue(cashAmmount:Number) : void
      {
         this.cashValue += cashAmmount;
      }
      
      public function getCashValue() : Number
      {
         return Math.ceil(this.cashValue * cashValueMultiplier);
      }
      
      public function getBlockSize() : Number
      {
         return this.blockSize;
      }
      
      public function getSelectObj() : MovieClip
      {
         return this.selectObj;
      }
      
      public function getStatsObj() : Object
      {
         var statsObj:Object = new Object();
         statsObj.itemName = this.itemName;
         statsObj.cashValue = Math.ceil(this.cashValue * cashValueMultiplier);
         statsObj.info = this.info;
         return statsObj;
      }
   }
}

