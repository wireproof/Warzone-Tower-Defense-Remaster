package com.main.ui
{
   import com.jgp.audio.AudioControl;
   import fl.controls.ComboBox;
   import fl.controls.List;
   import flash.events.Event;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.text.Font;
   import flash.text.TextFormat;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol233")]
   public class CustomComboBox extends ComboBox
   {
      
      public function CustomComboBox()
      {
         super();
         var font:Font = new ButtonFont();
         var tf:TextFormat = new TextFormat(font.fontName,null,16777215,null,null,null,null,null,null,null,null,null,null);
         tf.size = 9;
         textField.textField.embedFonts = true;
         var list:List = dropdown;
         list.setRendererStyle("textFormat",tf);
         var glow:* = new GlowFilter(4294967295,0.5);
         textField.filters = [glow];
         var ct:ColorTransform = new ColorTransform();
         ct.color = 16777215;
         textField.transform.colorTransform = ct;
         cacheAsBitmap = true;
         addEventListener("change",this.onSelectionChanged);
      }
      
      protected function onSelectionChanged(event:Event) : void
      {
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.playSound("ClickSound",0,null,false);
      }
   }
}

