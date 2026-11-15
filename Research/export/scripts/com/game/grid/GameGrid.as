package com.game.grid
{
   import com.jgp.bitmap.loading.BitmapArchive;
   import com.jgp.functions.SimpleDispatcher;
   import com.jgp.helpers.ArrayHelper;
   import com.jgp.math.geom.*;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.DropShadowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   
   public class GameGrid extends Sprite
   {
      
      protected static const MINIMUM_TILE_COST:Number = 130;
      
      protected var tileSize:Number;
      
      protected var gridWidth:Number;
      
      protected var gridHeight:Number;
      
      protected var gridNodes:Array;
      
      protected var bgBMD:BitmapData;
      
      protected var bgBMP:Bitmap;
      
      protected var fgBMD:BitmapData;
      
      protected var costChartBMD:BitmapData;
      
      protected var costChartBMP:Bitmap;
      
      protected var tileArchive:BitmapArchive;
      
      protected var floorArchiveNames:Array;
      
      protected var visualConfig:Object;
      
      protected var attachedObjRefs:Object;
      
      protected var checkToPoint:GPoint = new GPoint(0,0);
      
      protected var checkFromPoint:GPoint = new GPoint(0,0);
      
      protected var cornerPoint:* = new GPoint(0,0);
      
      public var dispatchSimpleEvent:Function;
      
      public var clearSimpleEvent:Function;
      
      public var registerSimpleEvent:Function;
      
      public function GameGrid(gridWidth:Number, gridHeight:Number, tileSize:Number, tileArchive:BitmapArchive, floorArchiveNames:Array, visualConfig:Object)
      {
         super();
         SimpleDispatcher.initialize(this);
         this.tileSize = tileSize;
         this.gridWidth = gridWidth;
         this.gridHeight = gridHeight;
         this.tileArchive = tileArchive;
         this.floorArchiveNames = floorArchiveNames;
         this.visualConfig = visualConfig;
         this.attachedObjRefs = new Object();
         this.createImageAssets();
         addChild(this.bgBMP);
         cacheAsBitmap = true;
      }
      
      public function drawGrid(blockList:Object) : void
      {
         this.buildGrid(blockList);
      }
      
      public function dispose() : void
      {
         this.costChartBMD.dispose();
         this.bgBMD.dispose();
      }
      
      protected function createImageAssets() : void
      {
         this.bgBMD = new BitmapData(this.tileSize * this.gridWidth,this.tileSize * this.gridHeight,true,0);
         this.fgBMD = this.bgBMD.clone();
         this.bgBMP = new Bitmap(this.bgBMD);
         this.costChartBMD = new BitmapData(this.tileSize * this.gridWidth,this.tileSize * this.gridHeight,true,16777215);
         this.costChartBMP = new Bitmap(this.costChartBMD);
      }
      
      protected function buildGrid(blockRefs:Object) : void
      {
         var column:Array = null;
         var gridTile:GridTile = null;
         var tileBlocked:Boolean = false;
         this.gridNodes = new Array();
         var gridLoc:GPoint = new GPoint(0,0);
         for(gridLoc.x = 0; gridLoc.x < this.gridWidth; ++gridLoc.x)
         {
            column = new Array();
            for(gridLoc.y = 0; gridLoc.y < this.gridHeight; ++gridLoc.y)
            {
               tileBlocked = blockRefs[gridLoc.toString()] != null;
               gridTile = new GridTile(tileBlocked);
               this.drawTileBackground(gridLoc,blockRefs[gridLoc.toString()]);
               column.push(gridTile);
            }
            this.gridNodes.push(column);
         }
         this.mergeBMDSAndApplyFilters();
      }
      
      public function drawTileBackground(gridLoc:GPoint, archiveName:String = "") : void
      {
         var screenLoc:GPoint = null;
         var sourceBMD:BitmapData = null;
         var floorArchiveName:String = null;
         if(this.checkPointSelectable(gridLoc))
         {
            screenLoc = this.gridToScreenLoc(gridLoc);
            floorArchiveName = ArrayHelper.getRandomElement(this.floorArchiveNames);
            if(this.tileArchive.nameRegistered(floorArchiveName))
            {
               sourceBMD = this.tileArchive.getBitmapData(floorArchiveName);
               this.bgBMD.copyPixels(sourceBMD,sourceBMD.rect,screenLoc,null,null,true);
            }
            if(this.tileArchive.nameRegistered(archiveName))
            {
               sourceBMD = this.tileArchive.getBitmapData(archiveName);
               this.fgBMD.copyPixels(sourceBMD,sourceBMD.rect,screenLoc,null,null,true);
               this.updateCostChart(gridLoc,"alphaBlock");
            }
         }
      }
      
      protected function mergeBMDSAndApplyFilters() : void
      {
         var ctObj:Object = null;
         var foregroundCt:ColorTransform = null;
         var colMatrix:* = undefined;
         var shadow:DropShadowFilter = null;
         var bgCt:ColorTransform = null;
         if(this.visualConfig.fgColorTransform != null)
         {
            ctObj = this.visualConfig.fgColorTransform;
            foregroundCt = new ColorTransform(ctObj.r,ctObj.g,ctObj.b,ctObj.a,ctObj.rM,ctObj.gM,ctObj.bM,ctObj.aM);
            this.fgBMD.colorTransform(this.fgBMD.rect,foregroundCt);
         }
         if(this.visualConfig.fgColMartix != null)
         {
            colMatrix = new ColorMatrixFilter();
            colMatrix.matrix = this.visualConfig.fgColMartix;
            this.fgBMD.applyFilter(this.fgBMD,this.fgBMD.rect,new GPoint(),colMatrix);
         }
         if(this.visualConfig.shadow != null)
         {
            shadow = new DropShadowFilter();
            shadow.distance = this.visualConfig.shadow.distance;
            shadow.blurX = this.visualConfig.shadow.blurX;
            shadow.blurY = this.visualConfig.shadow.blurY;
            shadow.strength = this.visualConfig.shadow.strength;
            shadow.angle = this.visualConfig.shadow.angle;
            shadow.quality = this.visualConfig.shadow.quality;
            shadow.alpha = this.visualConfig.shadow.alpha;
            this.fgBMD.applyFilter(this.fgBMD,this.fgBMD.rect,new GPoint(),shadow);
         }
         if(this.visualConfig.bgColorTransform != null)
         {
            ctObj = this.visualConfig.bgColorTransform;
            bgCt = new ColorTransform(ctObj.r,ctObj.g,ctObj.b,ctObj.a,ctObj.rM,ctObj.gM,ctObj.bM,ctObj.aM);
            this.bgBMD.colorTransform(this.bgBMD.rect,bgCt);
         }
         this.bgBMD.copyPixels(this.fgBMD,this.fgBMD.rect,new GPoint(),null,null,true);
         this.fgBMD.dispose();
      }
      
      public function updateCostChart(gridLoc:GPoint, alphaArchiveName:String) : void
      {
         var sourceBMD:BitmapData = this.tileArchive.getBitmapData(alphaArchiveName);
         var drawPoint:GPoint = this.gridToScreenLoc(gridLoc);
         drawPoint.x -= sourceBMD.width / 2 - this.tileSize / 2;
         drawPoint.y -= sourceBMD.height / 2 - this.tileSize / 2;
         this.costChartBMD.copyPixels(sourceBMD,sourceBMD.rect,drawPoint,null,null,true);
      }
      
      public function drawToBg(drawPoint:GPoint, sourceBMD:BitmapData, rect:Rectangle) : void
      {
         this.bgBMD.copyPixels(sourceBMD,rect,drawPoint,null,null,true);
      }
      
      public function attachGridObject(attachGridLoc:GPoint, objClip:MovieClip) : void
      {
         var y:Number = NaN;
         var drawPoint:GPoint = this.gridToScreenLoc(attachGridLoc);
         var tileWidth:Number = Math.floor(objClip.width / this.tileSize);
         var tileHeight:Number = Math.floor(objClip.height / this.tileSize);
         drawPoint.x -= tileWidth * this.tileSize / 2 - this.tileSize / 2;
         drawPoint.y -= tileHeight * this.tileSize / 2 - this.tileSize / 2;
         objClip.x = drawPoint.x;
         objClip.y = drawPoint.y;
         addChild(objClip);
         var gridLoc:GPoint = this.screenToGridLoc(drawPoint);
         var tileLoc:GPoint = new GPoint();
         for(var x:Number = gridLoc.x; x < gridLoc.x + tileWidth; x++)
         {
            for(y = gridLoc.y; y < gridLoc.y + tileHeight; y++)
            {
               tileLoc.x = x;
               tileLoc.y = y;
               this.getTile(tileLoc).lock();
            }
         }
         this.attachedObjRefs[attachGridLoc.toString()] = objClip;
      }
      
      public function getAttachedObject(gridLoc:GPoint) : MovieClip
      {
         return this.attachedObjRefs[gridLoc.toString()];
      }
      
      public function getTile(gridLoc:GPoint) : GridTile
      {
         return this.gridNodes[gridLoc.x][gridLoc.y];
      }
      
      public function getTileCost(gridLoc:GPoint) : Number
      {
         var sX:uint = gridLoc.x * this.tileSize + this.tileSize / 2;
         var sY:uint = gridLoc.y * this.tileSize + this.tileSize / 2;
         var pixelValue:uint = this.costChartBMD.getPixel32(sX,sY);
         var alphaValue:Number = pixelValue >> 24 & 0xFF;
         if(alphaValue < MINIMUM_TILE_COST)
         {
            alphaValue = MINIMUM_TILE_COST;
         }
         return alphaValue;
      }
      
      public function getLowestTileCost() : Number
      {
         var cost:Number = NaN;
         var gridLoc:GPoint = new GPoint();
         var lowestTileCost:Number = Infinity;
         for(gridLoc.x = 0; gridLoc.x < this.gridWidth; ++gridLoc.x)
         {
            for(gridLoc.y = 0; gridLoc.y < this.gridHeight; ++gridLoc.y)
            {
               if(this.getTile(gridLoc).isBlocked())
               {
                  cost = this.getTileCost(gridLoc);
                  if(cost < lowestTileCost && cost > 0)
                  {
                     lowestTileCost = cost;
                  }
               }
            }
         }
         return lowestTileCost;
      }
      
      public function screenToGridLoc(screenLoc:GPoint, overwrite:Boolean = false) : GPoint
      {
         var gridLoc:GPoint = null;
         if(overwrite)
         {
            gridLoc = screenLoc;
         }
         else
         {
            gridLoc = screenLoc.cloneMe();
         }
         gridLoc.x = Math.floor(gridLoc.x / this.tileSize);
         gridLoc.y = Math.floor(gridLoc.y / this.tileSize);
         return gridLoc;
      }
      
      public function gridToScreenLoc(gridLoc:GPoint, overwrite:Boolean = false) : GPoint
      {
         var screenLoc:GPoint = null;
         if(overwrite)
         {
            screenLoc = gridLoc;
         }
         else
         {
            screenLoc = gridLoc.cloneMe();
         }
         screenLoc.x = gridLoc.x * this.tileSize;
         screenLoc.y = gridLoc.y * this.tileSize;
         return screenLoc;
      }
      
      public function checkPointInGrid(point:GPoint) : Boolean
      {
         return point.x >= 0 && point.x < this.gridWidth && point.y >= 0 && point.y < this.gridHeight;
      }
      
      public function checkPointSelectable(point:GPoint) : Boolean
      {
         if(!this.checkPointInGrid(point))
         {
            return false;
         }
         return point.x > 0 && point.x < this.gridWidth - 1 && point.y > 0 && point.y < this.gridHeight - 1;
      }
      
      public function checkIfCornerCut(from:GPoint, to:GPoint, compareFunct:Function = null) : Boolean
      {
         if(compareFunct == null)
         {
            compareFunct = this.checkBlocked;
         }
         var xMov:Number = to.x - from.x;
         var yMov:Number = to.y - from.y;
         if(Math.abs(xMov) + Math.abs(yMov) == 2)
         {
            this.cornerPoint.x = from.x + xMov;
            this.cornerPoint.y = from.y;
            if(compareFunct(this.cornerPoint))
            {
               return true;
            }
            this.cornerPoint.x = from.x;
            this.cornerPoint.y = from.y + yMov;
            if(compareFunct(this.cornerPoint))
            {
               return true;
            }
         }
         return false;
      }
      
      public function checkBlocked(point:GPoint) : Boolean
      {
         return this.getTile(point).isBlocked();
      }
      
      public function checkLocked(point:GPoint) : Boolean
      {
         return this.getTile(point).isBlocked() || this.getTile(point).isLocked();
      }
      
      public function validatePoint(from:GPoint, to:GPoint, checkFunct:Function = null) : Boolean
      {
         if(checkFunct == null)
         {
            checkFunct = this.checkBlocked;
         }
         if(!this.checkPointInGrid(to))
         {
            return false;
         }
         if(checkFunct(to))
         {
            return false;
         }
         if(checkFunct(from))
         {
            return false;
         }
         if(!this.checkPointSelectable(from))
         {
            return false;
         }
         if(this.checkIfCornerCut(from,to))
         {
            return false;
         }
         return true;
      }
      
      public function checkBlockAvailable(from:GPoint, blockSize:Number) : Boolean
      {
         var gridLoc:GPoint = from.cloneMe();
         for(gridLoc.x = from.x; gridLoc.x < from.x + blockSize; ++gridLoc.x)
         {
            for(gridLoc.y = from.y; gridLoc.y < from.y + blockSize; ++gridLoc.y)
            {
               if(this.getTile(gridLoc).isLocked() || this.getTile(gridLoc).isBlocked() || !this.checkPointSelectable(gridLoc))
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public function getBlockAreaPoints(from:GPoint, blockSize:Number) : Array
      {
         var pointList:Array = new Array();
         var gridLoc:GPoint = from.cloneMe();
         for(gridLoc.x = from.x; gridLoc.x < from.x + blockSize; ++gridLoc.x)
         {
            for(gridLoc.y = from.y; gridLoc.y < from.y + blockSize; ++gridLoc.y)
            {
               pointList.push(gridLoc.cloneMe());
            }
         }
         return pointList;
      }
      
      public function getLockedPoints() : Array
      {
         var lockedPoints:Array = new Array();
         var gridLoc:GPoint = new GPoint(0,0);
         for(gridLoc.x = 0; gridLoc.x < this.gridWidth; ++gridLoc.x)
         {
            for(gridLoc.y = 0; gridLoc.y < this.gridHeight; ++gridLoc.y)
            {
               if(this.getTile(gridLoc).isLocked())
               {
                  lockedPoints.push(gridLoc.cloneMe());
               }
            }
         }
         return lockedPoints;
      }
      
      public function getTileSize() : Number
      {
         return this.tileSize;
      }
      
      public function getGridWidth() : Number
      {
         return this.gridWidth;
      }
      
      public function getGridHeight() : Number
      {
         return this.gridHeight;
      }
      
      public function getBgBMD() : BitmapData
      {
         return this.bgBMD;
      }
   }
}

