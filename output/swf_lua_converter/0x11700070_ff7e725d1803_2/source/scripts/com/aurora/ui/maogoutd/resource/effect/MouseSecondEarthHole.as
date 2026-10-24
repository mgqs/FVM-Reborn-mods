package com.aurora.ui.maogoutd.resource.effect
{
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class MouseSecondEarthHole extends a_4135
   {
      
      private static var ms_stMouseSecondEarthHoleVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(20);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(20);
      
      private static var a_1302:MovieClip = new MouseSecondEarthHoleMovie();
      
      public function MouseSecondEarthHole()
      {
         super();
         m_iYDisplayCenterPos = 1;
         a_1279 = 3;
      }
      
      public static function a_3926() : MouseSecondEarthHole
      {
         var stMouseSecondEarthHole:MouseSecondEarthHole = ms_stMouseSecondEarthHoleVector.pop();
         if(null == stMouseSecondEarthHole)
         {
            stMouseSecondEarthHole = new MouseSecondEarthHole();
         }
         return stMouseSecondEarthHole;
      }
      
      override public function a_1797(isReversed:Boolean) : Boolean
      {
         return super.a_1797(isReversed);
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
         visible = false;
         gotoAndStop(1);
         stop();
         if(-1 == ms_stMouseSecondEarthHoleVector.indexOf(this))
         {
            ms_stMouseSecondEarthHoleVector.push(this);
         }
         return true;
      }
      
      override protected function a_4109(a_4730:Event) : void
      {
         nextFrame();
         if(a_1273 == a_1274)
         {
            stop();
         }
      }
   }
}

