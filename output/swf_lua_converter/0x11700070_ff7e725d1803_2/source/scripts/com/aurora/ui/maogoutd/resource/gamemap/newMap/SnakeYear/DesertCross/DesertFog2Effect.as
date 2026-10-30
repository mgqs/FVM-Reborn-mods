package com.aurora.ui.maogoutd.resource.gamemap.newMap.SnakeYear.DesertCross
{
   import com.aurora.ui.maogoutd.resource.effect.BaseDesertFogEffect;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class DesertFog2Effect extends BaseDesertFogEffect
   {
      
      private static var ms_stDesertFog2EffectVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new DesertFog2EffectMovie();
      
      public function DesertFog2Effect()
      {
         super();
      }
      
      public static function a_3926() : BaseDesertFogEffect
      {
         var stDesertFog2Effect:DesertFog2Effect = ms_stDesertFog2EffectVector.pop();
         if(null == stDesertFog2Effect)
         {
            stDesertFog2Effect = new DesertFog2Effect();
         }
         return stDesertFog2Effect;
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
         if(-1 == ms_stDesertFog2EffectVector.indexOf(this))
         {
            ms_stDesertFog2EffectVector.push(this);
         }
         return true;
      }
      
      override public function get height() : Number
      {
         return 64;
      }
   }
}

