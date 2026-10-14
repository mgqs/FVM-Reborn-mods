package com.aurora.ui.maogoutd.resource.defender
{
   import com.aurora.ui.maogoutd.game.a_3491;
   import flash.display.FrameLabel;
   
   public class a_3960 extends a_3962
   {
      
      protected var a_1328:int = 2;
      
      protected var a_1329:int;
      
      protected var a_1330:int = 20;
      
      protected var a_1331:Boolean = true;
      
      public function a_3960()
      {
         super();
      }
      
      public function get isCanBeEaten() : Boolean
      {
         return this.a_1331;
      }
      
      override public function a_1797(stFieldGrid:a_3491) : Boolean
      {
         this.a_1329 = 0;
         return super.a_1797(stFieldGrid);
      }
      
      public function a_3961(iCurrentTime:int) : Boolean
      {
         if(iCurrentTime > m_iPlaceTimeIntervals + this.a_1330 && iCurrentTime >= this.a_1329 + this.a_1328)
         {
            this.a_1329 = iCurrentTime;
            nextFrame();
            if(a_1278 != null)
            {
               gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
            }
         }
         return true;
      }
      
      override public function a_3969(iRduceLifeValue:int) : Boolean
      {
         super.a_3969(iRduceLifeValue);
         if(a_1339 <= 0)
         {
            this.a_3940();
         }
         return true;
      }
      
      override public function a_3940() : Boolean
      {
         if(a_1334)
         {
            a_1334.a_3499(this);
         }
         super.a_3940();
         gotoAndStop(1);
         return true;
      }
   }
}

