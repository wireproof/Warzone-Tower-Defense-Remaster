package com.jgp.xml
{
   import com.jgp.functions.Callback;
   import flash.events.*;
   import flash.net.URLLoader;
   import flash.net.URLRequest;
   import flash.net.URLVariables;
   import flash.utils.getDefinitionByName;
   import flash.xml.*;
   
   public class XMLFetch
   {
      
      protected var dataTree:Object;
      
      protected var loadCallback:Callback;
      
      protected var loadAttempt:String;
      
      public function XMLFetch(fileName:String = null, loadCallback:Callback = null, urlVar:URLVariables = null, urlReqMeth:String = null)
      {
         super();
         if(fileName != null)
         {
            this.loadFile(fileName,loadCallback,urlVar,urlReqMeth);
         }
      }
      
      public function fetch(nodeName:String = null) : *
      {
         if(nodeName == null)
         {
            return this.dataTree;
         }
         var targList:Array = nodeName.split(".");
         var compiledTarget:Object = this.dataTree;
         while(targList.length > 0 && nodeName != null)
         {
            compiledTarget = compiledTarget[targList.shift()];
         }
         return compiledTarget;
      }
      
      public function loadFile(fileName:String, loadCallback:Callback = null, urlVars:URLVariables = null, urlReqMeth:String = null) : void
      {
         this.loadAttempt = fileName;
         this.loadCallback = loadCallback;
         var urlReq:URLRequest = new URLRequest(fileName);
         if(urlReqMeth != null)
         {
            urlReq.method = urlReqMeth;
         }
         if(urlVars != null)
         {
            urlReq.data = urlVars;
         }
         var urlLoader:URLLoader = new URLLoader(urlReq);
         urlLoader.addEventListener(Event.COMPLETE,this.URLLoaded,false,0,true);
         urlLoader.addEventListener("ioError",this.URLLoadError,false,0,true);
      }
      
      public function parseFromString(xmlData:String) : void
      {
         this.loadCallback = null;
         this.parseDocument(xmlData);
      }
      
      protected function URLLoaded(event:Event) : void
      {
         this.parseDocument(String(event.target.data));
      }
      
      protected function URLLoadError(event:Event) : void
      {
         this.loadFile(this.loadAttempt,this.loadCallback);
      }
      
      protected function parseDocument(xmlData:String) : void
      {
         this.dataTree = new Object();
         var xmlDoc:XMLDocument = new XMLDocument();
         xmlDoc.ignoreWhite = true;
         xmlDoc.parseXML(xmlData);
         this.addNodeList(this.dataTree,xmlDoc.childNodes);
         this.parsingCompleted();
      }
      
      protected function parsingCompleted() : void
      {
         if(this.loadCallback != null)
         {
            this.loadCallback.call();
         }
      }
      
      protected function addNodeList(addTo:Object, nodeList:*) : void
      {
         var thisNode:XMLNode = null;
         var nodeType:String = null;
         var subNode:Object = null;
         var classRef:Class = null;
         for(var n:* = 0; n < nodeList.length; n++)
         {
            thisNode = nodeList[n];
            if(thisNode.nodeName != "script")
            {
               nodeType = this.getNodeType(thisNode);
               if(nodeType == "Object" || nodeType == "Array")
               {
                  classRef = Class(getDefinitionByName(nodeType));
                  subNode = new classRef();
                  this.addNodeList(subNode,thisNode.childNodes);
               }
               else
               {
                  subNode = this.evaluateNode(nodeType,thisNode.firstChild.nodeValue);
               }
               if(addTo is Array)
               {
                  addTo.push(subNode);
               }
               else if(addTo is Object)
               {
                  addTo[this.getNewPropertyName(addTo,thisNode.nodeName)] = subNode;
               }
            }
         }
      }
      
      protected function getNodeType(xml:*) : String
      {
         if(xml.attributes.type == "Object" || xml.childNodes.length > 1 && xml.attributes.type == null)
         {
            return "Object";
         }
         if(xml.attributes.type == null)
         {
            return "String";
         }
         return xml.attributes.type;
      }
      
      protected function evaluateNode(nodeType:String, nodeValue:String) : *
      {
         var classRef:Class = getDefinitionByName(nodeType) as Class;
         if(nodeType == "Boolean")
         {
            return classRef(Number(nodeValue));
         }
         return classRef(nodeValue);
      }
      
      protected function getNewPropertyName(addTo:Object, nodeName:String) : String
      {
         var checkName:String = nodeName;
         var nameCount:Number = 0;
         while(addTo[checkName] != null)
         {
            nameCount++;
            checkName = nodeName + "_" + nameCount;
         }
         return checkName;
      }
   }
}

