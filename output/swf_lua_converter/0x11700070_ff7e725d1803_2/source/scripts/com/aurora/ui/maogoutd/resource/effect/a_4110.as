package com.aurora.ui.maogoutd.resource.effect
{
   import com.aurora.ui.maogoutd.resource.a_3909;
   
   public class a_4110 extends a_3909
   {
      
      public function a_4110()
      {
         super();
      }
      
      public function a_1797(isReseaved:Boolean = false) : Boolean
      {
         a_1283 = isReseaved;
         this.visible = true;
         gotoAndStop(1);
         return true;
      }
      
      public function a_3940() : Boolean
      {
         this.visible = false;
         gotoAndStop(1);
         return true;
      }
      
      public function a_3957(iTimeInterval:int) : void
      {
         nextFrame();
         if(a_1273 == a_1274)
         {
            gotoAndStop(1);
         }
      }
   }
}

