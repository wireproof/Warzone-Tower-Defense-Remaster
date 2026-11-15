package com.game.ui
{
   import com.game.ui.displays.ScoreBoard;
   import com.game.ui.grid.*;
   import com.game.ui.menus.*;
   import com.game.waves.WaveController;
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.math.geom.GPoint;
   import flash.display.MovieClip;
   
   public class GameUI extends MovieClip
   {
      
      protected var gridUI:GridUI;
      
      protected var itemMenu:ItemMenu;
      
      protected var scoreBoard:ScoreBoard;
      
      protected var UIConfig:Object;
      
      protected var waveController:WaveController;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function GameUI(gridUI:GridUI, UIConfig:Object, waveController:WaveController, groundOnly:Boolean)
      {
         super();
         SimpleDispatcher.initialize(this);
         this.gridUI = gridUI;
         this.UIConfig = UIConfig;
         this.waveController = waveController;
         UIConfig.itemMenu.groundOnly = groundOnly;
         this.itemMenu = new ItemMenu(UIConfig.itemMenu);
         var itemMenuScreenLoc:GPoint = GPoint.pointFromString(UIConfig.itemMenu.screenLoc);
         this.itemMenu.x = itemMenuScreenLoc.x;
         this.itemMenu.y = itemMenuScreenLoc.y;
         this.itemMenu.registerSimpleEvent("onItemSelected",new Callback(gridUI,gridUI.setActiveItem));
         this.itemMenu.registerSimpleEvent("sellCurrentSelection",new Callback(this,this.sellCurrentSelection));
         this.itemMenu.registerSimpleEvent("onResetGridItemPanel",new Callback(gridUI,gridUI.resetGridSelection));
         this.itemMenu.registerSimpleEvent("getProjectileParamsObj",new Callback(this,this.getProjectileParamsObj));
         this.itemMenu.registerSimpleEvent("checkIfEnoughCash",new Callback(this,this.checkIfEnoughCash));
         this.itemMenu.registerSimpleEvent("subtractCash",new Callback(this,this.subtractCash));
         gridUI.addDeselectExclusions(this.itemMenu.getInfoPanelContainer());
         gridUI.registerSimpleEvent("showGridItemInfoPanel",new Callback(this.itemMenu,this.itemMenu.showGridItemInfoPanel));
         gridUI.registerSimpleEvent("onGridSelectionDeactivated",new Callback(this.itemMenu,this.itemMenu.hideItemInfoPanel));
         gridUI.registerSimpleEvent("onActiveItemSet",new Callback(this.itemMenu,this.itemMenu.deselectActiveButton));
         gridUI.registerSimpleEvent("checkIfEnoughCash",new Callback(this,this.checkIfEnoughCash));
         gridUI.registerSimpleEvent("subtractCash",new Callback(this,this.subtractCash));
         gridUI.registerSimpleEvent("getProjectileParamsObj",new Callback(this,this.getProjectileParamsObj));
         var waveControllerScreenLoc:GPoint = GPoint.pointFromString(UIConfig.waveController.screenLoc);
         waveController.x = waveControllerScreenLoc.x;
         waveController.y = waveControllerScreenLoc.y;
         this.scoreBoard = new ScoreBoard();
         var scoreBoardScreenLoc:GPoint = GPoint.pointFromString(UIConfig.scoreBoard.screenLoc);
         this.scoreBoard.x = scoreBoardScreenLoc.x;
         this.scoreBoard.y = scoreBoardScreenLoc.y;
         addChild(gridUI);
         addChild(this.itemMenu);
         addChild(waveController);
         addChild(this.scoreBoard);
      }
      
      public function disable() : void
      {
         this.itemMenu.mouseChildren = false;
         this.waveController.mouseChildren = false;
         this.gridUI.clearEvents();
         this.gridUI.clearSelection();
         this.gridUI.mouseEnabled = false;
      }
      
      public function enable() : void
      {
         this.itemMenu.mouseChildren = true;
         this.waveController.mouseChildren = true;
         this.gridUI.setEvents();
         this.gridUI.mouseEnabled = true;
      }
      
      public function hideGridUI() : void
      {
         this.gridUI.visible = false;
      }
      
      protected function sellCurrentSelection(cashValue:Number) : void
      {
         this.gridUI.removeGridSelection();
         this.dispatchSimpleEvent("addCash",[cashValue]);
      }
      
      protected function getProjectileParamsObj(refName:String) : Object
      {
         return this.dispatchSimpleEvent("getProjectileParamsObj",[refName]);
      }
      
      public function updateCashDisplay(currentCash:Number) : void
      {
         this.itemMenu.updateCashDisplay(currentCash);
      }
      
      public function updateScoreDisplay(currentScore:Number) : void
      {
         this.scoreBoard.updateScoreDisplay(currentScore);
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

