package com.aurora.ui.maogoutd.resource.effect
{
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class StarDegre16Decoration extends a_4110
   {
      
      private static var ms_stStarDegre16DecorationVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new StarDegre16DecorationMovie();
      
      public function StarDegre16Decoration()
      {
         super();
      }
      
      public static function a_3926() : StarDegre16Decoration
      {
         var stStarDegre16Decoration:StarDegre16Decoration = ms_stStarDegre16DecorationVector.pop();
         if(null == stStarDegre16Decoration)
         {
            stStarDegre16Decoration = new StarDegre16Decoration();
         }
         return stStarDegre16Decoration;
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
         if(-1 == ms_stStarDegre16DecorationVector.indexOf(this))
         {
            ms_stStarDegre16DecorationVector.push(this);
         }
         return true;
      }
      
      override public function a_3957(iTimeInterval:int) : void
      {
         super.a_3957(iTimeInterval);
      }
   }
}

