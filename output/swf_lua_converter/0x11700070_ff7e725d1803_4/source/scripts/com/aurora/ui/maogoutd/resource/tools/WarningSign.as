package com.aurora.ui.maogoutd.resource.tools
{
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class WarningSign extends a_3909
   {
      
      private static var ms_stWarningSignVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(100);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(100);
      
      private static var a_1302:MovieClip = new WarningSignMovie();
      
      private static const END_TICK:int = 8;
      
      private var a_1109:Timer;
      
      private var m_iContinueTick:int;
      
      public function WarningSign()
      {
         super();
         this.a_1109 = new Timer(100);
         this.a_1109.addEventListener(TimerEvent.TIMER,this.a_4109);
      }
      
      public static function a_3926() : WarningSign
      {
         var stWarningSign:WarningSign = ms_stWarningSignVector.pop();
         if(null == stWarningSign)
         {
            stWarningSign = new WarningSign();
         }
         return stWarningSign;
      }
      
      public function a_3940() : Boolean
      {
         this.stop();
         if(null != this.parent)
         {
            this.parent.removeChild(this);
         }
         if(-1 == ms_stWarningSignVector.indexOf(this))
         {
            ms_stWarningSignVector.push(this);
         }
         return true;
      }
      
      override protected function a_3911() : Vector.<BitmapData>
      {
         return a_1300;
      }
      
      override protected function a_3912() : Vector.<Point>
      {
         return a_1301;
      }
      
      override protected function a_3913() : MovieClip
      {
         return a_1302;
      }
      
      public function a_1797(isReversed:Boolean, iContinueTick:int = -1, iDelay:int = 100) : Boolean
      {
         this.stop();
         a_1283 = isReversed;
         this.m_iContinueTick = iContinueTick;
         if(this.m_iContinueTick < a_1274)
         {
            this.m_iContinueTick = a_1274 - 1;
         }
         this.a_1109.delay = iDelay;
         visible = true;
         gotoAndStop(1);
         this.play();
         return true;
      }
      
      public function play() : void
      {
         this.a_1109.start();
      }
      
      public function stop() : void
      {
         this.a_1109.stop();
      }
      
      protected function a_4109(a_4730:Event) : void
      {
         nextFrame();
         --this.m_iContinueTick;
         if(this.m_iContinueTick > END_TICK && null != a_1278)
         {
            gotoAndStop(1);
         }
         else if(a_1273 == a_1274)
         {
            this.a_3940();
         }
      }
   }
}

