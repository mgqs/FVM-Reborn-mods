package com.aurora.ui.maogoutd.resource.wave
{
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.events.Event;
   
   public class a_4450 extends a_3909
   {
      
      public function a_4450()
      {
         super();
      }
      
      public function a_1797() : Boolean
      {
         if(a_3913().totalFrames <= 1)
         {
            return false;
         }
         this.visible = true;
         gotoAndStop(1);
         return true;
      }
      
      public function a_4451() : a_4450
      {
         return null;
      }
      
      public function a_3940() : Boolean
      {
         visible = true;
         if(Boolean(parent) && parent.contains(this))
         {
            parent.removeChild(this);
         }
         return true;
      }
      
      public function a_4332() : void
      {
         visible = true;
      }
      
      public function a_4333(a_4730:Event) : void
      {
         if(a_1273 == a_1274)
         {
            gotoAndStop(1);
         }
         nextFrame();
      }
   }
}

