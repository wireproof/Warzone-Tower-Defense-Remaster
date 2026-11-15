package com.jgp.php
{
   import com.jgp.functions.Callback;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   
   public class SignUp extends PHPConnect
   {
      
      public function SignUp(URL:String, username:String, password:String, confirm:String, firstname:String, email:String, option:Boolean, callback:Callback = null)
      {
         var urlVar:URLVariables = new URLVariables();
         urlVar["username"] = username;
         urlVar["pswd"] = password;
         urlVar["confirm"] = confirm;
         urlVar["first_name"] = firstname;
         urlVar["email"] = email;
         urlVar["opt_in"] = Number(option);
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
         return "Your user account has been created.";
      }
   }
}

