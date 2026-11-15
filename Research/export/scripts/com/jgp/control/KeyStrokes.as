package com.jgp.control
{
   import flash.display.Stage;
   import flash.events.*;
   
   public class KeyStrokes
   {
      
      protected var keyListener:Object;
      
      protected var activeStage:Stage;
      
      public function KeyStrokes(keyStage:Stage)
      {
         super();
         var listenList:Array = new Array();
         var i:Number = 1;
         while(i < 266)
         {
            listenList.push(i);
            i++;
         }
         this.setListenObject(listenList);
         this.setKeyEvent(keyStage);
      }
      
      protected function setKeyEvent(keyStage:Stage) : void
      {
         keyStage.addEventListener(KeyboardEvent.KEY_DOWN,this.keyDown,false,0,true);
         keyStage.addEventListener(KeyboardEvent.KEY_UP,this.keyUp,false,0,true);
         keyStage.addEventListener(Event.DEACTIVATE,this.deactivateKeys,false,0,true);
         keyStage.addEventListener(Event.ACTIVATE,this.deactivateKeys,false,0,true);
         this.activeStage = keyStage;
      }
      
      public function clearKeyEvent() : void
      {
         this.activeStage.removeEventListener(KeyboardEvent.KEY_DOWN,this.keyDown);
         this.activeStage.removeEventListener(KeyboardEvent.KEY_UP,this.keyUp);
      }
      
      protected function setListenObject(listenList:Array) : void
      {
         var i:* = undefined;
         this.keyListener = new Object();
         for(i in listenList)
         {
            this.keyListener["key_" + listenList[i]] = false;
         }
      }
      
      protected function keyDown(event:KeyboardEvent) : void
      {
         if(this.keyListener["key_" + event.keyCode] != null)
         {
            this.keyListener["key_" + event.keyCode] = true;
         }
      }
      
      protected function keyUp(event:KeyboardEvent) : void
      {
         if(this.keyListener["key_" + event.keyCode] != null)
         {
            this.keyListener["key_" + event.keyCode] = false;
         }
      }
      
      public function keyIsDown(keyNum:Number) : Boolean
      {
         return this.keyListener["key_" + keyNum];
      }
      
      public function deactivateKeys(event:Event) : void
      {
         var i:* = undefined;
         for(i in this.keyListener)
         {
            this.keyListener[i] = false;
         }
      }
   }
}

