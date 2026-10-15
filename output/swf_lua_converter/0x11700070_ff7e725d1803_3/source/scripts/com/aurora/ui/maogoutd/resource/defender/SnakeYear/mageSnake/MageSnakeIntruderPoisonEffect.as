package com.aurora.ui.maogoutd.resource.defender.SnakeYear.mageSnake
{
   import com.aurora.ui.maogoutd.resource.Intruder.a_4206;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class MageSnakeIntruderPoisonEffect extends a_3909
   {
      
      private static var ms_stMageSnakeIntruderPoisonEffectVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new MageSnakeIntruderPoisonEffectMovie();
      
      public var stTargetMouveIntruder:a_4206;
      
      private var m_stTiemr:Timer;
      
      public function MageSnakeIntruderPoisonEffect()
      {
         a_1271 = true;
         super();
         this.m_stTiemr = new Timer(100);
         a_1279 = -16;
         m_iYDisplayCenterPos = -20;
      }
      
      public static function a_3926() : MageSnakeIntruderPoisonEffect
      {
         var stMageSnakeIntruderPoisonEffect:MageSnakeIntruderPoisonEffect = ms_stMageSnakeIntruderPoisonEffectVector.pop();
         if(null == stMageSnakeIntruderPoisonEffect)
         {
            stMageSnakeIntruderPoisonEffect = new MageSnakeIntruderPoisonEffect();
         }
         return stMageSnakeIntruderPoisonEffect;
      }
      
      public function a_1797(isReseaved:Boolean = false) : Boolean
      {
         a_1283 = isReseaved;
         this.visible = true;
         gotoAndStop(1);
         this.m_stTiemr.addEventListener(TimerEvent.TIMER,this.a_4003);
         this.play();
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
      
      public function a_4003(a_4730:Event) : void
      {
         nextFrame();
         if(a_1273 == a_1274)
         {
            this.a_3940();
         }
      }
      
      public function a_3940() : Boolean
      {
         this.m_stTiemr.removeEventListener(TimerEvent.TIMER,this.a_4003);
         this.m_stTiemr.stop();
         this.visible = false;
         gotoAndStop(1);
         if(this.stTargetMouveIntruder != null && Boolean(this.stTargetMouveIntruder.m_stSnakePoisonEffect))
         {
            this.stTargetMouveIntruder.m_stSnakePoisonEffect = null;
            this.stTargetMouveIntruder = null;
         }
         if(-1 == ms_stMageSnakeIntruderPoisonEffectVector.indexOf(this))
         {
            ms_stMageSnakeIntruderPoisonEffectVector.push(this);
         }
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
         return true;
      }
   }
}

