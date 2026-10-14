package com.aurora.ui.maogoutd.resource.effect
{
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class a_4145 extends a_4110
   {
      
      private static var a_1428:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new StarDegre4DecorationMovie();
      
      public function a_4145()
      {
         super();
      }
      
      public static function a_3926() : a_4145
      {
         var stStarDegre45Decoration:a_4145 = a_1428.pop();
         if(null == stStarDegre45Decoration)
         {
            stStarDegre45Decoration = new a_4145();
         }
         return stStarDegre45Decoration;
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
         if(-1 == a_1428.indexOf(this))
         {
            a_1428.push(this);
         }
         return true;
      }
      
      override public function a_3957(iTimeInterval:int) : void
      {
         super.a_3957(iTimeInterval);
      }
   }
}

