package com.aurora.ui.maogoutd.resource.defender.PigYear.IceCreamPitcher
{
   import com.aurora.ui.maogoutd.resource.effect.a_4110;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class FrozenCardEffect extends a_4110
   {
      
      private static var ms_stFrozenCardEffectVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new FrozenCardEffectMovie();
      
      public function FrozenCardEffect()
      {
         super();
      }
      
      public static function a_3926() : FrozenCardEffect
      {
         var stFrozenCardEffect:FrozenCardEffect = ms_stFrozenCardEffectVector.pop();
         if(null == stFrozenCardEffect)
         {
            stFrozenCardEffect = new FrozenCardEffect();
         }
         return stFrozenCardEffect;
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
         if(-1 == ms_stFrozenCardEffectVector.indexOf(this))
         {
            ms_stFrozenCardEffectVector.push(this);
         }
         return true;
      }
      
      override public function a_3957(iTimeInterval:int) : void
      {
         super.a_3957(iTimeInterval);
      }
   }
}

