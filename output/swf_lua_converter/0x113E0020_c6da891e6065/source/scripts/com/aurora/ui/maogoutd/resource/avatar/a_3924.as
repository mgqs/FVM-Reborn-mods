package com.aurora.ui.maogoutd.resource.avatar
{
   import a_4724.AvatarDetailInfo;
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.defender.a_3953;
   
   public class a_3924 extends a_3953
   {
      
      protected var a_1289:Boolean = false;
      
      public function a_3924()
      {
         super();
      }
      
      public function a_3925(stAvatarDetailInfo:AvatarDetailInfo) : Boolean
      {
         return false;
      }
      
      override public function a_1797(stFieldGrid:a_3491) : Boolean
      {
         super.a_1797(stFieldGrid);
         this.a_1289 = false;
         return true;
      }
      
      override public function a_3969(iRduceLifeValue:int) : Boolean
      {
         var iXGridNo:int = a_1334.m_iXGridNo;
         var iYGridNo:int = a_1334.m_iYGridNo;
         var iCurrentTime:uint = uint(a_1334.m_stCurrentBattbleFieldView.iTimeIntervalNum);
         var isOwnBattleFiled:Boolean = a_1334.m_stCurrentBattbleFieldView.isOwnBattleField;
         super.a_3969(iRduceLifeValue);
         if(a_1339 <= 0)
         {
            a_1088.a_2063(iCurrentTime,iXGridNo,iYGridNo);
            if(!isOwnBattleFiled && Boolean(BattleFieldView.a_1054))
            {
               BattleFieldView.a_1054.a_3576(iXGridNo,iYGridNo);
            }
         }
         return true;
      }
      
      override public function a_3954(iCurrentTime:int) : Boolean
      {
         super.a_3954(iCurrentTime);
         return true;
      }
   }
}

