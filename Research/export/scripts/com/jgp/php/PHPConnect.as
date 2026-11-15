package com.jgp.php
{
   import com.jgp.functions.Callback;
   import com.jgp.xml.XMLFetch;
   import flash.net.URLVariables;
   
   public class PHPConnect extends XMLFetch
   {
      
      protected var urlVar:URLVariables;
      
      public function PHPConnect(fileName:String = null, loadCallback:Callback = null, urlVar:URLVariables = null, urlReqMeth:String = null)
      {
         this.urlVar = urlVar;
         super(fileName,loadCallback,urlVar,urlReqMeth);
      }
      
      override protected function parsingCompleted() : void
      {
         if(loadCallback != null)
         {
            loadCallback.call([this.getErrorCode() == 0]);
         }
      }
      
      public function getErrorMessage() : String
      {
         return fetch("result.error.message");
      }
      
      public function getErrorCode() : Number
      {
         return Number(fetch("result.error.code"));
      }
      
      public function getSuccessMessage() : String
      {
         return "connected successfully";
      }
      
      public function getSubmitVar(varName:String) : *
      {
         return this.urlVar[varName];
      }
      
      public function getReturnedVar(varName:String) : *
      {
         return fetch("result." + varName);
      }
   }
}

