package com.jgp.user
{
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.php.*;
   import com.main.ui.Button;
   import fl.controls.CheckBox;
   import fl.transitions.Tween;
   import fl.transitions.TweenEvent;
   import fl.transitions.easing.Regular;
   import flash.display.MovieClip;
   import flash.display.SimpleButton;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol148")]
   public class UserLogin extends MovieClip
   {
      
      public var closeButton:SimpleButton;
      
      public var errorText:TextField;
      
      public var loginButton:Button;
      
      public var login_password:TextField;
      
      public var login_userName:TextField;
      
      public var signUpButton:Button;
      
      public var signUp_confirm:TextField;
      
      public var signUp_email:TextField;
      
      public var signUp_firstName:TextField;
      
      public var signUp_option:CheckBox;
      
      public var signUp_password:TextField;
      
      public var signUp_userName:TextField;
      
      protected var connection:PHPConnect;
      
      protected var onLoggedInCallback:Callback;
      
      protected var fadeCallback:Callback;
      
      protected var tween:Tween;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function UserLogin(onLoggedInCallback:Callback)
      {
         super();
         this.onLoggedInCallback = onLoggedInCallback;
         SimpleDispatcher.initialize(this);
         this.loginButton.addEventListener(MouseEvent.MOUSE_DOWN,this.attemptLogin);
         this.signUpButton.addEventListener(MouseEvent.MOUSE_DOWN,this.attemptSignUp);
         this.closeButton.addEventListener(MouseEvent.MOUSE_DOWN,this.closeWindow);
         this.login_password.displayAsPassword = true;
         this.signUp_password.displayAsPassword = true;
         this.signUp_confirm.displayAsPassword = true;
         this.login_userName.tabIndex = 1;
         this.login_password.tabIndex = 2;
         this.loginButton.tabIndex = 3;
         this.signUp_userName.tabIndex = 4;
         this.signUp_password.tabIndex = 5;
         this.signUp_confirm.tabIndex = 6;
         this.signUp_firstName.tabIndex = 7;
         this.signUp_email.tabIndex = 8;
         this.signUp_option.tabIndex = 9;
         this.signUpButton.tabIndex = 10;
         addEventListener(Event.ADDED_TO_STAGE,this.onAddedToStage);
         this.fadeIn();
         this.__setProp_signUp_option_UserLogin_Layer1_0();
         this.__setProp_signUpButton_UserLogin_Layer1_0();
         this.__setProp_loginButton_UserLogin_Layer1_0();
      }
      
      protected function fadeIn() : void
      {
         blendMode = "layer";
         this.tween = new Tween(this,"alpha",Regular.easeOut,0,1,10,false);
      }
      
      protected function fadeOut(callback:Callback) : void
      {
         this.fadeCallback = callback;
         mouseChildren = false;
         mouseEnabled = false;
         this.tween.stop();
         this.tween = new Tween(this,"alpha",Regular.easeOut,this.alpha,0,10,false);
         this.tween.addEventListener(TweenEvent.MOTION_FINISH,this.onFadedOut);
      }
      
      protected function onFadedOut(event:Event) : void
      {
         if(this.fadeCallback != null)
         {
            this.fadeCallback.call();
         }
      }
      
      protected function onAddedToStage(event:Event) : void
      {
         this.errorText.text = "";
         this.login_password.text = "";
         this.signUp_password.text = "";
         this.signUp_confirm.text = "";
      }
      
      protected function attemptLogin(event:MouseEvent) : void
      {
         var username:String = this.login_userName.text;
         var password:String = this.login_password.text;
         this.errorText.text = "attemping to connect to the database..";
         this.connection = new Login("http://www.madcowinteractive.com/php/login.php",username,password,new Callback(this,this.onConnectionAttempt));
      }
      
      protected function attemptSignUp(event:MouseEvent) : void
      {
         mouseChildren = false;
         var username:String = this.signUp_userName.text;
         var password:String = this.signUp_password.text;
         var confirm:String = this.signUp_confirm.text;
         var firstname:String = this.signUp_firstName.text;
         var email:String = this.signUp_email.text;
         var option:Boolean = this.signUp_option.selected;
         this.errorText.text = "attemping to connect to the database..";
         this.connection = new SignUp("http://www.madcowinteractive.com/php/signup.php",username,password,confirm,firstname,email,option,new Callback(this,this.onConnectionAttempt));
      }
      
      protected function onConnectionAttempt(success:Boolean) : void
      {
         if(!success)
         {
            mouseChildren = true;
            this.errorText.text = this.connection.getErrorMessage();
         }
         else
         {
            this.errorText.text = this.connection.getSuccessMessage();
            this.dispatchSimpleEvent("updateUserData",[this.connection]);
            this.onLoggedInCallback.call();
            this.closeWindow();
         }
      }
      
      protected function closeWindow(event:Event = null) : void
      {
         this.fadeOut(new Callback(this,this.dispatchSimpleEvent,["onClosed"]));
      }
      
      internal function __setProp_signUp_option_UserLogin_Layer1_0() : *
      {
         try
         {
            this.signUp_option["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.signUp_option.enabled = true;
         this.signUp_option.label = "";
         this.signUp_option.labelPlacement = "right";
         this.signUp_option.selected = false;
         this.signUp_option.visible = true;
         try
         {
            this.signUp_option["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_signUpButton_UserLogin_Layer1_0() : *
      {
         try
         {
            this.signUpButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.signUpButton.emphasized = false;
         this.signUpButton.enabled = true;
         this.signUpButton.label = "create user";
         this.signUpButton.labelPlacement = "right";
         this.signUpButton.selected = false;
         this.signUpButton.toggle = false;
         this.signUpButton.visible = true;
         try
         {
            this.signUpButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_loginButton_UserLogin_Layer1_0() : *
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
         this.loginButton.label = "login";
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

