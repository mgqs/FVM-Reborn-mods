package com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation
{
   import com.aurora.ui.maogoutd.resource.effect.a_4108;
   import flash.display.BitmapData;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class GradeLevel10Animation extends a_4108
   {
      
      private static var ms_stGradeLevel10AnimationVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new GradeLevel10AnimationMovie();
      
      public function GradeLevel10Animation()
      {
         super();
         a_1279 = 0;
         m_iYDisplayCenterPos = 0;
         a_1275 = 1;
      }
      
      public static function a_3926() : GradeLevel10Animation
      {
         var stGradeLevel10Animation:GradeLevel10Animation = ms_stGradeLevel10AnimationVector.pop();
         if(null == stGradeLevel10Animation)
         {
            stGradeLevel10Animation = new GradeLevel10Animation();
         }
         return stGradeLevel10Animation;
      }
      
      override public function a_1797(isReversed:Boolean) : Boolean
      {
         super.a_1797(isReversed);
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
      
      override protected function a_4109(a_4730:Event) : void
      {
         nextFrame();
         if(a_1273 == a_1274 || a_1278 != null)
         {
            gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
         }
      }
      
      override public function a_3940() : Boolean
      {
         super.a_3940();
         if(-1 == ms_stGradeLevel10AnimationVector.indexOf(this))
         {
            ms_stGradeLevel10AnimationVector.push(this);
         }
         if(Boolean(parent) && parent.contains(this))
         {
            parent.removeChild(this);
         }
         return true;
      }
   }
}

