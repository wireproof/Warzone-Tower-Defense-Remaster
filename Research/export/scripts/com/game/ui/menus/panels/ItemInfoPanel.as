package com.game.ui.menus.panels
{
   import com.game.ai.towers.Tower;
   import com.game.ui.grid.GridSelectableItem;
   import com.jgp.functions.*;
   import com.jgp.helpers.ObjectHelper;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.text.TextField;
   import flash.utils.getQualifiedClassName;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol382")]
   public class ItemInfoPanel extends MovieClip
   {
      
      public var currentText:TextField;
      
      public var itemInfo:MovieClip;
      
      public var panel:UpgradePanel;
      
      protected var upgradeDisplay:Sprite;
      
      protected var selectedGridItem:GridSelectableItem;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function ItemInfoPanel()
      {
         addFrameScript(13,this.frame14);
         super();
         SimpleDispatcher.initialize(this);
         this.panel.registerSimpleEvent("onActionSelected",new Callback(this,this.sellCurrentSelection));
         this.panel.setActionButtonLabel("SELL");
         cacheAsBitmap = true;
      }
      
      protected function sellCurrentSelection() : void
      {
         this.dispatchSimpleEvent("sellCurrentSelection",[this.selectedGridItem.getCashValue()]);
      }
      
      public function displayGridItemInfo(selectedItem:GridSelectableItem) : void
      {
         var displayTextObj:Object = null;
         var tower:Tower = null;
         var projectileStats:Object = null;
         var combinedStats:Object = null;
         this.panel.showButton();
         this.selectedGridItem = selectedItem;
         this.clearUpgradeDisplay();
         var statsObj:Object = selectedItem.getStatsObj();
         this.setInfoDisplay(statsObj);
         if(selectedItem is Tower)
         {
            tower = selectedItem as Tower;
            projectileStats = tower.getProjectileObj();
            combinedStats = this.getCombinedStatsObj(statsObj,projectileStats);
            displayTextObj = this.getDisplayText(combinedStats);
            this.buildUpgradeDisplay(combinedStats,selectedItem,this.getDisplayText);
         }
         else
         {
            displayTextObj = this.getDisplayText(statsObj);
            this.buildUpgradeDisplay(statsObj,selectedItem,this.getDisplayText);
         }
         this.panel.setText(displayTextObj);
      }
      
      public function displayStoreItemInfo(statsObj:Object) : *
      {
         this.setInfoDisplay(statsObj);
         this.panel.bg.gotoAndStop(1);
         this.panel.hideButton();
         this.selectedGridItem = null;
         this.clearUpgradeDisplay();
         var displayTextObj:Object = this.getDisplayText(statsObj);
         this.panel.setText(displayTextObj);
      }
      
      protected function setInfoDisplay(statsObj:Object) : *
      {
         if(statsObj.info != null)
         {
            this.itemInfo.infoText.text = statsObj.info;
         }
         else
         {
            this.itemInfo.infoText.text = "";
         }
      }
      
      protected function buildUpgradeDisplay(combinedStats:Object, selectedItem:GridSelectableItem, displayFunct:Function) : void
      {
         var upgradePanel:UpgradePanel = null;
         var upgradeId:String = null;
         var clonedObj:Object = null;
         var upgradeObj:Object = null;
         var p:String = null;
         this.upgradeDisplay = new Sprite();
         this.upgradeDisplay.x = this.panel.x + this.panel.width;
         this.upgradeDisplay.y = this.panel.y;
         var xShift:Number = 0;
         var upgradePathList:Array = selectedItem.getUpgradePaths().split(",");
         var upgradesSet:Number = 0;
         for(var i:Number = 0; i < upgradePathList.length; i++)
         {
            upgradeId = upgradePathList[i];
            clonedObj = ObjectHelper.cloneObject(combinedStats);
            upgradeObj = this.dispatchSimpleEvent("getUpgradeRef",[upgradeId]);
            if(upgradeObj != null)
            {
               upgradesSet++;
               for(p in upgradeObj)
               {
                  if(getQualifiedClassName(upgradeObj[p]) == "Object")
                  {
                     ObjectHelper.copyProps(clonedObj,upgradeObj[p]);
                  }
                  else
                  {
                     clonedObj[p] = upgradeObj[p];
                  }
               }
               upgradePanel = new UpgradePanel();
               upgradePanel.setText(displayFunct(clonedObj));
               upgradePanel.setActionButtonLabel("BUY");
               upgradePanel.registerSimpleEvent("onActionSelected",new Callback(this,this.applyUpgrade,[upgradeObj]));
               upgradePanel.x = xShift;
               this.upgradeDisplay.addChild(upgradePanel);
               xShift += this.panel.width;
               if(i == upgradePathList.length - 1)
               {
                  upgradePanel.bg.gotoAndStop(1);
               }
               else
               {
                  upgradePanel.bg.gotoAndStop(2);
               }
            }
         }
         addChild(this.upgradeDisplay);
         if(upgradesSet > 0)
         {
            this.panel.bg.gotoAndStop(2);
         }
         else
         {
            this.panel.bg.gotoAndStop(1);
         }
      }
      
      protected function clearUpgradeDisplay() : void
      {
         if(this.upgradeDisplay != null)
         {
            removeChild(this.upgradeDisplay);
         }
         this.upgradeDisplay = null;
      }
      
      public function getCombinedStatsObj(statsObj:Object, projectileObj:Object, upgradeObj:Object = null) : Object
      {
         var combined:Object = ObjectHelper.cloneObject(statsObj);
         ObjectHelper.copyProps(combined,projectileObj);
         if(upgradeObj != null)
         {
            ObjectHelper.copyProps(combined,upgradeObj);
         }
         return combined;
      }
      
      protected function getDisplayText(combinedStats:Object) : Object
      {
         var displayObj:Object = new Object();
         if(this.displayPropValid(combinedStats,"cost"))
         {
            displayObj.cashText = "$" + combinedStats.cost + "\n";
         }
         else if(this.displayPropValid(combinedStats,"cashValue"))
         {
            displayObj.cashText = "$" + combinedStats.cashValue + "\n";
         }
         else
         {
            displayObj.cashText = "N/A" + "\n";
         }
         displayObj.titleText = combinedStats.itemName.toUpperCase();
         displayObj.bodyText = new String();
         if(this.displayPropValid(combinedStats,"targeting"))
         {
            displayObj.bodyText += combinedStats.targeting.toUpperCase() + "\n";
         }
         else
         {
            displayObj.bodyText += "N/A" + "\n";
         }
         var damage:Number = 0;
         if(this.displayPropValid(combinedStats,"directDamage"))
         {
            damage += Number(combinedStats.directDamage);
         }
         if(this.displayPropValid(combinedStats,"indirectDamage"))
         {
            damage += Number(combinedStats.indirectDamage);
         }
         if(damage > 0)
         {
            displayObj.bodyText += damage;
            if(this.displayPropValid(combinedStats,"shotsAtOnce"))
            {
               if(combinedStats.shotsAtOnce > 1)
               {
                  displayObj.bodyText += " x " + combinedStats.shotsAtOnce;
               }
            }
            if(!combinedStats.activeDamageCheck)
            {
            }
            displayObj.bodyText += "\n";
         }
         else
         {
            displayObj.bodyText += "N/A" + "\n";
         }
         if(this.displayPropValid(combinedStats,"range"))
         {
            displayObj.bodyText += combinedStats.range + "\n";
         }
         else
         {
            displayObj.bodyText += "N/A" + "\n";
         }
         if(this.displayPropValid(combinedStats,"explosionRadius"))
         {
            displayObj.bodyText += combinedStats.explosionRadius + "\n";
         }
         else
         {
            displayObj.bodyText += "N/A" + "\n";
         }
         if(this.displayPropValid(combinedStats,"reloadTime"))
         {
            displayObj.bodyText += combinedStats.reloadTime / 1000 + " SEC" + "\n";
         }
         else
         {
            displayObj.bodyText += "N/A" + "\n";
         }
         return displayObj;
      }
      
      protected function applyUpgrade(upgradeObj:Object) : void
      {
         var tower:Tower = null;
         var upgradeCost:Number = Number(upgradeObj.cost);
         var enoughCash:Boolean = this.dispatchSimpleEvent("checkIfEnoughCash",[upgradeCost]);
         if(enoughCash)
         {
            this.dispatchSimpleEvent("subtractCash",[upgradeCost]);
            if(this.selectedGridItem is Tower)
            {
               tower = this.selectedGridItem as Tower;
               tower.applyUpgrade(upgradeObj);
            }
            else
            {
               this.selectedGridItem.applyUpgrade(upgradeObj);
            }
            this.dispatchSimpleEvent("resetPanel",[this.selectedGridItem]);
         }
      }
      
      protected function displayPropValid(statsObj:Object, propName:String) : Boolean
      {
         return !(statsObj[propName] == null || statsObj[propName] == 0);
      }
      
      internal function frame14() : *
      {
         stop();
      }
   }
}

