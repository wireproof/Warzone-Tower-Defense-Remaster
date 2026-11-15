package com.main.ui
{
   import com.jgp.audio.AudioControl;
   import fl.controls.Button;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.AntiAliasType;
   import flash.text.Font;
   import flash.text.TextFormat;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol111")]
   public class Button extends fl.controls.Button
   {
      
      public function Button()
      {
         super();
         var font:Font = new ButtonFont();
         this.label = label.toUpperCase();
         textField.embedFonts = true;
         textField.antiAliasType = "advanced";
         var tf:TextFormat = new TextFormat(font.fontName,null,16777215);
         tf.size = 9;
         tf.bold = true;
         setStyle("textFormat",tf);
         var glow:* = new GlowFilter(0,0.75);
         textField.filters = [glow];
         cacheAsBitmap = true;
         textField.antiAliasType = AntiAliasType.ADVANCED;
         this.addEventListener(MouseEvent.MOUSE_DOWN,this.playClickSound,false);
      }
      
      override protected function keyDownHandler(event:KeyboardEvent) : void
      {
      }
      
      override protected function keyUpHandler(event:KeyboardEvent) : void
      {
      }
      
      override public function set label(labelText:String) : void
      {
         super.label = labelText.toUpperCase();
      }
      
      protected function playClickSound(event:MouseEvent) : void
      {
         var audioController:AudioControl = AudioControl.getInstance();
         audioController.playSound("ClickSound",0,null,false);
      }
   }
}

