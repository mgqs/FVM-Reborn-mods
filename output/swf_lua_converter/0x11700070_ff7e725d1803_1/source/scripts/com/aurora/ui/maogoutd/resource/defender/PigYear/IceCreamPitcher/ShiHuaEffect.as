package com.aurora.ui.maogoutd.resource.defender.PigYear.IceCreamPitcher
{
   import com.aurora.ui.maogoutd.resource.effect.a_4110;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class ShiHuaEffect extends a_4110
   {
      
      private static var ms_stShiHuaEffectVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new ShiHuaEffectMovie();
      
      public function ShiHuaEffect()
      {
         super();
      }
      
      public static function a_3926() : ShiHuaEffect
      {
         var stShiHuaEffect:ShiHuaEffect = ms_stShiHuaEffectVector.pop();
         if(null == stShiHuaEffect)
         {
            stShiHuaEffect = new ShiHuaEffect();
         }
         return stShiHuaEffect;
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
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
         super.a_3940();
         if(-1 == ms_stShiHuaEffectVector.indexOf(this))
         {
            ms_stShiHuaEffectVector.push(this);
         }
         return true;
      }
      
      override public function a_3957(iTimeInterval:int) : void
      {
         super.a_3957(iTimeInterval);
      }
   }
}

