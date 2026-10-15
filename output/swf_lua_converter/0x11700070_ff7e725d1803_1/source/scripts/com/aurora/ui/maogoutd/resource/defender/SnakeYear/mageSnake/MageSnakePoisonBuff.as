package com.aurora.ui.maogoutd.resource.defender.SnakeYear.mageSnake
{
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.Intruder.a_4206;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.utils.getTimer;
   
   public class MageSnakePoisonBuff extends a_3909
   {
      
      private static var ms_stMageSnakePoisonBuffVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(100);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(100);
      
      private static var a_1302:MovieClip = new MageSnakePoisonBuffMovie();
      
      private var m_iStartTime:int;
      
      private var appearedTimes:int = 0;
      
      public var stTargetGrid:a_3491;
      
      private var m_iHurtCD:int;
      
      private var a_1579:Number;
      
      public var m_BuffAddTimes:int;
      
      private var m_TatalPower:Number;
      
      public var m_BuffDurations:Array = [];
      
      public var m_BuffPowers:Array = [];
      
      private var m_iWaitTime:int;
      
      public function MageSnakePoisonBuff()
      {
         super();
         a_1279 = -38;
         m_iYDisplayCenterPos = -35;
      }
      
      public static function a_3926() : MageSnakePoisonBuff
      {
         var stMageSnakePoisonBuff:MageSnakePoisonBuff = ms_stMageSnakePoisonBuffVector.pop();
         if(stMageSnakePoisonBuff == null)
         {
            stMageSnakePoisonBuff = new MageSnakePoisonBuff();
         }
         return stMageSnakePoisonBuff;
      }
      
      public function a_1797(isReseaved:Boolean, iHurtCD:int = 1, iHurtPower:Number = 1) : Boolean
      {
         a_1283 = isReseaved;
         this.m_iHurtCD = iHurtCD;
         this.visible = true;
         gotoAndStop(1);
         this.m_iStartTime = 0;
         this.appearedTimes = getTimer();
         this.m_BuffAddTimes = 1;
         this.m_TatalPower = this.m_BuffAddTimes * this.a_1579;
         if(this.stTargetGrid.m_stCurrentBattbleFieldView.GetGameMoveMap())
         {
            this.stTargetGrid.m_stCurrentBattbleFieldView.GetGameMoveMap().AddMoveDisplayObject(this,this.stTargetGrid.m_iXGridNo,this.stTargetGrid.m_iYGridNo);
         }
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
         if(this.stTargetGrid != null && Boolean(this.stTargetGrid.m_stCurrentBattbleFieldView.GetGameMoveMap()))
         {
            this.stTargetGrid.m_stCurrentBattbleFieldView.GetGameMoveMap().RemoveMoveDisplayObject(this);
         }
         if(this.stTargetGrid != null)
         {
            this.stTargetGrid.m_stMageSnakePoisonBuff = null;
            this.stTargetGrid = null;
         }
         if(ms_stMageSnakePoisonBuffVector.indexOf(this) == -1)
         {
            ms_stMageSnakePoisonBuffVector.push(this);
         }
         this.m_BuffDurations = [];
         this.m_BuffPowers = [];
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
         return true;
      }
      
      public function a_3957(iCurrentTime:int) : void
      {
         var totalPower:Number = NaN;
         var power:Number = NaN;
         nextFrame();
         if(a_1273 == a_1274)
         {
            gotoAndStop(1);
         }
         var currentTime:int = getTimer();
         var elapsedTime:int = currentTime - this.appearedTimes;
         if(this.m_iStartTime % 20 == 0)
         {
            if(this.stTargetGrid != null)
            {
               totalPower = 0;
               for each(power in this.m_BuffPowers)
               {
                  totalPower += power;
               }
               this.a_4352(totalPower);
            }
         }
         ++this.m_iStartTime;
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
         }
      }
      
      private function a_4352(totalPower:Number) : void
      {
         var i:int = 0;
         var stMoveIntruder:a_4206 = null;
         if(this.stTargetGrid != null)
         {
            for(i = 0; i < this.stTargetGrid.a_1511.length; i++)
            {
               stMoveIntruder = this.stTargetGrid.a_1511[i];
               if(stMoveIntruder.iLifeValue > 0)
               {
                  stMoveIntruder.a_3969(totalPower);
                  if(stMoveIntruder.iLifeValue > 0)
                  {
                     stMoveIntruder.AddSnakePoisonEffect();
                  }
               }
            }
         }
      }
   }
}

