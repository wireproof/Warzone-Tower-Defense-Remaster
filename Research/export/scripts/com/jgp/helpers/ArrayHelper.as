package com.jgp.helpers
{
   public class ArrayHelper
   {
      
      public function ArrayHelper()
      {
         super();
      }
      
      public static function getRandomIndex(array:Array) : Number
      {
         return Math.floor(Math.random() * array.length);
      }
      
      public static function getRandomElement(array:Array) : *
      {
         return array[getRandomIndex(array)];
      }
      
      public static function removeRandomElement(array:Array) : *
      {
         return array.splice(getRandomIndex(array),1)[0];
      }
      
      public static function clone(array:Array) : Array
      {
         var clonedArray:Array = new Array();
         for(var i:* = 0; i < array.length; i++)
         {
            clonedArray.push(array[i]);
         }
         return clonedArray;
      }
      
      public static function jumbleElements(array:Array) : Array
      {
         var tempArray:Array = clone(array);
         var jumbledArray:Array = new Array();
         while(tempArray.length > 0)
         {
            jumbledArray.push(removeRandomElement(tempArray));
         }
         return jumbledArray;
      }
      
      public static function merge(... args) : *
      {
         var j:Number = NaN;
         var merged:Array = new Array();
         for(var i:Number = 0; i < args.length; i++)
         {
            if(args[i] is Array)
            {
               for(j = 0; j < args[i].length; j++)
               {
                  merged.push(args[i][j]);
               }
            }
         }
         return merged;
      }
   }
}

