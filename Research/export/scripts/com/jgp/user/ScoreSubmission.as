package com.jgp.user
{
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.php.ScoreSubmit;
   import com.main.ui.Button;
   import fl.transitions.Tween;
   import fl.transitions.TweenEvent;
   import fl.transitions.easing.Regular;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol158")]
   public class ScoreSubmission extends MovieClip
   {
      
      public var exitToMainButton:Button;
      
      public var loggedInDisplay:MovieClip;
      
      public var loggedOutDisplay:MovieClip;
      
      public var retryButton:Button;
      
      public var scoreText:TextField;
      
      public var scoresButton:Button;
      
      protected var scoreValue:Number;
      
      protected var level:String;
      
      protected var gameId:Number;
      
      protected var submitURL:String;
      
      protected var connection:ScoreSubmit;
      
      protected var loginPrompt:UserLogin;
      
      protected var retryCallback:Callback;
      
      protected var fadeCallback:Callback;
      
      protected var tween:Tween;
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function ScoreSubmission(dispatcher:SimpleDispatcher, submitURL:String, scoreValue:Number, level:String, gameId:Number, retryCallback:Callback = null)
      {
         stop();
         this.scoreValue = scoreValue;
         this.level = level;
         this.gameId = gameId;
         this.submitURL = submitURL;
         this.retryCallback = retryCallback;
         super();
         this.scoreText.text = String(scoreValue);
         SimpleDispatcher.initialize(this,dispatcher);
         var userData:Object = this.dispatchSimpleEvent("getUserData");
         if(userData == null)
         {
            this.setLoggedOutState();
         }
         else
         {
            this.setLoggedInState();
         }
         this.setButtonEvents();
         this.fadeIn();
         this.__setProp_retryButton_ScoreSubmission_loggedin_0();
         this.__setProp_scoresButton_ScoreSubmission_loggedin_0();
         this.__setProp_exitToMainButton_ScoreSubmission_loggedin_0();
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
      
      protected function setButtonEvents() : void
      {
         this.loggedOutDisplay.loginButton.addEventListener(MouseEvent.MOUSE_DOWN,this.openLogin);
         this.loggedInDisplay.logoutButton.addEventListener(MouseEvent.MOUSE_DOWN,this.logout);
         this.loggedInDisplay.submitButton.addEventListener(MouseEvent.MOUSE_DOWN,this.submitScore);
         if(this.retryCallback != null)
         {
            this.retryButton.addEventListener(MouseEvent.MOUSE_DOWN,this.retry);
         }
         else
         {
            this.retryButton.visible = false;
         }
         this.scoresButton.addEventListener(MouseEvent.MOUSE_DOWN,this.showHighScores);
         this.exitToMainButton.addEventListener(MouseEvent.MOUSE_DOWN,this.showMainMenu);
      }
      
      protected function setLoggedOutState() : void
      {
         this.loggedOutDisplay.visible = true;
         this.loggedInDisplay.visible = false;
      }
      
      protected function openLogin(event:Event = null) : void
      {
         this.loggedOutDisplay.mouseChildren = false;
         this.loginPrompt = this.dispatchSimpleEvent("showLogInPrompt",[new Callback(this,this.setLoggedInState)]);
         addChild(this.loginPrompt);
         this.loginPrompt.registerSimpleEvent("onClosed",new Callback(this,this.onLoginClosed));
      }
      
      protected function showMainMenu(event:Event = null) : void
      {
         this.dispatchSimpleEvent("showMainMenu");
      }
      
      protected function showHighScores(event:Event = null) : void
      {
         this.dispatchSimpleEvent("showHighScores");
      }
      
      protected function onLoginClosed() : void
      {
         removeChild(this.loginPrompt);
         this.loggedOutDisplay.mouseChildren = true;
      }
      
      protected function logout(event:Event = null) : void
      {
         this.dispatchSimpleEvent("logout");
         this.setLoggedOutState();
      }
      
      protected function setLoggedInState() : void
      {
         this.loggedOutDisplay.visible = false;
         this.loggedInDisplay.visible = true;
         var userData:Object = this.dispatchSimpleEvent("getUserData");
         if(userData != null)
         {
            this.loggedInDisplay.loginText.text = "Logged in as " + userData.username.toLowerCase() + ". ";
         }
         else
         {
            this.setLoggedOutState();
         }
      }
      
      protected function retry(event:Event = null) : void
      {
         this.fadeOut(this.retryCallback);
      }
      
      protected function submitScore(event:Event = null) : void
      {
         mouseChildren = false;
         this.loggedInDisplay.errorText.text = "submitting your score...";
         var userData:Object = this.dispatchSimpleEvent("getUserData");
         this.connection = new ScoreSubmit(this.submitURL,userData.id,this.gameId,this.scoreValue,this.level,new Callback(this,this.onSubmitComplete));
      }
      
      protected function onSubmitComplete(success:Boolean) : void
      {
         this.loggedOutDisplay.mouseChildren = true;
         mouseChildren = true;
         if(!success)
         {
            this.loggedInDisplay.errorText.text = this.connection.getErrorMessage();
         }
         else
         {
            this.loggedInDisplay.errorText.text = this.connection.getSuccessMessage();
            this.loggedInDisplay.submitButton.enabled = false;
            this.loggedInDisplay.submitButton.alpha = 0.2;
            this.loggedOutDisplay.loginButton.enabled = false;
            this.loggedOutDisplay.loginButton.alpha = 0.2;
            this.loggedOutDisplay.loginText.alpha = 0;
         }
      }
      
      internal function __setProp_retryButton_ScoreSubmission_loggedin_0() : *
      {
         try
         {
            this.retryButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.retryButton.emphasized = false;
         this.retryButton.enabled = true;
         this.retryButton.label = "click to retry";
         this.retryButton.labelPlacement = "right";
         this.retryButton.selected = false;
         this.retryButton.toggle = false;
         this.retryButton.visible = true;
         try
         {
            this.retryButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_scoresButton_ScoreSubmission_loggedin_0() : *
      {
         try
         {
            this.scoresButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.scoresButton.emphasized = false;
         this.scoresButton.enabled = true;
         this.scoresButton.label = "highscores";
         this.scoresButton.labelPlacement = "right";
         this.scoresButton.selected = false;
         this.scoresButton.toggle = false;
         this.scoresButton.visible = true;
         try
         {
            this.scoresButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
      
      internal function __setProp_exitToMainButton_ScoreSubmission_loggedin_0() : *
      {
         try
         {
            this.exitToMainButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.exitToMainButton.emphasized = false;
         this.exitToMainButton.enabled = true;
         this.exitToMainButton.label = "exit to main menu";
         this.exitToMainButton.labelPlacement = "right";
         this.exitToMainButton.selected = false;
         this.exitToMainButton.toggle = false;
         this.exitToMainButton.visible = true;
         try
         {
            this.exitToMainButton["componentInspectorSetting"] = false;
         }
         catch(e:Error)
         {
         }
      }
   }
}

