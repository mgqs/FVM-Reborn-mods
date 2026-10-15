package com.aurora.ui.maogoutd.resource.effect
{
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class DesertFogEffect extends BaseDesertFogEffect
   {
      
      private static var ms_stDesertFogEffectVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new DesertFogEffectMovie();
      
      public function DesertFogEffect()
      {
         super();
      }
      
      public static function a_3926() : BaseDesertFogEffect
      {
         var stDesertFogEffect:DesertFogEffect = ms_stDesertFogEffectVector.pop();
         if(null == stDesertFogEffect)
         {
            stDesertFogEffect = new DesertFogEffect();
         }
         return stDesertFogEffect;
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
         if(-1 == ms_stDesertFogEffectVector.indexOf(this))
         {
            ms_stDesertFogEffectVector.push(this);
         }
         return true;
      }
   }
}

