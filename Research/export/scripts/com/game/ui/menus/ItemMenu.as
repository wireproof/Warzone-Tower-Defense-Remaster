package com.game.ui.menus
{
   import com.game.ui.grid.GridSelectableItem;
   import com.game.ui.menus.buttons.ItemSelectButton;
   import com.game.ui.menus.panels.ItemInfoPanel;
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.helpers.ObjectHelper;
   import com.jgp.math.geom.GPoint;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol350")]
   public class ItemMenu extends MovieClip
   {
      
      public var cashText:TextField;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      protected var itemRefs:Object;
      
      protected var upgradeRefs:Object;
      
      protected var selectedButton:ItemSelectButton;
      
      protected var itemInfoPanel:ItemInfoPanel;
      
      protected var allowPanelHide:Boolean = true;
      
      protected var itemButtons:Array;
      
      protected var groundOnly:Boolean;
      
      public function ItemMenu(configObject:Object)
      {
         super();
         SimpleDispatcher.initialize(this);
         this.groundOnly = configObject.groundOnly;
         this.itemRefs = configObject.itemRefs;
         this.setItemButtons(configObject.buttonConfigList);
         this.upgradeRefs = configObject.upgradeRefs;
         this.itemInfoPanel = new ItemInfoPanel();
         var screenLoc:GPoint = GPoint.pointFromString(configObject.infoPanel.screenLoc);
         this.itemInfoPanel.x = screenLoc.x;
         this.itemInfoPanel.y = screenLoc.y;
         this.itemInfoPanel.registerSimpleEvent("sellCurrentSelection",new Callback(this,this.sellCurrentSelection));
         this.itemInfoPanel.registerSimpleEvent("getUpgradeRef",new Callback(this,this.getUpgradeRef));
         this.itemInfoPanel.registerSimpleEvent("resetPanel",new Callback(this,this.resetGridItemPanel));
         this.itemInfoPanel.registerSimpleEvent("checkIfEnoughCash",new Callback(this,this.checkIfEnoughCash));
         this.itemInfoPanel.registerSimpleEvent("subtractCash",new Callback(this,this.subtractCash));
         cacheAsBitmap = true;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      protected function onAddedToStage(event:Event) : void
      {
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPressed);
      }
      
      protected function onRemovedFromStage(event:Event) : void
      {
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPressed);
      }
      
      protected function onKeyPressed(event:KeyboardEvent) : void
      {
         if(!mouseChildren)
         {
            return;
         }
         if(event.keyCode == 49)
         {
            this.onItemButtonSelected(this.itemButtons[0]);
         }
         else if(event.keyCode == 50)
         {
            this.onItemButtonSelected(this.itemButtons[1]);
         }
         else if(event.keyCode == 51)
         {
            this.onItemButtonSelected(this.itemButtons[2]);
         }
         else if(event.keyCode == 52)
         {
            this.onItemButtonSelected(this.itemButtons[3]);
         }
         else if(event.keyCode == 53)
         {
            this.onItemButtonSelected(this.itemButtons[4]);
         }
         else if(event.keyCode == 54)
         {
            this.onItemButtonSelected(this.itemButtons[5]);
         }
         else if(event.keyCode == 55)
         {
            this.onItemButtonSelected(this.itemButtons[6]);
         }
         else if(event.keyCode == 56)
         {
            this.onItemButtonSelected(this.itemButtons[7]);
         }
         else if(event.keyCode == 57)
         {
            this.onItemButtonSelected(this.itemButtons[8]);
         }
         else if(event.keyCode == 58)
         {
            this.onItemButtonSelected(this.itemButtons[9]);
         }
         else if(event.keyCode == 81)
         {
            this.onItemButtonSelected(this.itemButtons[9]);
         }
         else if(event.keyCode == 87)
         {
            this.onItemButtonSelected(this.itemButtons[10]);
         }
         else if(event.keyCode == 69)
         {
            this.onItemButtonSelected(this.itemButtons[11]);
         }
         else if(event.keyCode == 82)
         {
            this.onItemButtonSelected(this.itemButtons[12]);
         }
      }
      
      protected function setItemButtons(buttonList:Array) : void
      {
         var selectButton:ItemSelectButton = null;
         var itemRef:Object = null;
         var buttonConfig:Object = null;
         this.itemButtons = new Array();
         var buttonDispatcher:SimpleDispatcher = new SimpleDispatcher();
         buttonDispatcher.registerSimpleEvent("onSelected",new Callback(this,this.onItemButtonSelected));
         for each(buttonConfig in buttonList)
         {
            selectButton = new ItemSelectButton(buttonConfig,buttonDispatcher);
            addChild(selectButton);
            this.itemButtons.push(selectButton);
            if(this.groundOnly)
            {
               itemRef = this.getItemRef(buttonConfig.itemId);
               if(itemRef.tower != null)
               {
                  if(itemRef.tower.targeting != null)
                  {
                     if(itemRef.tower.targeting == "air")
                     {
                        selectButton.disable();
                     }
                  }
               }
            }
         }
      }
      
      protected function onItemButtonSelected(itemBut:ItemSelectButton) : void
      {
         if(this.selectedButton != null)
         {
            this.selectedButton.setUnselectState();
         }
         this.selectedButton = itemBut;
         if(!this.selectedButton.isEnabled())
         {
            return;
         }
         this.selectedButton.setSelectState();
         var itemObj:Object = this.getItemRef(itemBut.getItemId());
         this.showStoreItemInfoPanel(itemObj);
         this.dispatchSimpleEvent("onItemSelected",[itemObj]);
      }
      
      public function deselectActiveButton() : void
      {
         if(this.selectedButton != null)
         {
            this.selectedButton.setUnselectState();
         }
         this.selectedButton = null;
      }
      
      protected function sellCurrentSelection(cashValue:Number) : void
      {
         this.hideItemInfoPanel();
         this.dispatchSimpleEvent("sellCurrentSelection",[cashValue]);
      }
      
      protected function resetGridItemPanel(selectedItem:GridSelectableItem) : void
      {
         this.showGridItemInfoPanel(selectedItem);
         this.dispatchSimpleEvent("onResetGridItemPanel");
      }
      
      public function showGridItemInfoPanel(selectedItem:GridSelectableItem) : void
      {
         this.itemInfoPanel.displayGridItemInfo(selectedItem);
         if(!contains(this.itemInfoPanel))
         {
            addChild(this.itemInfoPanel);
         }
         this.allowPanelHide = true;
      }
      
      public function showStoreItemInfoPanel(itemObj:Object) : void
      {
         var projectileParams:Object = null;
         var bombObj:* = undefined;
         var combinedObj:Object = new Object();
         combinedObj = ObjectHelper.cloneObject(itemObj);
         if(combinedObj.tower != null)
         {
            ObjectHelper.copyProps(combinedObj,combinedObj.tower);
            projectileParams = this.dispatchSimpleEvent("getProjectileParamsObj",[combinedObj.projectileRefName]);
            ObjectHelper.copyProps(combinedObj,projectileParams);
         }
         if(combinedObj.bomb != null)
         {
            bombObj = this.dispatchSimpleEvent("getProjectileParamsObj",[combinedObj.bomb]);
            ObjectHelper.copyProps(combinedObj,bombObj);
         }
         this.itemInfoPanel.displayStoreItemInfo(combinedObj);
         if(!contains(this.itemInfoPanel))
         {
            addChild(this.itemInfoPanel);
         }
         this.allowPanelHide = false;
      }
      
      public function hideItemInfoPanel(overridePanelHide:Boolean = false) : void
      {
         if(overridePanelHide)
         {
            this.allowPanelHide = false;
         }
         if(this.allowPanelHide)
         {
            if(contains(this.itemInfoPanel))
            {
               removeChild(this.itemInfoPanel);
            }
         }
      }
      
      public function getInfoPanelContainer() : ItemInfoPanel
      {
         return this.itemInfoPanel;
      }
      
      public function getItemRef(refName:String) : Object
      {
         return this.itemRefs[refName];
      }
      
      public function getUpgradeRef(refName:String) : Object
      {
         return this.upgradeRefs[refName];
      }
      
      public function updateCashDisplay(currentCash:Number) : void
      {
         this.cashText.text = "$" + String(currentCash);
      }
      
      protected function checkIfEnoughCash(cashValue:Number) : Boolean
      {
         return this.dispatchSimpleEvent("checkIfEnoughCash",[cashValue]);
      }
      
      protected function subtractCash(cashValue:Number) : void
      {
         this.dispatchSimpleEvent("subtractCash",[cashValue]);
      }
   }
}

