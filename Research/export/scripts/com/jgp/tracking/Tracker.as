package com.jgp.tracking
{
   import flash.external.ExternalInterface;
   
   public class Tracker
   {
      
      protected static var activeDomain:String;
      
      protected static var enabled:Boolean = true;
      
      public function Tracker()
      {
         super();
      }
      
      public static function trackEvent(eventName:String) : void
      {
         if(ExternalInterface.available && enabled)
         {
            ExternalInterface.call("MCITrackEvent",eventName);
         }
      }
      
      public static function setTrackState(domain:String) : void
      {
         activeDomain = domain;
         enabled = domain.indexOf("madcowinteractive.com") >= 0;
      }
      
      public static function getActiveDomain() : String
      {
         return activeDomain;
      }
   }
}

