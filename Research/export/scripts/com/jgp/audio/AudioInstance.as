package com.jgp.audio
{
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   
   public class AudioInstance
   {
      
      protected var audioId:String;
      
      protected var loopCount:Number;
      
      protected var dispatcher:SimpleDispatcher;
      
      protected var callback:Callback;
      
      protected var channel:SoundChannel;
      
      protected var sound:Sound;
      
      protected var soundClassName:String;
      
      protected var transform:SoundTransform;
      
      protected var pausePos:Number = -1;
      
      protected var pauseable:Boolean;
      
      public function AudioInstance()
      {
         super();
      }
      
      internal function initialize(sound:Sound, soundClassName:String, audioId:String, loopCount:Number, dispatcher:SimpleDispatcher, pauseable:Boolean, callback:Callback = null) : void
      {
         this.pausePos = -1;
         this.soundClassName = soundClassName;
         this.audioId = audioId;
         this.loopCount = loopCount;
         this.dispatcher = dispatcher;
         this.callback = callback;
         this.pauseable = pauseable;
         this.sound = sound;
      }
      
      internal function play(pos:Number = 0) : Boolean
      {
         if(this.channel != null)
         {
            this.channel.removeEventListener(Event.SOUND_COMPLETE,this.onSoundComplete);
         }
         this.channel = this.sound.play(pos);
         if(this.channel == null)
         {
            return false;
         }
         this.channel.addEventListener(Event.SOUND_COMPLETE,this.onSoundComplete,false,0,true);
         return true;
      }
      
      internal function stop() : void
      {
         this.channel.stop();
      }
      
      internal function pause() : void
      {
         if(this.pauseable)
         {
            this.pausePos = this.channel.position;
            this.stop();
         }
      }
      
      internal function unpause() : void
      {
         if(this.pauseable)
         {
            this.play(this.pausePos);
            this.pausePos = -1;
         }
      }
      
      internal function isPaused() : Boolean
      {
         return this.pausePos != -1;
      }
      
      internal function clearLoop() : void
      {
         this.loopCount = 0;
      }
      
      protected function onSoundComplete(event:Event) : void
      {
         if(this.loopCount == 0)
         {
            if(this.callback != null)
            {
               this.callback.call();
            }
            this.dispatcher.dispatchSimpleEvent("onSoundComplete",[this]);
         }
         else
         {
            --this.loopCount;
            this.play();
         }
      }
      
      internal function getId() : String
      {
         return this.audioId;
      }
      
      internal function getSoundClassName() : String
      {
         return this.soundClassName;
      }
   }
}

