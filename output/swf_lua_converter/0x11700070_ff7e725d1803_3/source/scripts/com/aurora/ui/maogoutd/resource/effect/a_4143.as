package com.aurora.ui.maogoutd.resource.effect
{
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class a_4143 extends a_3909
   {
      
      private static var a_1427:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(1000);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(1000);
      
      private static var a_1302:MovieClip = new SmallMouseMoveIntruderBoomDieMovie();
      
      private var m_stTiemr:Timer;
      
      public function a_4143()
      {
         super();
         this.m_stTiemr = new Timer(100);
      }
      
      public static function a_3926() : a_4143
      {
         var stSmallMouseMoveIntruderBoomDie:a_4143 = a_1427.pop();
         if(null == stSmallMouseMoveIntruderBoomDie)
         {
            stSmallMouseMoveIntruderBoomDie = new a_4143();
         }
         return stSmallMouseMoveIntruderBoomDie;
      }
      
      public function a_1797(isReversed:Boolean) : Boolean
      {
         a_1283 = isReversed;
         a_1272 = 0;
         this.m_stTiemr.addEventListener(TimerEvent.TIMER,this.a_4003);
         this.visible = true;
         gotoAndStop(1);
         this.play();
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
      
      protected function a_3940() : Boolean
      {
         this.visible = false;
         gotoAndStop(1);
         this.m_stTiemr.removeEventListener(TimerEvent.TIMER,this.a_4003);
         this.m_stTiemr.stop();
         if(-1 == a_1427.indexOf(this))
         {
            a_1427.push(this);
         }
         return true;
      }
      
      public function play() : void
      {
         this.m_stTiemr.start();
      }
      
      public function stop() : void
      {
         this.m_stTiemr.stop();
      }
      
      private function a_4003(a_4730:Event) : void
      {
         nextFrame();
         if(a_1273 == a_1274)
         {
            this.a_3940();
            return;
         }
      }
   }
}

