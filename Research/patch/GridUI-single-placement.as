package com.game.ui.grid
{
   import com.game.ai.creeps.Creep;
   import com.game.ai.towers.Tower;
   import com.game.grid.GameGrid;
   import com.jgp.audio.AudioControl;
   import com.jgp.functions.*;
   import com.jgp.helpers.ObjectHelper;
   import com.jgp.math.geom.GPoint;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.*;
   import flash.geom.ColorTransform;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol448")]
   public class GridUI extends MovieClip
   {
      
      protected var gridRef:GameGrid;
      
      protected var mouseLoc:GPoint;
      
      protected var highlight:MovieClip;
      
      protected var currentBlockSize:Number;
      
      protected var activeItemObject:Object;
      
      protected var selectedGridItem:GridSelectableItem;
      
      protected var gridSelectLayer:Sprite;
      
      protected var towerSelector:TowerSelector;
      
      protected var msgClip:MovieClip;
      
      protected var deselectExclusions:Array;
      
      protected var towerLimit:Number;
      
      protected var towersRemaining:Number;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function GridUI(gridRef:GameGrid, towerLimit:Number)
      {
         super();
         SimpleDispatcher.initialize(this);
         this.gridRef = gridRef;
         this.towerLimit = towerLimit;
         this.towersRemaining = towerLimit;
         this.deselectExclusions = new Array();
         this.highlight = new GridHighlighter();
         this.highlight.visible = false;
         addChild(this.highlight);
         addEventListener(Event.ADDED_TO_STAGE,this.setMouseEvents,false,0,true);
         addEventListener(Event.REMOVED_FROM_STAGE,this.clearMouseEvents,false,0,true);
         this.gridSelectLayer = new Sprite();
         addChild(this.gridSelectLayer);
         this.towerSelector = new TowerSelector();
         this.createMessageClip();
      }
      
      protected function onKeyPressed(event:KeyboardEvent) : void
      {
         if(event.keyCode == 27 || event.keyCode == 32)
         {
            this.clearSelection();
         }
      }
      
      protected function setMouseEvents(event:Event = null) : void
      {
         this.setEvents();
      }
      
      protected function clearMouseEvents(event:Event = null) : void
      {
         this.clearEvents();
      }
      
      public function setEvents() : void
      {
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPressed);
         addEventListener(Event.ENTER_FRAME,this.updateSelectionState,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_DOWN,this.onMousePressed,false,0,true);
      }
      
      public function clearEvents() : void
      {
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this.onKeyPressed);
         removeEventListener(Event.ENTER_FRAME,this.updateSelectionState);
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,this.onMousePressed);
      }
      
      protected function updateMouseLoc() : void
      {
         if(this.mouseLoc == null)
         {
            this.mouseLoc = new GPoint();
         }
         this.mouseLoc.x = mouseX;
         this.mouseLoc.y = mouseY;
      }
      
      protected function updateSelectionState(event:Event = null) : void
      {
         this.updateMouseLoc();
         var gridLoc:GPoint = this.gridRef.screenToGridLoc(this.mouseLoc);
         if(this.gridRef.checkPointSelectable(gridLoc) && this.activeItemObject != null)
         {
            this.highlight.visible = true;
            if(this.currentBlockSize > 0)
            {
               this.updatePlacementCursor(gridLoc);
            }
            else
            {
               this.updateTargetCursor();
            }
         }
         else
         {
            this.highlight.visible = false;
         }
         if(this.selectedGridItem != null)
         {
            if(this.selectedGridItem is Tower)
            {
               this.showTowerTarget();
            }
         }
      }
      
      public function clearSelection() : void
      {
         if(this.activeItemObject != null)
         {
            this.activeItemObject = null;
            if(this.selectedGridItem != null)
            {
               this.deactivateGridSelection();
            }
            this.dispatchSimpleEvent("onActiveItemSet");
            this.highlight.gotoAndStop(1);
            this.highlight.visible = false;
            this.gridSelectLayer.mouseChildren = true;
         }
      }
      
      protected function updatePlacementCursor(gridLoc:GPoint) : void
      {
         var range:Number = NaN;
         var maxX:Number = this.gridRef.getGridWidth() - this.currentBlockSize - 1;
         if(gridLoc.x > maxX)
         {
            gridLoc.x = maxX;
         }
         var maxY:Number = this.gridRef.getGridHeight() - this.currentBlockSize - 1;
         if(gridLoc.y > maxY)
         {
            gridLoc.y = maxY;
         }
         this.highlight.placement.visible = true;
         this.highlight.target.visible = false;
         this.gridSelectLayer.mouseChildren = true;
         var highlightSize:Number = this.gridRef.getTileSize() * this.currentBlockSize;
         this.highlight.placement.block.gotoAndStop(this.currentBlockSize);
         if(this.activeItemObject.tower != null)
         {
            this.highlight.placement.rangeIndicator.visible = true;
            range = Number(this.activeItemObject.tower.range);
            this.highlight.placement.rangeIndicator.width = range * 2;
            this.highlight.placement.rangeIndicator.height = range * 2;
            this.highlight.placement.rangeIndicator.x = highlightSize / 2;
            this.highlight.placement.rangeIndicator.y = highlightSize / 2;
         }
         else
         {
            this.highlight.placement.rangeIndicator.visible = false;
         }
         var highlightScreenLoc:GPoint = this.gridRef.gridToScreenLoc(gridLoc);
         this.highlight.x = highlightScreenLoc.x;
         this.highlight.y = highlightScreenLoc.y;
         var blockAvailable:* = this.gridRef.checkBlockAvailable(gridLoc,this.currentBlockSize) && !(this.activeItemObject["tower"] != null && this.towersRemaining == 0);
         this.updateHighlightColor(blockAvailable);
      }
      
      protected function updateTargetCursor() : void
      {
         this.highlight.placement.visible = false;
         this.highlight.target.visible = true;
         this.gridSelectLayer.mouseChildren = false;
         var bombObj:Object = this.dispatchSimpleEvent("getProjectileParamsObj",[this.activeItemObject.bomb]);
         this.highlight.target.width = bombObj.explosionRadius * 2;
         this.highlight.target.height = bombObj.explosionRadius * 2;
         this.updateHighlightColor(this.dispatchSimpleEvent("checkIfEnoughCash",[this.activeItemObject.cost]));
         this.highlight.x = this.mouseLoc.x;
         this.highlight.y = this.mouseLoc.y;
      }
      
      protected function onMousePressed(event:MouseEvent) : void
      {
         this.updateMouseLoc();
         var gridLoc:GPoint = this.gridRef.screenToGridLoc(this.mouseLoc);
         if(this.activeItemObject != null && this.gridRef.checkPointSelectable(gridLoc))
         {
            if(this.currentBlockSize > 0)
            {
               this.setGridPlacement(gridLoc);
            }
            if(this.activeItemObject != null && this.activeItemObject.bomb != null)
            {
               this.setBomb();
            }
         }
         if(this.selectedGridItem != null)
         {
            if(!this.isDeselectExclusion(event.target as DisplayObject))
            {
               if(this.selectedGridItem is Tower)
               {
                  if(!this.attemptTargetOverride())
                  {
                     this.deactivateGridSelection();
                  }
               }
               else
               {
                  this.deactivateGridSelection();
               }
            }
         }
      }
      
      protected function setBomb() : void
      {
         var enoughCash:Boolean = this.dispatchSimpleEvent("checkIfEnoughCash",[this.activeItemObject.cost]);
         if(enoughCash)
         {
            this.dispatchSimpleEvent("subtractCash",[this.activeItemObject.cost]);
            this.dispatchSimpleEvent("setBomb",[this.activeItemObject.bomb,this.mouseLoc,this.activeItemObject.targeting]);
         }
      }
      
      protected function setGridPlacement(gridLoc:GPoint) : void
      {
         var blockAvailable:* = undefined;
         var pointList:Array = null;
         var pathsStillGood:Boolean = false;
         var audioController:AudioControl = null;
         var screenLoc:GPoint = null;
         var maxX:Number = this.gridRef.getGridWidth() - this.currentBlockSize;
         if(gridLoc.x > maxX)
         {
            gridLoc.x = maxX;
         }
         var maxY:Number = this.gridRef.getGridHeight() - this.currentBlockSize;
         if(gridLoc.y > maxY)
         {
            gridLoc.y = maxY;
         }
         var enoughCash:Boolean = this.dispatchSimpleEvent("checkIfEnoughCash",[this.activeItemObject.cost]);
         if(enoughCash && !(this.activeItemObject["tower"] != null && this.towersRemaining == 0))
         {
            blockAvailable = this.gridRef.checkBlockAvailable(gridLoc,this.currentBlockSize);
            if(blockAvailable)
            {
               pointList = this.gridRef.getBlockAreaPoints(gridLoc,this.currentBlockSize);
               this.setPlacement(pointList);
               pathsStillGood = this.dispatchSimpleEvent("generatePathing");
               if(!pathsStillGood)
               {
                  this.undoPlacement(pointList);
                  this.setInvalidPlacementMessaage();
               }
               else
               {
                  audioController = AudioControl.getInstance();
                  audioController.playSound("Thud");
                  screenLoc = this.gridRef.gridToScreenLoc(pointList[0]);
                  if(this.activeItemObject["tower"] != null)
                  {
                     this.placeTower(this.activeItemObject["tower"],screenLoc);
                  }
                  if(this.activeItemObject["block"] != null)
                  {
                     this.placeBlock(this.activeItemObject["block"],screenLoc);
                  }
                  this.dispatchSimpleEvent("subtractCash",[this.activeItemObject.cost]);
                  this.clearSelection();
               }
            }
         }
         else if(this.activeItemObject["tower"] != null && this.towersRemaining == 0)
         {
            this.setTowersRemainingMessage(this.towersRemaining);
         }
      }
      
      protected function placeTower(towerConfig:Object, screenLoc:GPoint) : void
      {
         var towerParamsObj:Object = ObjectHelper.cloneObject(towerConfig);
         towerParamsObj.info = this.activeItemObject.info;
         towerParamsObj.footPrintSize = this.gridRef.getTileSize() * this.currentBlockSize;
         var selectItem:GridSelectableItem = this.dispatchSimpleEvent("placeTower",[screenLoc,towerParamsObj]);
         selectItem.addToCashValue(this.activeItemObject.cost);
         selectItem.setSelectArea(this.generateSelectArea(selectItem,towerParamsObj.footPrintSize),this.currentBlockSize);
         selectItem.registerSimpleEvent("onSelected",new Callback(this,this.onGridItemSelected));
         if(this.towersRemaining != Infinity)
         {
            --this.towersRemaining;
            this.setTowersRemainingMessage(this.towersRemaining);
         }
      }
      
      protected function placeBlock(className:String, screenLoc:GPoint) : void
      {
         var footPrintSize:Number = this.gridRef.getTileSize() * this.currentBlockSize;
         var selectItem:GridSelectableItem = new GridSelectableItem(new SimpleDispatcher(),{
            "skinName":className,
            "itemName":this.activeItemObject.itemName,
            "info":this.activeItemObject.info
         });
         selectItem.registerSimpleEvent("onSelected",new Callback(this,this.onGridItemSelected));
         selectItem.x = screenLoc.x;
         selectItem.y = screenLoc.y;
         selectItem.addToCashValue(this.activeItemObject.cost);
         selectItem.setSelectArea(this.generateSelectArea(selectItem,footPrintSize),this.currentBlockSize);
         this.gridRef.addChild(selectItem);
         if(this.activeItemObject.upgradePaths != null)
         {
            selectItem.setUpgradePaths(this.activeItemObject.upgradePaths);
         }
      }
      
      protected function setPlacement(pointList:Array) : void
      {
         var point:GPoint = null;
         for each(point in pointList)
         {
            this.gridRef.getTile(point).block();
         }
      }
      
      protected function undoPlacement(pointList:Array) : void
      {
         var point:GPoint = null;
         for each(point in pointList)
         {
            this.gridRef.getTile(point).unblock();
         }
      }
      
      protected function updateCostChartForList(pointList:Array) : void
      {
         var point:GPoint = null;
         for each(point in pointList)
         {
            this.gridRef.updateCostChart(point,"alphaBlockObstacles");
         }
      }
      
      protected function generateSelectArea(selectItem:GridSelectableItem, footPrintSize:Number) : MovieClip
      {
         var selectArea:MovieClip = new MovieClip();
         selectArea.buttonMode = true;
         selectArea.graphics.beginFill(16711680,0);
         selectArea.graphics.drawRect(selectItem.x,selectItem.y,footPrintSize,footPrintSize);
         this.gridSelectLayer.addChild(selectArea);
         return selectArea;
      }
      
      protected function onGridItemSelected(selectedItem:GridSelectableItem) : void
      {
         var selectedTower:Tower = null;
         var range:Number = NaN;
         this.clearActiveItem();
         var blockSize:Number = selectedItem.getBlockSize();
         var tileSize:Number = this.gridRef.getTileSize();
         this.towerSelector.rangeIndicator.visible = false;
         this.towerSelector.x = selectedItem.x;
         this.towerSelector.y = selectedItem.y;
         var footPrintSize:Number = blockSize * tileSize;
         this.towerSelector.outline.gotoAndStop(blockSize);
         this.towerSelector.targetIndicator.visible = false;
         this.towerSelector.overrideIndicator.visible = false;
         if(selectedItem is Tower)
         {
            selectedTower = selectedItem as Tower;
            range = selectedTower.getRange();
            this.towerSelector.rangeIndicator.width = range * 2;
            this.towerSelector.rangeIndicator.height = range * 2;
            this.towerSelector.rangeIndicator.visible = true;
            this.towerSelector.rangeIndicator.x = footPrintSize / 2;
            this.towerSelector.rangeIndicator.y = footPrintSize / 2;
         }
         this.selectedGridItem = selectedItem;
         this.dispatchSimpleEvent("onActiveItemSet");
         this.dispatchSimpleEvent("showGridItemInfoPanel",[selectedItem]);
         if(!contains(this.towerSelector))
         {
            addChild(this.towerSelector);
         }
      }
      
      protected function showTowerTarget() : void
      {
         var tower:Tower = this.selectedGridItem as Tower;
         var targetOverride:Creep = tower.getTargetOverride();
         if(targetOverride != null && tower.manualTargetOk())
         {
            this.updateTargetIndicator(this.towerSelector.overrideIndicator,targetOverride.getScreenCenterLocation());
         }
         else
         {
            this.towerSelector.overrideIndicator.visible = false;
         }
         var target:Creep = tower.getCurrentTarget();
         if(target != null && targetOverride != target && tower.manualTargetOk())
         {
            this.updateTargetIndicator(this.towerSelector.targetIndicator,target.getScreenCenterLocation());
         }
         else
         {
            this.towerSelector.targetIndicator.visible = false;
         }
      }
      
      protected function updateTargetIndicator(indicator:MovieClip, screenLoc:GPoint) : void
      {
         indicator.x = screenLoc.x - this.towerSelector.x;
         indicator.y = screenLoc.y - this.towerSelector.y;
         indicator.visible = true;
      }
      
      protected function attemptTargetOverride() : Boolean
      {
         var tower:Tower = this.selectedGridItem as Tower;
         var creepList:Array = this.dispatchSimpleEvent("getTargets",[tower.getTargetingType(),this.checkIfValidTargetOverride]);
         if(creepList != null)
         {
            tower.setCurrentTarget(creepList[0]);
            this.showTowerTarget();
            return true;
         }
         return false;
      }
      
      protected function checkIfValidTargetOverride(creep:Creep) : Boolean
      {
         var tower:Tower = this.selectedGridItem as Tower;
         if(creep.checkPointInBounds(this,this.mouseLoc))
         {
            return true;
         }
         return false;
      }
      
      protected function deactivateGridSelection() : void
      {
         if(this.selectedGridItem != null)
         {
            this.dispatchSimpleEvent("onGridSelectionDeactivated");
            if(contains(this.towerSelector))
            {
               removeChild(this.towerSelector);
            }
            this.selectedGridItem = null;
         }
      }
      
      protected function setGridMask(gridRef:GameGrid) : void
      {
         var gridMask:Sprite = new Sprite();
         var tileSize:Number = gridRef.getTileSize();
         gridMask.graphics.beginFill(16711680,1);
         gridMask.graphics.drawRect(0,0,gridRef.width - tileSize * 2,gridRef.height - tileSize * 2);
         gridMask.x = gridRef.x;
         gridMask.y = gridRef.y;
         mask = gridMask;
      }
      
      protected function updateHighlightColor(active:Boolean) : void
      {
         var colorTransform:ColorTransform = this.highlight.transform.colorTransform;
         var enoughCash:Boolean = this.dispatchSimpleEvent("checkIfEnoughCash",[this.activeItemObject.cost]);
         if(active && enoughCash)
         {
            colorTransform.color = 65280;
         }
         else
         {
            colorTransform.color = 16711680;
         }
         this.highlight.transform.colorTransform = colorTransform;
      }
      
      public function addDeselectExclusions(dispObj:DisplayObject) : void
      {
         this.deselectExclusions.push(dispObj);
      }
      
      public function isDeselectExclusion(displayObj:DisplayObject) : Boolean
      {
         var excludeObj:* = undefined;
         var bounds:Object = null;
         var mouseLoc:GPoint = null;
         if(this.gridSelectLayer.contains(displayObj))
         {
            return true;
         }
         for each(excludeObj in this.deselectExclusions)
         {
            bounds = excludeObj.getBounds(this);
            mouseLoc = new GPoint(excludeObj.mouseX,excludeObj.mouseY);
            if(mouseLoc.x >= 0 && mouseLoc.x <= excludeObj.width && mouseLoc.y >= 0 && mouseLoc.y <= excludeObj.height)
            {
               return true;
            }
         }
         return false;
      }
      
      public function setActiveItem(itemObject:Object) : void
      {
         this.deactivateGridSelection();
         this.activeItemObject = itemObject;
         this.currentBlockSize = itemObject.blockSize;
      }
      
      public function clearActiveItem() : void
      {
         this.activeItemObject = null;
         this.highlight.visible = false;
      }
      
      public function resetGridSelection() : void
      {
         if(this.selectedGridItem != null)
         {
            this.onGridItemSelected(this.selectedGridItem);
         }
      }
      
      public function removeGridSelection() : void
      {
         var gridLoc:GPoint = null;
         var blockSize:Number = NaN;
         var pointList:Array = null;
         var screenCenter:GPoint = null;
         if(this.selectedGridItem != null)
         {
            this.gridSelectLayer.removeChild(this.selectedGridItem.getSelectObj());
            gridLoc = this.gridRef.screenToGridLoc(new GPoint(this.selectedGridItem.x,this.selectedGridItem.y));
            blockSize = this.selectedGridItem.getBlockSize();
            pointList = this.gridRef.getBlockAreaPoints(gridLoc,blockSize);
            this.undoPlacement(pointList);
            if(this.selectedGridItem is Tower)
            {
               this.dispatchSimpleEvent("removeTower",[this.selectedGridItem]);
               if(this.towerLimit != Infinity)
               {
                  ++this.towersRemaining;
                  this.setTowersRemainingMessage(this.towersRemaining);
               }
            }
            else
            {
               this.gridRef.removeChild(this.selectedGridItem);
            }
            screenCenter = this.gridRef.gridToScreenLoc(gridLoc);
            screenCenter.x += blockSize / 2 * this.gridRef.getTileSize();
            screenCenter.y += blockSize / 2 * this.gridRef.getTileSize();
            this.dispatchSimpleEvent("setRemoveExplosion",[screenCenter]);
            this.deactivateGridSelection();
            this.dispatchSimpleEvent("generatePathing");
         }
      }
      
      protected function setMessage(msg:String) : void
      {
         this.msgClip.gotoAndPlay(1);
         this.msgClip.msg.message.text = msg;
      }
      
      protected function createMessageClip() : void
      {
         this.msgClip = new MessageClip();
         this.msgClip.gotoAndStop(this.msgClip.totalFrames);
         this.msgClip.cacheAsBitmap = true;
         this.msgClip.x = this.gridRef.width / 2;
         this.msgClip.y = this.gridRef.height / 2;
         this.msgClip.mouseEnabled = false;
         this.msgClip.mouseChildren = false;
         addChild(this.msgClip);
      }
      
      protected function setTowersRemainingMessage(num:Number) : void
      {
         this.setMessage(num + " tower(s) remaining");
      }
      
      protected function setInvalidPlacementMessaage() : void
      {
         this.setMessage("Invalid Placement");
      }
   }
}

