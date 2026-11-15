package com.jgp.helpers
{
   import flash.utils.getQualifiedClassName;
   
   public class ObjectHelper
   {
      
      public function ObjectHelper()
      {
         super();
      }
      
      public static function cloneObject(obj:Object) : Object
      {
         var coloneProp:* = undefined;
         var i:String = null;
         var cloned:Object = new Object();
         for(i in obj)
         {
            coloneProp = obj[i];
            if(getQualifiedClassName(coloneProp) == "Object")
            {
               coloneProp = cloneObject(coloneProp);
            }
            cloned[i] = coloneProp;
         }
         return cloned;
      }
      
      public static function copyProps(toObj:Object, fromObj:Object) : void
      {
         var p:String = null;
         for(p in fromObj)
         {
            try
            {
               toObj[p] = fromObj[p];
            }
            catch(error:Error)
            {
            }
         }
      }
   }
}

