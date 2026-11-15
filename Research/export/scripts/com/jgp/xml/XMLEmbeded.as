package com.jgp.xml
{
   import com.game.level.LevelLayoutData;
   import flash.display.Sprite;
   import flash.utils.ByteArray;
   
   public class XMLEmbeded extends Sprite
   {
      
      private static var _instance:XMLEmbeded;
      
      private var _config_mj:Class = XMLEmbeded__config_mj;
      
      private var _level_1_config:Class = XMLEmbeded__level_1_config;
      
      private var _level_1_layout:Class = XMLEmbeded__level_1_layout;
      
      private var _level_1_ground_config:Class = XMLEmbeded__level_1_ground_config;
      
      private var _level_1_ground_layout:Class = XMLEmbeded__level_1_ground_layout;
      
      private var _level_2_config:Class = XMLEmbeded__level_2_config;
      
      private var _level_2_layout:Class = XMLEmbeded__level_2_layout;
      
      private var _level_2_ground_config:Class = XMLEmbeded__level_2_ground_config;
      
      private var _level_2_ground_layout:Class = XMLEmbeded__level_2_ground_layout;
      
      private var _level_3_config:Class = XMLEmbeded__level_3_config;
      
      private var _level_3_layout:Class = XMLEmbeded__level_3_layout;
      
      private var _level_3_ground_config:Class = XMLEmbeded__level_3_ground_config;
      
      private var _level_3_ground_layout:Class = XMLEmbeded__level_3_ground_layout;
      
      private var _level_4_config:Class = XMLEmbeded__level_4_config;
      
      private var _level_4_layout:Class = XMLEmbeded__level_4_layout;
      
      private var _level_4_ground_config:Class = XMLEmbeded__level_4_ground_config;
      
      private var _level_4_ground_layout:Class = XMLEmbeded__level_4_ground_layout;
      
      private var _level_5_config:Class = XMLEmbeded__level_5_config;
      
      private var _level_5_layout:Class = XMLEmbeded__level_5_layout;
      
      private var _level_5_ground_config:Class = XMLEmbeded__level_5_ground_config;
      
      private var _level_5_ground_layout:Class = XMLEmbeded__level_5_ground_layout;
      
      private var _level_6_config:Class = XMLEmbeded__level_6_config;
      
      private var _level_6_layout:Class = XMLEmbeded__level_6_layout;
      
      private var _level_6_ground_config:Class = XMLEmbeded__level_6_ground_config;
      
      private var _level_6_ground_layout:Class = XMLEmbeded__level_6_ground_layout;
      
      public function XMLEmbeded()
      {
         super();
      }
      
      public static function getInstance() : XMLEmbeded
      {
         if(_instance == null)
         {
            _instance = new XMLEmbeded();
         }
         return _instance;
      }
      
      private function getXMLFetchObj(binaryData:Class) : XMLFetch
      {
         var byteArray:ByteArray = new binaryData();
         var data:XML = new XML(byteArray.readUTFBytes(byteArray.length));
         var xmlFetcher:XMLFetch = new XMLFetch();
         xmlFetcher.parseFromString(data.toXMLString());
         return xmlFetcher;
      }
      
      public function getMainConfigXML() : XMLFetch
      {
         return this.getXMLFetchObj(this._config_mj);
      }
      
      public function getLevelLayoutXML(levelName:String) : LevelLayoutData
      {
         var classRef:Class = this[levelName + "_layout"] as Class;
         var byteArray:ByteArray = new classRef();
         var data:XML = new XML(byteArray.readUTFBytes(byteArray.length));
         var levelLayoutData:LevelLayoutData = new LevelLayoutData();
         levelLayoutData.parseFromString(data.toXMLString());
         return levelLayoutData;
      }
      
      public function getLevelConfigXML(levelName:String) : XMLFetch
      {
         var classRef:Class = this[levelName + "_config"] as Class;
         return this.getXMLFetchObj(classRef);
      }
   }
}

