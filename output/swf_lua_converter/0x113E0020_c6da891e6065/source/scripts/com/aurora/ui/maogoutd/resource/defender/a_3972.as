package com.aurora.ui.maogoutd.resource.defender
{
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.Intruder.a_4206;
   import com.aurora.ui.maogoutd.resource.tools.a_4425;
   import flash.display.FrameLabel;
   
   public class a_3972 extends a_3962
   {
      
      protected var m_isSleep:Boolean = true;
      
      protected var m_isGoHit:Boolean = false;
      
      protected var a_1348:int = 1;
      
      protected var a_1349:int = 2;
      
      protected var a_1350:int = 0;
      
      public function a_3972()
      {
         super();
      }
      
      override public function a_1797(stFieldGrid:a_3491) : Boolean
      {
         this.m_isSleep = true;
         this.m_isGoHit = false;
         this.a_1350 = a_3491.a_1080 / 10;
         if(stFieldGrid.m_stCurrentBattbleFieldView.iIntruderMoveDirection > 0)
         {
            this.a_1350 *= -1;
         }
         return super.a_1797(stFieldGrid);
      }
      
      public function a_3973(iCurrentTime:int) : Boolean
      {
         var stMoveIntruder:a_4206 = null;
         var iXGridNo:int = 0;
         var stTestFieldGrid:a_3491 = null;
         var stIntruderRemoteThrowEffect:a_4425 = null;
         if(iCurrentTime % 2 == 0)
         {
            nextFrame();
            if(a_1278 != null)
            {
               gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
            }
            if(a_1273 == a_1274)
            {
               gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
            }
         }
         if(!this.m_isGoHit && a_1334.a_1511.length > 0)
         {
            for each(stMoveIntruder in a_1334.a_1511)
            {
               if(!this.m_isGoHit && !stMoveIntruder.isCannotSeeByFighter && hitTestObject(stMoveIntruder))
               {
                  this.m_isGoHit = true;
                  a_3969(a_1339);
                  a_1275 = this.a_1349;
                  gotoAndStop((a_1276[this.a_1348] as FrameLabel).frame);
               }
            }
         }
         if(this.m_isGoHit && a_1273 >= (a_1276[this.a_1349] as FrameLabel).frame)
         {
            x += this.a_1350;
            if(!a_1283 && x > BattleFieldView.a_1013 || a_1283 && x < 0)
            {
               this.a_3940();
               return true;
            }
            if(!a_1283)
            {
               iXGridNo = int((x + width) / a_3491.a_1080);
            }
            else
            {
               iXGridNo = BattleFieldView.a_1011 - 1 - int((x - width) / a_3491.a_1080);
            }
            stTestFieldGrid = a_1334.m_stCurrentBattbleFieldView.a_3438(iXGridNo,a_1334.m_iYGridNo);
            if(stTestFieldGrid)
            {
               for each(stMoveIntruder in stTestFieldGrid.a_1511)
               {
                  if(hitTestObject(stMoveIntruder))
                  {
                     if(0 == stMoveIntruder.iSpaceState)
                     {
                        stIntruderRemoteThrowEffect = a_4425.a_3926();
                        stIntruderRemoteThrowEffect.a_1797(stMoveIntruder.stDisplayBitmap.bitmapData.clone(),a_1283);
                        stIntruderRemoteThrowEffect.x = stMoveIntruder.x;
                        stIntruderRemoteThrowEffect.y = stMoveIntruder.y;
                        parent.addChild(stIntruderRemoteThrowEffect);
                     }
                     stMoveIntruder.a_4212();
                  }
               }
            }
         }
         return false;
      }
      
      public function a_3974() : void
      {
         this.m_isSleep = false;
         this.m_isGoHit = true;
         if(a_1339 > 0)
         {
            a_3969(a_1339);
            if(a_1275 != this.a_1349)
            {
               a_1275 = this.a_1349;
               gotoAndStop((a_1276[this.a_1348] as FrameLabel).frame);
            }
         }
      }
      
      override public function a_3940() : Boolean
      {
         if(a_1334)
         {
            a_1334.m_stCurrentBattbleFieldView.m_arrBaseInsuranceVector[a_1334.m_iYGridNo] = null;
         }
         super.a_3940();
         return true;
      }
   }
}

