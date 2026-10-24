package com.aurora.ui.maogoutd.resource.bitmap
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   
   public class a_3939 extends Bitmap
   {
      
      private static var a_1297:Array = new Array();
      
      private static var a_1298:BitmapData = new RatEarthHoleBitmapdata(58,56);
      
      public function a_3939(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false)
      {
         super(bitmapData,pixelSnapping,smoothing);
      }
      
      public static function a_3926() : a_3939
      {
         var stRatEarthHole:a_3939 = null;
         stRatEarthHole = a_1297.pop();
         if(null == stRatEarthHole)
         {
            stRatEarthHole = new a_3939(a_1298);
         }
         stRatEarthHole.visible = true;
         return stRatEarthHole;
      }
      
      public function a_3940() : Boolean
      {
         this.visible = false;
         if(-1 == a_1297.indexOf(this))
         {
            a_1297.push(this);
         }
         return true;
      }
   }
}

