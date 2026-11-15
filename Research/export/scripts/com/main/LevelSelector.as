package com.main
{
   import com.jgp.audio.AudioControl;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol319")]
   public class LevelSelector extends MovieClip
   {
      
      public var levelImages:MovieClip;
      
      public var levelNameText:TextField;
      
      public var nextButton:SimpleButton;
      
      public var prevButton:SimpleButton;
      
      protected var filePath:String;
      
      protected var displayIndex:Number = 0;
      
      protected var levelList:Array;
      
      public function LevelSelector()
      {
         super();
      }
      
      public function initialize(levList:Array) : void
      {
         this.levelList = levList;
         this.nextButton.addEventListener(MouseEvent.MOUSE_DOWN,this.showNext);
         this.prevButton.addEventListener(MouseEvent.MOUSE_DOWN,this.showPrev);
         this.showThumb();
      }
      
      public function setFilePath(path:String) : void
      {
         this.filePath = path;
      }
      
      protected function showNext(event:MouseEvent) : void
      {
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.playSound("ClickSound",0,null,false);
         ++this.displayIndex;
         if(this.displayIndex > this.levelList.length - 1)
         {
            this.displayIndex = 0;
         }
         this.showThumb();
      }
      
      protected function showPrev(event:MouseEvent) : void
      {
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.playSound("ClickSound",0,null,false);
         --this.displayIndex;
         if(this.displayIndex < 0)
         {
            this.displayIndex = this.levelList.length - 1;
         }
         this.showThumb();
      }
      
      protected function showThumb() : void
      {
         this.levelNameText.text = this.levelList[this.displayIndex].name;
         this.levelImages.gotoAndStop(this.displayIndex + 1);
      }
      
      public function getSelectedLevelName() : String
      {
         return this.levelList[this.displayIndex].name;
      }
      
      public function getSelectedLevelDirectory() : String
      {
         return this.levelList[this.displayIndex].dir;
      }
   }
}

