package warzone_original_fla
{
   import adobe.utils.*;
   import com.main.ui.Button;
   import flash.accessibility.*;
   import flash.desktop.*;
   import flash.display.*;
   import flash.errors.*;
   import flash.events.*;
   import flash.external.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.globalization.*;
   import flash.media.*;
   import flash.net.*;
   import flash.net.drm.*;
   import flash.printing.*;
   import flash.profiler.*;
   import flash.sampler.*;
   import flash.sensors.*;
   import flash.system.*;
   import flash.text.*;
   import flash.text.engine.*;
   import flash.text.ime.*;
   import flash.ui.*;
   import flash.utils.*;
   import flash.xml.*;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol153")]
   public dynamic class ScoreSubmissionLoggedOut_213 extends MovieClip
   {
      
      public var loginButton:Button;
      
      public var loginText:TextField;
      
      public function ScoreSubmissionLoggedOut_213()
      {
         super();
         this.__setProp_loginButton_ScoreSubmissionLoggedOut_Layer1_0();
      }
      
      internal function __setProp_loginButton_ScoreSubmissionLoggedOut_Layer1_0() : *
      {
         try
         {
            this.loginButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.loginButton.emphasized = false;
         this.loginButton.enabled = true;
         this.loginButton.label = "login / create account";
         this.loginButton.labelPlacement = "right";
         this.loginButton.selected = false;
         this.loginButton.toggle = false;
         this.loginButton.visible = true;
         try
         {
            this.loginButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

