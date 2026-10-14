package com.aurora.ui.maogoutd.resource.defender.fusionCard.termiThreeShotGun
{
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.shot.ShotTrigger.BaseShotTrigger;
   import com.aurora.ui.maogoutd.resource.shot.ShotTrigger.ShotTriggerManager;
   import com.aurora.ui.maogoutd.resource.shot.ShotTrigger.ShotTriggerType;
   import com.aurora.ui.maogoutd.resource.shot.a_4348;
   import flash.display.BitmapData;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class TermiThreeShotGunPrimaryShot extends a_4348
   {
      
      private static var a_1591:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(100);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(100);
      
      private static var a_1302:MovieClip = new TermiThreeShotGunPrimaryShotMovie();
      
      public function TermiThreeShotGunPrimaryShot()
      {
         super();
         a_1279 = -13;
         m_iYDisplayCenterPos = -8;
         a_1573 = 2;
         a_1588 = true;
         a_1275 = 0;
         a_1587 = 1;
      }
      
      public static function a_4344() : a_4348
      {
         var stTermiThreeShotGunPrimaryShot:TermiThreeShotGunPrimaryShot = a_1591.pop();
         if(null == stTermiThreeShotGunPrimaryShot)
         {
            stTermiThreeShotGunPrimaryShot = new TermiThreeShotGunPrimaryShot();
         }
         BattleFieldView.a_1018.play();
         return stTermiThreeShotGunPrimaryShot;
      }
      
      override public function a_1797(iGlobalID:int, numSpeed:Number, iHurtPower:int, iXpos:int, iYpos:int, stCurrentBattleView:BattleFieldView, stStartFieldGrid:a_3491, isBothWayShot:Boolean = false, numHotMultiplier:Number = 1, iThreeRowShotType:int = 0) : Boolean
      {
         super.a_1797(iGlobalID,numSpeed,iHurtPower,iXpos,iYpos,stCurrentBattleView,stStartFieldGrid,isBothWayShot,numHotMultiplier,iThreeRowShotType);
         if(-1 == m_iShotGroupIndex)
         {
            m_numYSpeed = -2 * Math.abs(m_numXSpeed);
         }
         else if(1 == m_iShotGroupIndex)
         {
            m_numYSpeed = 2 * Math.abs(m_numXSpeed);
         }
         var trigger:BaseShotTrigger = ShotTriggerManager.Instance.CreateTrigger(ShotTriggerType.BURNBUFFTRIGGER,30,m_iGlobalID,21,m_isSpecial);
         AddTrigger(trigger);
         return true;
      }
      
      override public function a_4216(iCurrentTime:int) : void
      {
         if(m_isHited && !m_isPenetrate)
         {
            nextFrame();
            if(a_1273 == a_1274 || a_1278 != null)
            {
               m_bActive.Value = false;
               this.a_3940();
            }
            return;
         }
         if(a_1588)
         {
            nextFrame();
            if(a_1273 == a_1274 || a_1278 != null)
            {
               gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
            }
         }
         if(0 == a_1447)
         {
            a_1447 = iCurrentTime;
         }
         a_4351();
         if(a_1578)
         {
            if(!FollowingShotHandle())
            {
               return;
            }
         }
         x += m_numXSpeed;
         if(-1 == m_iShotGroupIndex && y > a_1586 - a_3491.a_1081 * 0.9)
         {
            y += m_numYSpeed;
         }
         else if(1 == m_iShotGroupIndex && y < a_1586 + 20 + a_3491.a_1081 * 0.9)
         {
            y += m_numYSpeed;
         }
      }
      
      override protected function ReboundHandler() : void
      {
         rotationY = rotationY == -180 ? 0 : -180;
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
      
      override protected function a_3940() : Boolean
      {
         super.a_3940();
         rotationY = 0;
         if(-1 == a_1591.indexOf(this))
         {
            a_1591.push(this);
         }
         return true;
      }
   }
}

