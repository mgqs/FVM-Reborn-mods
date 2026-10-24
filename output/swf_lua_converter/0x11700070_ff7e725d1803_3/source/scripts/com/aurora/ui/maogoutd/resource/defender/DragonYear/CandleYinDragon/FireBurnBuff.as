package com.aurora.ui.maogoutd.resource.defender.DragonYear.CandleYinDragon
{
   import com.aurora.ui.maogoutd.resource.Intruder.a_4206;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class FireBurnBuff extends a_3909
   {
      
      private static var ms_stFireBurnBuffVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(100);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(100);
      
      private static var a_1302:MovieClip = new FireBurnBuffMovie();
      
      private var m_stTiemr:Timer;
      
      private var m_iStartTime:int;
      
      private var appearedTimes:int = 0;
      
      public var stTargetMouveIntruder:a_4206;
      
      private var m_iHurtCD:int;
      
      private var a_1579:Number;
      
      public var m_BuffAddTimes:int;
      
      private var m_TatalPower:Number;
      
      public var m_BuffDurations:Array = [];
      
      public var m_BuffPowers:Array = [];
      
      private var m_iWaitTime:int;
      
      public function FireBurnBuff()
      {
         super();
         a_1279 = -24;
         m_iYDisplayCenterPos = -16;
         this.m_stTiemr = new Timer(50);
      }
      
      public static function a_3926() : FireBurnBuff
      {
         var stFireBurnBuff:FireBurnBuff = ms_stFireBurnBuffVector.pop();
         if(stFireBurnBuff == null)
         {
            stFireBurnBuff = new FireBurnBuff();
         }
         return stFireBurnBuff;
      }
      
      public function a_1797(isReseaved:Boolean, iHurtCD:int = 1, iHurtPower:Number = 1) : Boolean
      {
         a_1283 = isReseaved;
         this.m_iHurtCD = iHurtCD;
         this.m_stTiemr.addEventListener(TimerEvent.TIMER,this.a_4003);
         this.visible = true;
         gotoAndStop(1);
         this.play();
         this.m_iStartTime = 0;
         this.appearedTimes = 0;
         this.m_BuffAddTimes = 1;
         this.m_TatalPower = this.m_BuffAddTimes * this.a_1579;
         return true;
      }
      
      public function get WaitTime() : int
      {
         return this.m_iWaitTime;
      }
      
      public function set WaitTime(iWaitTime:int) : void
      {
         this.m_iWaitTime = iWaitTime;
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
      
      public function a_3940() : Boolean
      {
         gotoAndStop(1);
         this.m_stTiemr.removeEventListener(TimerEvent.TIMER,this.a_4003);
         this.m_stTiemr.stop();
         if(this.stTargetMouveIntruder != null)
         {
            this.stTargetMouveIntruder.m_stFireBurnBuff = null;
            this.stTargetMouveIntruder = null;
         }
         if(ms_stFireBurnBuffVector.indexOf(this) == -1)
         {
            ms_stFireBurnBuffVector.push(this);
         }
         this.m_BuffDurations = [];
         this.m_BuffPowers = [];
         if(this.parent != null)
         {
            this.parent.removeChild(this);
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
      
      private function a_4003(a_4730:TimerEvent) : void
      {
         var totalPower:Number = NaN;
         var power:Number = NaN;
         nextFrame();
         if(a_1273 == a_1274)
         {
            gotoAndStop(1);
         }
         for(var i:* = int(this.m_BuffDurations.length - 1); i >= 0; i--)
         {
            --this.m_BuffDurations[i];
            if(this.m_BuffDurations[i] <= 0)
            {
               this.m_BuffDurations.splice(i,1);
               this.m_BuffPowers.splice(i,1);
            }
         }
         if(this.m_BuffDurations.length == 0)
         {
            this.a_3940();
            return;
         }
         if((this.m_iStartTime - 5) % (this.m_iHurtCD * 10) == 0)
         {
            if(this.stTargetMouveIntruder != null && this.stTargetMouveIntruder.iLifeValue > 0)
            {
               totalPower = 0;
               for each(power in this.m_BuffPowers)
               {
                  totalPower += power;
               }
               if(this.stTargetMouveIntruder.iLifeValue - totalPower > 0)
               {
                  this.stTargetMouveIntruder.a_3969(totalPower);
               }
               else
               {
                  this.stTargetMouveIntruder.PowerfulBombReduceLifeRate(totalPower / 900);
               }
            }
         }
         ++this.m_iStartTime;
      }
   }
}

