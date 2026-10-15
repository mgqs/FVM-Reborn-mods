package com.aurora.ui.maogoutd.resource.effect
{
   import com.aurora.ui.maogoutd.resource.EffectManager;
   import com.aurora.ui.maogoutd.resource.GameMovieClip;
   import flash.display.BitmapData;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class BaseGameEffect extends a_4108
   {
      
      private var m_bEndRelease:Boolean = false;
      
      public var m_stMoveClip:GameMovieClip;
      
      public var anotherKey:String = null;
      
      public function BaseGameEffect()
      {
         super();
      }
      
      override public function a_1797(isReversed:Boolean) : Boolean
      {
         a_1275 = -1;
         a_1279 = this.m_stMoveClip.a_1279;
         m_iYDisplayCenterPos = this.m_stMoveClip.m_iYDisplayCenterPos;
         scaleX = this.m_stMoveClip.m_iScaleX;
         scaleY = this.m_stMoveClip.m_iScaleY;
         this.m_bEndRelease = false;
         super.a_1797(isReversed);
         play();
         return true;
      }
      
      override protected function a_4109(a_4730:Event) : void
      {
         nextFrame();
         if(a_1278 != null || a_1273 == a_1274)
         {
            if(this.m_bEndRelease == true)
            {
               this.a_3940();
            }
            else
            {
               gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
            }
         }
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
      
      public function SetAnimation(startIndex:int, bEndRelease:Boolean = false) : void
      {
         this.m_bEndRelease = bEndRelease;
         PlayAnimation(startIndex);
      }
      
      public function SetAnimationOnce2Loop(startIndex:int, loopIndex:int) : void
      {
         this.m_bEndRelease = false;
         a_1275 = loopIndex;
         gotoAndStop((a_1276[startIndex] as FrameLabel).frame);
      }
      
      override public function a_3940() : Boolean
      {
         EffectManager.getInstance().CheckInOne(this);
         super.a_3940();
         if(Boolean(parent) && parent.contains(this))
         {
            parent.removeChild(this);
         }
         return true;
      }
   }
}

