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
   
   [Embed(source="/_assets/assets.swf", symbol="symbol157")]
   public dynamic class ScoreSubmissionLoggedIn_214 extends MovieClip
   {
      
      public var errorText:TextField;
      
      public var loginText:TextField;
      
      public var logoutButton:Button;
      
      public var submitButton:Button;
      
      public function ScoreSubmissionLoggedIn_214()
      {
         super();
         this.__setProp_logoutButton_ScoreSubmissionLoggedIn_Layer1_0();
         this.__setProp_submitButton_ScoreSubmissionLoggedIn_Layer1_0();
      }
      
      internal function __setProp_logoutButton_ScoreSubmissionLoggedIn_Layer1_0() : *
      {
         try
         {
            this.logoutButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.logoutButton.emphasized = false;
         this.logoutButton.enabled = true;
         this.logoutButton.label = "logout";
         this.logoutButton.labelPlacement = "right";
         this.logoutButton.selected = false;
         this.logoutButton.toggle = false;
         this.logoutButton.visible = true;
         try
         {
            this.logoutButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_submitButton_ScoreSubmissionLoggedIn_Layer1_0() : *
      {
         try
         {
            this.submitButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.submitButton.emphasized = false;
         this.submitButton.enabled = true;
         this.submitButton.label = "submit score";
         this.submitButton.labelPlacement = "right";
         this.submitButton.selected = false;
         this.submitButton.toggle = false;
         this.submitButton.visible = true;
         try
         {
            this.submitButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

