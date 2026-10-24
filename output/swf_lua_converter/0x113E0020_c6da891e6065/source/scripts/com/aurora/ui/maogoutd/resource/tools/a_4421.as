package com.aurora.ui.maogoutd.resource.tools
{
   import a_4718.b_179;
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.avatar.a_3924;
   import com.aurora.ui.maogoutd.resource.defender.a_3976;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class a_4421 extends a_3976
   {
      
      private static var a_1623:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(100);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(100);
      
      private static var a_1302:MovieClip = new HelmetScoopMovie();
      
      private var m_stTiemr:Timer;
      
      public function a_4421()
      {
         super();
         a_1098 = b_179.a_403;
         this.m_stTiemr = new Timer(50);
      }
      
      public static function a_3926() : a_4421
      {
         var stHelmetScoop:a_4421 = a_1623.pop();
         if(null == stHelmetScoop)
         {
            stHelmetScoop = new a_4421();
         }
         return stHelmetScoop;
      }
      
      override public function a_1797(stFieldGrid:a_3491) : Boolean
      {
         a_1272 = 0;
         this.m_stTiemr.addEventListener(TimerEvent.TIMER,this.a_4003);
         this.visible = true;
         gotoAndStop(1);
         this.play();
         BattleFieldView.a_1027.play();
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
         a_1623.push(this);
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
               a_1334.m_stProtector.a_3969(a_1334.m_stProtector.iLifeValue);
               a_1334.a_3496(a_1334.m_stProtector);
            }
            else if(Boolean(a_1334.m_stAttackFighter) && !(a_1334.m_stAttackFighter is a_3924))
            {
               a_1334.m_stAttackFighter.a_3969(a_1334.m_stAttackFighter.iLifeValue);
               a_1334.a_3497(a_1334.m_stAttackFighter);
            }
            else if(a_1334.m_stBaseAuxiliaryFighter)
            {
               a_1334.m_stBaseAuxiliaryFighter.a_3969(a_1334.m_stBaseAuxiliaryFighter.iLifeValue);
               a_1334.a_3501(a_1334.m_stBaseAuxiliaryFighter);
            }
            else if(a_1334.m_stFlowerDefense)
            {
               a_1334.m_stFlowerDefense.a_3969(a_1334.m_stFlowerDefense.iLifeValue);
               a_1334.a_3500(a_1334.m_stFlowerDefense);
            }
            else if(a_1334.m_stBoomDefense)
            {
               a_1334.m_stBoomDefense.a_3969(a_1334.m_stBoomDefense.iLifeValue);
               a_1334.a_3499(a_1334.m_stBoomDefense);
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

