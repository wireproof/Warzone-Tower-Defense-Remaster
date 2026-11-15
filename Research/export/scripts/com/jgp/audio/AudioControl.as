package com.jgp.audio
{
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import flash.media.Sound;
   import flash.media.SoundMixer;
   import flash.media.SoundTransform;
   import flash.utils.getDefinitionByName;
   
   public class AudioControl
   {
      
      protected static var instance:AudioControl;
      
      protected static var MAX_SOUND_CHANNELS:Number = 12;
      
      protected var transform:SoundTransform;
      
      protected var mixer:SoundMixer;
      
      protected var soundInstanceId:Number = 0;
      
      protected var activeSoundRefs:Object;
      
      protected var audioInstances:Array;
      
      protected var activeMusicTrackName:String;
      
      protected var musicLoop:AudioInstance;
      
      protected var soundCache:Object;
      
      protected var audioInstanceDispatcher:SimpleDispatcher;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function AudioControl()
      {
         super();
         this.soundCache = new Object();
         SimpleDispatcher.initialize(this);
         this.activeSoundRefs = new Object();
         this.setAudioInstanceDispatcher();
         this.transform = new SoundTransform();
         SoundMixer.soundTransform = this.transform;
         this.audioInstances = new Array();
         var i:Number = 0;
         while(i < MAX_SOUND_CHANNELS)
         {
            this.audioInstances.push(new AudioInstance());
            i++;
         }
         this.musicLoop = new AudioInstance();
      }
      
      protected static function initialize() : void
      {
         instance = new AudioControl();
      }
      
      public static function getInstance() : AudioControl
      {
         if(instance == null)
         {
            initialize();
         }
         return instance;
      }
      
      protected function setAudioInstanceDispatcher() : void
      {
         this.audioInstanceDispatcher = new SimpleDispatcher();
         this.audioInstanceDispatcher.registerSimpleEvent("onSoundComplete",new Callback(this,this.onAudioInstanceCompleted));
      }
      
      public function playSound(soundClassName:String, loopCount:Number = 0, callback:Callback = null, pauseable:Boolean = true) : String
      {
         if(this.audioInstances.length == 0)
         {
            return null;
         }
         ++this.soundInstanceId;
         var idName:String = "s_" + this.soundInstanceId;
         this.activeSoundRefs[idName] = this.audioInstances.pop();
         this.activeSoundRefs[idName].initialize(this.getCachedSound(soundClassName),soundClassName,idName,loopCount,this.audioInstanceDispatcher,pauseable,callback);
         this.activeSoundRefs[idName].play();
         return idName;
      }
      
      public function playMusic(soundClassName:String, pauseable:Boolean = true) : void
      {
         if(soundClassName != this.activeMusicTrackName)
         {
            this.activeMusicTrackName = soundClassName;
            this.musicLoop.initialize(this.getCachedSound(soundClassName),soundClassName,"music",Infinity,this.audioInstanceDispatcher,pauseable,null);
            this.musicLoop.play();
         }
      }
      
      public function stopMusic() : void
      {
         if(this.activeMusicTrackName != null)
         {
            this.musicLoop.stop();
            this.activeMusicTrackName = null;
         }
      }
      
      public function stopSound(idName:String) : void
      {
         this.activeSoundRefs[idName].stop();
         this.audioInstances.push(this.activeSoundRefs[idName]);
         delete this.activeSoundRefs[idName];
      }
      
      public function clearLoop(idName:String) : void
      {
         this.activeSoundRefs[idName].clearLoop();
      }
      
      public function stopSounds(exceptionList:Array = null) : void
      {
         var i:String = null;
         this.soundInstanceId = 0;
         if(exceptionList == null)
         {
            exceptionList = new Array();
         }
         for(i in this.activeSoundRefs)
         {
            if(exceptionList.indexOf(this.activeSoundRefs[i].getSoundClassName()) == -1)
            {
               this.stopSound(i);
            }
         }
      }
      
      public function pause() : void
      {
         var i:String = null;
         for(i in this.activeSoundRefs)
         {
            if(!this.activeSoundRefs[i].isPaused())
            {
               this.activeSoundRefs[i].pause();
            }
         }
         if(this.musicLoop != null)
         {
            if(!this.musicLoop.isPaused())
            {
               this.musicLoop.pause();
            }
         }
      }
      
      public function unpause() : void
      {
         var i:String = null;
         for(i in this.activeSoundRefs)
         {
            if(this.activeSoundRefs[i].isPaused())
            {
               this.activeSoundRefs[i].unpause();
            }
         }
         if(this.musicLoop != null)
         {
            if(this.musicLoop.isPaused())
            {
               this.musicLoop.unpause();
            }
         }
      }
      
      public function stopAll() : void
      {
         this.stopMusic();
         this.stopSounds();
      }
      
      protected function onAudioInstanceCompleted(instance:AudioInstance) : void
      {
         this.audioInstances.push(this.activeSoundRefs[instance.getId()]);
         delete this.activeSoundRefs[instance.getId()];
      }
      
      public function setVolume(vol:Number) : void
      {
         this.transform.volume = vol;
         SoundMixer.soundTransform = this.transform;
         this.dispatchSimpleEvent("onVolumeChanged");
      }
      
      public function getVolume() : Number
      {
         return this.transform.volume;
      }
      
      protected function getCachedSound(soundName:String) : Sound
      {
         var soundClass:Class = null;
         if(this.soundCache[soundName] == null)
         {
            soundClass = getDefinitionByName(soundName) as Class;
            this.soundCache[soundName] = new soundClass();
         }
         return this.soundCache[soundName];
      }
   }
}

