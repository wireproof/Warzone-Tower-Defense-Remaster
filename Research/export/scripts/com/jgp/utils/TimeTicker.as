package com.jgp.utils
{
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import flash.display.DisplayObject;
   import flash.events.Event;
   
   public class TimeTicker extends SimpleDispatcher
   {
      
      protected var tickInterval:Number;
      
      protected var lastUpdateAt:Number;
      
      protected var time:Number;
      
      protected var tickDuration:Number;
      
      protected var eventTarget:DisplayObject;
      
      protected var queuedFunctionsRefs:Object;
      
      protected var queuedFunctionId:Number = 0;
      
      public function TimeTicker(eventTarget:DisplayObject, desiredFrameRate:Number)
      {
         super();
         this.eventTarget = eventTarget;
         this.queuedFunctionsRefs = new Object();
         this.setTickInterval(desiredFrameRate);
         this.time = 0;
         eventTarget.addEventListener(Event.ENTER_FRAME,this.onTick,false,0,true);
      }
      
      public function setTickInterval(desiredFrameRate:Number) : void
      {
         this.tickInterval = Math.round(1000 / desiredFrameRate);
      }
      
      protected function onTick(event:Event = null) : void
      {
         this.time += this.tickInterval;
         dispatchSimpleEvent("update",[this]);
         this.checkQueuedFunctions();
      }
      
      public function getTime() : Number
      {
         return this.time;
      }
      
      public function getTickDuration() : Number
      {
         return this.tickInterval;
      }
      
      public function pause() : void
      {
         this.eventTarget.removeEventListener(Event.ENTER_FRAME,this.onTick);
      }
      
      public function unpause() : void
      {
         this.onTick();
         this.eventTarget.addEventListener(Event.ENTER_FRAME,this.onTick,false,0,true);
      }
      
      public function addQueuedFunction(callback:Callback, ticksUntilExecute:Number) : void
      {
         if(ticksUntilExecute > 0)
         {
            ++this.queuedFunctionId;
            this.queuedFunctionsRefs["q_" + this.queuedFunctionId] = {
               "callback":callback,
               "executeAt":this.getTime() + ticksUntilExecute * this.tickInterval
            };
         }
      }
      
      protected function checkQueuedFunctions() : void
      {
         var i:String = null;
         for(i in this.queuedFunctionsRefs)
         {
            if(this.queuedFunctionsRefs[i].executeAt == this.time)
            {
               this.queuedFunctionsRefs[i].callback.call();
               delete this.queuedFunctionsRefs[i];
            }
         }
      }
   }
}

