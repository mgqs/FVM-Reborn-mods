package com.aurora.ui.maogoutd.resource.tools
{
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.BitmapData;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class a_4448 extends a_3909
   {
      
      private static var a_1636:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(100);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(100);
      
      private static var a_1302:MovieClip = new WaterWaveMovie();
      
      public function a_4448()
      {
         super();
      }
      
      public static function a_3926() : a_4448
      {
         var stWaterWave:a_4448 = a_1636.pop();
         if(null == stWaterWave)
         {
            stWaterWave = new a_4448();
         }
         return stWaterWave;
      }
      
      public function a_1797(isReseaved:Boolean) : Boolean
      {
         a_1283 = isReseaved;
         if(BattleFieldView.lastMouseMoveIntruder != null)
         {
            BattleFieldView.lastMouseMoveIntruder.m_stWaterEffect = this;
         }
         a_1275 = 1;
         gotoAndStop(1);
         this.visible = true;
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
      
      override public function nextFrame() : void
      {
         super.nextFrame();
         if(a_1278 != null || a_1273 == a_1274)
         {
            gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
         }
      }
      
      public function a_3940() : Boolean
      {
         if(Boolean(parent) && parent.contains(this))
         {
            parent.removeChild(this);
         }
         if(-1 == a_1636.indexOf(this))
         {
            a_1636.push(this);
         }
         return true;
      }
   }
}

