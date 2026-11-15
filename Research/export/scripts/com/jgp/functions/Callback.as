package com.jgp.functions
{
   import flash.events.Event;
   
   public class Callback
   {
      
      protected var callObj:Object;
      
      protected var callFunct:Function;
      
      protected var callArgs:Array;
      
      public function Callback(callObj:Object, callFunct:Function, callArgs:Array = null)
      {
         super();
         this.callObj = callObj;
         this.callFunct = callFunct;
         this.callArgs = callArgs;
      }
      
      public function call(argOveride:Array = null) : *
      {
         if(argOveride == null)
         {
            return this.callFunct.apply(this.callObj,this.callArgs);
         }
         return this.callFunct.apply(this.callObj,argOveride);
      }
      
      public function getDelegation() : Function
      {
         return this.call;
      }
      
      public function getEventDelegation() : Function
      {
         return this.callOnEvent;
      }
      
      protected function callOnEvent(event:Event = null) : *
      {
         return this.call();
      }
      
      public function getFunctionRef() : Function
      {
         return this.callFunct;
      }
   }
}

