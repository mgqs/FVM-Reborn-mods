package com.aurora.ui.maogoutd.resource
{
   import a_4715.EncrypBooleanEx;
   import a_4715.EncrypIntEx;
   import a_4715.EncrypNumber;
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
      
      protected static var a_1261:ColorTransform = new ColorTransform(0.1,0.8,1.3,1,-30,-30,-30,0);
      
      protected static var a_1262:ColorTransform = new ColorTransform(1,1,1,1,50,50,50,0);
      
      protected static var a_1263:ColorTransform = new ColorTransform();
      
      private var a_1260:Sprite = new Sprite();
      
      private var a_1264:MovieClip;
      
      private var a_1265:Vector.<BitmapData>;
      
      private var a_1266:Vector.<Point>;
      
      private var a_1267:Bitmap;
      
      private var a_1268:Point = new Point(0,0);
      
      private var a_1269:BitmapData;
      
      private var a_1270:BitmapData;
      
      private var m_isRenderLiveEx:EncrypBooleanEx;
      
      protected var a_1271:Boolean = false;
      
      private var m_numSkewingDiffNumEx:EncrypNumber;
      
      private var m_iCurrentFrameEx:EncrypIntEx;
      
      protected var m_iTotalFramesEncrypIntEx:EncrypIntEx;
      
      private var m_iFrameLabelIndexEx:EncrypIntEx;
      
      protected var a_1276:Array;
      
      protected var a_1277:Array;
      
      private var m_szCurrentLableEx:String;
      
      private var m_iXDisplayCenterPosEx:EncrypIntEx;
      
      private var m_iYDisplayCenterPosEx:EncrypIntEx;
      
      private var m_isCutTheAroundBlankLineEx:EncrypBooleanEx;
      
      private var m_isCutTheBlankAreaEx:EncrypBooleanEx;
      
      private var m_isShowShadowEx:EncrypBooleanEx;
      
      private var m_isReversedEx:EncrypBooleanEx;
      
      private var m_iShotedLightFrameNumEx:EncrypIntEx;
      
      private var m_iColdSlowFrameNumEx:EncrypIntEx;
      
      private var m_iImmuneFrameNumEx:EncrypIntEx;
      
      private var m_iCharmlevelEx:EncrypIntEx;
      
      private var m_iFireHurtFrameNumEx:EncrypIntEx;
      
      public function a_3909()
      {
         super();
         this.a_3910();
      }
      
      protected function get a_1272() : Number
      {
         if(!this.m_numSkewingDiffNumEx)
         {
            this.m_numSkewingDiffNumEx = new EncrypNumber(0);
         }
         return this.m_numSkewingDiffNumEx.Value;
      }
      
      protected function set a_1272(value:Number) : void
      {
         if(!this.m_numSkewingDiffNumEx)
         {
            this.m_numSkewingDiffNumEx = new EncrypNumber(0);
         }
         this.m_numSkewingDiffNumEx.Value = value;
      }
      
      protected function get a_1273() : int
      {
         if(!this.m_iCurrentFrameEx)
         {
            this.m_iCurrentFrameEx = new EncrypIntEx(0);
         }
         return this.m_iCurrentFrameEx.Value;
      }
      
      protected function set a_1273(value:int) : void
      {
         if(!this.m_iCurrentFrameEx)
         {
            this.m_iCurrentFrameEx = new EncrypIntEx(0);
         }
         this.m_iCurrentFrameEx.Value = value;
      }
      
      protected function set a_1274(value:int) : void
      {
         if(!this.m_iTotalFramesEncrypIntEx)
         {
            this.m_iTotalFramesEncrypIntEx = new EncrypIntEx(0);
         }
         if(this.m_iTotalFramesEncrypIntEx.Value != 0 && value == 1)
         {
            value = int(this.a_1265.length);
         }
         this.m_iTotalFramesEncrypIntEx.Value = value;
      }
      
      protected function get a_1274() : int
      {
         if(!this.m_iTotalFramesEncrypIntEx)
         {
            this.m_iTotalFramesEncrypIntEx = new EncrypIntEx(0);
         }
         if(Boolean(this.a_1264) && this.a_1264.totalFrames != this.m_iTotalFramesEncrypIntEx.Value)
         {
            return int.MAX_VALUE;
         }
         return this.m_iTotalFramesEncrypIntEx.Value;
      }
      
      protected function get a_1275() : int
      {
         if(!this.m_iFrameLabelIndexEx)
         {
            this.m_iFrameLabelIndexEx = new EncrypIntEx();
         }
         return this.m_iFrameLabelIndexEx.Value;
      }
      
      protected function set a_1275(value:int) : void
      {
         if(!this.m_iFrameLabelIndexEx)
         {
            this.m_iFrameLabelIndexEx = new EncrypIntEx();
         }
         this.m_iFrameLabelIndexEx.Value = value;
      }
      
      protected function get a_1278() : String
      {
         return this.m_szCurrentLableEx;
      }
      
      protected function set a_1278(value:String) : void
      {
         this.m_szCurrentLableEx = value;
      }
      
      protected function get a_1279() : int
      {
         if(!this.m_iXDisplayCenterPosEx)
         {
            this.m_iXDisplayCenterPosEx = new EncrypIntEx(0);
         }
         return this.m_iXDisplayCenterPosEx.Value;
      }
      
      protected function set a_1279(value:int) : void
      {
         if(!this.m_iXDisplayCenterPosEx)
         {
            this.m_iXDisplayCenterPosEx = new EncrypIntEx(0);
         }
         this.m_iXDisplayCenterPosEx.Value = value;
      }
      
      protected function get m_iYDisplayCenterPos() : int
      {
         if(!this.m_iYDisplayCenterPosEx)
         {
            this.m_iYDisplayCenterPosEx = new EncrypIntEx(0);
         }
         return this.m_iYDisplayCenterPosEx.Value;
      }
      
      protected function set m_iYDisplayCenterPos(value:int) : void
      {
         if(!this.m_iYDisplayCenterPosEx)
         {
            this.m_iYDisplayCenterPosEx = new EncrypIntEx(0);
         }
         this.m_iYDisplayCenterPosEx.Value = value;
      }
      
      protected function get a_1280() : Boolean
      {
         if(!this.m_isCutTheAroundBlankLineEx)
         {
            this.m_isCutTheAroundBlankLineEx = new EncrypBooleanEx(false);
         }
         return this.m_isCutTheAroundBlankLineEx.Value;
      }
      
      protected function set a_1280(value:Boolean) : void
      {
         if(!this.m_isCutTheAroundBlankLineEx)
         {
            this.m_isCutTheAroundBlankLineEx = new EncrypBooleanEx(false);
         }
         this.m_isCutTheAroundBlankLineEx.Value = value;
      }
      
      protected function get a_1281() : Boolean
      {
         if(!this.m_isCutTheBlankAreaEx)
         {
            this.m_isCutTheBlankAreaEx = new EncrypBooleanEx(false);
         }
         return this.m_isCutTheBlankAreaEx.Value;
      }
      
      protected function set a_1281(value:Boolean) : void
      {
         if(!this.m_isCutTheBlankAreaEx)
         {
            this.m_isCutTheBlankAreaEx = new EncrypBooleanEx(false);
         }
         this.m_isCutTheBlankAreaEx.Value = value;
      }
      
      protected function get a_1282() : Boolean
      {
         if(!this.m_isShowShadowEx)
         {
            this.m_isShowShadowEx = new EncrypBooleanEx(false);
         }
         return this.m_isShowShadowEx.Value;
      }
      
      protected function set a_1282(value:Boolean) : void
      {
         if(!this.m_isShowShadowEx)
         {
            this.m_isShowShadowEx = new EncrypBooleanEx(false);
         }
         this.m_isShowShadowEx.Value = value;
      }
      
      protected function get a_1283() : Boolean
      {
         if(!this.m_isReversedEx)
         {
            this.m_isReversedEx = new EncrypBooleanEx(false);
         }
         return this.m_isReversedEx.Value;
      }
      
      protected function set a_1283(value:Boolean) : void
      {
         if(!this.m_isReversedEx)
         {
            this.m_isReversedEx = new EncrypBooleanEx(false);
         }
         this.m_isReversedEx.Value = value;
      }
      
      protected function get a_1284() : int
      {
         if(!this.m_iShotedLightFrameNumEx)
         {
            this.m_iShotedLightFrameNumEx = new EncrypIntEx(0);
         }
         return this.m_iShotedLightFrameNumEx.Value;
      }
      
      protected function set a_1284(value:int) : void
      {
         if(!this.m_iShotedLightFrameNumEx)
         {
            this.m_iShotedLightFrameNumEx = new EncrypIntEx(0);
         }
         this.m_iShotedLightFrameNumEx.Value = value;
      }
      
      protected function get a_1285() : int
      {
         if(!this.m_iColdSlowFrameNumEx)
         {
            this.m_iColdSlowFrameNumEx = new EncrypIntEx(0);
         }
         return this.m_iColdSlowFrameNumEx.Value;
      }
      
      protected function set a_1285(value:int) : void
      {
         if(!this.m_iColdSlowFrameNumEx)
         {
            this.m_iColdSlowFrameNumEx = new EncrypIntEx(0);
         }
         this.m_iColdSlowFrameNumEx.Value = value;
      }
      
      protected function get m_iImmuneFrameNum() : int
      {
         if(!this.m_iImmuneFrameNumEx)
         {
            this.m_iImmuneFrameNumEx = new EncrypIntEx(0);
         }
         return this.m_iImmuneFrameNumEx.Value;
      }
      
      protected function set m_iImmuneFrameNum(value:int) : void
      {
         if(!this.m_iImmuneFrameNumEx)
         {
            this.m_iImmuneFrameNumEx = new EncrypIntEx(0);
         }
         this.m_iImmuneFrameNumEx.Value = value;
      }
      
      protected function get m_iCharmlevel() : int
      {
         if(!this.m_iCharmlevelEx)
         {
            this.m_iCharmlevelEx = new EncrypIntEx(0);
         }
         return this.m_iCharmlevelEx.Value;
      }
      
      protected function set m_iCharmlevel(value:int) : void
      {
         if(!this.m_iCharmlevelEx)
         {
            this.m_iCharmlevelEx = new EncrypIntEx(0);
         }
         this.m_iCharmlevelEx.Value = value;
      }
      
      protected function get m_iFireHurtFrameNum() : int
      {
         if(!this.m_iFireHurtFrameNumEx)
         {
            this.m_iFireHurtFrameNumEx = new EncrypIntEx(0);
         }
         return this.m_iFireHurtFrameNumEx.Value;
      }
      
      protected function set m_iFireHurtFrameNum(value:int) : void
      {
         if(!this.m_iFireHurtFrameNumEx)
         {
            this.m_iFireHurtFrameNumEx = new EncrypIntEx(0);
         }
         this.m_iFireHurtFrameNumEx.Value = value;
      }
      
      public function get iCurrentFrame() : int
      {
         return this.a_1273;
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
      
      public function get stOriginalMovieClip() : MovieClip
      {
         return this.a_1264;
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
         this.a_1267.y = this.m_iYDisplayCenterPos;
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
         this; //unpopped
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
      
      public function a_3916() : Boolean
      {
         var iFrameCacheLen:int = int(this.a_1265.length);
         for(var i:int = 0; i < iFrameCacheLen; i++)
         {
            if(null != this.a_1265[i])
            {
               this.a_1265[i].dispose();
               this.a_1265[i] = null;
            }
         }
         return true;
      }
      
      public function IsReversed() : Boolean
      {
         return this.a_1283;
      }
      
      protected function a_3419() : void
      {
         if(this.a_1266[this.a_1273])
         {
            if(this.a_1283 || this.m_iCharmlevel > 0)
            {
               this.a_1267.x = -this.a_1279 - this.a_1266[this.a_1273].x;
            }
            else
            {
               this.a_1267.x = this.a_1279 + this.a_1266[this.a_1273].x;
            }
            this.a_1267.y = this.m_iYDisplayCenterPos + this.a_1266[this.a_1273].y;
            this.a_1268 = this.a_1266[this.a_1273];
         }
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
         if(null == this.a_1265[this.a_1273])
         {
            if(!this.a_1260.contains(this.a_1264))
            {
               this.a_1260.addChild(this.a_1264);
            }
            this.a_1264.gotoAndStop(this.a_1273);
            if(0 == this.a_1264.width || 0 == this.a_1264.height)
            {
               return;
            }
            this.a_1264.x = 0;
            this.a_1264.y = 0;
            numWidthSkewing = this.a_1264.width - int(this.a_1264.width);
            numHeightSkewing = this.a_1264.height - int(this.a_1264.height);
            stBoundes = this.a_1260.getBounds(this.a_1264);
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
            if(this.a_1281)
            {
               stValidRect = stBitmapData.getColorBoundsRect(4294967295,0,false);
               stValidRect.height += stValidRect.y;
               stValidRect.y = 0;
               stValidRect.width = stBitmapData.width;
               stValidRect.x = 0;
               if(0 == stValidRect.width || 0 == stValidRect.height || stValidRect.equals(stBitmapData.rect))
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
         this.a_1267.bitmapData = this.a_1265[this.a_1273];
         if(this.a_1285 > 0)
         {
            this.a_1267.transform.colorTransform = a_1261;
            --this.a_1285;
            if(this.a_1284 > 0)
            {
               --this.a_1284;
            }
         }
         else if(this.a_1284 > 0)
         {
            this.a_1267.transform.colorTransform = a_1262;
            --this.a_1284;
         }
         else
         {
            this.a_1267.transform.colorTransform = a_1263;
         }
         if(this.a_1283 || this.m_iCharmlevel > 0)
         {
            this.a_1267.scaleX = -1;
         }
         else
         {
            this.a_1267.scaleX = 1;
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
            return;
         }
         this.a_1264.x = 0;
         this.a_1264.y = 0;
         var numWidthSkewing:Number = this.a_1264.width - int(this.a_1264.width);
         var numHeightSkewing:Number = this.a_1264.height - int(this.a_1264.height);
         this.a_1260.addChild(this.a_1264);
         stBoundes = this.a_1260.getBounds(this.a_1264);
         this.a_1269.fillRect(this.a_1269.rect,0);
         this.a_1269.draw(this.a_1264,new Matrix(1,0,0,1,int(-stBoundes.x),int(-stBoundes.y)));
         this.a_1260.removeChild(this.a_1264);
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
         if(this.a_1283 || this.m_iCharmlevel > 0)
         {
            this.a_1267.scaleX = -1;
         }
         else
         {
            this.a_1267.scaleX = 1;
         }
         if(this.a_1285 > 0)
         {
            this.a_1267.transform.colorTransform = a_1261;
            --this.a_1285;
            if(this.a_1284 > 0)
            {
               --this.a_1284;
            }
         }
         else if(this.a_1284 > 0)
         {
            this.a_1267.transform.colorTransform = a_1262;
            --this.a_1284;
         }
         else if(this.a_1267.transform.colorTransform !== a_1263)
         {
            this.a_1267.transform.colorTransform = a_1263;
         }
         this.a_3419();
      }
      
      private function SetColorTransformIfChanged(target:Bitmap, newTransform:ColorTransform) : void
      {
         if(!target || !target.transform)
         {
            return;
         }
         var cur:ColorTransform = target.transform.colorTransform;
         if(cur.alphaMultiplier != newTransform.alphaMultiplier || cur.redMultiplier != newTransform.redMultiplier || cur.greenMultiplier != newTransform.greenMultiplier || cur.blueMultiplier != newTransform.blueMultiplier || cur.alphaOffset != newTransform.alphaOffset || cur.redOffset != newTransform.redOffset || cur.greenOffset != newTransform.greenOffset || cur.blueOffset != newTransform.blueOffset)
         {
            target.transform.colorTransform = newTransform;
         }
      }
      
      private function SetScaleXIfChanged(target:Bitmap, newScaleX:Number) : void
      {
         if(Boolean(target) && target.scaleX !== newScaleX)
         {
            target.scaleX = newScaleX;
         }
      }
   }
}

