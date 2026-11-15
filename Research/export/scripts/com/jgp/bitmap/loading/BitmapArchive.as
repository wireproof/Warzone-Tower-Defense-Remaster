package com.jgp.bitmap.loading
{
   import flash.display.*;
   
   public class BitmapArchive
   {
      
      internal var bitmapRefs:Object;
      
      public function BitmapArchive()
      {
         super();
         this.bitmapRefs = new Object();
      }
      
      public function setBitmap(fileName:String, bmp:Bitmap) : void
      {
         this.bitmapRefs[fileName] = bmp;
      }
      
      public function setBitmapData(fileName:String, bmd:BitmapData) : void
      {
         this.bitmapRefs[fileName] = new Bitmap(bmd);
      }
      
      public function getBitmap(fileName:String) : Bitmap
      {
         if(this.bitmapRefs[fileName] != null)
         {
            return this.bitmapRefs[fileName];
         }
         return null;
      }
      
      public function dispose(fileName:String) : void
      {
         if(this.bitmapRefs[fileName] != null)
         {
            this.getBitmapData(fileName).dispose();
            delete this.bitmapRefs[fileName];
         }
      }
      
      public function getBitmapData(fileName:String) : BitmapData
      {
         var bmp:Bitmap = null;
         if(this.bitmapRefs[fileName] != null)
         {
            bmp = this.bitmapRefs[fileName];
            return bmp.bitmapData;
         }
         return null;
      }
      
      public function copyArchive(toCopy:BitmapArchive, overwrite:Boolean = false) : void
      {
         var i:* = undefined;
         for(i in toCopy.bitmapRefs)
         {
            if(this.bitmapRefs[i] == null || overwrite)
            {
               this.setBitmap(i,toCopy.getBitmap(i));
            }
         }
      }
      
      public function nameRegistered(fileName:String) : Boolean
      {
         return this.bitmapRefs[fileName] != null;
      }
   }
}

