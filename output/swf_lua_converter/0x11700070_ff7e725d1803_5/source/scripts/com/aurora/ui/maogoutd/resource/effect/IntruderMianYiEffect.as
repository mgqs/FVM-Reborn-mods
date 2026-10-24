package com.aurora.ui.maogoutd.resource.effect
{
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class IntruderMianYiEffect extends a_3909
   {
      
      private static var ms_stIntruderMianYiEffectVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new IntruderMianYiEffectMovie();
      
      public function IntruderMianYiEffect()
      {
         a_1271 = true;
         super();
      }
      
      public static function a_3926() : IntruderMianYiEffect
      {
         var stIntruderMianYiEffect:IntruderMianYiEffect = ms_stIntruderMianYiEffectVector.pop();
         if(null == stIntruderMianYiEffect)
         {
            stIntruderMianYiEffect = new IntruderMianYiEffect();
         }
         return stIntruderMianYiEffect;
      }
      
      public function a_1797(isReseaved:Boolean = false) : Boolean
      {
         a_1283 = isReseaved;
         this.visible = true;
         gotoAndStop(1);
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
      
      public function a_3940() : Boolean
      {
         this.visible = false;
         gotoAndStop(1);
         if(-1 == ms_stIntruderMianYiEffectVector.indexOf(this))
         {
            ms_stIntruderMianYiEffectVector.push(this);
         }
         return true;
      }
      
      public function a_4003(a_4730:Event) : void
      {
         nextFrame();
         if(a_1273 == a_1274)
         {
            gotoAndStop(1);
         }
      }
   }
}

