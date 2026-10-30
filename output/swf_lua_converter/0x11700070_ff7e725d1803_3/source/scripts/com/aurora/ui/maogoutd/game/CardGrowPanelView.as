package com.aurora.ui.maogoutd.game
{
   import a_4715.EncrypIntEx;
   import a_4728.a_1778;
   import a_4729.a_1789;
   import a_4752.GlobalVariables;
   import a_4752.a_2036;
   import com.aurora.protocol.game.maogoutd.CardDieVO;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class CardGrowPanelView extends Sprite
   {
      
      public var m_stMoneyText:TextField;
      
      public var m_stGrowChangeArea:Sprite;
      
      public var m_stHelmetArea:HelmetScoopAreaView;
      
      public var m_stMoreCardRightTopRound:Sprite;
      
      public var m_stMoreCardGrowChangeArea:Sprite;
      
      public var m_iEnemyLimit:int = 10000;
      
      private var a_1074:EncrypIntEx = new EncrypIntEx();
      
      private var a_1075:EncrypIntEx = new EncrypIntEx(2000);
      
      private var a_1076:Array = [];
      
      private var m_arrGameCardViews2:Array = [];
      
      private var a_1077:Number = 67;
      
      private var a_1078:Timer;
      
      private var a_1079:EncrypIntEx = new EncrypIntEx();
      
      private var m_iMoney:EncrypIntEx = new EncrypIntEx();
      
      public var m_iLastDeathDefender:int;
      
      public var m_iEnergyMAX:int = -1;
      
      public function CardGrowPanelView()
      {
         super();
         this.a_1797(null);
         this.a_1078 = new Timer(100);
      }
      
      public function get iMoneyCount() : int
      {
         return this.a_1074.Value - this.a_1075.Value;
      }
      
      public function a_1797(arrSelectedCards:Array) : Boolean
      {
         var stGameCardView:GameCardView = null;
         this.a_1075.Value = 10 + int(Math.random() * 2000);
         this.m_stMoneyText.text = "0";
         this.m_iMoney.Value = 0;
         this.m_iEnergyMAX = -1;
         this.a_1074.Value = this.a_1075.Value;
         this.a_1077 = 67;
         this.m_stGrowChangeArea.width = 18;
         this.m_stHelmetArea.x = 99;
         this.m_stHelmetArea.y = 0;
         this.m_stHelmetArea.a_3517();
         this.m_stHelmetArea.m_stMoreCardsScoopBackGround.visible = false;
         this.m_stHelmetArea.m_stLastCardsScoopBackGround.visible = false;
         this.m_stHelmetArea.m_stLessCardsScoopBackGround.visible = true;
         this.m_stHelmetArea.a_3555(true);
         this.m_stMoreCardRightTopRound.visible = false;
         this.m_stMoreCardGrowChangeArea.visible = false;
         for each(stGameCardView in this.a_1076)
         {
            removeChild(stGameCardView);
            stGameCardView.a_3517();
         }
         this.a_1076 = [];
         this.m_arrGameCardViews2 = [];
         if(null != root)
         {
            root.addEventListener("MoneyFlameClick",this.a_3482);
            root.addEventListener("ReduceEnergy",this.OnReduceEnergy);
            root.addEventListener("ReduceEnergy2",this.OnReduceEnergy2);
            root.addEventListener("SetEnergyMAX",this.OnSetEnergyMAX);
            root.addEventListener("DefenseCardCountChange",this.a_3483);
            root.addEventListener("GameCardCoolDown",this.OnGameCardCoolDown);
            root.addEventListener("GameCardCopy",this.OnGameCardCopy);
            root.addEventListener("GameCardRandomCopy",this.OnGameCardRandomCopy);
            root.addEventListener("OnGameDeathCardRandomCopy",this.OnGameDeathCardRandomCopy);
            root.addEventListener("GameRangeDeathCardCopy",this.OnAddRangeDeathCardCopy);
            root.addEventListener("GameCloseCopyCardProcess",this.OnGameCloseCopyCardProcess);
         }
         a_1789.getInstance().addEventListener("AddDeathCard",this.OnAddDeathCard);
         this.SetEnemyLimit(-1);
         while(GlobalVariables.getInstance().m_iEatDieArr.length > 0)
         {
            GlobalVariables.getInstance().m_iEatDieArr.pop();
         }
         return true;
      }
      
      public function SetEnemyLimit(iValue:int) : void
      {
         if(iValue == -1)
         {
            if(GlobalVariables.getInstance().m_iMonthCardVipService > 0)
            {
               this.m_iEnemyLimit = 15000;
            }
            else
            {
               this.m_iEnemyLimit = 10000;
            }
         }
         else
         {
            this.m_iEnemyLimit = iValue;
         }
         this.UpdateMoney();
      }
      
      private function OnAddDeathCard(stDataEvent:a_1778) : void
      {
         var i:int = 0;
         var copyItem:int = 0;
         var data:CardDieVO = null;
         var arrVanishDefender:Array = stDataEvent.dataObject as Array;
         if(arrVanishDefender != null && arrVanishDefender.length > 0)
         {
            for(i = 0; i < arrVanishDefender.length; i++)
            {
               if(arrVanishDefender[i].m_byIsTool == 1)
               {
                  copyItem = int(arrVanishDefender[i].m_iDefenderTypeID);
                  if(!BattleFieldView.JudgeIsCopyCard(copyItem) && !BattleFieldView.JudgeIsCooldownCard(copyItem))
                  {
                     this.m_iLastDeathDefender = arrVanishDefender[i].m_iDefenderTypeID;
                     data = new CardDieVO();
                     data.m_iDefenderID = arrVanishDefender[i].m_iDefenderID;
                     data.m_iDefenderTypeID = arrVanishDefender[i].m_iDefenderTypeID;
                     data.m_byYGridNo = arrVanishDefender[i].m_byYGridNo;
                     data.m_byXGridNo = arrVanishDefender[i].m_byXGridNo;
                     data.m_byIsTool = arrVanishDefender[i].m_byIsTool;
                     data.m_iOrigSeatID = arrVanishDefender[i].m_iOrigSeatID;
                     data.m_DieTime = new Date().getTime() / 1000;
                     GlobalVariables.getInstance().m_iEatDieArr.push(data);
                  }
               }
            }
         }
      }
      
      public function a_3476(iGameCardTypeID:uint) : GameCardView
      {
         return this.a_1076[iGameCardTypeID];
      }
      
      public function GetGameCardViewByIndex(index:int) : GameCardView
      {
         return this.m_arrGameCardViews2[index];
      }
      
      public function GetLeftUseCardView() : GameCardView
      {
         for(var i:int = 0; i < this.m_arrGameCardViews2.length; i++)
         {
            if(!a_2036.getInstance().tagCom.HasTag(300 + i) && this.m_arrGameCardViews2[i].iGrowTimes <= 0)
            {
               return this.m_arrGameCardViews2[i];
            }
            if(i == this.m_arrGameCardViews2.length - 1)
            {
               return this.m_arrGameCardViews2[i];
            }
         }
         return null;
      }
      
      public function a_3477(iGameCardTypeID:uint) : Boolean
      {
         var stGameCardView:GameCardView = null;
         if(4294967295 == iGameCardTypeID)
         {
            this.m_stHelmetArea.a_3517();
            this.m_stHelmetArea.a_3555(true);
            for each(stGameCardView in this.a_1076)
            {
               if(stGameCardView.stBaseDefense)
               {
                  stGameCardView.a_3516();
                  this.a_3480(stGameCardView.iDefensePrice);
                  stGameCardView.a_3517();
               }
            }
            return true;
         }
         stGameCardView = this.a_1076[iGameCardTypeID];
         if(null == stGameCardView)
         {
            return false;
         }
         stGameCardView.a_3516();
         this.a_3480(stGameCardView.iDefensePrice);
         BattleFieldView.a_1022.play();
         return true;
      }
      
      public function a_3478(iGameCardTypeID:uint) : Boolean
      {
         if(1 == iGameCardTypeID)
         {
            this.m_stHelmetArea.a_3555(true);
            return true;
         }
         var stGameCardView:GameCardView = new GameCardView(iGameCardTypeID);
         stGameCardView.x = this.a_1077 + 10;
         stGameCardView.y = 5;
         stGameCardView.a_3513();
         addChild(stGameCardView);
         this.a_1076[stGameCardView.a_3512()] = stGameCardView;
         stGameCardView.cardIndex = this.m_arrGameCardViews2.length;
         this.m_arrGameCardViews2.push(stGameCardView);
         this.a_1077 += 53;
         if(this.a_1077 > 710)
         {
            x = 114;
            this.m_stGrowChangeArea.width = 835 - 70 - 15;
            this.m_stMoreCardRightTopRound.visible = true;
            this.m_stMoreCardGrowChangeArea.visible = true;
            this.m_stHelmetArea.m_stMoreCardsScoopBackGround.visible = true;
            this.m_stHelmetArea.m_stLastCardsScoopBackGround.visible = false;
            this.m_stHelmetArea.m_stLessCardsScoopBackGround.visible = false;
            this.m_stHelmetArea.x = 752;
            if(int((this.a_1077 - 67) / 53) >= 13 && int((this.a_1077 - 67) / 53) <= 14)
            {
               this.m_stHelmetArea.y = 65;
               this.m_stMoreCardGrowChangeArea.height = 70;
            }
            else if(int((this.a_1077 - 67) / 53) > 14)
            {
               this.m_stHelmetArea.y = 134 + 68 * (int((this.a_1077 - 67) / 53) - 15);
               this.m_stMoreCardGrowChangeArea.height = 140 + 68 * (int((this.a_1077 - 67) / 53) - 15);
               if(int((this.a_1077 - 67) / 53) >= 21)
               {
                  this.m_stHelmetArea.x = -2;
                  this.m_stHelmetArea.y = 77;
                  this.m_stHelmetArea.m_stMoreCardsScoopBackGround.visible = false;
                  this.m_stHelmetArea.m_stLastCardsScoopBackGround.visible = true;
                  this.m_stHelmetArea.m_stLessCardsScoopBackGround.visible = false;
               }
            }
            if(this.a_1077 > 850)
            {
               stGameCardView.x = 766;
               stGameCardView.y = 5 + (int((this.a_1077 - 68) / 54) - 13) * 68;
            }
         }
         else
         {
            x = 135;
            this.m_stGrowChangeArea.width = this.a_1077 - 70;
            this.m_stHelmetArea.x = this.m_stGrowChangeArea.x + this.m_stGrowChangeArea.width - 2;
         }
         stGameCardView.addEventListener(MouseEvent.CLICK,this.a_3484);
         return true;
      }
      
      public function a_3479() : void
      {
         var stGameCardView:GameCardView = null;
         x = -2;
         this.m_stHelmetArea.m_stMoreCardsScoopBackGround.visible = false;
         this.m_stHelmetArea.m_stLastCardsScoopBackGround.visible = false;
         this.m_stHelmetArea.m_stLessCardsScoopBackGround.visible = true;
         this.m_stHelmetArea.y = 0;
         this.m_stMoreCardRightTopRound.visible = false;
         this.m_stMoreCardGrowChangeArea.visible = false;
         for each(stGameCardView in this.a_1076)
         {
            if(stGameCardView.y > 5)
            {
               stGameCardView.x += int((stGameCardView.y - 5) / 68) * 53;
               stGameCardView.y = 5;
               this.m_stGrowChangeArea.width += 53;
            }
         }
         this.m_stHelmetArea.x = this.m_stGrowChangeArea.x + this.m_stGrowChangeArea.width - 15;
      }
      
      public function a_3480(iAddMoney:uint) : void
      {
         this.a_1074.Value += iAddMoney;
         this.UpdateMoney();
      }
      
      public function a_3481(iSubMoney:uint) : void
      {
         if(iSubMoney > this.a_1074.Value - this.a_1075.Value)
         {
            iSubMoney = this.a_1074.Value - this.a_1075.Value;
         }
         this.a_1074.Value -= iSubMoney;
         this.UpdateMoney();
      }
      
      public function SubMoney2(iSubMoney:uint) : void
      {
         if(iSubMoney > this.a_1074.Value - this.a_1075.Value)
         {
            return;
         }
         this.a_1074.Value -= iSubMoney;
         this.UpdateMoney();
      }
      
      private function UpdateMoney() : void
      {
         var stGameCardView:GameCardView = null;
         if(this.a_1074.Value > this.m_iEnemyLimit + this.a_1075.Value)
         {
            this.a_1074.Value = this.m_iEnemyLimit + this.a_1075.Value;
         }
         this.m_stMoneyText.text = (this.a_1074.Value - this.a_1075.Value).toString();
         this.m_iMoney.Value = this.a_1074.Value - this.a_1075.Value;
         for each(stGameCardView in this.a_1076)
         {
            if(stGameCardView.iDefensePrice > this.a_1074.Value - this.a_1075.Value)
            {
               stGameCardView.a_3513();
            }
            else if(stGameCardView.iGrowTimes == 0)
            {
               stGameCardView.a_3514();
            }
         }
      }
      
      private function a_3482(stDataEvent:a_1778) : void
      {
         var iAddMoney:int = stDataEvent.dataObject as int;
         this.a_3480(iAddMoney);
      }
      
      private function OnReduceEnergy(stDataEvent:a_1778) : void
      {
         var iReduceMoney:int = stDataEvent.dataObject as int;
         this.a_3481(iReduceMoney);
      }
      
      private function OnReduceEnergy2(stDataEvent:a_1778) : void
      {
         var iReduceMoney:int = stDataEvent.dataObject as int;
         this.SubMoney2(iReduceMoney);
      }
      
      private function OnSetEnergyMAX(stDataEvent:a_1778) : void
      {
         var max:int = stDataEvent.dataObject as int;
         this.SetEnemyLimit(max);
      }
      
      private function a_3483(stDataEvent:a_1778) : void
      {
         var iDefenseTypeID:int = int(stDataEvent.dataObject[0]);
         var iDefenseCount:int = int(stDataEvent.dataObject[1]);
         var stGameCardView:GameCardView = this.a_3476(iDefenseTypeID);
         if(stGameCardView)
         {
            stGameCardView.a_3515(iDefenseCount * 50);
            if(stGameCardView.iNeedAdditionPrice)
            {
               if(stGameCardView.iDefensePrice <= this.a_1074.Value - this.a_1075.Value)
               {
                  if(stGameCardView.iGrowTimes == 0)
                  {
                     stGameCardView.a_3514();
                  }
               }
               else if(stGameCardView.iDefensePrice > this.a_1074.Value - this.a_1075.Value)
               {
                  stGameCardView.a_3513();
               }
            }
         }
         var dataEvent:a_1778 = new a_1778("DefenseCardCountChange");
         dataEvent.dataObjectNew = stDataEvent.dataObject;
         a_1789.getInstance().dispatchEvent(dataEvent);
      }
      
      private function OnGameCardCopy(stDataEvent:a_1778) : void
      {
         var stGameCardView:GameCardView = null;
         var copyByWhoID:String = stDataEvent.dataObject.toString();
         var cardID:int = int(GlobalVariables.getInstance().m_prevPlacedCardDic[copyByWhoID]);
         if(cardID > 0)
         {
            stGameCardView = this.a_3476(cardID);
            stGameCardView.OnGameCardCopy(cardID,copyByWhoID);
         }
      }
      
      private function OnGameCardRandomCopy(stDataEvent:a_1778) : void
      {
         var stGameCard:GameCardView = null;
         var stGameCardView:GameCardView = null;
         var copyByWhoID:String = stDataEvent.dataObject.toString();
         var tempArray:Array = new Array();
         var stkey:int = 0;
         var copyItem:uint = 0;
         for each(stGameCard in this.a_1076)
         {
            copyItem = uint(stGameCard.a_3512());
            if(!BattleFieldView.JudgeIsCopyCard(copyItem) && !BattleFieldView.JudgeIsCooldownCard(copyItem))
            {
               tempArray.push(copyItem);
            }
         }
         if(tempArray != null && tempArray.length != 0)
         {
            stkey = Math.floor(Math.random() * tempArray.length);
            stGameCardView = this.a_3476(tempArray[stkey]);
            stGameCardView.OnGameCardCopy(tempArray[stkey],copyByWhoID);
         }
      }
      
      private function OnGameDeathCardRandomCopy(stDataEvent:a_1778) : void
      {
         var stGameCardView:GameCardView = null;
         var copyByWhoID:String = stDataEvent.dataObject.toString();
         if(this.m_iLastDeathDefender != -1)
         {
            stGameCardView = this.a_3476(this.m_iLastDeathDefender);
            stGameCardView.OnGameCardCopy(this.m_iLastDeathDefender,copyByWhoID);
         }
      }
      
      private function OnAddRangeDeathCardCopy(stDataEvent:a_1778) : void
      {
         var stGameCardView:GameCardView = null;
         var cardID:int = int(stDataEvent.dataObject[0]);
         var copyByWhoID:String = stDataEvent.dataObject[1].toString();
         if(cardID != -1)
         {
            stGameCardView = this.a_3476(cardID);
            stGameCardView.OnGameCardCopy(cardID,copyByWhoID);
         }
      }
      
      protected function OnGameCloseCopyCardProcess(stDataEvent:a_1778) : void
      {
         var stGameCardView:GameCardView = null;
         var cardID:int = int(stDataEvent.dataObject[0]);
         var copyByWhoID:String = stDataEvent.dataObject[1].toString();
         if(copyByWhoID != "")
         {
            stGameCardView = this.a_3476(cardID);
            stGameCardView.onCloseCopyCardProcess(copyByWhoID);
         }
      }
      
      private function OnGameCardCoolDown(stDataEvent:a_1778) : Boolean
      {
         var stGameCardView:GameCardView = null;
         var iGameCardTypeID:uint = stDataEvent.dataObject[0] as uint;
         var arrExcludedDefense:Array = stDataEvent.dataObject[1];
         var reduceRate:Number = stDataEvent.dataObject.length > 2 ? Number(stDataEvent.dataObject[2]) : 0;
         var time:Number = 0;
         if(a_2036.getInstance().tagCom.HasTag(19))
         {
            time = 20;
         }
         else if(a_2036.getInstance().tagCom.HasTag(18))
         {
            time = 10;
         }
         else if(a_2036.getInstance().tagCom.HasTag(17))
         {
            time = 5;
         }
         if(4294967295 == iGameCardTypeID)
         {
            for each(stGameCardView in this.a_1076)
            {
               if(time > 0)
               {
                  if(Boolean(stGameCardView) && -1 == arrExcludedDefense.indexOf(stGameCardView.a_3512()))
                  {
                     stGameCardView.AddGrowTime(time);
                  }
               }
               else if(Boolean(stGameCardView) && Boolean(-1 == arrExcludedDefense.indexOf(stGameCardView.a_3512())) && stGameCardView.m_iOnHand == false)
               {
                  stGameCardView.a_3516();
               }
            }
            a_2036.getInstance().tagCom.RemoveTag(17);
            a_2036.getInstance().tagCom.RemoveTag(18);
            a_2036.getInstance().tagCom.RemoveTag(19);
            return true;
         }
         if(4294967290 == iGameCardTypeID)
         {
            for each(stGameCardView in this.a_1076)
            {
               if(Boolean(stGameCardView) && Boolean(-1 != arrExcludedDefense.indexOf(stGameCardView.a_3512())) && stGameCardView.m_iOnHand == false)
               {
                  stGameCardView.ReduceGrowTimeRate(reduceRate);
               }
            }
            return true;
         }
         stGameCardView = this.a_1076[iGameCardTypeID];
         if(null == stGameCardView)
         {
            return false;
         }
         if(arrExcludedDefense.length > 0 && arrExcludedDefense[0] == 1 && time > 0)
         {
            stGameCardView.AddGrowTime(time);
            a_2036.getInstance().tagCom.RemoveTag(17);
            a_2036.getInstance().tagCom.RemoveTag(18);
            a_2036.getInstance().tagCom.RemoveTag(19);
         }
         else
         {
            stGameCardView.a_3516();
         }
         return true;
      }
      
      private function a_3484(a_4730:Event) : void
      {
         if((a_4730.currentTarget as GameCardView).iDefensePrice > this.a_1074.Value - this.a_1075.Value)
         {
            this.a_1079.Value = 10;
            this.a_1078.start();
         }
      }
      
      private function a_3485(a_4730:Event) : void
      {
         if(this.a_1079.Value > 0)
         {
            --this.a_1079.Value;
            if(this.a_1079.Value % 2 == 0)
            {
               this.m_stMoneyText.textColor = 0;
            }
            else
            {
               this.m_stMoneyText.textColor = 15728640;
            }
         }
         else
         {
            this.a_1078.stop();
         }
      }
      
      public function get Money() : int
      {
         return this.m_iMoney.Value;
      }
      
      public function OnTimeInterval(iTimeNum:uint) : void
      {
         var stGameCardView:GameCardView = null;
         if(iTimeNum % 2 == 0)
         {
            if(this.a_1078.running)
            {
               this.a_3485(null);
            }
            for each(stGameCardView in this.a_1076)
            {
               stGameCardView.a_3518(null);
            }
         }
      }
   }
}

