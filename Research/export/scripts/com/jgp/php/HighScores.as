package com.jgp.php
{
   import com.jgp.functions.Callback;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   
   public class HighScores extends PHPConnect
   {
      
      public function HighScores(URL:String, gameId:Number, level:String, dayCount:Number, nameFilter:String, callback:Callback = null)
      {
         var urlVar:URLVariables = new URLVariables();
         urlVar["gameId"] = gameId;
         urlVar["levelFilter"] = level;
         urlVar["dayLimit"] = dayCount;
         urlVar["nameFilter"] = nameFilter;
         var date:Date = new Date();
         urlVar["noCache"] = date.time;
         super(URL,callback,urlVar,URLRequestMethod.POST);
      }
      
      override protected function parseDocument(xmlData:String) : void
      {
         super.parseDocument(xmlData);
      }
   }
}

