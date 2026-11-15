package com.newgrounds.components
{
   import adobe.utils.*;
   import flash.accessibility.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.media.*;
   import flash.net.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol743")]
   public dynamic class FlashAd extends FlashAdBase
   {
      
      public var playButton:MovieClip;
      
      public var adContainer:MovieClip;
      
      public var newgroundsButton:SimpleButton;
      
      public function FlashAd()
      {
         super();
         addFrameScript(0,frame1,1,frame2,9,frame10,19,frame20);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame2() : *
      {
         initPlayButton();
      }
      
      internal function frame20() : *
      {
         initPlayButton();
      }
      
      internal function frame10() : *
      {
         initPlayButton();
      }
      
      public function onPlayClick(param1:MouseEvent) : void
      {
         removeAd();
         if(parent)
         {
            parent.removeChild(this);
         }
      }
      
      public function initPlayButton() : *
      {
         if(this["playButton"])
         {
            this["playButton"].addEventListener(MouseEvent.CLICK,onPlayClick);
            if(!this["showPlayButton"])
            {
               this["playButton"].visible = false;
            }
         }
      }
   }
}

