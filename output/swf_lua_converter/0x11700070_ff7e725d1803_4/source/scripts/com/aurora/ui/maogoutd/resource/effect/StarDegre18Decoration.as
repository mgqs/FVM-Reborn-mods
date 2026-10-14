package com.aurora.ui.maogoutd.resource.effect
{
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class StarDegre18Decoration extends a_4110
   {
      
      private static var ms_stStarDegre18DecorationVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new StarDegre18DecorationMovie();
      
      private var m_lastTimeInterval:int;
      
      public function StarDegre18Decoration()
      {
         super();
      }
      
      public static function a_3926() : StarDegre18Decoration
      {
         var stStarDegre18Decoration:StarDegre18Decoration = ms_stStarDegre18DecorationVector.pop();
         if(null == stStarDegre18Decoration)
         {
            stStarDegre18Decoration = new StarDegre18Decoration();
         }
         return stStarDegre18Decoration;
      }
      
      override public function a_1797(isReseaved:Boolean = false) : Boolean
      {
         super.a_1797(isReseaved);
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
      
      override public function a_3940() : Boolean
      {
         super.a_3940();
         if(-1 == ms_stStarDegre18DecorationVector.indexOf(this))
         {
            ms_stStarDegre18DecorationVector.push(this);
         }
         return true;
      }
      
      override public function a_3957(iTimeInterval:int) : void
      {
         if(this.m_lastTimeInterval == iTimeInterval + 2 || iTimeInterval % 2 == 0)
         {
            super.a_3957(iTimeInterval);
         }
         this.m_lastTimeInterval = iTimeInterval;
      }
   }
}

