package com.game.grid
{
   public class GridTile
   {
      
      protected var bgAssetName:String = "default_tile_bg";
      
      protected var blocked:Boolean = false;
      
      protected var locked:Boolean = false;
      
      public function GridTile(blockTile:Boolean)
      {
         super();
         if(blockTile)
         {
            this.block();
         }
      }
      
      public function isBlocked() : Boolean
      {
         return this.blocked;
      }
      
      public function block() : void
      {
         this.blocked = true;
      }
      
      public function unblock() : void
      {
         this.blocked = false;
      }
      
      public function isLocked() : Boolean
      {
         return this.locked;
      }
      
      public function lock() : void
      {
         this.locked = true;
      }
      
      public function unlock() : void
      {
         this.locked = false;
      }
   }
}

