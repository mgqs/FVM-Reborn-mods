package com.aurora.ui.maogoutd.resource.defender
{
   import a_4715.EncrypNumber;
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.a_3491;
   import flash.display.FrameLabel;
   
   public class a_3975 extends a_3962
   {
      
      private var m_EnergyRateEx:EncrypNumber;
      
      public function a_3975()
      {
         super();
      }
      
      override public function a_1797(stFieldGrid:a_3491) : Boolean
      {
         this.EnergyRate = 1;
         return super.a_1797(stFieldGrid);
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
      
      public function a_3957(iCurrentTime:int) : void
      {
         this.nextFrame();
         if(a_1278 != null)
         {
            gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
         }
         if(a_1273 == a_1274)
         {
            gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
         }
         if(a_1336)
         {
            a_1336.a_3957(iCurrentTime);
         }
         if(m_stFrozenCardEffect)
         {
            m_stFrozenCardEffect.a_3957(iCurrentTime);
         }
         if(m_stShiHuaEffect)
         {
            m_stShiHuaEffect.a_3957(iCurrentTime);
         }
         buffCom.UpdateBuff(2);
      }
      
      override public function nextFrame() : void
      {
         super.nextFrame();
         if(this.EnergyRate > 1 && m_AddFireBuff != null)
         {
            if(stFieldGrid != null && Boolean(stFieldGrid.m_stCurrentBattbleFieldView.GetGameMoveMap()))
            {
               if(!this.CanAddEnergyRate())
               {
                  this.EnergyRate = 1;
                  m_AddFireBuff.a_3940();
                  m_AddFireBuff = null;
               }
            }
         }
      }
      
      override public function a_3940() : Boolean
      {
         if(a_1334)
         {
            a_1334.a_3496(this);
            a_1334.m_stCurrentBattbleFieldView.stCheckFieldGridsVector[a_1334.m_iYGridNo][a_1334.m_iXGridNo].a_3496(this);
         }
         super.a_3940();
         this.EnergyRate = 1;
         return true;
      }
      
      public function get EnergyRate() : Number
      {
         if(!this.m_EnergyRateEx)
         {
            this.m_EnergyRateEx = new EncrypNumber(1);
         }
         return this.m_EnergyRateEx.Value;
      }
      
      public function set EnergyRate(value:Number) : void
      {
         if(!this.m_EnergyRateEx)
         {
            this.m_EnergyRateEx = new EncrypNumber(1);
         }
         this.m_EnergyRateEx.Value = value;
      }
      
      private function CanAddEnergyRate() : Boolean
      {
         var iXGridNo:int = 0;
         var iYGridNo:int = 0;
         var targetFieldGrid:a_3491 = null;
         if(stFieldGrid == null)
         {
            return false;
         }
         var iXCenterGridNo:int = stFieldGrid.m_iXGridNo;
         var iYCenterGridNo:int = stFieldGrid.m_iYGridNo;
         var iAttackRange:int = 1;
         var iStartXGridNo:int = Math.max(iXCenterGridNo - iAttackRange,0);
         var iStartYGridNo:int = Math.max(iYCenterGridNo - iAttackRange,0);
         var iEndXGridNo:int = Math.min(iXCenterGridNo + iAttackRange,BattleFieldView.a_1011 - 1);
         var iEndYGridNo:int = Math.min(iYCenterGridNo + iAttackRange,BattleFieldView.a_1012 - 1);
         loop0:
         for(iXGridNo = iStartXGridNo; iXGridNo <= iEndXGridNo; )
         {
            iYGridNo = iStartYGridNo;
            while(true)
            {
               if(iYGridNo > iEndYGridNo)
               {
                  iXGridNo++;
                  continue loop0;
               }
               targetFieldGrid = stFieldGrid.m_stCurrentBattbleFieldView.stFieldGridsVector[iYGridNo][iXGridNo];
               if(targetFieldGrid != null)
               {
                  if(null != targetFieldGrid.m_stAttackFighter && (targetFieldGrid.m_stAttackFighter.a_3512() == 286394256 || targetFieldGrid.m_stAttackFighter.a_3512() == 286394270))
                  {
                     break;
                  }
               }
               iYGridNo++;
            }
            return true;
         }
         iAttackRange = 2;
         iStartXGridNo = Math.max(iXCenterGridNo - iAttackRange,0);
         iStartYGridNo = Math.max(iYCenterGridNo - iAttackRange,0);
         iEndXGridNo = Math.min(iXCenterGridNo + iAttackRange,BattleFieldView.a_1011 - 1);
         iEndYGridNo = Math.min(iYCenterGridNo + iAttackRange,BattleFieldView.a_1012 - 1);
         loop2:
         for(iXGridNo = iStartXGridNo; iXGridNo <= iEndXGridNo; )
         {
            iYGridNo = iStartYGridNo;
            while(true)
            {
               if(iYGridNo > iEndYGridNo)
               {
                  iXGridNo++;
                  continue loop2;
               }
               targetFieldGrid = stFieldGrid.m_stCurrentBattbleFieldView.stFieldGridsVector[iYGridNo][iXGridNo];
               if(targetFieldGrid != null)
               {
                  if(null != targetFieldGrid.m_stAttackFighter && targetFieldGrid.m_stAttackFighter.a_3512() == 286394271)
                  {
                     break;
                  }
               }
               iYGridNo++;
            }
            return true;
         }
         return false;
      }
   }
}

