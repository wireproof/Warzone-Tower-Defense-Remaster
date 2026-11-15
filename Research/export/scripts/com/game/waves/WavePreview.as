package com.game.waves
{
   import com.jgp.functions.SimpleDispatcher;
   import fl.transitions.Tween;
   import fl.transitions.TweenEvent;
   import fl.transitions.easing.Regular;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.utils.getDefinitionByName;
   
   public class WavePreview extends MovieClip
   {
      
      protected static const ITEM_SPACING:Number = 22;
      
      protected static const VIEW_HEIGHT:Number = 22;
      
      protected var previewItemList:Array;
      
      protected var previewCount:Number;
      
      protected var previewScroller:Sprite;
      
      protected var added:Number = 0;
      
      protected var shifted:Number = 0;
      
      protected var toRemove:Number = 0;
      
      protected var highlight:MovieClip;
      
      protected var tween:Tween;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function WavePreview(dispatcher:SimpleDispatcher, previewCount:Number, previewInitList:Array)
      {
         super();
         SimpleDispatcher.initialize(this,dispatcher);
         this.previewCount = previewCount;
         this.previewScroller = new Sprite();
         this.previewScroller.x += ITEM_SPACING / 2;
         addChild(this.previewScroller);
         this.highlight = new WaveHighlight();
         this.highlight.x = this.previewScroller.x;
         this.highlight.y = this.previewScroller.y;
         addChild(this.highlight);
         this.createMask();
         this.setInitList(previewInitList);
      }
      
      protected function createMask() : void
      {
         var maskWidth:Number = ITEM_SPACING * this.previewCount;
         var maskSprite:Sprite = new Sprite();
         maskSprite.graphics.beginFill(16711680,0.5);
         maskSprite.graphics.moveTo(0,-VIEW_HEIGHT / 2);
         maskSprite.graphics.lineTo(maskWidth,-VIEW_HEIGHT / 2);
         maskSprite.graphics.lineTo(maskWidth,VIEW_HEIGHT / 2);
         maskSprite.graphics.lineTo(0,VIEW_HEIGHT / 2);
         maskSprite.graphics.lineTo(0,-VIEW_HEIGHT / 2);
         maskSprite.graphics.endFill();
         addChild(maskSprite);
         this.previewScroller.mask = maskSprite;
      }
      
      protected function setInitList(previewInitList:Array) : void
      {
         this.previewItemList = new Array();
         for(var i:Number = 0; i < this.previewCount; i++)
         {
            this.setPreviewIcon(previewInitList[i].skinName,false);
         }
      }
      
      public function setPreviewIcon(skinName:String, posHighlight:Boolean = true) : void
      {
         var skinClass:Class = getDefinitionByName(skinName) as Class;
         var iconClip:DisplayObject = new skinClass();
         iconClip.x = this.added * ITEM_SPACING;
         if(iconClip.height > 18)
         {
            iconClip.height = 18;
            iconClip.scaleX = iconClip.scaleY;
         }
         this.previewScroller.addChildAt(iconClip,0);
         this.previewItemList.push(iconClip);
         ++this.added;
         if(this.added > this.previewCount + 1)
         {
            ++this.shifted;
            ++this.toRemove;
            if(this.tween != null)
            {
               this.tween.stop();
            }
            this.tween = new Tween(this.previewScroller,"x",Regular.easeOut,this.previewScroller.x,-(this.shifted * ITEM_SPACING) + ITEM_SPACING / 2,2 / 3,true);
            this.tween.addEventListener(TweenEvent.MOTION_FINISH,this.onTweenFinished);
            this.tween.addEventListener(TweenEvent.MOTION_CHANGE,this.onTweenUpdated);
         }
      }
      
      protected function onTweenUpdated(event:TweenEvent) : void
      {
         this.previewScroller.x = Math.floor(this.previewScroller.x);
      }
      
      protected function onTweenFinished(event:TweenEvent) : void
      {
         while(this.toRemove > 0)
         {
            --this.toRemove;
            this.previewScroller.removeChild(this.previewItemList.shift());
         }
         this.tween = null;
      }
      
      public function pause() : void
      {
         if(this.tween != null)
         {
            this.tween.stop();
         }
      }
      
      public function unpause() : void
      {
         if(this.tween != null)
         {
            this.tween.resume();
         }
      }
   }
}

