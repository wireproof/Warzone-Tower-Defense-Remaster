package com.jgp.functions
{
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   
   public class DelayedCallback extends Callback
   {
      
      protected var callTimer:Timer;
      
      protected var argOverride:Array;
      
      protected var delay:Number;
      
      protected var reps:Number;
      
      protected var callRefs:Object = new Object();
      
      protected var callId:Number = 0;
      
      public function DelayedCallback(callObj:Object, callFunct:Function, delay:Number, reps:Number = 1, callArgs:Array = null)
      {
         this.reps = reps;
         this.delay = delay;
         super(callObj,callFunct,callArgs);
      }
      
      override public function call(argOveride:Array = null) : *
      {
         ++this.callId;
         var callIdName:String = "call_" + this.callId;
         var callTimer:Timer = new Timer(this.delay,this.reps);
         callTimer.addEventListener(TimerEvent.TIMER,new Callback(this,this.delayedCall,[callIdName]).getEventDelegation());
         this.callRefs[callIdName] = new Object();
         this.callRefs[callIdName].argOveride = argOveride;
         this.callRefs[callIdName].timer = callTimer;
         callTimer.start();
      }
      
      protected function delayedCall(callIdName:String) : void
      {
         super.call(this.callRefs[callIdName].argOveride);
         if(!this.callRefs[callIdName].timer.running)
         {
            this.callRefs[callIdName].timer.stop();
            delete this.callRefs[callIdName];
         }
      }
   }
}

