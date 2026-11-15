package com.jgp.user
{
   import com.jgp.functions.Callback;
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.php.PHPConnect;
   
   public class UserManagement
   {
      
      protected static var loginPrompt:UserLogin;
      
      protected static var userData:Object;
      
      protected static var GAME_ID:Number = 1;
      
      protected static var SCORE_SUBMIT_URL:String = "http://www.madcowinteractive.com/php/TDWarzone/submit_score_v5.php";
      
      protected static var HIGH_SCORES_URL:String = "http://www.madcowinteractive.com/php/highscores.php";
      
      public function UserManagement()
      {
         super();
      }
      
      public static function getLogInPrompt(callback:Callback) : UserLogin
      {
         loginPrompt = new UserLogin(callback);
         loginPrompt.registerSimpleEvent("updateUserData",new Callback(UserManagement,updateUserFromConnection));
         return loginPrompt;
      }
      
      protected static function updateUserFromConnection(connection:PHPConnect) : void
      {
         userData = {
            "username":connection.getSubmitVar("username"),
            "id":Number(connection.getReturnedVar("id"))
         };
      }
      
      public static function getScoreSubmissionPrompt(scoreValue:Number, levelId:String, retryCallback:Callback) : ScoreSubmission
      {
         var dispatcher:SimpleDispatcher = new SimpleDispatcher();
         dispatcher.registerSimpleEvent("getUserData",new Callback(UserManagement,getUserData));
         dispatcher.registerSimpleEvent("showLogInPrompt",new Callback(UserManagement,getLogInPrompt));
         dispatcher.registerSimpleEvent("logout",new Callback(UserManagement,logoutCurrentUser));
         return new ScoreSubmission(dispatcher,SCORE_SUBMIT_URL,scoreValue,levelId,GAME_ID,retryCallback);
      }
      
      public static function getHighScoresDisplay(levelList:Array, modeList:Array, exitCallback:Callback = null) : HighScoresDisplay
      {
         return new HighScoresDisplay(HIGH_SCORES_URL,GAME_ID,levelList,modeList,exitCallback);
      }
      
      public static function getUserData() : Object
      {
         return userData;
      }
      
      public static function logoutCurrentUser() : void
      {
         userData = null;
      }
   }
}

