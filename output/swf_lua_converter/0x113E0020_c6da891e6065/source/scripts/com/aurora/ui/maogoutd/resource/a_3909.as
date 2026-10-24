package com.aurora.ui.maogoutd.resource
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Timer;
   
   public class a_3909 extends Sprite
   {
      
      private static var a_1260:Sprite = new Sprite();
      
      private var a_1264:MovieClip;
      
      private var a_1265:Vector.<BitmapData>;
      
      private var a_1266:Vector.<Point>;
      
      private var a_1267:Bitmap;
      
      private var a_1268:Point = new Point(0,0);
      
      private var a_1269:BitmapData;
      
      private var a_1270:BitmapData;
      
      protected var a_1271:Boolean = false;
      
      protected var a_1272:Number = 0;
      
      protected var a_1273:int = 0;
      
      protected var a_1274:int;
      
      protected var a_1275:int;
      
      protected var a_1276:Array;
      
      protected var a_1277:Array;
      
      protected var a_1278:String;
      
      protected var a_1279:int = 0;
      
      protected var a_1280:Boolean = false;
      
      protected var a_1281:Boolean = false;
      
      protected var a_1282:Boolean = false;
      
      protected var a_1283:Boolean = false;
      
      protected var a_1284:int = 0;
      
      protected var a_1285:int = 0;
      
      protected var a_1468:int = 0;
      
      public function a_3909()
      {
         super();
         this.a_3910();
      }
      
      override public function get width() : Number
      {
         if(this.a_1271 && Boolean(this.a_1269))
         {
            return this.a_1269.getColorBoundsRect(4294967295,0,false).width;
         }
         return super.width;
      }
      
      override public function get height() : Number
      {
         if(this.a_1271 && Boolean(this.a_1269))
         {
            return this.a_1269.getColorBoundsRect(4294967295,0,false).height;
         }
         return super.height;
      }
      
      public function get iTotalFrames() : int
      {
         return this.a_1274;
      }
      
      public function get stDisplayBitmap() : Bitmap
      {
         return this.a_1267;
      }
      
      protected function a_3910() : Boolean
      {
         var frameLabel:FrameLabel = null;
         var iMaxRendWidth:int = 0;
         var iMaxRendHeight:int = 0;
         var i:int = 0;
         this.a_1265 = this.a_3911();
         if(null == this.a_1265)
         {
            trace("null == m_arrFrameCache");
            return false;
         }
         this.a_1266 = this.a_3912();
         if(null == this.a_1266)
         {
            trace("null == m_arrFrameCacheSkewing");
            return false;
         }
         this.a_1264 = this.a_3913();
         if(null == this.a_1264)
         {
            trace("null == m_arrFrameCache");
            return false;
         }
         if(null == this.a_1267)
         {
            this.a_1267 = new Bitmap();
         }
         this.a_1267.x = this.a_1279;
         this.a_1267.y = 0;
         addChild(this.a_1267);
         this.a_1274 = this.a_1264.totalFrames;
         this.a_1276 = this.a_1264.currentLabels;
         this.a_1277 = new Array();
         for each(frameLabel in this.a_1276)
         {
            this.a_1277[frameLabel.frame] = frameLabel.name;
         }
         if(this.a_1271)
         {
            iMaxRendWidth = 1;
            iMaxRendHeight = 1;
            for(i = 1; i <= this.a_1274; i++)
            {
               this.a_1264.gotoAndStop(i);
               if(this.a_1264.width > iMaxRendWidth)
               {
                  iMaxRendWidth = this.a_1264.width + 1;
               }
               if(this.a_1264.height > iMaxRendHeight)
               {
                  iMaxRendHeight = this.a_1264.height + 1;
               }
            }
            this.a_1269 = new BitmapData(iMaxRendWidth,iMaxRendHeight,true,0);
            this.a_1270 = this.a_1269.clone();
            this.a_1267.bitmapData = this.a_1269;
         }
         return true;
      }
      
      protected function a_3911() : Vector.<BitmapData>
      {
         return null;
      }
      
      protected function a_3912() : Vector.<Point>
      {
         return null;
      }
      
      protected function a_3913() : MovieClip
      {
         return null;
      }
      
      protected function a_3914() : Sprite
      {
         return null;
      }
      
      public function a_3915(stTimer:Timer) : void
      {
         stTimer.addEventListener(TimerEvent.TIMER,this.playForward);
      }
      
      private function playForward(a_4730:Event = null) : void
      {
         this.nextFrame();
      }
      
      public function nextFrame() : void
      {
         ++this.a_1273;
         if(this.a_1273 > this.a_1274)
         {
            this.a_1273 = this.a_1274;
         }
         if(this.a_1271)
         {
            this.a_3918();
         }
         else
         {
            this.a_3917();
         }
      }
      
      public function gotoAndStop(frame:Object, scene:String = null) : void
      {
         this.a_1273 = frame as int;
         if(this.a_1271)
         {
            this.a_3918();
         }
         else
         {
            this.a_3917();
         }
      }
      
      protected function a_3419() : void
      {
         if(this.a_1283)
         {
            this.a_1267.x = -this.a_1279 - this.a_1266[this.a_1273].x - this.a_1267.width;
         }
         else
         {
            this.a_1267.x = this.a_1279 + this.a_1266[this.a_1273].x;
         }
         this.a_1267.y = this.a_1266[this.a_1273].y;
         this.a_1268 = this.a_1266[this.a_1273];
      }
      
      private function a_3917() : void
      {
         var iCacheIndex:int = 0;
         var stOriginBitmapData:BitmapData = null;
         var stRect:Rectangle = null;
         var stBoundes:Rectangle = null;
         var stBitmapData:BitmapData = null;
         var numWidthSkewing:Number = NaN;
         var numHeightSkewing:Number = NaN;
         var iDrawBitmapDataWidth:int = 0;
         var iDrawBitmapDataHeight:int = 0;
         var iDrawXSheft:int = 0;
         var iDrawYSheft:int = 0;
         var stValidBitmapData:BitmapData = null;
         var stValidRect:Rectangle = null;
         var stCopyBitmapData:BitmapData = null;
         var stReverseBitmapData:BitmapData = null;
         var iYPos:int = 0;
         var iXPos:int = 0;
         var stColdBitmapData:BitmapData = null;
         var stShotHighLightBitmapData:BitmapData = null;
         if(null == this.a_1265[this.a_1273])
         {
            this.a_1264.gotoAndStop(this.a_1273);
            if(0 == this.a_1264.width || 0 == this.a_1264.height)
            {
               trace("ERROR: 0 == m_stOriginalMovieClip.width || 0 == m_stOriginalMovieClip.height");
               return;
            }
            this.a_1264.x = 0;
            this.a_1264.y = 0;
            numWidthSkewing = this.a_1264.width - int(this.a_1264.width);
            numHeightSkewing = this.a_1264.height - int(this.a_1264.height);
            a_1260.addChild(this.a_1264);
            stBoundes = a_1260.getBounds(this.a_1264);
            iDrawBitmapDataWidth = this.a_1264.width + (numWidthSkewing > 0 ? 1 : 0);
            iDrawBitmapDataHeight = this.a_1264.height + (numHeightSkewing > 0 ? 1 : 0);
            iDrawXSheft = int(-stBoundes.x);
            iDrawYSheft = int(-stBoundes.y);
            if(this.a_1280)
            {
               iDrawBitmapDataWidth -= 3;
               iDrawBitmapDataHeight -= 3;
               iDrawXSheft -= 2;
               iDrawYSheft -= 2;
            }
            stBitmapData = new BitmapData(iDrawBitmapDataWidth,iDrawBitmapDataHeight,true,0);
            stBitmapData.draw(this.a_1264,new Matrix(1,0,0,1,iDrawXSheft,iDrawYSheft));
            a_1260.removeChild(this.a_1264);
            if(this.a_1281)
            {
               stValidRect = stBitmapData.getColorBoundsRect(4294967295,0,false);
               stValidRect.height += stValidRect.y;
               stValidRect.y = 0;
               stValidRect.width = stBitmapData.width;
               stValidRect.x = 0;
               if(stValidRect.equals(stBitmapData.rect))
               {
                  stValidBitmapData = stBitmapData;
               }
               else
               {
                  stValidBitmapData = new BitmapData(stValidRect.width,stValidRect.height,true,0);
                  stValidBitmapData.copyPixels(stBitmapData,stValidRect,new Point(0,0));
                  stBitmapData.dispose();
               }
               this.a_1265[this.a_1273] = stValidBitmapData;
            }
            else
            {
               this.a_1265[this.a_1273] = stBitmapData;
            }
            if(1 == this.a_1273 && null == this.a_1266[0])
            {
               this.a_1266[0] = new Point(int(stBoundes.x),int(stBoundes.y));
            }
            this.a_1266[this.a_1273] = new Point(int(stBoundes.x) - this.a_1266[0].x,int(stBoundes.y) - this.a_1266[0].y);
         }
         this.a_1278 = this.a_1277[this.a_1273];
         if(this.a_1283)
         {
            if(null == this.a_1265[this.a_1274 + this.a_1273])
            {
               stCopyBitmapData = this.a_1265[this.a_1273];
               stReverseBitmapData = new BitmapData(stCopyBitmapData.width,stCopyBitmapData.height,true,0);
               for(iYPos = 0; iYPos < stCopyBitmapData.height; iYPos++)
               {
                  for(iXPos = 0; iXPos < stCopyBitmapData.width; iXPos++)
                  {
                     stReverseBitmapData.setPixel32(stCopyBitmapData.width - iXPos - 1,iYPos,stCopyBitmapData.getPixel32(iXPos,iYPos));
                  }
               }
               this.a_1265[this.a_1274 + this.a_1273] = stReverseBitmapData;
            }
            this.a_1267.bitmapData = this.a_1265[this.a_1274 + this.a_1273];
         }
         else
         {
            this.a_1267.bitmapData = this.a_1265[this.a_1273];
         }
         if(this.a_1285 > 0)
         {
            iCacheIndex = this.a_1274 * 4 + this.a_1273;
            if(this.a_1283)
            {
               iCacheIndex = this.a_1274 * 5 + this.a_1273;
            }
            if(null == this.a_1265[iCacheIndex])
            {
               stOriginBitmapData = this.a_1267.bitmapData;
               stColdBitmapData = stOriginBitmapData.clone();
               stRect = new Rectangle(0,0,stColdBitmapData.width,stColdBitmapData.height);
               stColdBitmapData.colorTransform(stRect,new ColorTransform(0.1,0.8,1.3,1,-30,-30,-30,0));
               this.a_1265[iCacheIndex] = stColdBitmapData;
            }
            this.a_1267.bitmapData = this.a_1265[iCacheIndex];
            --this.a_1285;
            if(this.a_1284 > 0)
            {
               --this.a_1284;
            }
         }
         else if(this.a_1284 > 0)
         {
            iCacheIndex = this.a_1274 * 2 + this.a_1273;
            if(this.a_1283)
            {
               iCacheIndex = this.a_1274 * 3 + this.a_1273;
            }
            if(null == this.a_1265[iCacheIndex])
            {
               stOriginBitmapData = this.a_1267.bitmapData;
               stShotHighLightBitmapData = stOriginBitmapData.clone();
               stRect = new Rectangle(0,0,stShotHighLightBitmapData.width,stShotHighLightBitmapData.height);
               stShotHighLightBitmapData.colorTransform(stRect,new ColorTransform(1,1,1,1,50,50,50,0));
               this.a_1265[iCacheIndex] = stShotHighLightBitmapData;
            }
            this.a_1267.bitmapData = this.a_1265[iCacheIndex];
            --this.a_1284;
         }
         this.a_3419();
      }
      
      private function a_3918() : void
      {
         var stBoundes:Rectangle = null;
         var stRect:Rectangle = null;
         var iMaxRendWidth:int = 0;
         var iMaxRendHeight:int = 0;
         var i:int = 0;
         var stValidBitmapData:BitmapData = null;
         var stValidRect:Rectangle = null;
         var iYPos:int = 0;
         var iXPos:int = 0;
         if(this.a_1271 && null == this.a_1269 && null == this.a_1270)
         {
            iMaxRendWidth = 1;
            iMaxRendHeight = 1;
            for(i = 1; i <= this.a_1274; i++)
            {
               this.a_1264.gotoAndStop(i);
               if(this.a_1264.width > iMaxRendWidth)
               {
                  iMaxRendWidth = this.a_1264.width + 1;
               }
               if(this.a_1264.height > iMaxRendHeight)
               {
                  iMaxRendHeight = this.a_1264.height + 1;
               }
            }
            this.a_1269 = new BitmapData(iMaxRendWidth,iMaxRendHeight,true,0);
            this.a_1270 = this.a_1269.clone();
            this.a_1267.bitmapData = this.a_1269;
         }
         this.a_1264.gotoAndStop(this.a_1273);
         if(0 == this.a_1264.width || 0 == this.a_1264.height)
         {
            trace("ERROR: 0 == m_stOriginalMovieClip.width || 0 == m_stOriginalMovieClip.height");
            return;
         }
         this.a_1264.x = 0;
         this.a_1264.y = 0;
         var numWidthSkewing:Number = this.a_1264.width - int(this.a_1264.width);
         var numHeightSkewing:Number = this.a_1264.height - int(this.a_1264.height);
         a_1260.addChild(this.a_1264);
         stBoundes = a_1260.getBounds(this.a_1264);
         this.a_1269.fillRect(this.a_1269.rect,0);
         this.a_1269.draw(this.a_1264,new Matrix(1,0,0,1,int(-stBoundes.x),int(-stBoundes.y)));
         a_1260.removeChild(this.a_1264);
         if(this.a_1281)
         {
            stValidRect = this.a_1269.getColorBoundsRect(4294967295,0,false);
            stValidRect.height += stValidRect.y;
            stValidRect.y = 0;
            stValidRect.width = this.a_1269.width;
            stValidRect.x = 0;
            if(!stValidRect.equals(this.a_1269.rect))
            {
               this.a_1270.copyPixels(this.a_1269,stValidRect,new Point(0,0));
               this.a_1269.fillRect(this.a_1269.rect,0);
               this.a_1269.copyPixels(this.a_1270,stValidRect,new Point(0,0));
            }
         }
         if(1 == this.a_1273 && null == this.a_1266[0])
         {
            this.a_1266[0] = new Point(int(stBoundes.x),int(stBoundes.y));
         }
         this.a_1266[this.a_1273] = new Point(int(stBoundes.x) - this.a_1266[0].x,int(stBoundes.y) - this.a_1266[0].y);
         this.a_1278 = this.a_1277[this.a_1273];
         if(this.a_1283)
         {
            this.a_1270.copyPixels(this.a_1269,this.a_1269.rect,new Point(0,0));
            for(iYPos = 0; iYPos < this.a_1270.height; iYPos++)
            {
               for(iXPos = 0; iXPos < this.a_1270.width; iXPos++)
               {
                  this.a_1269.setPixel32(this.a_1270.width - iXPos - 1,iYPos,this.a_1270.getPixel32(iXPos,iYPos));
               }
            }
         }
         if(this.a_1285 > 0)
         {
            stRect = new Rectangle(0,0,this.a_1269.width,this.a_1269.height);
            this.a_1269.colorTransform(stRect,new ColorTransform(0.1,0.8,1.3,1,-30,-30,-30,0));
            --this.a_1285;
            if(this.a_1284 > 0)
            {
               --this.a_1284;
            }
         }
         else if(this.a_1284 > 0)
         {
            stRect = new Rectangle(0,0,this.a_1269.width,this.a_1269.height);
            this.a_1269.colorTransform(stRect,new ColorTransform(1,1,1,1,25,25,25,0));
            --this.a_1284;
         }
         this.a_3419();
      }
   }
}

