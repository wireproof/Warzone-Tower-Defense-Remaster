package com.jgp.functions
{
   public class SimpleDispatcher
   {
      
      protected var eventRefs:Object;
      
      public function SimpleDispatcher()
      {
         super();
         this.eventRefs = new Object();
      }
      
      public static function initialize(obj:Object, dispatchInstance:SimpleDispatcher = null) : void
      {
         if(dispatchInstance == null)
         {
            dispatchInstance = new SimpleDispatcher();
         }
         obj.registerSimpleEvent = dispatchInstance.registerSimpleEvent;
         obj.dispatchSimpleEvent = dispatchInstance.dispatchSimpleEvent;
         obj.clearSimpleEvent = dispatchInstance.clearSimpleEvent;
      }
      
      public function registerSimpleEvent(eventName:String, callback:Callback) : void
      {
         if(this.eventRefs[eventName] == null)
         {
            this.eventRefs[eventName] = new Array();
         }
         this.eventRefs[eventName].push(callback);
      }
      
      public function clearSimpleEvent(eventName:String, functionRef:Function = null) : void
      {
         var revisedEventList:Array = null;
         var i:* = undefined;
         if(this.eventRefs[eventName] != null)
         {
            if(functionRef != null)
            {
               revisedEventList = new Array();
               for(i = 0; i < this.eventRefs[eventName].length; i++)
               {
                  if(this.eventRefs[eventName][i].getFunctionRef() != functionRef)
                  {
                     revisedEventList.push(this.eventRefs[eventName][i]);
                  }
               }
               this.eventRefs[eventName] = revisedEventList;
            }
            else
            {
               delete this.eventRefs[eventName];
            }
         }
      }
      
      public function dispatchSimpleEvent(eventName:String, args:Array = null) : *
      {
         var i:* = undefined;
         var resultsArray:Array = new Array();
         if(this.eventRefs[eventName] != null)
         {
            for(i = 0; i < this.eventRefs[eventName].length; i++)
            {
               resultsArray.push(this.eventRefs[eventName][i].call(args));
            }
         }
         if(resultsArray.length == 1)
         {
            return resultsArray[0];
         }
         return resultsArray;
      }
   }
}

