package com.aurora.ui.maogoutd.resource.defender
{
   import com.aurora.ui.maogoutd.game.a_3491;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class a_4002 extends a_3976
   {
      
      private static var a_1360:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(100);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(100);
      
      private static var a_1302:MovieClip = new CoffeeWakeUpBeanDefenseMovie();
      
      private var m_stTiemr:Timer;
      
      public function a_4002()
      {
         super();
         a_1338 = -30;
         this.m_stTiemr = new Timer(100);
      }
      
      public static function a_3926() : a_4002
      {
         var stCoffeeWakeUpBeanDefense:a_4002 = a_1360.pop();
         if(null == stCoffeeWakeUpBeanDefense)
         {
            stCoffeeWakeUpBeanDefense = new a_4002();
         }
         return stCoffeeWakeUpBeanDefense;
      }
      
      override public function a_1797(stFieldGrid:a_3491) : Boolean
      {
         this.m_stTiemr.addEventListener(TimerEvent.TIMER,this.a_4003);
         this.visible = true;
         gotoAndStop(1);
         this.play();
         return super.a_1797(stFieldGrid);
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
      
      override public function a_3940() : Boolean
      {
         this.m_stTiemr.removeEventListener(TimerEvent.TIMER,this.a_4003);
         this.m_stTiemr.stop();
         a_1360.push(this);
         return super.a_3940();
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
            if(a_1334.m_stProtector)
            {
               a_1334.m_stProtector.a_3970();
            }
            else if(a_1334.m_stAttackFighter)
            {
               a_1334.m_stAttackFighter.a_3970();
            }
            else if(a_1334.m_stBaseAuxiliaryFighter)
            {
               a_1334.m_stBaseAuxiliaryFighter.a_3970();
            }
            else if(a_1334.m_stFlowerDefense)
            {
               a_1334.m_stFlowerDefense.a_3970();
            }
            else if(a_1334.m_stBoomDefense)
            {
               a_1334.m_stBoomDefense.a_3970();
            }
            if(a_1334.m_stCurrentBattbleFieldView.contains(this))
            {
               a_1334.m_stCurrentBattbleFieldView.removeChild(this);
            }
            this.a_3940();
            return;
         }
      }
   }
}

