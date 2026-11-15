package com.jgp.php
{
   import com.adobe.crypto.MD5;
   import com.jgp.functions.Callback;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   
   public class Login extends PHPConnect
   {
      
      public function Login(URL:String, username:String, password:String, callback:Callback = null)
      {
         var urlVar:URLVariables = new URLVariables();
         urlVar["username"] = username;
         urlVar["pswd"] = MD5.hash(password);
         var date:Date = new Date();
         urlVar["noCache"] = date.time;
         super(URL,callback,urlVar,URLRequestMethod.GET);
      }
      
      override protected function parseDocument(xmlData:String) : void
      {
         super.parseDocument(xmlData);
      }
      
      override public function getSuccessMessage() : String
      {
         return "You are now logged in.";
      }
   }
}

