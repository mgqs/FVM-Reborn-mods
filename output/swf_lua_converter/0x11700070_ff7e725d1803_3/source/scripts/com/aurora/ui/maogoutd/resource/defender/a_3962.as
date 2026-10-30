package com.aurora.ui.maogoutd.resource.defender
{
   import a_4715.EncrypBooleanEx;
   import a_4715.EncrypIntEx;
   import a_4715.EncrypUintEx;
   import a_4752.TagComponent;
   import a_4753.b_150;
   import com.adobe.utils.RandomSeed;
   import com.aurora.protocol.game.maogoutd.CVanishDefender;
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.BattleLayerDefine;
   import com.aurora.ui.maogoutd.game.Buff.BuffComponent;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import com.aurora.ui.maogoutd.resource.defender.HorseYear.stardome.ImperialStrikeHurtBuff;
   import com.aurora.ui.maogoutd.resource.defender.PigYear.IceCreamPitcher.FrozenCardEffect;
   import com.aurora.ui.maogoutd.resource.defender.PigYear.IceCreamPitcher.ShiHuaEffect;
   import com.aurora.ui.maogoutd.resource.defender.RabbitYear.YanYanRabbit.YanYanRabbitAddFireBuff;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel10Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel11Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel12Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel13Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel14Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel15Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel16Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel1Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel2Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel3Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel4Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel5Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel6Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel7Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel8Animation;
   import com.aurora.ui.maogoutd.resource.effect.GradeLevelAnimation.GradeLevel9Animation;
   import com.aurora.ui.maogoutd.resource.effect.StarDegre10Decoration;
   import com.aurora.ui.maogoutd.resource.effect.StarDegre11Decoration;
   import com.aurora.ui.maogoutd.resource.effect.StarDegre12Decoration;
   import com.aurora.ui.maogoutd.resource.effect.StarDegre13Decoration;
   import com.aurora.ui.maogoutd.resource.effect.StarDegre14Decoration;
   import com.aurora.ui.maogoutd.resource.effect.StarDegre15Decoration;
   import com.aurora.ui.maogoutd.resource.effect.StarDegre16Decoration;
   import com.aurora.ui.maogoutd.resource.effect.StarDegre18Decoration;
   import com.aurora.ui.maogoutd.resource.effect.StarDegre19Decoration;
   import com.aurora.ui.maogoutd.resource.effect.StarDegre20Decoration;
   import com.aurora.ui.maogoutd.resource.effect.StarDegreMaxDecoration;
   import com.aurora.ui.maogoutd.resource.effect.a_4108;
   import com.aurora.ui.maogoutd.resource.effect.a_4110;
   import com.aurora.ui.maogoutd.resource.effect.a_4145;
   import com.aurora.ui.maogoutd.resource.effect.a_4147;
   import com.aurora.ui.maogoutd.resource.effect.a_4149;
   import com.aurora.ui.maogoutd.resource.effect.a_4151;
   import com.aurora.ui.maogoutd.resource.effect.a_4153;
   import com.aurora.ui.maogoutd.resource.effect.a_4155;
   import flash.display.Bitmap;
   import flash.display.FrameLabel;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import flash.utils.clearInterval;
   import flash.utils.setTimeout;
   
   public class a_3962 extends a_3909
   {
      
      public static var a_1088:b_150;
      
      public static var s_GlobalInitCount:int = 0;
      
      public var m_stShadowRefence:Bitmap;
      
      public var m_iDefenseGlobalID:int;
      
      public var m_iBeOtherPlaced:Boolean;
      
      public var m_iDefenseRandomSeed:RandomSeed = new RandomSeed();
      
      public var m_IsCaclueCoolDown:int = 0;
      
      public var m_iMoveState:int;
      
      private var m_iPlaceTimeIntervalsEx:EncrypUintEx = new EncrypUintEx();
      
      private var m_isHurtByOpponentEx:EncrypBooleanEx;
      
      private var m_iDieTypeEx:EncrypIntEx;
      
      private var m_iDefenseStateTypeEx:EncrypIntEx;
      
      private var m_iOffsetByYEx:EncrypIntEx;
      
      private var m_isNeedAddShawdowEx:EncrypBooleanEx;
      
      private var m_iDefenseTypeIDEx:EncrypUintEx = new EncrypUintEx();
      
      private var m_iDefensePriceEx:EncrypUintEx;
      
      public var m_iRealDefensePrice:uint;
      
      private var m_iTickTimeEx:EncrypIntEx;
      
      private var m_iFangyuTimeEx:EncrypIntEx;
      
      private var ResetStarTimeout:int;
      
      private var m_isNeedAdditionPriceEx:EncrypBooleanEx;
      
      protected var a_1334:a_3491;
      
      protected var a_1335:int;
      
      public var iUpgradeArray:Array = new Array();
      
      protected var m_stBaseGradeLevel:a_4108;
      
      protected var a_1336:a_4110;
      
      public var m_stFrozenCardEffect:FrozenCardEffect;
      
      public var m_stShiHuaEffect:ShiHuaEffect;
      
      public var m_AddFireBuff:YanYanRabbitAddFireBuff;
      
      public var m_FangyuBuff:a_4108;
      
      public var m_BaseEffect:a_4108;
      
      private var m_iStarDegreeEx:EncrypIntEx = new EncrypIntEx(0);
      
      private var m_iOrigSeatIDEx:EncrypIntEx = new EncrypIntEx(0);
      
      private var m_iRealStarDegreeEx:EncrypIntEx = new EncrypIntEx(0);
      
      private var m_iSkillDegreeEx:EncrypIntEx = new EncrypIntEx(0);
      
      private var m_iGradeDegreeEx:EncrypIntEx = new EncrypIntEx(0);
      
      private var m_iXPosSheftEx:EncrypIntEx;
      
      private var m_iYPosSheftEx:EncrypIntEx;
      
      private var m_iHiddenLifeValueEx:EncrypIntEx;
      
      private var m_isShihuaEx:EncrypBooleanEx;
      
      private var m_isShowFrozenEx:EncrypBooleanEx;
      
      private var m_CannotFrozenCard:Array = new Array(288817232,288817246,288817247,286392912,286392926,286392927,286396464,286396478,286396479);
      
      private var m_stTimer:Timer;
      
      private var ticks:int;
      
      private var m_bIsSleepingEx:EncrypBooleanEx = new EncrypBooleanEx(false);
      
      private var m_bIsNotEaten:EncrypBooleanEx = new EncrypBooleanEx(false);
      
      private var m_bServerIssuedEx:EncrypBooleanEx;
      
      private var m_bPlaceByUpGradeCardEx:EncrypBooleanEx;
      
      private var _tagCom:TagComponent = new TagComponent();
      
      private var _buffCom:BuffComponent;
      
      public function a_3962()
      {
         super();
         gotoAndStop(1);
      }
      
      public function get m_iPlaceTimeIntervals() : uint
      {
         return this.m_iPlaceTimeIntervalsEx.Value;
      }
      
      public function set m_iPlaceTimeIntervals(iValue:uint) : void
      {
         this.m_iPlaceTimeIntervalsEx.Value = iValue;
      }
      
      public function get m_isHurtByOpponent() : Boolean
      {
         if(!this.m_isHurtByOpponentEx)
         {
            this.m_isHurtByOpponentEx = new EncrypBooleanEx();
         }
         return this.m_isHurtByOpponentEx.Value;
      }
      
      public function set m_isHurtByOpponent(value:Boolean) : void
      {
         if(!this.m_isHurtByOpponentEx)
         {
            this.m_isHurtByOpponentEx = new EncrypBooleanEx();
         }
         this.m_isHurtByOpponentEx.Value = value;
      }
      
      public function get m_iDieType() : int
      {
         if(!this.m_iDieTypeEx)
         {
            this.m_iDieTypeEx = new EncrypIntEx();
         }
         return this.m_iDieTypeEx.Value;
      }
      
      public function set m_iDieType(value:int) : void
      {
         if(!this.m_iDieTypeEx)
         {
            this.m_iDieTypeEx = new EncrypIntEx();
         }
         this.m_iDieTypeEx.Value = value;
      }
      
      public function get m_iDefenseStateType() : int
      {
         if(!this.m_iDefenseStateTypeEx)
         {
            this.m_iDefenseStateTypeEx = new EncrypIntEx(0);
         }
         return this.m_iDefenseStateTypeEx.Value;
      }
      
      public function set m_iDefenseStateType(value:int) : void
      {
         if(!this.m_iDefenseStateTypeEx)
         {
            this.m_iDefenseStateTypeEx = new EncrypIntEx();
         }
         this.m_iDefenseStateTypeEx.Value = value;
      }
      
      public function get m_iOffsetByY() : int
      {
         if(!this.m_iOffsetByYEx)
         {
            this.m_iOffsetByYEx = new EncrypIntEx();
         }
         return this.m_iOffsetByYEx.Value;
      }
      
      public function set m_iOffsetByY(value:int) : void
      {
         if(!this.m_iOffsetByYEx)
         {
            this.m_iOffsetByYEx = new EncrypIntEx();
         }
         this.m_iOffsetByYEx.Value = value;
      }
      
      protected function get a_1333() : Boolean
      {
         if(!this.m_isNeedAddShawdowEx)
         {
            this.m_isNeedAddShawdowEx = new EncrypBooleanEx(false);
         }
         return this.m_isNeedAddShawdowEx.Value;
      }
      
      protected function set a_1333(value:Boolean) : void
      {
         if(!this.m_isNeedAddShawdowEx)
         {
            this.m_isNeedAddShawdowEx = new EncrypBooleanEx(false);
         }
         this.m_isNeedAddShawdowEx.Value = value;
      }
      
      protected function get a_1098() : uint
      {
         return this.m_iDefenseTypeIDEx.Value;
      }
      
      protected function set a_1098(iValue:uint) : void
      {
         this.m_iDefenseTypeIDEx.Value = iValue;
      }
      
      public function GetRealPrice() : int
      {
         if(this.m_iRealDefensePrice > 0)
         {
            return this.m_iRealDefensePrice;
         }
         return this.iDefensePrice;
      }
      
      public function get m_iTickTime() : int
      {
         if(!this.m_iTickTimeEx)
         {
            this.m_iTickTimeEx = new EncrypIntEx();
         }
         return this.m_iTickTimeEx.Value;
      }
      
      public function set m_iTickTime(value:int) : void
      {
         if(!this.m_iTickTimeEx)
         {
            this.m_iTickTimeEx = new EncrypIntEx();
         }
         this.m_iTickTimeEx.Value = value;
      }
      
      public function get m_iFangyuTime() : int
      {
         if(!this.m_iFangyuTimeEx)
         {
            this.m_iFangyuTimeEx = new EncrypIntEx();
         }
         return this.m_iFangyuTimeEx.Value;
      }
      
      public function set m_iFangyuTime(value:int) : void
      {
         if(!this.m_iFangyuTimeEx)
         {
            this.m_iFangyuTimeEx = new EncrypIntEx();
         }
         this.m_iFangyuTimeEx.Value = value;
      }
      
      protected function get a_1095() : uint
      {
         if(!this.m_iDefensePriceEx)
         {
            this.m_iDefensePriceEx = new EncrypUintEx();
         }
         return this.m_iDefensePriceEx.Value;
      }
      
      protected function set a_1095(value:uint) : void
      {
         if(!this.m_iDefensePriceEx)
         {
            this.m_iDefensePriceEx = new EncrypUintEx();
         }
         this.m_iDefensePriceEx.Value = value;
      }
      
      protected function get a_1096() : Boolean
      {
         if(!this.m_isNeedAdditionPriceEx)
         {
            this.m_isNeedAdditionPriceEx = new EncrypBooleanEx(false);
         }
         return this.m_isNeedAdditionPriceEx.Value;
      }
      
      protected function set a_1096(value:Boolean) : void
      {
         if(!this.m_isNeedAdditionPriceEx)
         {
            this.m_isNeedAdditionPriceEx = new EncrypBooleanEx(false);
         }
         this.m_isNeedAdditionPriceEx.Value = value;
      }
      
      public function get a_1094() : int
      {
         return this.m_iStarDegreeEx.Value;
      }
      
      public function set a_1094(iValue:int) : void
      {
         this.m_iStarDegreeEx.Value = iValue;
      }
      
      public function get m_iOrigSeatID() : int
      {
         return this.m_iOrigSeatIDEx.Value;
      }
      
      public function set m_iOrigSeatID(iValue:int) : void
      {
         this.m_iOrigSeatIDEx.Value = iValue;
      }
      
      public function get m_iRealStarDegree() : int
      {
         return this.m_iRealStarDegreeEx.Value;
      }
      
      public function set m_iRealStarDegree(iValue:int) : void
      {
         this.m_iRealStarDegreeEx.Value = iValue;
      }
      
      public function get m_iSkillDegree() : int
      {
         return this.m_iSkillDegreeEx.Value;
      }
      
      public function set m_iSkillDegree(iValue:int) : void
      {
         this.m_iSkillDegreeEx.Value = iValue;
      }
      
      public function get m_iGradeDegree() : int
      {
         return this.m_iGradeDegreeEx.Value;
      }
      
      public function set m_iGradeDegree(iValue:int) : void
      {
         this.m_iGradeDegreeEx.Value = iValue;
      }
      
      protected function get a_1337() : int
      {
         if(!this.m_iXPosSheftEx)
         {
            this.m_iXPosSheftEx = new EncrypIntEx(0);
         }
         return this.m_iXPosSheftEx.Value;
      }
      
      protected function set a_1337(value:int) : void
      {
         if(!this.m_iXPosSheftEx)
         {
            this.m_iXPosSheftEx = new EncrypIntEx(0);
         }
         this.m_iXPosSheftEx.Value = value;
      }
      
      protected function get a_1338() : int
      {
         if(!this.m_iYPosSheftEx)
         {
            this.m_iYPosSheftEx = new EncrypIntEx(0);
         }
         return this.m_iYPosSheftEx.Value;
      }
      
      protected function set a_1338(value:int) : void
      {
         if(!this.m_iYPosSheftEx)
         {
            this.m_iYPosSheftEx = new EncrypIntEx(0);
         }
         this.m_iYPosSheftEx.Value = value;
      }
      
      protected function set m_iHiddenLifeValue(value:int) : void
      {
         if(!this.m_iHiddenLifeValueEx)
         {
            this.m_iHiddenLifeValueEx = new EncrypIntEx(50);
         }
         this.m_iHiddenLifeValueEx.Value = value;
      }
      
      protected function get m_iHiddenLifeValue() : int
      {
         if(!this.m_iHiddenLifeValueEx)
         {
            this.m_iHiddenLifeValueEx = new EncrypIntEx(50);
         }
         return this.m_iHiddenLifeValueEx.Value;
      }
      
      public function get m_isShihua() : Boolean
      {
         if(!this.m_isShihuaEx)
         {
            this.m_isShihuaEx = new EncrypBooleanEx(false);
         }
         return this.m_isShihuaEx.Value;
      }
      
      public function set m_isShihua(value:Boolean) : void
      {
         if(!this.m_isShihuaEx)
         {
            this.m_isShihuaEx = new EncrypBooleanEx(false);
         }
         this.m_isShihuaEx.Value = value;
         if(this.m_isShowFrozen)
         {
            return;
         }
         var bShouldShowShiHua:Boolean = value && !this.checkHasProtector() && !this.checkHasTrayDefense();
         if(bShouldShowShiHua)
         {
            this.CreateShiHuaEffect();
         }
         else if(this.m_stShiHuaEffect)
         {
            this.m_stShiHuaEffect.a_3940();
            this.m_stShiHuaEffect = null;
         }
         this.visible = !value;
         if(bShouldShowShiHua)
         {
            this.a_2217();
         }
         else
         {
            this.a_2218();
         }
      }
      
      public function get m_isShowFrozen() : Boolean
      {
         if(!this.m_isShowFrozenEx)
         {
            this.m_isShowFrozenEx = new EncrypBooleanEx(false);
         }
         return this.m_isShowFrozenEx.Value;
      }
      
      public function set m_isShowFrozen(value:Boolean) : void
      {
         if(value && this.m_CannotFrozenCard.indexOf(this.a_3512()) != -1)
         {
            return;
         }
         if(!this.m_isShowFrozenEx)
         {
            this.m_isShowFrozenEx = new EncrypBooleanEx(false);
         }
         this.m_isShowFrozenEx.Value = value;
         if(value == false)
         {
            this.m_isShihua = false;
         }
         if(this.m_stFrozenCardEffect)
         {
            this.m_stFrozenCardEffect.visible = value;
         }
         if(this.stFieldGrid != null)
         {
            this.stFieldGrid.m_isShowFrozen = this.checkFieldisShowFrozen();
         }
         var bShouldShowFrozen:Boolean = value && !this.checkHasProtector() && !this.checkHasTrayDefense();
         if(bShouldShowFrozen && this.stFieldGrid.m_bShowFrozenEffect)
         {
            this.addFrozenEffect();
         }
         else if(this.m_stFrozenCardEffect)
         {
            this.m_stFrozenCardEffect.a_3940();
            this.m_stFrozenCardEffect = null;
         }
         if(!(Boolean(this.stFieldGrid) && !this.stFieldGrid.m_bShowFrozenEffect))
         {
            this.visible = !value;
            if(bShouldShowFrozen)
            {
               this.a_2217();
            }
            else
            {
               this.a_2218();
            }
         }
      }
      
      private function checkHasProtector() : Boolean
      {
         if(this.stFieldGrid != null && this.stFieldGrid.m_stProtector != null && this.stFieldGrid.m_stProtector.a_3512() == this.a_3512())
         {
            return this.stFieldGrid.m_stAttackFighter != null || this.stFieldGrid.m_stTrayDefense != null || this.stFieldGrid.m_stBoomDefense != null || this.stFieldGrid.m_stFlowerDefense != null || this.stFieldGrid.m_stBaseAuxiliaryFighter != null;
         }
         return false;
      }
      
      private function checkHasTrayDefense() : Boolean
      {
         if(this.stFieldGrid != null && this.stFieldGrid.m_stTrayDefense != null && this.stFieldGrid.m_stTrayDefense.a_3512() == this.a_3512())
         {
            return this.stFieldGrid.m_stAttackFighter != null || this.stFieldGrid.m_stProtector != null || this.stFieldGrid.m_stBoomDefense != null || this.stFieldGrid.m_stFlowerDefense != null || this.stFieldGrid.m_stBaseAuxiliaryFighter != null;
         }
         return false;
      }
      
      private function checkFieldisShowFrozen() : Boolean
      {
         if(this.stFieldGrid.m_stAttackFighter != null && this.stFieldGrid.m_stAttackFighter.m_isShowFrozen)
         {
            return true;
         }
         if(this.stFieldGrid.m_stTrayDefense != null && this.stFieldGrid.m_stTrayDefense.m_isShowFrozen)
         {
            return true;
         }
         if(this.stFieldGrid.m_stBoomDefense != null && this.stFieldGrid.m_stBoomDefense.m_isShowFrozen)
         {
            return true;
         }
         if(this.stFieldGrid.m_stFlowerDefense != null && this.stFieldGrid.m_stFlowerDefense.m_isShowFrozen)
         {
            return true;
         }
         if(this.stFieldGrid.m_stBaseAuxiliaryFighter != null && this.stFieldGrid.m_stBaseAuxiliaryFighter.m_isShowFrozen)
         {
            return true;
         }
         if(this.stFieldGrid.m_stProtector != null && this.stFieldGrid.m_stProtector.m_isShowFrozen)
         {
            return true;
         }
         return false;
      }
      
      public function a_2217() : void
      {
         if(this.m_stTimer == null)
         {
            this.m_stTimer = new Timer(1000);
            this.m_stTimer.addEventListener(TimerEvent.TIMER,this.OnTickHandler);
         }
         if(this.m_stTimer.running)
         {
            this.m_stTimer.stop();
         }
         this.ticks = 0;
         this.m_stTimer.start();
      }
      
      public function a_2218() : void
      {
         if(Boolean(this.m_stTimer) && this.m_stTimer.hasEventListener(TimerEvent.TIMER))
         {
            this.m_stTimer.removeEventListener(TimerEvent.TIMER,this.OnTickHandler);
         }
         if(this.m_stTimer)
         {
            this.m_stTimer.stop();
            this.m_stTimer = null;
         }
      }
      
      private function OnTickHandler(e:TimerEvent) : void
      {
         ++this.ticks;
         if(this.m_isShihua && this.ticks == this.stFieldGrid.m_stCurrentBattbleFieldView.ms_iShihuaTime)
         {
            this.m_iDieType = 1;
            this.a_3969(this.iLifeValue);
         }
         else if(this.ticks == this.stFieldGrid.m_stCurrentBattbleFieldView.ms_iFrozenBrokeTime)
         {
            this.m_iDieType = 1;
            this.a_3969(this.iLifeValue);
         }
      }
      
      protected function get a_1340() : Boolean
      {
         return this.m_bIsSleepingEx.Value;
      }
      
      protected function set a_1340(bValue:Boolean) : void
      {
         this.m_bIsSleepingEx.Value = bValue;
      }
      
      public function get IsNotEaten() : Boolean
      {
         return this.m_bIsNotEaten.Value;
      }
      
      public function set IsNotEaten(bValue:Boolean) : void
      {
         this.m_bIsNotEaten.Value = bValue;
      }
      
      public function get isSleeping() : Boolean
      {
         return this.a_1340;
      }
      
      public function get isNeedAdditionPrice() : Boolean
      {
         return this.a_1096;
      }
      
      public function get iUpgradeID() : int
      {
         return this.a_1335;
      }
      
      public function get iXPosSheft() : int
      {
         return this.a_1337;
      }
      
      public function get iYPosSheft() : int
      {
         return this.a_1338;
      }
      
      public function get isNeedAddShawdow() : Boolean
      {
         return this.a_1333;
      }
      
      public function set a_1339(iValue:int) : void
      {
         this.m_iHiddenLifeValue = iValue;
      }
      
      public function set iDefenseTypeID(value:uint) : void
      {
         this.a_1098 = value;
      }
      
      public function get iDefensePrice() : uint
      {
         return this.a_1095;
      }
      
      public function set iDefensePrice(value:uint) : void
      {
         this.a_1095 = value;
      }
      
      public function get iLifeValue() : int
      {
         return this.a_1339;
      }
      
      public function set stFieldGrid(value:a_3491) : void
      {
         this.a_1334 = value;
      }
      
      public function get stFieldGrid() : a_3491
      {
         return this.a_1334;
      }
      
      public function a_3512() : int
      {
         return this.a_1098;
      }
      
      public function a_3963() : int
      {
         return this.a_3964();
      }
      
      public function a_1797(mstFieldGrid:a_3491) : Boolean
      {
         this.m_stShadowRefence = null;
         this.stFieldGrid = mstFieldGrid;
         if(this.stFieldGrid.m_stCurrentBattbleFieldView.iIntruderMoveDirection > 0)
         {
            a_1283 = true;
         }
         else
         {
            a_1283 = false;
         }
         this.IsNotEaten = false;
         gotoAndStop(1);
         a_1275 = 0;
         this.a_1339 = 50;
         a_1282 = true;
         this.m_iDieType = 0;
         this.m_isHurtByOpponent = false;
         if(this.m_bServerIssued)
         {
            ++s_GlobalInitCount;
         }
         if(this.m_iTickTime > 0)
         {
            if(this.ResetStarTimeout > 0)
            {
               clearInterval(this.ResetStarTimeout);
            }
            this.ResetStarTimeout = setTimeout(this.onResetCardGradeTimerComplete,this.m_iTickTime);
         }
         if(this.a_1336)
         {
            this.a_1336.a_3940();
            this.a_1336 = null;
         }
         if(this.a_1094 == 4)
         {
            this.a_1336 = a_4145.a_3926();
         }
         else if(this.a_1094 == 5)
         {
            this.a_1336 = a_4147.a_3926();
         }
         else if(this.a_1094 == 6)
         {
            this.a_1336 = a_4149.a_3926();
         }
         else if(this.a_1094 == 7)
         {
            this.a_1336 = a_4151.a_3926();
         }
         else if(this.a_1094 == 8)
         {
            this.a_1336 = a_4153.a_3926();
         }
         else if(this.a_1094 == 9)
         {
            this.a_1336 = a_4155.a_3926();
         }
         else if(this.a_1094 == 10)
         {
            this.a_1336 = StarDegre10Decoration.a_3926();
         }
         else if(this.a_1094 == 11)
         {
            this.a_1336 = StarDegre11Decoration.a_3926();
         }
         else if(this.a_1094 == 12)
         {
            this.a_1336 = StarDegre12Decoration.a_3926();
         }
         else if(this.a_1094 == 13)
         {
            this.a_1336 = StarDegre13Decoration.a_3926();
         }
         else if(this.a_1094 == 14)
         {
            this.a_1336 = StarDegre14Decoration.a_3926();
         }
         else if(this.a_1094 == 15)
         {
            this.a_1336 = StarDegre15Decoration.a_3926();
         }
         else if(this.a_1094 == 16)
         {
            this.a_1336 = StarDegre16Decoration.a_3926();
         }
         else if(this.a_1094 == 17)
         {
            this.a_1336 = StarDegreMaxDecoration.a_3926();
         }
         else if(this.a_1094 == 18)
         {
            this.a_1336 = StarDegre18Decoration.a_3926();
         }
         else if(this.a_1094 == 19)
         {
            this.a_1336 = StarDegre19Decoration.a_3926();
         }
         else if(this.a_1094 == 20)
         {
            this.a_1336 = StarDegre20Decoration.a_3926();
         }
         if(this.a_1336)
         {
            this.a_1336.a_1797(false);
            if(a_1283)
            {
               this.a_1336.x = stDisplayBitmap.x - this.a_1336.width - (width - this.a_1336.width) * 0.5;
            }
            else
            {
               this.a_1336.x = (width - this.a_1336.width) * 0.5;
            }
            this.a_1336.y = height - this.a_1336.height;
            addChild(this.a_1336);
         }
         this.m_isShowFrozen = false;
         this.m_isShihua = false;
         return true;
      }
      
      public function finalizeInitialization() : void
      {
         if(!this.m_bServerIssued || !this.a_1334 || this.m_iGradeDegree <= 0 || this.a_1336 == null)
         {
            return;
         }
         if(this.m_stBaseGradeLevel)
         {
            this.m_stBaseGradeLevel.a_3940();
            this.m_stBaseGradeLevel = null;
         }
         switch(this.m_iGradeDegree)
         {
            case 1:
               this.m_stBaseGradeLevel = GradeLevel1Animation.a_3926();
               break;
            case 2:
               this.m_stBaseGradeLevel = GradeLevel2Animation.a_3926();
               break;
            case 3:
               this.m_stBaseGradeLevel = GradeLevel3Animation.a_3926();
               break;
            case 4:
               this.m_stBaseGradeLevel = GradeLevel4Animation.a_3926();
               break;
            case 5:
               this.m_stBaseGradeLevel = GradeLevel5Animation.a_3926();
               break;
            case 6:
               this.m_stBaseGradeLevel = GradeLevel6Animation.a_3926();
               break;
            case 7:
               this.m_stBaseGradeLevel = GradeLevel7Animation.a_3926();
               break;
            case 8:
               this.m_stBaseGradeLevel = GradeLevel8Animation.a_3926();
               break;
            case 9:
               this.m_stBaseGradeLevel = GradeLevel9Animation.a_3926();
               break;
            case 10:
               this.m_stBaseGradeLevel = GradeLevel10Animation.a_3926();
               break;
            case 11:
               this.m_stBaseGradeLevel = GradeLevel11Animation.a_3926();
               break;
            case 12:
               this.m_stBaseGradeLevel = GradeLevel12Animation.a_3926();
               break;
            case 13:
               this.m_stBaseGradeLevel = GradeLevel13Animation.a_3926();
               break;
            case 14:
               this.m_stBaseGradeLevel = GradeLevel14Animation.a_3926();
               break;
            case 15:
               this.m_stBaseGradeLevel = GradeLevel15Animation.a_3926();
               break;
            case 16:
               this.m_stBaseGradeLevel = GradeLevel16Animation.a_3926();
         }
         if(this.m_stBaseGradeLevel)
         {
            this.m_stBaseGradeLevel.a_1797(false);
            this.m_stBaseGradeLevel.x = this.x + this.a_1336.x + (this.a_1336.width - this.m_stBaseGradeLevel.width) * 0.5 - 1;
            this.m_stBaseGradeLevel.y = this.y + this.a_1336.y + BattleFieldView.yOffsetList[this.a_1094];
            parent.addChild(this.m_stBaseGradeLevel);
            if(this.a_1334.m_stCurrentBattbleFieldView.GetGameMoveMap())
            {
               this.a_1334.m_stCurrentBattbleFieldView.GetGameMoveMap().AddMoveDisplayObject(this.m_stBaseGradeLevel,this.a_1334.m_iXGridNo,this.a_1334.m_iYGridNo);
            }
            this.m_stBaseGradeLevel.play();
         }
      }
      
      protected function a_3964() : int
      {
         return 70;
      }
      
      public function CanBeEat() : Boolean
      {
         return true;
      }
      
      protected function a_3965() : int
      {
         return 0;
      }
      
      public function get a_1339() : int
      {
         return this.m_iHiddenLifeValue;
      }
      
      protected function a_3966() : int
      {
         return 0;
      }
      
      public function a_3967() : Boolean
      {
         if(this.a_1336)
         {
            this.a_1336.visible = false;
         }
         return true;
      }
      
      public function a_3968() : Boolean
      {
         if(this.a_1336)
         {
            this.a_1336.visible = true;
         }
         return true;
      }
      
      public function a_3969(iRduceLifeValue:int) : Boolean
      {
         var stDefenderInfo:CVanishDefender = null;
         var iVanishTimeNum:int = 0;
         if(Boolean(this.m_iDieType == 1 && this.m_FangyuBuff) && Boolean(iRduceLifeValue > 0) && this.m_iFangyuTime > 0)
         {
            if(--this.m_iFangyuTime == 0)
            {
               this.m_FangyuBuff.a_3940();
               this.m_FangyuBuff = null;
            }
            return false;
         }
         this.a_1339 -= iRduceLifeValue;
         if(Boolean(this.a_1334) && this.a_1339 <= 0)
         {
            stDefenderInfo = new CVanishDefender();
            stDefenderInfo.m_iDefenderID = this.m_iDefenseGlobalID;
            stDefenderInfo.m_iDefenderTypeID = this.a_1098;
            stDefenderInfo.m_byXGridNo = this.a_1334.m_iInitialXGridNo;
            stDefenderInfo.m_byYGridNo = this.a_1334.m_iInitialYGridNo;
            stDefenderInfo.m_iOrigSeatID = this.m_iOrigSeatID;
            stDefenderInfo.m_byIsTool = this.m_iDieType;
            iVanishTimeNum = this.a_1334.m_stCurrentBattbleFieldView.iTimeIntervalNum;
            a_1088.a_2060(iVanishTimeNum,this.a_1334.m_stCurrentBattbleFieldView.m_byTeamNo,new Array(stDefenderInfo));
         }
         return true;
      }
      
      private function onResetCardGradeTimerComplete() : void
      {
         var stInitialFieldGrid:a_3491 = null;
         if(this.stFieldGrid != null)
         {
            stInitialFieldGrid = this.a_1334.m_stCurrentBattbleFieldView.a_3438(this.stFieldGrid.m_iXGridNo,this.stFieldGrid.m_iYGridNo);
            this.a_3940();
            a_1088.a_2059(this.m_iDefenseGlobalID,this.a_3512(),stInitialFieldGrid.m_iInitialXGridNo,stInitialFieldGrid.m_iInitialYGridNo,0,1,this.m_iRealStarDegree,0,0,this.m_iOrigSeatID);
         }
      }
      
      public function a_3940() : Boolean
      {
         var stBattleFieldView:BattleFieldView = null;
         this.tagCom.ClearAll();
         this.buffCom.ClearAll();
         this.m_iMoveState = 0;
         this.m_iDefenseStateType = 0;
         this.m_IsCaclueCoolDown = 0;
         this.m_iTickTime = this.m_iFangyuTime = 0;
         if(this.ResetStarTimeout > 0)
         {
            clearInterval(this.ResetStarTimeout);
         }
         this.m_isShowFrozen = false;
         this.m_bServerIssued = false;
         this.m_bPlaceByUpGradeCard = false;
         if(this.m_stFrozenCardEffect)
         {
            this.m_stFrozenCardEffect.a_3940();
            this.m_stFrozenCardEffect = null;
         }
         this.m_isShihua = false;
         if(this.m_stShiHuaEffect)
         {
            this.m_stShiHuaEffect.a_3940();
            this.m_stShiHuaEffect = null;
         }
         if(this.m_AddFireBuff)
         {
            this.m_AddFireBuff.a_3940();
            this.m_AddFireBuff = null;
         }
         if(this.m_FangyuBuff)
         {
            this.m_FangyuBuff.a_3940();
            this.m_FangyuBuff = null;
         }
         if(this.m_BaseEffect)
         {
            this.m_BaseEffect.a_3940();
            this.m_BaseEffect = null;
         }
         if(Boolean(this.m_stBaseGradeLevel) && Boolean(this.m_stBaseGradeLevel.parent))
         {
            this.m_stBaseGradeLevel.parent.removeChild(this.m_stBaseGradeLevel);
            if(this.a_1334.m_stCurrentBattbleFieldView.GetGameMoveMap())
            {
               this.a_1334.m_stCurrentBattbleFieldView.GetGameMoveMap().RemoveMoveDisplayObject(this.m_stBaseGradeLevel);
            }
            this.m_stBaseGradeLevel = null;
         }
         if(Boolean(this.a_1334) && null != this.m_stShadowRefence)
         {
            stBattleFieldView = this.a_1334.m_stCurrentBattbleFieldView;
            if(this.m_stShadowRefence.parent)
            {
               this.m_stShadowRefence.parent.removeChild(this.m_stShadowRefence);
            }
            this.m_stShadowRefence = null;
         }
         if(this.stFieldGrid != null && this.stFieldGrid.m_stCurrentBattbleFieldView.m_MoveDefense == this)
         {
            this.stFieldGrid.m_stCurrentBattbleFieldView.m_MoveDefense = null;
         }
         if(this.stFieldGrid != null && this.stFieldGrid.m_stCurrentBattbleFieldView.m_OtherMoveDefense == this)
         {
            this.stFieldGrid.m_stCurrentBattbleFieldView.m_OtherMoveDefense = null;
         }
         if(parent)
         {
            parent.removeChild(this);
         }
         if(Boolean(this.a_1334 && this.a_1334.m_stSpaceMarkEffect && this.a_1334.m_stBaseToolDefense == null && this.a_1334.m_stBaseAuxiliaryFighter == null && this.a_1334.m_stFlowerDefense == null && this.a_1334.m_stBoomDefense == null && this.a_1334.m_stTrayDefense == null) && Boolean(this.a_1334.m_stAttackFighter == null) && this.a_1334.m_stProtector == null)
         {
            this.a_1334.m_stSpaceMarkEffect.a_3940();
            this.a_1334.m_stSpaceMarkEffect = null;
         }
         this.stFieldGrid = null;
         visible = false;
         a_1283 = false;
         gotoAndStop(1);
         this.a_1094 = 0;
         if(this.a_1336)
         {
            if(contains(this.a_1336))
            {
               removeChild(this.a_1336);
            }
            this.a_1336.a_3940();
            this.a_1336 = null;
         }
         if(stBattleFieldView)
         {
            stBattleFieldView.SortDisplayObject();
            if(stBattleFieldView.GetGameMoveMap())
            {
               stBattleFieldView.GetGameMoveMap().RemoveMoveDisplayObject(this);
            }
         }
         return true;
      }
      
      public function ReduceDefensePrice(iValue:int) : void
      {
         this.a_1095 += iValue;
      }
      
      public function a_3970() : Boolean
      {
         return false;
      }
      
      public function SpecialSkillCallBack(... args) : void
      {
      }
      
      public function get m_bServerIssued() : Boolean
      {
         if(!this.m_bServerIssuedEx)
         {
            this.m_bServerIssuedEx = new EncrypBooleanEx();
         }
         return this.m_bServerIssuedEx.Value;
      }
      
      public function set m_bServerIssued(value:Boolean) : void
      {
         if(!this.m_bServerIssuedEx)
         {
            this.m_bServerIssuedEx = new EncrypBooleanEx();
         }
         this.m_bServerIssuedEx.Value = value;
      }
      
      public function get m_bPlaceByUpGradeCard() : Boolean
      {
         if(!this.m_bPlaceByUpGradeCardEx)
         {
            this.m_bPlaceByUpGradeCardEx = new EncrypBooleanEx();
         }
         return this.m_bPlaceByUpGradeCardEx.Value;
      }
      
      public function set m_bPlaceByUpGradeCard(value:Boolean) : void
      {
         if(!this.m_bPlaceByUpGradeCardEx)
         {
            this.m_bPlaceByUpGradeCardEx = new EncrypBooleanEx();
         }
         this.m_bPlaceByUpGradeCardEx.Value = value;
      }
      
      private function addFrozenEffect() : void
      {
         if(this.m_stFrozenCardEffect == null)
         {
            this.m_stFrozenCardEffect = FrozenCardEffect.a_3926();
         }
         if(this.m_stFrozenCardEffect)
         {
            this.m_stFrozenCardEffect.a_1797(false);
            this.m_stFrozenCardEffect.x = a_3491.a_1080 * this.a_1334.m_iXGridNo;
            this.m_stFrozenCardEffect.y = a_3491.a_1081 * this.a_1334.m_iYGridNo;
            this.a_1334.m_stCurrentBattbleFieldView.AddToBattleView(this.m_stFrozenCardEffect,BattleLayerDefine.EFFECTS_BASE_TYPE,this.a_1334);
         }
      }
      
      public function AddFangyuBuff(hitTime:int, continueTick:int) : void
      {
         var buff:ImperialStrikeHurtBuff = null;
         var offsetX:Number = NaN;
         if(!this.a_1334 || hitTime <= 0 || continueTick <= 0)
         {
            return;
         }
         this.m_iFangyuTime += hitTime;
         if(!this.m_FangyuBuff)
         {
            buff = ImperialStrikeHurtBuff.a_3926();
            buff.m_BaseDefense = this;
            buff.a_1797(buff.IsReversed());
            buff.AddBuff(continueTick,0);
            offsetX = this.width - 34.25;
            buff.x = this.x + this.iXPosSheft + (this.IsReversed() ? -offsetX : offsetX);
            buff.y = this.y + this.iYPosSheft;
            this.stFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(buff,BattleLayerDefine.OBSTACL_TYPE,this.stFieldGrid);
            this.m_FangyuBuff = buff;
         }
         else
         {
            ImperialStrikeHurtBuff(this.m_FangyuBuff).AddBuff(continueTick,0);
         }
      }
      
      private function CreateShiHuaEffect() : void
      {
         if(this.m_stShiHuaEffect == null)
         {
            this.m_stShiHuaEffect = ShiHuaEffect.a_3926();
         }
         if(this.m_stShiHuaEffect)
         {
            this.m_stShiHuaEffect.a_1797(false);
            this.m_stShiHuaEffect.x = a_3491.a_1080 * this.a_1334.m_iXGridNo;
            this.m_stShiHuaEffect.y = a_3491.a_1081 * this.a_1334.m_iYGridNo - 20;
            this.a_1334.m_stCurrentBattbleFieldView.AddToBattleView(this.m_stShiHuaEffect,BattleLayerDefine.EFFECTS_BASE_TYPE,this.a_1334);
         }
      }
      
      public function get tagCom() : TagComponent
      {
         return this._tagCom;
      }
      
      public function get buffCom() : BuffComponent
      {
         if(this._buffCom == null)
         {
            this._buffCom = new BuffComponent();
            this._buffCom.a_3014(this._tagCom,this);
         }
         return this._buffCom;
      }
      
      public function SetAnimationOnce2Loop(onceIdx:int, loopIdx:int) : void
      {
         a_1275 = loopIdx;
         gotoAndStop((a_1276[onceIdx] as FrameLabel).frame);
      }
   }
}

