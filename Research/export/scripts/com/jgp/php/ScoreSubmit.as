package com.jgp.php
{
   import com.adobe.crypto.MD5;
   import com.jgp.functions.Callback;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   
   public class ScoreSubmit extends PHPConnect
   {
      
      public function ScoreSubmit(URL:String, userId:Number, gameId:Number, score:Number, level:String, callback:Callback = null)
      {
         var urlVar:URLVariables = new URLVariables();
         urlVar["userId"] = userId;
         urlVar["gameId"] = gameId;
         urlVar["score"] = score;
         urlVar["level"] = level;
         var checkSum:Number = Math.round(((score * 367 + 46) / 3 * 12 - 62) / 100);
         urlVar["validate"] = MD5.hash(level + "NZ" + checkSum + "ZI" + userId);
         var date:Date = new Date();
         urlVar["noCache"] = date.time;
         super(URL,callback,urlVar,URLRequestMethod.POST);
      }
      
      override public function getSuccessMessage() : String
      {
         return "Your score has been successfully submitted.";
      }
   }
}

