package com.aurora.ui.maogoutd.resource.defender.DragonYear.GoldEros
{
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class MouseMoveIntruderBatDieEffect extends a_3909
   {
      
      private static var ms_stMouseMoveIntruderBatDieEffectVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(1000);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(1000);
      
      private static var a_1302:MovieClip = new MouseMoveIntruderBatDieEffectMovie();
      
      private var m_stTiemr:Timer;
      
      public function MouseMoveIntruderBatDieEffect()
      {
         super();
         this.m_stTiemr = new Timer(100);
         a_1279 = -18;
         m_iYDisplayCenterPos = -8;
      }
      
      public static function a_3926() : MouseMoveIntruderBatDieEffect
      {
         var stMouseMoveIntruderBatDieEffect:MouseMoveIntruderBatDieEffect = ms_stMouseMoveIntruderBatDieEffectVector.pop();
         if(null == stMouseMoveIntruderBatDieEffect)
         {
            stMouseMoveIntruderBatDieEffect = new MouseMoveIntruderBatDieEffect();
         }
         return stMouseMoveIntruderBatDieEffect;
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
         if(-1 == ms_stMouseMoveIntruderBatDieEffectVector.indexOf(this))
         {
            ms_stMouseMoveIntruderBatDieEffectVector.push(this);
         }
         if(Boolean(parent) && parent.contains(this))
         {
            parent.removeChild(this);
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

