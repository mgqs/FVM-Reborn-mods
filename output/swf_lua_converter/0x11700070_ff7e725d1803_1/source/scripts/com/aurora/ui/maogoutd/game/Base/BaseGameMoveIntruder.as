package com.aurora.ui.maogoutd.game.Base
{
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.EffectManager;
   import com.aurora.ui.maogoutd.resource.GameMovieClip;
   import com.aurora.ui.maogoutd.resource.Intruder.a_4206;
   import flash.display.BitmapData;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class BaseGameMoveIntruder extends a_4206
   {
      
      public var m_stMoveClip:GameMovieClip;
      
      public var anotherKey:String = null;
      
      protected var MAX_LIFE:int = 0;
      
      protected var INJURED_LIFE:int = 0;
      
      protected var ONE_GRID_SPEED:Number = 0;
      
      public function BaseGameMoveIntruder()
      {
         super();
      }
      
      override public function a_1797(iGlobalMoveFighterID:int, iIntruderMoveDirection:int) : Boolean
      {
         super.a_1797(iGlobalMoveFighterID,iIntruderMoveDirection);
         a_1279 = this.m_stMoveClip.a_1279;
         m_iYDisplayCenterPos = this.m_stMoveClip.m_iYDisplayCenterPos;
         scaleX = this.m_stMoveClip.m_iScaleX;
         scaleY = this.m_stMoveClip.m_iScaleY;
         this.SetSpeed(this.ONE_GRID_SPEED);
         a_1339 = this.MAX_LIFE;
         a_1275 = -1;
         this.SetAnimation(0,0);
         return true;
      }
      
      override protected function a_3911() : Vector.<BitmapData>
      {
         if(this.m_stMoveClip == null)
         {
            this.m_stMoveClip = EffectManager.getInstance().lastMoveClip;
         }
         return EffectManager.getInstance().GetMoveClip2(this.m_stMoveClip).a_1300;
      }
      
      override protected function a_3912() : Vector.<Point>
      {
         if(this.m_stMoveClip == null)
         {
            this.m_stMoveClip = EffectManager.getInstance().lastMoveClip;
         }
         return EffectManager.getInstance().GetMoveClip2(this.m_stMoveClip).a_1301;
      }
      
      override protected function a_3913() : MovieClip
      {
         if(this.m_stMoveClip == null)
         {
            this.m_stMoveClip = EffectManager.getInstance().lastMoveClip;
         }
         return this.m_stMoveClip;
      }
      
      override protected function a_3940() : Boolean
      {
         EffectManager.getInstance().CheckInOneMouse(this);
         super.a_3940();
         return true;
      }
      
      protected function SetDeadAnim(deadAnim:int) : void
      {
         this.SetAnimation(deadAnim);
         if(m_stCurrentFieldGrid)
         {
            m_stCurrentFieldGrid.a_3457(this);
            m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
         }
         play();
      }
      
      override public function a_4216(iCurrentTime:int) : Boolean
      {
         var numOrigXPos:Number = x;
         super.a_4216(iCurrentTime);
         SetGameMapModePicnicPosition(numOrigXPos);
         return true;
      }
      
      private function SetSpeed(moveSpeed:Number) : void
      {
         a_1350 = a_3491.a_1080 / (20 * moveSpeed);
         if(!a_1283)
         {
            a_1350 *= -1;
         }
      }
      
      public function InDamage() : Boolean
      {
         return a_1339 > 0 && a_1339 < this.INJURED_LIFE;
      }
      
      public function SetAnimation(animIdx1:int, animIdx2:int = 0) : void
      {
         if(this.InDamage())
         {
            animIdx1 = animIdx2;
         }
         if(a_1275 != animIdx1)
         {
            a_1275 = animIdx1;
            gotoAndStop((a_1276[animIdx1] as FrameLabel).frame);
            a_3419();
         }
      }
      
      public function SetAnimationOnce2Loop(onceAnim1:int, loopAnim1:int, onceAnim2:int, loopAnim2:int) : void
      {
         if(this.InDamage())
         {
            onceAnim1 = onceAnim2;
            loopAnim1 = loopAnim2;
         }
         a_1275 = loopAnim1;
         gotoAndStop((a_1276[onceAnim1] as FrameLabel).frame);
         a_3419();
      }
   }
}

