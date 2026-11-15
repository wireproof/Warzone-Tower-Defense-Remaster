package com.jgp.user
{
   import com.jgp.functions.SimpleDispatcher;
   import fl.controls.ComboBox;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class LevelSelectListBox extends MovieClip
   {
      
      protected var selectBox:ComboBox;
      
      protected var leveDataList:Array;
      
      protected var imgLoader:Loader;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function LevelSelectListBox()
      {
         super();
         this.imgLoader = new Loader();
         SimpleDispatcher.initialize(this);
      }
      
      public function initialize(comboBox:ComboBox, itemList:Array) : void
      {
         var item:Object = null;
         this.selectBox = comboBox;
         for each(item in itemList)
         {
            this.selectBox.addItem(item);
         }
         this.selectBox.addEventListener(Event.CHANGE,this.onListSelectionChanged);
         this.selectBox.selectedIndex = 0;
      }
      
      public function onLevelSelected(event:MouseEvent) : *
      {
         this.dispatchSimpleEvent("onLevelSelected");
      }
      
      public function onListSelectionChanged(event:Event = null) : *
      {
         this.dispatchSimpleEvent("onListSelectionChanged");
      }
      
      public function getSelectedLabel() : String
      {
         return this.selectBox.selectedLabel;
      }
      
      public function getSelectedData() : String
      {
         return this.selectBox.selectedItem.data;
      }
   }
}

