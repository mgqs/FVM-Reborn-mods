package com.aurora.ui.maogoutd.resource.tools
{
   import com.aurora.ui.maogoutd.resource.bitmap.RedDangerFieldAlarmBitmapData;
   import flash.display.BitmapData;
   
   public class a_4440 extends a_4408
   {
      
      private static var a_1630:Array = new Array();
      
      private static var a_1631:BitmapData = new RedDangerFieldAlarmBitmapData(59,59);
      
      public function a_4440(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false)
      {
         super(bitmapData,pixelSnapping,smoothing);
         alpha = 0.7;
      }
      
      public static function a_3926() : a_4408
      {
         var stRedDangerFieldAlarm:a_4440 = null;
         stRedDangerFieldAlarm = a_1630.pop();
         if(null == stRedDangerFieldAlarm)
         {
            stRedDangerFieldAlarm = new a_4440(a_1631);
         }
         stRedDangerFieldAlarm.visible = true;
         return stRedDangerFieldAlarm;
      }
      
      override public function a_3940() : Boolean
      {
         a_1630.push(this);
         return true;
      }
   }
}

