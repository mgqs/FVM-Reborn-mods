package com.aurora.ui.maogoutd.resource.effect.baseClimb
{
   import a_4715.EncrypBooleanEx;
   import a_4715.EncrypIntEx;
   import a_4715.EncrypNumber;
   import com.aurora.ui.maogoutd.resource.effect.a_4108;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class BaseClimbEffect extends a_4108
   {
      
      private static var ms_stBaseClimbEffect:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(100);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(100);
      
      private static var a_1302:MovieClip = new MovieClip();
      
      protected var m_fClimbHeightEx:EncrypNumber;
      
      protected var m_fClimbWidthEx:EncrypNumber;
      
      protected var m_iClimbTickEx:EncrypIntEx;
      
      protected var m_bIsNeedParabola:EncrypBooleanEx;
      
      private var m_bIsRunning:Boolean;
      
      public function BaseClimbEffect()
      {
         super();
         a_1279 = -0.5 * width;
         this.m_fClimbHeightEx = new EncrypNumber(6);
         this.m_iClimbTickEx = new EncrypIntEx(20);
         this.m_fClimbWidthEx = new EncrypNumber(1);
         this.m_bIsNeedParabola = new EncrypBooleanEx(false);
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
      
      public function get ClimbHeight() : Number
      {
         return this.m_fClimbHeightEx.Value;
      }
      
      public function get ClimbWidth() : Number
      {
         return this.m_fClimbWidthEx.Value;
      }
      
      public function get ClimbTick() : int
      {
         return this.m_iClimbTickEx.Value;
      }
      
      public function get IsNeedParabola() : Boolean
      {
         return this.m_bIsNeedParabola.Value;
      }
      
      override public function a_1797(isReversed:Boolean) : Boolean
      {
         super.a_1797(isReversed);
         this.m_bIsRunning = false;
         return true;
      }
      
      override public function a_3940() : Boolean
      {
         this.m_bIsRunning = false;
         super.a_3940();
         if(null != this.parent)
         {
            this.parent.removeChild(this);
         }
         return true;
      }
      
      public function a_3567(bIsNeed:Boolean = false) : void
      {
         if(!bIsNeed && this.m_bIsRunning)
         {
            return;
         }
         gotoAndStop(1);
         play();
         this.m_bIsRunning = true;
      }
      
      private function EndPlay() : void
      {
         stop();
         gotoAndStop(1);
         this.m_bIsRunning = false;
      }
      
      override protected function a_4109(a_4730:Event) : void
      {
         nextFrame();
         if(a_1273 == a_1274)
         {
            this.EndPlay();
         }
      }
   }
}

