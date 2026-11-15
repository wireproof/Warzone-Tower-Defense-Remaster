package com.main
{
   import com.jgp.bitmap.loading.BitmapArchive;
   import com.jgp.control.KeyStrokes;
   import com.jgp.tracking.Tracker;
   import com.newgrounds.API;
   import com.newgrounds.APIEvent;
   import com.newgrounds.components.FlashAd;
   import flash.display.MovieClip;
   import flash.events.ContextMenuEvent;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.Security;
   import flash.ui.ContextMenu;
   import flash.ui.ContextMenuItem;
   
   [SWF(width="833", height="607", backgroundColor="#333333", frameRate="34")]
   public dynamic class DocClass extends MovieClip
   {
      
      public var gameContainer:MovieClip;
      
      protected var bmpArchive:BitmapArchive;
      
      protected var keyStrokes:KeyStrokes;
      
      public var filePath:String = "";
      
      private var _flashAd:FlashAd;
      
      public function DocClass()
      {
         super();
         Security.allowInsecureDomain("*");
         Security.allowDomain("*");
         API.debugMode = API.RELEASE_MODE;
         API.addEventListener(APIEvent.API_CONNECTED,this.onAPIConnected);
         API.connect(root,"36240:OgV4mk8K","mFXh41CqdFLYnUj4E66TrqHVnDM9r71D","1.0.7");
      }
      
      private function onAPIConnected(event:APIEvent) : void
      {
         if(event.success)
         {
            this._flashAd = new FlashAd();
            this._flashAd.visible = false;
            addChild(this._flashAd);
            if(stage)
            {
               this.init();
            }
            else
            {
               addEventListener(Event.ADDED_TO_STAGE,this.init);
            }
         }
      }
      
      public function init(myEvent:Event = null) : void
      {
         var domain:String = root.loaderInfo.url;
         Tracker.setTrackState(domain);
         Tracker.trackEvent("game loaded");
         this.initMain();
         this._flashAd = new FlashAd();
      }
      
      protected function setContextMenu() : void
      {
         var item:ContextMenuItem = null;
         var contextMenu:ContextMenu = new ContextMenu();
         this.contextMenu = contextMenu;
         contextMenu.hideBuiltInItems();
         item = new ContextMenuItem("visit madcowinteractive.com");
         item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.vistMadCow);
         contextMenu.customItems.push(item);
         if(stage.displayState != null)
         {
            item = new ContextMenuItem("toggle fullscreen mode");
            item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,this.toggleFullScreen);
            contextMenu.customItems.push(item);
         }
      }
      
      private function toggleFullScreen(event:ContextMenuEvent) : void
      {
         switch(stage.displayState)
         {
            case "normal":
               stage.fullScreenSourceRect = new Rectangle(0,0,833,607);
               stage.displayState = "fullScreen";
               break;
            case "fullScreen":
            default:
               stage.displayState = "normal";
         }
      }
      
      private function vistMadCow(event:Event) : void
      {
         navigateToURL(new URLRequest("http://www.madcowinteractive.com"),"_blank");
      }
      
      protected function setBMPArchive() : void
      {
         this.bmpArchive = new BitmapArchive();
         this.bmpArchive.setBitmapData("crater_1",new crater_1(0,0));
         this.bmpArchive.setBitmapData("crater_2",new crater_2(0,0));
         this.bmpArchive.setBitmapData("crater_3",new crater_3(0,0));
         this.bmpArchive.setBitmapData("G1",new G1(0,0));
         this.bmpArchive.setBitmapData("G2",new G2(0,0));
         this.bmpArchive.setBitmapData("B1",new B1(0,0));
         this.bmpArchive.setBitmapData("B2",new B2(0,0));
         this.bmpArchive.setBitmapData("B3",new B3(0,0));
         this.bmpArchive.setBitmapData("B4",new B4(0,0));
         this.bmpArchive.setBitmapData("B5",new B5(0,0));
         this.bmpArchive.setBitmapData("B6",new B6(0,0));
         this.bmpArchive.setBitmapData("B7",new B7(0,0));
         this.bmpArchive.setBitmapData("B8",new B8(0,0));
         this.bmpArchive.setBitmapData("B9",new B9(0,0));
         this.bmpArchive.setBitmapData("alphaBlock",new alphaBlock(0,0));
         this.bmpArchive.setBitmapData("particle: smoke puff",new smokepuff(0,0));
         this.bmpArchive.setBitmapData("particle: bullet",new bullet(0,0));
         this.bmpArchive.setBitmapData("particle: flare",new flare(0,0));
         this.bmpArchive.setBitmapData("particle: glow",new glow(0,0));
         this.bmpArchive.setBitmapData("particle: greenGlow",new greenGlow(0,0));
         this.bmpArchive.setBitmapData("particle: shrapnel",new shrapnel(0,0));
         this.bmpArchive.setBitmapData("sand",new TerrainImage(0,0));
         this.bmpArchive.setBitmapData("grass",new GrassTerrain(0,0));
         this.bmpArchive.setBitmapData("C_1",new C_1(0,0));
         this.bmpArchive.setBitmapData("B_C_1",new B_C_1(0,0));
         this.bmpArchive.setBitmapData("B_C_2",new B_C_2(0,0));
         this.bmpArchive.setBitmapData("B_C_3",new B_C_3(0,0));
         this.bmpArchive.setBitmapData("B_CN_1",new B_CN_1(0,0));
         this.bmpArchive.setBitmapData("B_CN_2",new B_CN_2(0,0));
         this.bmpArchive.setBitmapData("B_CN_3",new B_CN_3(0,0));
         this.bmpArchive.setBitmapData("B_CN_4",new B_CN_4(0,0));
         this.bmpArchive.setBitmapData("L_C_1",new L_C_1(0,0));
         this.bmpArchive.setBitmapData("L_C_2",new L_C_2(0,0));
         this.bmpArchive.setBitmapData("L_C_3",new L_C_3(0,0));
         this.bmpArchive.setBitmapData("R_C_1",new R_C_1(0,0));
         this.bmpArchive.setBitmapData("R_C_2",new R_C_2(0,0));
         this.bmpArchive.setBitmapData("R_C_3",new R_C_3(0,0));
         this.bmpArchive.setBitmapData("T_C_1",new T_C_1(0,0));
         this.bmpArchive.setBitmapData("T_C_2",new T_C_2(0,0));
         this.bmpArchive.setBitmapData("T_C_3",new T_C_3(0,0));
         this.bmpArchive.setBitmapData("T_CN_1",new T_CN_1(0,0));
         this.bmpArchive.setBitmapData("T_CN_2",new T_CN_2(0,0));
         this.bmpArchive.setBitmapData("T_CN_3",new T_CN_3(0,0));
         this.bmpArchive.setBitmapData("T_CN_4",new T_CN_4(0,0));
         this.bmpArchive.setBitmapData("S_B_C_1",new S_B_C_1(0,0));
         this.bmpArchive.setBitmapData("S_B_C_2",new S_B_C_2(0,0));
         this.bmpArchive.setBitmapData("S_B_C_3",new S_B_C_3(0,0));
         this.bmpArchive.setBitmapData("S_B_CN_1",new S_B_CN_1(0,0));
         this.bmpArchive.setBitmapData("S_B_CN_2",new S_B_CN_2(0,0));
         this.bmpArchive.setBitmapData("S_L_C_1",new S_L_C_1(0,0));
         this.bmpArchive.setBitmapData("S_L_C_2",new S_L_C_2(0,0));
         this.bmpArchive.setBitmapData("S_L_C_3",new S_L_C_3(0,0));
         this.bmpArchive.setBitmapData("S_R_C_1",new S_R_C_1(0,0));
         this.bmpArchive.setBitmapData("S_R_C_2",new S_R_C_2(0,0));
         this.bmpArchive.setBitmapData("S_R_C_3",new S_R_C_3(0,0));
         this.bmpArchive.setBitmapData("S_T_C_1",new S_T_C_1(0,0));
         this.bmpArchive.setBitmapData("S_T_C_2",new S_T_C_2(0,0));
         this.bmpArchive.setBitmapData("S_T_C_3",new S_T_C_3(0,0));
         this.bmpArchive.setBitmapData("S_T_CN_1",new S_T_CN_1(0,0));
         this.bmpArchive.setBitmapData("S_T_CN_2",new S_T_CN_2(0,0));
      }
      
      protected function initMain() : void
      {
         this.setContextMenu();
         this.setBMPArchive();
         var main:MainApp = new MainApp(this.filePath,this.bmpArchive,this.gameContainer);
         main.addEventListener("onGameStarted",this.onGameStarted);
         addChild(main);
         if(this._flashAd != null)
         {
            addChild(this._flashAd);
         }
      }
      
      private function onGameStarted(event:Event) : void
      {
         if(Boolean(this._flashAd) && this._flashAd.parent != null)
         {
            this._flashAd.parent.removeChild(this._flashAd);
         }
      }
   }
}

