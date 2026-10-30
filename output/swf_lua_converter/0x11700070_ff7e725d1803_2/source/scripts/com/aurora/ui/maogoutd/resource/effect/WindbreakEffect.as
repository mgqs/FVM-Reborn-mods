package com.aurora.ui.maogoutd.resource.effect
{
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class WindbreakEffect extends a_4108
   {
      
      private static var ms_stWindbreakEffectVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(20);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(20);
      
      private static var a_1302:MovieClip = new WindbreakEffectMovie();
      
      public function WindbreakEffect()
      {
         super();
      }
      
      public static function a_3926() : WindbreakEffect
      {
         var stWindbreakEffect:WindbreakEffect = ms_stWindbreakEffectVector.pop();
         if(null == stWindbreakEffect)
         {
            stWindbreakEffect = new WindbreakEffect();
         }
         return stWindbreakEffect;
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
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
         super.a_3940();
         if(-1 == ms_stWindbreakEffectVector.indexOf(this))
         {
            ms_stWindbreakEffectVector.push(this);
         }
         return true;
      }
      
      override protected function a_4109(a_4730:Event) : void
      {
         nextFrame();
         if(a_1273 == a_1274)
         {
            gotoAndStop(1);
         }
      }
   }
}

