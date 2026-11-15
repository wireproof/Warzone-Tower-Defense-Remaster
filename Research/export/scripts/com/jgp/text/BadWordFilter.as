package com.jgp.text
{
   public class BadWordFilter
   {
      
      protected static var FILLER_TEXT:String = "#$%@!#$#*@#!@$$%@!#$#*@#!@$$%@!#$#*@#!@$$%@!#$#*@#!@$";
      
      protected static var wordList:Array = new Array();
      
      public function BadWordFilter()
      {
         super();
      }
      
      public static function setWordList(words:String) : void
      {
         wordList = words.split(",");
      }
      
      public static function filterBadWords(msgText:String) : String
      {
         var wordIndex:Number = NaN;
         var word:String = null;
         for each(word in wordList)
         {
            wordIndex = msgText.indexOf(word);
            while(wordIndex >= 0)
            {
               msgText = replaceWord(msgText,word,wordIndex);
               wordIndex = msgText.indexOf(word);
            }
         }
         return msgText;
      }
      
      protected static function replaceWord(msgText:String, replaceWord:String, startIndex:Number) : String
      {
         var endIndex:Number = startIndex + replaceWord.length;
         var start:String = msgText.substring(0,startIndex);
         var end:String = msgText.substring(endIndex,msgText.length);
         return start + FILLER_TEXT.substr(0,replaceWord.length) + end;
      }
   }
}

