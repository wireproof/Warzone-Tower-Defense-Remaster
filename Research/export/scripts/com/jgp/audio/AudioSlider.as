package com.jgp.audio
{
   import com.jgp.functions.Callback;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol285")]
   public class AudioSlider extends MovieClip
   {
      
      public var bar:MovieClip;
      
      public var knob:MovieClip;
      
      public var percentBar:MovieClip;
      
      protected var knobClip:MovieClip;
      
      protected var barClip:MovieClip;
      
      protected var minX:Number;
      
      protected var maxX:Number;
      
      protected var dragActive:Boolean = false;
      
      public function AudioSlider()
      {
         super();
         this.configureClips();
         this.minX = this.knobClip.width / 2;
         this.maxX = this.barClip.width - this.knobClip.width / 2;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
      }
      
      protected function configureClips() : void
      {
         this.knobClip = this.knob;
         this.barClip = this.bar;
         this.barClip.mouseEnabled = false;
         this.knobClip.mouseChildren = false;
         this.knobClip.buttonMode = true;
         this.knobClip.useHandCursor = true;
      }
      
      protected function onAddedToStage(event:Event) : void
      {
         this.setKnobToCurrentVolume();
         this.knobClip.addEventListener(MouseEvent.MOUSE_DOWN,this.setKnobDrag);
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.registerSimpleEvent("onVolumeChanged",new Callback(this,this.onAudioChangedExternal));
      }
      
      protected function onRemovedFromStage(event:Event) : void
      {
         this.knobClip.removeEventListener(MouseEvent.MOUSE_DOWN,this.setKnobDrag);
         if(this.dragActive)
         {
            this.clearKnobDrag();
         }
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.clearSimpleEvent("onVolumeChanged",this.onAudioChangedExternal);
      }
      
      protected function setKnobToCurrentVolume() : void
      {
         var audioController:AudioControl = AudioControl.getInstance();
         var currentVolume:Number = audioController.getVolume();
         var scrollWidth:Number = this.barClip.width - this.knobClip.width;
         var scrollShiftX:Number = currentVolume * scrollWidth;
         this.knobClip.x = this.minX + scrollShiftX;
         this.percentBar.width = this.knobClip.x;
      }
      
      protected function setKnobDrag(event:MouseEvent) : void
      {
         stage.addEventListener(MouseEvent.MOUSE_UP,this.clearKnobDrag);
         stage.addEventListener(MouseEvent.MOUSE_MOVE,this.updateKnobDrag);
         this.dragActive = true;
      }
      
      protected function onAudioChangedExternal() : void
      {
         if(!this.dragActive)
         {
            this.setKnobToCurrentVolume();
         }
      }
      
      protected function clearKnobDrag(event:MouseEvent = null) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_UP,this.clearKnobDrag);
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,this.updateKnobDrag);
         this.dragActive = false;
      }
      
      protected function updateKnobDrag(event:MouseEvent) : void
      {
         var newX:Number = mouseX;
         if(newX < this.minX)
         {
            newX = this.minX;
         }
         if(newX > this.maxX)
         {
            newX = this.maxX;
         }
         this.knobClip.x = newX;
         this.percentBar.width = this.knobClip.x;
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.setVolume(this.getBarPercent());
      }
      
      protected function getBarPercent() : Number
      {
         return (this.knobClip.x - this.minX) / (this.barClip.width - this.knobClip.width);
      }
   }
}

