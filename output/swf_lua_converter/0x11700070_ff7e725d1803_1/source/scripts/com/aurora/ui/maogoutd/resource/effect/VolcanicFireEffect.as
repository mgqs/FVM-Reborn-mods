package com.aurora.ui.maogoutd.resource.effect
{
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class VolcanicFireEffect extends a_3909
   {
      
      private static var ms_stVolcanicFireEffectVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new VolcanicFireEffectMovie();
      
      private var m_stCurrentFieldGrid:a_3491;
      
      public function VolcanicFireEffect()
      {
         super();
      }
      
      public static function a_3926() : VolcanicFireEffect
      {
         var stVolcanicFireEffect:VolcanicFireEffect = ms_stVolcanicFireEffectVector.pop();
         if(null == stVolcanicFireEffect)
         {
            stVolcanicFireEffect = new VolcanicFireEffect();
         }
         return stVolcanicFireEffect;
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
         if(Boolean(parent) && parent.contains(this))
         {
            parent.removeChild(this);
         }
         if(this.m_stCurrentFieldGrid != null)
         {
            this.m_stCurrentFieldGrid.m_hasFireEffect = false;
         }
         this.visible = false;
         gotoAndStop(1);
         if(-1 == ms_stVolcanicFireEffectVector.indexOf(this))
         {
            ms_stVolcanicFireEffectVector.push(this);
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
      
      public function get stCurrentFieldGrid() : a_3491
      {
         return this.m_stCurrentFieldGrid;
      }
      
      public function set stCurrentFieldGrid(value:a_3491) : void
      {
         this.m_stCurrentFieldGrid = value;
         if(this.m_stCurrentFieldGrid != null)
         {
            this.m_stCurrentFieldGrid.m_hasFireEffect = true;
         }
      }
   }
}

