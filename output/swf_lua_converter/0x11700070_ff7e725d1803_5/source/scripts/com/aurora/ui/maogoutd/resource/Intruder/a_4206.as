package com.aurora.ui.maogoutd.resource.Intruder
{
   import a_4715.EncrypBooleanEx;
   import a_4715.EncrypIntEx;
   import a_4715.EncrypNumber;
   import a_4715.EncrypUintEx;
   import a_4718.b_181;
   import a_4718.b_182;
   import a_4752.TagComponent;
   import a_4752.a_2036;
   import a_4753.b_150;
   import a_4754.a_2161;
   import com.adobe.utils.RandomSeed;
   import com.aurora.protocol.game.maogoutd.CVanishEnemy;
   import com.aurora.ui.maogoutd.ClientLog.a_4807;
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.BattleLayerDefine;
   import com.aurora.ui.maogoutd.game.Buff.BuffComponent;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import com.aurora.ui.maogoutd.resource.avatar.a_3924;
   import com.aurora.ui.maogoutd.resource.defender.DragonYear.CandleYinDragon.FireBurnBuff;
   import com.aurora.ui.maogoutd.resource.defender.DragonYear.GoldEros.MouseMoveIntruderBatDieEffect;
   import com.aurora.ui.maogoutd.resource.defender.SnakeYear.mageSnake.MageSnakeIntruderPoisonEffect;
   import com.aurora.ui.maogoutd.resource.defender.TigerYear.JiaoTiger.JiaoTigerPoisonShot;
   import com.aurora.ui.maogoutd.resource.defender.a_3962;
   import com.aurora.ui.maogoutd.resource.effect.CharmMouseBoomDie;
   import com.aurora.ui.maogoutd.resource.effect.IntruderMeiHuoEffect;
   import com.aurora.ui.maogoutd.resource.effect.IntruderMianYiEffect;
   import com.aurora.ui.maogoutd.resource.effect.IntruderPoisonGasEffect;
   import com.aurora.ui.maogoutd.resource.effect.IntruderShanDianEffect;
   import com.aurora.ui.maogoutd.resource.effect.VertigoEffect;
   import com.aurora.ui.maogoutd.resource.effect.a_4108;
   import com.aurora.ui.maogoutd.resource.effect.a_4143;
   import com.aurora.ui.maogoutd.resource.shot.a_4348;
   import com.aurora.ui.maogoutd.resource.tools.a_4448;
   import flash.display.FrameLabel;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.text.TextFormatAlign;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class a_4206 extends a_3909
   {
      
      public static var a_1457:int;
      
      public static var a_1088:b_150;
      
      protected static const BOOM_INJURE_LIFE:int = 900;
      
      public static var ms_arrIntruderDataArray:Array = [];
      
      public static var m_iInitTime:EncrypIntEx = new EncrypIntEx(0);
      
      public static var m_iRealeaseTimes:EncrypUintEx = new EncrypUintEx(0);
      
      public static var m_iViewBuffId:int = 0;
      
      private static var m_stRandomSeed:RandomSeed = new RandomSeed();
      
      private static const ms_iMaxNum:int = 20;
      
      public var m_bServerIssued:EncrypBooleanEx = new EncrypBooleanEx(false);
      
      public var m_iDieType:int = 0;
      
      public var m_stFreezeUpEffect:a_4108;
      
      public var m_stXuanYunEffect:VertigoEffect;
      
      public var m_stFireBurnBuff:FireBurnBuff;
      
      public var m_stMianYiEffect:IntruderMianYiEffect;
      
      public var m_stShanDianEffect:IntruderShanDianEffect;
      
      public var m_stPoisonGasEffect:IntruderPoisonGasEffect;
      
      public var m_stSnakePoisonEffect:MageSnakeIntruderPoisonEffect;
      
      public var m_stBBQMasterBurnEffect:a_4108;
      
      public var m_stGoldZBSBaseBurnEffect:a_4108;
      
      public var m_stGoldZBSFirstBurnEffect:a_4108;
      
      public var m_stGoldZBSSecondBurnEffect:a_4108;
      
      public var m_stWuGuSnakeHurtIntruderEffect:a_4108;
      
      public var m_stWaterEffect:a_4448;
      
      public var m_stGeneralPoisonEffect:a_4108;
      
      public var m_stGeneralSnowEffect:a_4108;
      
      public var m_stGeneralBloodEffect:a_4108;
      
      public var m_stGeneralBurnEffect:a_4108;
      
      public var m_stMeiHuoEffect:IntruderMeiHuoEffect;
      
      public var a_1459:int;
      
      public var m_isRemovedFromBattaleField:Boolean;
      
      public var m_lifeValueTxt:TextField = new TextField();
      
      private var m_PoisonHurtPower:Number;
      
      public var m_stGameBattleView:BattleFieldView;
      
      public var m_bPostEnemy:Boolean = true;
      
      public var m_stCurrentFieldGrid:a_3491;
      
      private var m_BruisAttackID:EncrypUintEx = new EncrypUintEx();
      
      private var m_stMoveIntruderTypeIDEx:EncrypIntEx = new EncrypIntEx();
      
      private var m_isShowShandianEx:EncrypBooleanEx = new EncrypBooleanEx(false);
      
      private var m_isLocalIntruderAppeared:EncrypBooleanEx = new EncrypBooleanEx(false);
      
      private var m_isLifeCorrectedEx:EncrypBooleanEx = new EncrypBooleanEx(false);
      
      private var m_isWaterMoveIntruderEx:EncrypBooleanEx = new EncrypBooleanEx(false);
      
      private var m_isHurtByFireFlyEx:EncrypBooleanEx = new EncrypBooleanEx(false);
      
      private var m_ChageMouseYLockedEx:EncrypBooleanEx = new EncrypBooleanEx(false);
      
      private var m_isCannotSeeByFighterEx:EncrypBooleanEx = new EncrypBooleanEx(false);
      
      protected var m_isCannotSeeByInsuranceEx:EncrypBooleanEx;
      
      protected var m_m_isCannotHurtByInsuranceEx:EncrypBooleanEx;
      
      protected var m_isGoHeadNotEatDefenseEx:EncrypBooleanEx;
      
      protected var a_1465:int = 0;
      
      protected var m_iIntruderState:int = 0;
      
      private var m_bBoomIsReduceLife:EncrypBooleanEx;
      
      private var m_IsAirEliteEx:EncrypBooleanEx;
      
      private var m_isCanCharm:EncrypBooleanEx;
      
      private var m_iArmorLifeValueEx:EncrypIntEx;
      
      private var m_iYPosSkewingEx:EncrypIntEx;
      
      private var m_iFreezeUpFrameNumEx:EncrypIntEx;
      
      private var m_iBoundStopFrameNumEx:EncrypIntEx;
      
      private var m_numMoveSpeedFactorEx:EncrypNumber;
      
      private var m_iMoveSpeedEx:EncrypNumber;
      
      private var m_iMoveTimeIntervalNumEx:EncrypIntEx;
      
      private var m_iLastMoveTimeEx:EncrypIntEx;
      
      private var m_iJumpOverTimeEx:EncrypIntEx;
      
      private var m_iClarmLanderTimeEx:EncrypIntEx;
      
      private var m_iMaxClarmLanderTimeEx:EncrypIntEx;
      
      protected var m_bClarmLanderIsNeedParabola:Boolean;
      
      private var m_fClimbWidthTickEx:EncrypNumber;
      
      private var m_fClimbHeightTickEx:EncrypNumber;
      
      private var m_iHideLifeValueEx:EncrypIntEx;
      
      protected var a_1475:Boolean;
      
      private var m_iEatLifeValueEx:EncrypIntEx;
      
      private var m_InitialLifeValueEx:EncrypIntEx;
      
      private var m_iEatTimeIntervalNumEx:EncrypIntEx;
      
      private var m_iLastEatTimeEx:EncrypIntEx;
      
      protected var m_LastPositionX:int;
      
      protected var m_LastPositionY:int;
      
      private var m_numShowNextFrameFactorEx:EncrypNumber;
      
      private var m_SecondDieFrameEx:EncrypIntEx;
      
      private var m_DropDieTypeEx:EncrypIntEx;
      
      private var m_iShowNextFrameTimeIntervalNumEx:EncrypIntEx;
      
      private var m_iChageSpeedNumEx:EncrypIntEx;
      
      protected var a_1480:int = 0;
      
      protected var a_1481:Boolean = true;
      
      private var a_1482:Boolean = false;
      
      private var m_CantBoundStopMouseArr:Array = new Array(8388649,8389221);
      
      private var m_iTargetYGrid:int = 0;
      
      private var m_iMoveYSpeed:Number = 0;
      
      private var m_iMoveYTimes:int = 0;
      
      private var m_MouseArr:Array = new Array(8392723,8389315,8388773,8389220,8389219,8389116,8388743,8388727,8388642,8388627);
      
      protected var _damageParam:Array = new Array();
      
      private var _tagCom:TagComponent = new TagComponent();
      
      private var _buffCom:BuffComponent;
      
      public function a_4206()
      {
         super();
         gotoAndStop(1);
         mouseEnabled = false;
         this.BoomIsReduceLife = false;
         var format:TextFormat = new TextFormat();
         format.size = 14;
         format.color = 16777113;
         format.bold = true;
         format.font = "Arial";
         format.align = TextFormatAlign.LEFT;
         this.m_lifeValueTxt.defaultTextFormat = format;
         this.m_lifeValueTxt.selectable = false;
         this.m_lifeValueTxt.mouseEnabled = false;
         this.m_lifeValueTxt.multiline = true;
         this.m_lifeValueTxt.wordWrap = true;
         this.m_lifeValueTxt.width = 100;
         this.m_lifeValueTxt.height = 35;
         this.m_lifeValueTxt.filters = [new GlowFilter(0,1,2,2,10)];
      }
      
      private static function GetRandInt(iMaxNum:int) : int
      {
         return m_stRandomSeed.nextInt(iMaxNum);
      }
      
      public function get PoisonHurtPower() : Number
      {
         return this.m_PoisonHurtPower;
      }
      
      public function set PoisonHurtPower(value:Number) : void
      {
         this.m_PoisonHurtPower = value;
      }
      
      public function get BruisAttackID() : uint
      {
         return this.m_BruisAttackID.Value;
      }
      
      public function set BruisAttackID(iValue:uint) : void
      {
         this.m_BruisAttackID.Value = iValue;
      }
      
      public function get m_stMoveIntruderTypeID() : int
      {
         return this.m_stMoveIntruderTypeIDEx.Value;
      }
      
      public function set m_stMoveIntruderTypeID(value:int) : void
      {
         this.m_stMoveIntruderTypeIDEx.Value = value;
      }
      
      public function get m_isShowShandian() : Boolean
      {
         return this.m_isShowShandianEx.Value;
      }
      
      public function set m_isShowShandian(value:Boolean) : void
      {
         this.m_isShowShandianEx.Value = value;
         if(value)
         {
            this.a_4208(b_182.enm_shotEffectShanDian,20);
         }
         else if(Boolean(this.m_stShanDianEffect) && this.m_stShanDianEffect.visible)
         {
            this.m_stShanDianEffect.a_3940();
            this.m_stShanDianEffect = null;
         }
      }
      
      protected function get m_isLifeCorrected() : Boolean
      {
         return this.m_isLifeCorrectedEx.Value;
      }
      
      protected function set m_isLifeCorrected(value:Boolean) : void
      {
         this.m_isLifeCorrectedEx.Value = value;
      }
      
      protected function get a_1461() : Boolean
      {
         return this.m_isWaterMoveIntruderEx.Value;
      }
      
      protected function set a_1461(value:Boolean) : void
      {
         this.m_isWaterMoveIntruderEx.Value = value;
      }
      
      public function get m_isHurtByFireFly() : Boolean
      {
         return this.m_isHurtByFireFlyEx.Value;
      }
      
      public function set m_isHurtByFireFly(value:Boolean) : void
      {
         this.m_isHurtByFireFlyEx.Value = value;
      }
      
      public function get m_ChageMouseYLocked() : Boolean
      {
         return this.m_ChageMouseYLockedEx.Value;
      }
      
      public function set m_ChageMouseYLocked(value:Boolean) : void
      {
         this.m_ChageMouseYLockedEx.Value = value;
      }
      
      protected function get a_1462() : Boolean
      {
         return this.m_isCannotSeeByFighterEx.Value;
      }
      
      protected function set a_1462(value:Boolean) : void
      {
         this.m_isCannotSeeByFighterEx.Value = value;
      }
      
      protected function SetCannotSeeByFighter(value:Boolean) : void
      {
         if(this.a_1462 != value)
         {
            if(value)
            {
               if(null != this.m_stCurrentFieldGrid)
               {
                  this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.ReduceRowIntruderNum(this,this.m_stCurrentFieldGrid.m_iYGridNo);
               }
               this.a_1462 = value;
            }
            else
            {
               this.a_1462 = value;
               if(null != this.m_stCurrentFieldGrid)
               {
                  this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddRowIntruderNum(this,this.m_stCurrentFieldGrid.m_iYGridNo);
               }
            }
         }
      }
      
      protected function get a_1463() : Boolean
      {
         if(!this.m_isCannotSeeByInsuranceEx)
         {
            this.m_isCannotSeeByInsuranceEx = new EncrypBooleanEx(false);
         }
         return this.m_isCannotSeeByInsuranceEx.Value;
      }
      
      protected function set a_1463(value:Boolean) : void
      {
         if(!this.m_isCannotSeeByInsuranceEx)
         {
            this.m_isCannotSeeByInsuranceEx = new EncrypBooleanEx(false);
         }
         this.m_isCannotSeeByInsuranceEx.Value = value;
      }
      
      protected function get m_m_isCannotHurtByInsurance() : Boolean
      {
         if(!this.m_m_isCannotHurtByInsuranceEx)
         {
            this.m_m_isCannotHurtByInsuranceEx = new EncrypBooleanEx(false);
         }
         return this.m_m_isCannotHurtByInsuranceEx.Value;
      }
      
      protected function set m_m_isCannotHurtByInsurance(value:Boolean) : void
      {
         if(!this.m_m_isCannotHurtByInsuranceEx)
         {
            this.m_m_isCannotHurtByInsuranceEx = new EncrypBooleanEx(false);
         }
         this.m_m_isCannotHurtByInsuranceEx.Value = value;
      }
      
      protected function get a_1464() : Boolean
      {
         if(this.m_stCurrentFieldGrid != null && this.m_stCurrentFieldGrid.tagCom.HasTag(140))
         {
            return true;
         }
         if(!this.m_isGoHeadNotEatDefenseEx)
         {
            this.m_isGoHeadNotEatDefenseEx = new EncrypBooleanEx(false);
         }
         return this.m_isGoHeadNotEatDefenseEx.Value;
      }
      
      protected function set a_1464(value:Boolean) : void
      {
         if(!this.m_isGoHeadNotEatDefenseEx)
         {
            this.m_isGoHeadNotEatDefenseEx = new EncrypBooleanEx(false);
         }
         this.m_isGoHeadNotEatDefenseEx.Value = value;
      }
      
      protected function get BoomIsReduceLife() : Boolean
      {
         if(!this.m_bBoomIsReduceLife)
         {
            this.m_bBoomIsReduceLife = new EncrypBooleanEx(false);
         }
         return this.m_bBoomIsReduceLife.Value;
      }
      
      protected function set BoomIsReduceLife(bValue:Boolean) : void
      {
         if(!this.m_bBoomIsReduceLife)
         {
            this.m_bBoomIsReduceLife = new EncrypBooleanEx(false);
         }
         this.m_bBoomIsReduceLife.Value = bValue;
      }
      
      public function get m_IsAirElite() : Boolean
      {
         if(!this.m_IsAirEliteEx)
         {
            this.m_IsAirEliteEx = new EncrypBooleanEx(false);
         }
         return this.m_IsAirEliteEx.Value;
      }
      
      public function set m_IsAirElite(bValue:Boolean) : void
      {
         if(!this.m_IsAirEliteEx)
         {
            this.m_IsAirEliteEx = new EncrypBooleanEx(false);
         }
         this.m_IsAirEliteEx.Value = bValue;
      }
      
      public function get CanCharm() : Boolean
      {
         if(!this.m_isCanCharm)
         {
            this.m_isCanCharm = new EncrypBooleanEx(true);
         }
         return this.m_isCanCharm.Value;
      }
      
      public function set CanCharm(bValue:Boolean) : void
      {
         if(!this.m_isCanCharm)
         {
            this.m_isCanCharm = new EncrypBooleanEx(true);
         }
         this.m_isCanCharm.Value = bValue;
      }
      
      protected function get a_1466() : int
      {
         if(!this.m_iArmorLifeValueEx)
         {
            this.m_iArmorLifeValueEx = new EncrypIntEx();
         }
         return this.m_iArmorLifeValueEx.Value;
      }
      
      protected function set a_1466(value:int) : void
      {
         if(!this.m_iArmorLifeValueEx)
         {
            this.m_iArmorLifeValueEx = new EncrypIntEx();
         }
         this.m_iArmorLifeValueEx.Value = value;
      }
      
      protected function get a_1467() : int
      {
         if(!this.m_iYPosSkewingEx)
         {
            this.m_iYPosSkewingEx = new EncrypIntEx();
         }
         return this.m_iYPosSkewingEx.Value;
      }
      
      protected function set a_1467(value:int) : void
      {
         if(!this.m_iYPosSkewingEx)
         {
            this.m_iYPosSkewingEx = new EncrypIntEx();
         }
         this.m_iYPosSkewingEx.Value = value;
      }
      
      protected function get a_1468() : int
      {
         if(!this.m_iFreezeUpFrameNumEx)
         {
            this.m_iFreezeUpFrameNumEx = new EncrypIntEx(0);
         }
         return this.m_iFreezeUpFrameNumEx.Value;
      }
      
      protected function set a_1468(value:int) : void
      {
         if(!this.m_iFreezeUpFrameNumEx)
         {
            this.m_iFreezeUpFrameNumEx = new EncrypIntEx(0);
         }
         this.m_iFreezeUpFrameNumEx.Value = value;
      }
      
      protected function get a_1469() : int
      {
         if(!this.m_iBoundStopFrameNumEx)
         {
            this.m_iBoundStopFrameNumEx = new EncrypIntEx(0);
         }
         return this.m_iBoundStopFrameNumEx.Value;
      }
      
      protected function set a_1469(value:int) : void
      {
         if(!this.m_iBoundStopFrameNumEx)
         {
            this.m_iBoundStopFrameNumEx = new EncrypIntEx(0);
         }
         this.m_iBoundStopFrameNumEx.Value = value;
      }
      
      protected function get a_1470() : Number
      {
         if(!this.m_numMoveSpeedFactorEx)
         {
            this.m_numMoveSpeedFactorEx = new EncrypNumber(1);
         }
         return this.m_numMoveSpeedFactorEx.Value * this.AccelerationEffectValue;
      }
      
      protected function get AccelerationEffectValue() : Number
      {
         if(null != this.m_stCurrentFieldGrid && this.m_stCurrentFieldGrid.IsHasAcceleration && (0 == this.a_1465 || 2 == this.a_1465))
         {
            return 2;
         }
         return 1;
      }
      
      protected function set a_1470(value:Number) : void
      {
         if(!this.m_numMoveSpeedFactorEx)
         {
            this.m_numMoveSpeedFactorEx = new EncrypNumber(1);
         }
         this.m_numMoveSpeedFactorEx.Value = value;
      }
      
      protected function get a_1350() : Number
      {
         if(!this.m_iMoveSpeedEx)
         {
            this.m_iMoveSpeedEx = new EncrypNumber(0);
         }
         return this.m_iMoveSpeedEx.Value;
      }
      
      protected function set a_1350(value:Number) : void
      {
         if(!this.m_iMoveSpeedEx)
         {
            this.m_iMoveSpeedEx = new EncrypNumber(0);
         }
         this.m_iMoveSpeedEx.Value = value;
      }
      
      protected function get a_1471() : int
      {
         if(!this.m_iMoveTimeIntervalNumEx)
         {
            this.m_iMoveTimeIntervalNumEx = new EncrypIntEx(1);
         }
         return this.m_iMoveTimeIntervalNumEx.Value;
      }
      
      protected function set a_1471(value:int) : void
      {
         if(!this.m_iMoveTimeIntervalNumEx)
         {
            this.m_iMoveTimeIntervalNumEx = new EncrypIntEx(1);
         }
         this.m_iMoveTimeIntervalNumEx.Value = value;
      }
      
      protected function get a_1472() : int
      {
         if(!this.m_iLastMoveTimeEx)
         {
            this.m_iLastMoveTimeEx = new EncrypIntEx(0);
         }
         return this.m_iLastMoveTimeEx.Value;
      }
      
      protected function set a_1472(value:int) : void
      {
         if(!this.m_iLastMoveTimeEx)
         {
            this.m_iLastMoveTimeEx = new EncrypIntEx(0);
         }
         this.m_iLastMoveTimeEx.Value = value;
      }
      
      protected function get a_1473() : int
      {
         if(!this.m_iJumpOverTimeEx)
         {
            this.m_iJumpOverTimeEx = new EncrypIntEx(0);
         }
         return this.m_iJumpOverTimeEx.Value;
      }
      
      protected function set a_1473(value:int) : void
      {
         if(!this.m_iJumpOverTimeEx)
         {
            this.m_iJumpOverTimeEx = new EncrypIntEx(0);
         }
         this.m_iJumpOverTimeEx.Value = value;
      }
      
      protected function get a_1474() : int
      {
         if(!this.m_iClarmLanderTimeEx)
         {
            this.m_iClarmLanderTimeEx = new EncrypIntEx(0);
         }
         return this.m_iClarmLanderTimeEx.Value;
      }
      
      protected function set a_1474(value:int) : void
      {
         if(!this.m_iClarmLanderTimeEx)
         {
            this.m_iClarmLanderTimeEx = new EncrypIntEx(0);
         }
         this.m_iClarmLanderTimeEx.Value = value;
      }
      
      protected function get m_iMaxClarmLanderTime() : int
      {
         if(!this.m_iMaxClarmLanderTimeEx)
         {
            this.m_iMaxClarmLanderTimeEx = new EncrypIntEx(20);
         }
         return this.m_iMaxClarmLanderTimeEx.Value;
      }
      
      protected function set m_iMaxClarmLanderTime(value:int) : void
      {
         if(!this.m_iMaxClarmLanderTimeEx)
         {
            this.m_iMaxClarmLanderTimeEx = new EncrypIntEx(20);
         }
         this.m_iMaxClarmLanderTimeEx.Value = value;
      }
      
      protected function get m_fClimbWidthTick() : Number
      {
         if(!this.m_fClimbWidthTickEx)
         {
            this.m_fClimbWidthTickEx = new EncrypNumber(1);
         }
         return this.m_fClimbWidthTickEx.Value;
      }
      
      protected function set m_fClimbWidthTick(fValue:Number) : void
      {
         if(!this.m_fClimbWidthTickEx)
         {
            this.m_fClimbWidthTickEx = new EncrypNumber(1);
         }
         this.m_fClimbWidthTickEx.Value = fValue;
      }
      
      protected function get m_fClimbHeightTick() : Number
      {
         if(!this.m_fClimbHeightTickEx)
         {
            this.m_fClimbHeightTickEx = new EncrypNumber(6);
         }
         return this.m_fClimbHeightTickEx.Value;
      }
      
      protected function set m_fClimbHeightTick(fValue:Number) : void
      {
         if(!this.m_fClimbHeightTickEx)
         {
            this.m_fClimbHeightTickEx = new EncrypNumber(6);
         }
         this.m_fClimbHeightTickEx.Value = fValue;
      }
      
      protected function get a_1377() : int
      {
         if(!this.m_iEatLifeValueEx)
         {
            this.m_iEatLifeValueEx = new EncrypIntEx(10);
         }
         return this.m_iEatLifeValueEx.Value;
      }
      
      protected function set a_1377(value:int) : void
      {
         if(!this.m_iEatLifeValueEx)
         {
            this.m_iEatLifeValueEx = new EncrypIntEx(10);
         }
         this.m_iEatLifeValueEx.Value = value;
      }
      
      protected function get m_InitialLifeValue() : int
      {
         if(!this.m_InitialLifeValueEx)
         {
            this.m_InitialLifeValueEx = new EncrypIntEx(10);
         }
         return this.m_InitialLifeValueEx.Value;
      }
      
      protected function set m_InitialLifeValue(value:int) : void
      {
         if(!this.m_InitialLifeValueEx)
         {
            this.m_InitialLifeValueEx = new EncrypIntEx(10);
         }
         this.m_InitialLifeValueEx.Value = value;
      }
      
      protected function get a_1476() : int
      {
         if(!this.m_iEatTimeIntervalNumEx)
         {
            this.m_iEatTimeIntervalNumEx = new EncrypIntEx(12);
         }
         return this.m_iEatTimeIntervalNumEx.Value;
      }
      
      protected function set a_1476(value:int) : void
      {
         if(!this.m_iEatTimeIntervalNumEx)
         {
            this.m_iEatTimeIntervalNumEx = new EncrypIntEx(12);
         }
         this.m_iEatTimeIntervalNumEx.Value = value;
      }
      
      protected function get a_1477() : int
      {
         if(!this.m_iLastEatTimeEx)
         {
            this.m_iLastEatTimeEx = new EncrypIntEx(0);
         }
         return this.m_iLastEatTimeEx.Value;
      }
      
      protected function set a_1477(value:int) : void
      {
         if(!this.m_iLastEatTimeEx)
         {
            this.m_iLastEatTimeEx = new EncrypIntEx(0);
         }
         this.m_iLastEatTimeEx.Value = value;
      }
      
      protected function get a_1478() : Number
      {
         if(!this.m_numShowNextFrameFactorEx)
         {
            this.m_numShowNextFrameFactorEx = new EncrypNumber(1);
         }
         return this.m_numShowNextFrameFactorEx.Value;
      }
      
      protected function set a_1478(value:Number) : void
      {
         if(!this.m_numShowNextFrameFactorEx)
         {
            this.m_numShowNextFrameFactorEx = new EncrypNumber(1);
         }
         this.m_numShowNextFrameFactorEx.Value = value;
      }
      
      protected function get m_SecondDieFrame() : int
      {
         if(!this.m_SecondDieFrameEx)
         {
            this.m_SecondDieFrameEx = new EncrypIntEx(0);
         }
         return this.m_SecondDieFrameEx.Value;
      }
      
      protected function set m_SecondDieFrame(value:int) : void
      {
         if(!this.m_SecondDieFrameEx)
         {
            this.m_SecondDieFrameEx = new EncrypIntEx(0);
         }
         this.m_SecondDieFrameEx.Value = value;
      }
      
      public function get m_DropDieType() : int
      {
         if(!this.m_DropDieTypeEx)
         {
            this.m_DropDieTypeEx = new EncrypIntEx(0);
         }
         return this.m_DropDieTypeEx.Value;
      }
      
      public function set m_DropDieType(value:int) : void
      {
         if(!this.m_DropDieTypeEx)
         {
            this.m_DropDieTypeEx = new EncrypIntEx(0);
         }
         this.m_DropDieTypeEx.Value = value;
      }
      
      protected function get a_1479() : int
      {
         if(!this.m_iShowNextFrameTimeIntervalNumEx)
         {
            this.m_iShowNextFrameTimeIntervalNumEx = new EncrypIntEx(2);
         }
         return this.m_iShowNextFrameTimeIntervalNumEx.Value;
      }
      
      protected function set a_1479(value:int) : void
      {
         if(!this.m_iShowNextFrameTimeIntervalNumEx)
         {
            this.m_iShowNextFrameTimeIntervalNumEx = new EncrypIntEx(2);
         }
         this.m_iShowNextFrameTimeIntervalNumEx.Value = value;
      }
      
      protected function get m_iChageSpeedNum() : int
      {
         if(!this.m_iChageSpeedNumEx)
         {
            this.m_iChageSpeedNumEx = new EncrypIntEx(0);
         }
         return this.m_iChageSpeedNumEx.Value;
      }
      
      protected function set m_iChageSpeedNum(value:int) : void
      {
         if(!this.m_iChageSpeedNumEx)
         {
            this.m_iChageSpeedNumEx = new EncrypIntEx(0);
         }
         this.m_iChageSpeedNumEx.Value = value;
      }
      
      public function get numHardRate() : Number
      {
         return 1;
      }
      
      public function set numHardRate(value:Number) : void
      {
      }
      
      protected function get a_1460() : Boolean
      {
         return this.m_isLocalIntruderAppeared.Value;
      }
      
      protected function set a_1460(value:Boolean) : void
      {
         var iMapID:int = 0;
         var byGameMode:int = 0;
         var iMouseID:int = 0;
         var iOldValue:int = 0;
         this.m_isLocalIntruderAppeared.Value = value;
         if(Boolean(value && root) && Boolean(root.hasOwnProperty("m_stGameData")) && Boolean((root as Object).m_stGameData))
         {
            iMapID = int((root as Object).m_stGameData["iMapID"]);
            byGameMode = int((root as Object).m_stGameData["byGameMode"]);
            iMouseID = this.m_stMoveIntruderTypeID - 8388608;
            if(Boolean(ms_arrIntruderDataArray[iMouseID]) && ms_arrIntruderDataArray[iMouseID]["Life"] > 0)
            {
               this.a_1339 = ms_arrIntruderDataArray[iMouseID]["Life"];
            }
            if(Boolean(ms_arrIntruderDataArray[iMouseID]) && Boolean(ms_arrIntruderDataArray[iMouseID][iMapID]) && ms_arrIntruderDataArray[iMouseID][iMapID][byGameMode] > 0)
            {
               this.numHardRate = ms_arrIntruderDataArray[iMouseID][iMapID][byGameMode] / 15000;
               if(1 == this.numHardRate)
               {
                  this.a_1339 = ms_arrIntruderDataArray[iMouseID][iMapID][byGameMode];
               }
               else if(this.numHardRate > 1)
               {
                  this.a_1339 *= this.numHardRate;
               }
            }
            if((iMapID & 0xF0000000) == 1879048192 && this.m_bServerIssued.Value == true)
            {
               iOldValue = this.a_1339;
               this.GetWorldBossAdd();
               this.numHardRate *= this.a_1339 / iOldValue;
            }
            this.m_InitialLifeValue = this.a_1339;
         }
      }
      
      private function GetWorldBossAdd() : void
      {
         var cfg:Object = a_2161.e.getCurDuanweiQualityCfg();
         if(cfg != null)
         {
            if(this.IsBossIntruder)
            {
               this.a_1339 *= 1 + Number(cfg.bossBloodPer) / 100;
               this.a_1339 += cfg.bossBloodAdd;
            }
            else
            {
               this.a_1339 *= 1 + Number(cfg.normalMouseBloodPer) / 100;
               this.a_1339 += cfg.normalMouseBloodAdd;
            }
         }
      }
      
      public function get isFearCatHead() : Boolean
      {
         return this.a_1481;
      }
      
      public function get isCannotSeeByInsurance() : Boolean
      {
         return this.a_1463;
      }
      
      public function get isCannotHurtByInsurance() : Boolean
      {
         return this.m_m_isCannotHurtByInsurance;
      }
      
      public function get isGoHeadNotEatDefense() : Boolean
      {
         return this.a_1464;
      }
      
      public function get iSpaceState() : int
      {
         return this.a_1465;
      }
      
      public function get iIntruderState() : int
      {
         return this.m_iIntruderState;
      }
      
      public function get iBoundStop() : Boolean
      {
         if(this.a_1469 > 0)
         {
            return true;
         }
         return false;
      }
      
      public function get iBoomIsReduceLife() : Boolean
      {
         return this.BoomIsReduceLife;
      }
      
      protected function get a_1339() : int
      {
         if(!this.m_iHideLifeValueEx)
         {
            this.m_iHideLifeValueEx = new EncrypIntEx(100);
         }
         return this.m_iHideLifeValueEx.Value;
      }
      
      public function get isCannotSeeByFighter() : Boolean
      {
         return this.a_1462;
      }
      
      public function get iLifeValue() : int
      {
         if(!this.m_iHideLifeValueEx)
         {
            this.m_iHideLifeValueEx = new EncrypIntEx(100);
         }
         return this.m_iHideLifeValueEx.Value;
      }
      
      public function get iArmorLifeValue() : int
      {
         return this.a_1466;
      }
      
      public function get iInitialLifeValue() : int
      {
         return this.m_InitialLifeValue;
      }
      
      protected function set a_1339(value:int) : void
      {
         if(!this.m_iHideLifeValueEx)
         {
            this.m_iHideLifeValueEx = new EncrypIntEx(100);
         }
         this.m_iHideLifeValueEx.Value = value;
         if(this.m_lifeValueTxt != null)
         {
            this.m_lifeValueTxt.text = "体力:" + this.m_iHideLifeValueEx.Value.toString();
         }
      }
      
      public function set iDIYLife(value:int) : void
      {
         this.a_1339 = value;
         this.m_InitialLifeValue = value;
      }
      
      public function set InitAppearedLife(value:Boolean) : void
      {
      }
      
      public function get isEatingDefense() : Boolean
      {
         return this.a_1475;
      }
      
      public function get iYPosSkewing() : int
      {
         return this.a_1467;
      }
      
      public function OnPreInit(battleView:BattleFieldView, addedMoveIntruder:a_4269) : void
      {
      }
      
      public function a_1797(iGlobalMoveFighterID:int, iIntruderMoveDirection:int) : Boolean
      {
         if(m_iInitTime.Value == 0)
         {
            m_iInitTime.Value = getTimer();
         }
         this.m_InitialLifeValue = 0;
         this.a_1460 = false;
         this.m_isLifeCorrected = false;
         this.a_1472 = 0;
         this.a_1473 = 0;
         this.a_1474 = 0;
         this.m_bClarmLanderIsNeedParabola = false;
         this.a_1475 = false;
         this.a_1477 = 0;
         this.m_SecondDieFrame = a_1274;
         this.m_DropDieType = 0;
         this.a_1480 = 0;
         this.m_isRemovedFromBattaleField = false;
         this.a_1464 = false;
         this.m_isShowShandian = false;
         this.a_1459 = iGlobalMoveFighterID;
         this.m_LastPositionX = this.m_LastPositionY = 0;
         if(iIntruderMoveDirection < 0)
         {
            a_1283 = false;
         }
         else
         {
            a_1283 = true;
         }
         this.m_iDieType = 0;
         this.a_1470 = 1;
         this.a_1478 = 1;
         a_1285 = 0;
         this.a_1468 = 0;
         this.a_1469 = 0;
         a_1284 = 0;
         m_iFireHurtFrameNum = 0;
         this.m_iChageSpeedNum = 0;
         gotoAndStop(1);
         a_1275 = 0;
         m_iCharmlevel = 0;
         this.m_isHurtByFireFly = false;
         this.m_ChageMouseYLocked = false;
         this.CanCharm = true;
         this.PoisonHurtPower = 0;
         this.BruisAttackID = 0;
         visible = true;
         this.play();
         return true;
      }
      
      public function get globalMoveFighterID() : int
      {
         return this.a_1459;
      }
      
      public function set iGlobalMoveFighterID(value:int) : void
      {
         this.a_1459 = value;
      }
      
      public function a_3432() : void
      {
         this.a_3940();
      }
      
      protected function a_3940() : Boolean
      {
         var stEnemyVanish:CVanishEnemy = null;
         var arrBaseMoveIntruderVector:Array = null;
         if(this.m_bServerIssued.Value && this.m_iHideLifeValueEx.Value > 0)
         {
            if(getTimer() - m_iInitTime.Value < 10000)
            {
               m_iRealeaseTimes.Value += 2;
            }
            else
            {
               ++m_iRealeaseTimes.Value;
            }
            if(m_iRealeaseTimes.Value > 14)
            {
            }
         }
         else
         {
            m_iInitTime.Value = getTimer();
            if(m_iRealeaseTimes.Value < 2)
            {
               m_iRealeaseTimes.Value = 0;
            }
            else
            {
               m_iRealeaseTimes.Value -= 2;
            }
         }
         this.m_iDieType = 0;
         a_4807.Get().ShowLog("times:" + m_iRealeaseTimes.Value + " m_iLifeValue:" + this.a_1339 + " m_iH:" + this.m_iHideLifeValueEx.Value);
         if(this.m_bPostEnemy == true && Boolean(a_1088))
         {
            if(this.m_stCurrentFieldGrid)
            {
               stEnemyVanish = new CVanishEnemy();
               stEnemyVanish.m_iEnemyID = this.a_1459;
               stEnemyVanish.m_iEnemyTypeID = this.m_stMoveIntruderTypeID - 8388608;
               stEnemyVanish.m_byYGridNo = this.m_stCurrentFieldGrid.m_iYGridNo;
               stEnemyVanish.m_byXGridNo = this.m_stCurrentFieldGrid.m_iXGridNo;
               a_1088.a_2061(this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.iTimeIntervalNum,this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.m_byTeamNo,[stEnemyVanish]);
            }
         }
         if(this.m_stCurrentFieldGrid)
         {
            this.m_stCurrentFieldGrid.a_3457(this);
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
            arrBaseMoveIntruderVector = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.m_arrBaseMoveIntruderVector;
            if(-1 != arrBaseMoveIntruderVector.indexOf(this))
            {
               arrBaseMoveIntruderVector.splice(arrBaseMoveIntruderVector.indexOf(this),1);
            }
         }
         this.PoisonHurtPower = 0;
         this.BruisAttackID = 0;
         this.RealeaseFollowEffect();
         this.a_1468 = 0;
         this.a_1469 = 0;
         m_iImmuneFrameNum = 0;
         if(this.m_lifeValueTxt != null && this.m_lifeValueTxt.parent != null)
         {
            this.m_lifeValueTxt.parent.removeChild(this.m_lifeValueTxt);
         }
         if(Boolean(parent) && parent.contains(this))
         {
            parent.removeChild(this);
         }
         visible = false;
         gotoAndStop(1);
         this.m_stCurrentFieldGrid = null;
         this.m_iMoveYTimes = this.m_iMoveYSpeed = 0;
         this.a_1462 = false;
         this.stop();
         this.m_bServerIssued.Value = false;
         this.m_ChageMouseYLocked = false;
         this.CanCharm = false;
         this.tagCom.ClearAll();
         this.buffCom.ClearAll();
         return true;
      }
      
      public function UpdateFollowEffect() : void
      {
         if(this.m_stMianYiEffect != null)
         {
            this.m_stMianYiEffect.x = x + 0.5 * (width - this.m_stMianYiEffect.width) + stDisplayBitmap.x - 20;
            this.m_stMianYiEffect.y = y + this.m_stMianYiEffect.height + stDisplayBitmap.y - 50;
         }
         if(this.m_stShanDianEffect != null)
         {
            this.m_stShanDianEffect.x = x + 0.5 * (width - this.m_stShanDianEffect.width) + stDisplayBitmap.x - 20;
            this.m_stShanDianEffect.y = y + 0.5 * (height - this.m_stShanDianEffect.height) + stDisplayBitmap.y;
         }
         if(this.m_stPoisonGasEffect != null)
         {
            this.m_stPoisonGasEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stPoisonGasEffect.y = y + stDisplayBitmap.y;
         }
         if(this.m_stSnakePoisonEffect != null)
         {
            this.m_stSnakePoisonEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stSnakePoisonEffect.y = y + stDisplayBitmap.y;
         }
         if(this.m_stBBQMasterBurnEffect != null)
         {
            this.m_stBBQMasterBurnEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stBBQMasterBurnEffect.y = y + stDisplayBitmap.y;
         }
         if(this.m_stGoldZBSBaseBurnEffect != null)
         {
            this.m_stGoldZBSBaseBurnEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stGoldZBSBaseBurnEffect.y = y + stDisplayBitmap.y;
         }
         if(this.m_stGoldZBSFirstBurnEffect != null)
         {
            this.m_stGoldZBSFirstBurnEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stGoldZBSFirstBurnEffect.y = y + stDisplayBitmap.y;
         }
         if(this.m_stGoldZBSSecondBurnEffect != null)
         {
            this.m_stGoldZBSSecondBurnEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stGoldZBSSecondBurnEffect.y = y + stDisplayBitmap.y;
         }
         if(this.m_stGeneralPoisonEffect != null)
         {
            this.m_stGeneralPoisonEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stGeneralPoisonEffect.y = y + stDisplayBitmap.y;
         }
         if(this.m_stGeneralSnowEffect != null)
         {
            this.m_stGeneralSnowEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stGeneralSnowEffect.y = y + stDisplayBitmap.y;
         }
         if(this.m_stGeneralBloodEffect != null)
         {
            this.m_stGeneralBloodEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stGeneralBloodEffect.y = y + stDisplayBitmap.y;
         }
         if(this.m_stGeneralBurnEffect != null)
         {
            this.m_stGeneralBurnEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stGeneralBurnEffect.y = y + stDisplayBitmap.y;
         }
      }
      
      public function RealeaseFollowEffect(exceptWuGuSnakeHurt:Boolean = false) : void
      {
         if(Boolean(this.m_stFreezeUpEffect) && this.m_stFreezeUpEffect.visible)
         {
            this.m_stFreezeUpEffect.a_3940();
            this.m_stFreezeUpEffect = null;
         }
         if(Boolean(this.m_stXuanYunEffect) && this.m_stXuanYunEffect.visible)
         {
            this.m_stXuanYunEffect.a_3940();
            this.m_stXuanYunEffect = null;
         }
         if(Boolean(this.m_stFireBurnBuff) && this.m_stFireBurnBuff.visible)
         {
            this.m_stFireBurnBuff.a_3940();
            this.m_stFireBurnBuff = null;
         }
         if(Boolean(this.m_stMianYiEffect) && this.m_stMianYiEffect.visible)
         {
            this.m_stMianYiEffect.a_3940();
            this.m_stMianYiEffect = null;
         }
         if(Boolean(this.m_stShanDianEffect) && this.m_stShanDianEffect.visible)
         {
            this.m_stShanDianEffect.a_3940();
            this.m_stShanDianEffect = null;
         }
         if(Boolean(this.m_stPoisonGasEffect) && this.m_stPoisonGasEffect.visible)
         {
            this.m_stPoisonGasEffect.a_3940();
            this.m_stPoisonGasEffect = null;
         }
         if(Boolean(this.m_stSnakePoisonEffect) && this.m_stSnakePoisonEffect.visible)
         {
            this.m_stSnakePoisonEffect.a_3940();
            this.m_stSnakePoisonEffect = null;
         }
         if(Boolean(this.m_stBBQMasterBurnEffect) && this.m_stBBQMasterBurnEffect.visible)
         {
            this.m_stBBQMasterBurnEffect.a_3940();
            this.m_stBBQMasterBurnEffect = null;
         }
         if(Boolean(this.m_stGoldZBSBaseBurnEffect) && this.m_stGoldZBSBaseBurnEffect.visible)
         {
            this.m_stGoldZBSBaseBurnEffect.a_3940();
            this.m_stGoldZBSBaseBurnEffect = null;
         }
         if(Boolean(this.m_stGoldZBSFirstBurnEffect) && this.m_stGoldZBSFirstBurnEffect.visible)
         {
            this.m_stGoldZBSFirstBurnEffect.a_3940();
            this.m_stGoldZBSFirstBurnEffect = null;
         }
         if(Boolean(this.m_stGoldZBSSecondBurnEffect) && this.m_stGoldZBSSecondBurnEffect.visible)
         {
            this.m_stGoldZBSSecondBurnEffect.a_3940();
            this.m_stGoldZBSSecondBurnEffect = null;
         }
         if(Boolean(this.m_stGeneralSnowEffect) && this.m_stGeneralSnowEffect.visible)
         {
            this.m_stGeneralSnowEffect.a_3940();
            this.m_stGeneralSnowEffect = null;
         }
         if(Boolean(this.m_stGeneralBloodEffect) && this.m_stGeneralBloodEffect.visible)
         {
            this.m_stGeneralBloodEffect.a_3940();
            this.m_stGeneralBloodEffect = null;
         }
         if(Boolean(this.m_stGeneralBurnEffect) && this.m_stGeneralBurnEffect.visible)
         {
            this.m_stGeneralBurnEffect.a_3940();
            this.m_stGeneralBurnEffect = null;
         }
         if(this.m_stMeiHuoEffect)
         {
            this.m_stMeiHuoEffect.a_3940();
            this.m_stMeiHuoEffect = null;
         }
         if(Boolean(this.m_stWuGuSnakeHurtIntruderEffect) && !exceptWuGuSnakeHurt)
         {
            this.m_stWuGuSnakeHurtIntruderEffect.a_3940();
            this.m_stWuGuSnakeHurtIntruderEffect = null;
         }
         this.m_stWaterEffect = null;
      }
      
      public function ResetEffect() : void
      {
         this.RealeaseFollowEffect();
         this.a_1470 = 1;
         this.a_1478 = 1;
         a_1285 = 0;
         this.a_1468 = 0;
         this.a_1469 = 0;
         a_1284 = 0;
         m_iFireHurtFrameNum = 0;
         this.m_iChageSpeedNum = 0;
      }
      
      protected function ResetMovieStatus() : Boolean
      {
         return false;
      }
      
      public function a_4207() : void
      {
      }
      
      public function PickEnergyPower(energy:int) : void
      {
      }
      
      public function HideSkill(boo:Boolean) : void
      {
      }
      
      public function SpecialSkillCallBack(... args) : void
      {
      }
      
      public function ChaneSpeed(m_speedF:int, m_iTime:int) : void
      {
         var baseSpeed:Number = Math.abs(this.a_1350 / 0.5);
         this.a_1470 = m_speedF / baseSpeed;
         this.m_iChageSpeedNum = m_iTime;
      }
      
      public function a_4208(iEffectType:int, iEffectTime:int, stBaseEffect:a_4108 = null) : void
      {
         if(this.m_stCurrentFieldGrid == null)
         {
            return;
         }
         if(iEffectType == b_182.enm_shotEffectImmune)
         {
            if(iEffectTime > m_iImmuneFrameNum && this.a_1339 > 0)
            {
               m_iImmuneFrameNum = iEffectTime;
               this.a_1468 = 0;
               this.a_1469 = 0;
               a_1285 = 0;
               if(this.a_1470 < 1)
               {
                  this.a_1470 = 1;
               }
            }
            if(this.m_stMianYiEffect == null)
            {
               this.m_stMianYiEffect = IntruderMianYiEffect.a_3926();
               this.m_stMianYiEffect.a_1797(a_1283);
               this.m_stMianYiEffect.x = x + 0.5 * (width - this.m_stMianYiEffect.width) + stDisplayBitmap.x - 20;
               this.m_stMianYiEffect.y = y + this.m_stMianYiEffect.height + stDisplayBitmap.y - 50;
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(this.m_stMianYiEffect,BattleLayerDefine.EFFECTS_TOP_TYPE,this.m_stCurrentFieldGrid);
            }
         }
         else if(m_iImmuneFrameNum > 0)
         {
            if(iEffectType == b_182.a_433 || iEffectType == b_182.a_434 || iEffectType == b_182.enm_shotEffectXuanYun)
            {
               return;
            }
         }
         else if(iEffectType == b_182.enm_shotEffectPoisonGas)
         {
            if(this.m_stPoisonGasEffect == null && this.m_stCurrentFieldGrid != null && this.a_1339 > 0)
            {
               this.m_stPoisonGasEffect = IntruderPoisonGasEffect.a_3926();
               this.m_stPoisonGasEffect.stTargetIntruder = this;
               this.m_stPoisonGasEffect.WaitTime = iEffectTime;
               this.m_stPoisonGasEffect.a_1797(a_1283,1,this.PoisonHurtPower);
               this.m_stPoisonGasEffect.x = x + 0.5 * width + stDisplayBitmap.x;
               this.m_stPoisonGasEffect.y = y + stDisplayBitmap.y;
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(this.m_stPoisonGasEffect,BattleLayerDefine.EFFECTS_TOP_TYPE,this.m_stCurrentFieldGrid);
            }
         }
         else if(b_182.enm_shotEffectShanDian == iEffectType)
         {
            if(this.m_stShanDianEffect == null && this.m_stCurrentFieldGrid != null)
            {
               this.m_stShanDianEffect = IntruderShanDianEffect.a_3926();
               this.m_stShanDianEffect.a_1797(a_1283);
               this.m_stShanDianEffect.x = x + 0.5 * (width - this.m_stShanDianEffect.width) + stDisplayBitmap.x - 20;
               this.m_stShanDianEffect.y = y + 0.5 * (height - this.m_stShanDianEffect.height) + stDisplayBitmap.y;
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(this.m_stShanDianEffect,BattleLayerDefine.EFFECTS_TOP_TYPE,this.m_stCurrentFieldGrid);
            }
         }
         else if(b_182.a_432 == iEffectType)
         {
            a_1284 = iEffectTime;
         }
         else if(b_182.a_433 == iEffectType)
         {
            a_1284 = 1;
            if(iEffectTime > a_1285)
            {
               a_1285 = iEffectTime;
               this.a_1470 = 0.5;
               this.a_1478 = 1.5;
            }
            else if(0 == iEffectTime)
            {
               a_1285 = 0;
            }
         }
         else if(b_182.enm_shotEffectFreezeStop == iEffectType)
         {
            if(iEffectTime > this.a_1469 && this.a_1339 > 0)
            {
               this.a_1469 = iEffectTime;
            }
            if(stDisplayBitmap)
            {
               stDisplayBitmap.transform.colorTransform = a_1261;
            }
         }
         else if(b_182.a_434 == iEffectType)
         {
            if(0 == this.a_1468 && iEffectTime > 0)
            {
               if(stDisplayBitmap)
               {
                  stDisplayBitmap.transform.colorTransform = a_1261;
               }
               if(Boolean(this.m_stFreezeUpEffect) && this.m_stFreezeUpEffect.visible)
               {
                  this.m_stFreezeUpEffect.a_3940();
                  this.m_stFreezeUpEffect = null;
               }
               if(stBaseEffect)
               {
                  this.m_stFreezeUpEffect = stBaseEffect;
                  this.m_stFreezeUpEffect.a_1797(a_1283);
                  this.m_stFreezeUpEffect.x = x + 0.5 * (width - this.m_stFreezeUpEffect.width) + stDisplayBitmap.x;
                  this.m_stFreezeUpEffect.y = y + (height - this.m_stFreezeUpEffect.height) + stDisplayBitmap.y;
                  this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(this.m_stFreezeUpEffect,BattleLayerDefine.EFFECT_LAYER_TRAY_BOTTOM_TYPE,this.m_stCurrentFieldGrid);
               }
            }
            if(iEffectTime > this.a_1468)
            {
               this.a_1468 = iEffectTime;
            }
         }
         else if(b_182.a_435 == iEffectType)
         {
            if(iEffectTime > this.a_1469 && this.a_1339 > 0 && this.m_CantBoundStopMouseArr.indexOf(this.m_stMoveIntruderTypeID) == -1)
            {
               this.a_1469 = iEffectTime;
               this.a_1478 = 0;
               this.a_1470 = 0;
            }
         }
         else if(b_182.enm_shotEffectXuanYun == iEffectType)
         {
            if(iEffectTime > this.a_1469 && this.a_1339 > 0)
            {
               this.a_1469 = iEffectTime;
            }
            if(this.m_stXuanYunEffect == null)
            {
               this.m_stXuanYunEffect = VertigoEffect.a_3926();
               this.m_stXuanYunEffect.a_1797(a_1283);
               if(height > 110)
               {
                  this.m_stXuanYunEffect.scaleX = this.m_stXuanYunEffect.scaleY = 0.6;
               }
               else
               {
                  this.m_stXuanYunEffect.scaleX = this.m_stXuanYunEffect.scaleY = 0.45;
               }
               this.m_stXuanYunEffect.x = x + 0.5 * (width - this.m_stXuanYunEffect.width) + stDisplayBitmap.x;
               this.m_stXuanYunEffect.y = y + this.m_stXuanYunEffect.height + stDisplayBitmap.y - 50;
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(this.m_stXuanYunEffect,BattleLayerDefine.EFFECTS_TOP_TYPE,this.m_stCurrentFieldGrid);
            }
         }
         else if(b_182.a_436 == iEffectType)
         {
            if(iEffectTime > m_iFireHurtFrameNum)
            {
               m_iFireHurtFrameNum = iEffectTime;
            }
            if(a_1285 > 1)
            {
               a_1285 = 1;
            }
            if(this.a_1468 > 1)
            {
               this.a_1468 = 1;
            }
            this.a_1470 = 2;
            this.a_1478 = 0.2;
         }
      }
      
      public function a_3969(iRduceLifeValue:int) : Boolean
      {
         return this.HurtLife(iRduceLifeValue,false);
      }
      
      public function a_4209(iRduceLifeValue:int) : Boolean
      {
         return this.HurtLife(iRduceLifeValue,true);
      }
      
      public function ReduceLife2(iRduceLifeValue:int, damageParams:Array = null) : Boolean
      {
         if(damageParams != null)
         {
            this._damageParam = damageParams;
         }
         var bReduce:Boolean = this.a_3969(iRduceLifeValue);
         this._damageParam.length = 0;
         return bReduce;
      }
      
      public function ReduceLifeIgnoreArmor2(iRduceLifeValue:int, damageParams:Array = null) : Boolean
      {
         if(damageParams != null)
         {
            this._damageParam = damageParams;
         }
         var bReduce:Boolean = this.a_4209(iRduceLifeValue);
         this._damageParam.length = 0;
         return bReduce;
      }
      
      public function ReduceAllLife(iRduceLifeValue:int, bIsIgnoreArmor:Boolean = false, ishowHuijing:Boolean = false) : Boolean
      {
         if(this.a_1339 <= 0)
         {
            return false;
         }
         if(this.IsBossIntruder)
         {
            if(bIsIgnoreArmor)
            {
               this.a_4209(iRduceLifeValue);
            }
            else
            {
               this.a_3969(iRduceLifeValue);
            }
         }
         else
         {
            this.HurtLife(iRduceLifeValue,bIsIgnoreArmor);
            if(ishowHuijing)
            {
               this.ShowBoomDieEffect();
               if(this.a_1339 <= 0)
               {
                  this.a_3940();
               }
            }
         }
         return true;
      }
      
      private function SendReduceLife(iRecordLifeDiff:int, iRduceLifeValue:int) : void
      {
         var iRandomNum:int = GetRandInt(ms_iMaxNum);
         if(0 == iRandomNum && 0 != iRecordLifeDiff)
         {
            a_1088.PostDamageValidate(iRduceLifeValue);
         }
      }
      
      private function HurtLife(iRduceLifeValue:int, bIsIgnoreArmor:Boolean) : Boolean
      {
         if(this.HasTag(10))
         {
            return true;
         }
         if(this.m_stCurrentFieldGrid != null)
         {
            if(bIsIgnoreArmor == true && this.m_stCurrentFieldGrid.HasTag(1))
            {
               return true;
            }
            if(this._damageParam.length > 0)
            {
               if(this._damageParam.indexOf(102) != -1 && this.m_stCurrentFieldGrid.HasTag(2))
               {
                  return true;
               }
               if(this._damageParam.indexOf(103) != -1 && this.m_stCurrentFieldGrid.HasTag(3))
               {
                  return true;
               }
            }
         }
         if(!this.m_isLifeCorrected)
         {
            this.m_isLifeCorrected = true;
            if(1 != this.numHardRate)
            {
               this.a_1339 = 15000 * this.numHardRate;
            }
         }
         if(this.m_stCurrentFieldGrid != null && iRduceLifeValue > 0 && this.m_iDieType == 0)
         {
            iRduceLifeValue *= this.m_stCurrentFieldGrid.m_iHurtRate;
         }
         var hurtRate:Number = 1;
         if(this._damageParam.indexOf(107) == -1)
         {
            if(this._damageParam.indexOf(108) != -1)
            {
               iRduceLifeValue *= 0.1;
            }
            else if(this.HasTag(16))
            {
               iRduceLifeValue *= 0.1;
            }
            else if(this.HasTag(28))
            {
               iRduceLifeValue *= 0.6;
            }
            else if(this.HasTag(27))
            {
               iRduceLifeValue *= 0.6;
            }
            else if(this.HasTag(26))
            {
               iRduceLifeValue *= 0.6;
            }
         }
         var iRecordLifeDiff:int = this.a_1339 - iRduceLifeValue;
         if(!bIsIgnoreArmor && this.a_1466 > 0)
         {
            this.a_1466 -= iRduceLifeValue;
         }
         else
         {
            this.a_1339 -= iRduceLifeValue;
         }
         if(this.a_1339 <= 0)
         {
            this.SendReduceLife(iRecordLifeDiff,iRduceLifeValue);
            this.a_1469 = 0;
            this.a_1468 = 0;
            this.RealeaseFollowEffect(true);
         }
         if(0 != iRduceLifeValue && Boolean(this.m_stCurrentFieldGrid))
         {
            this.ResetMovieStatus();
         }
         return true;
      }
      
      public function ShowBoomDieEffect() : void
      {
         var stSmallMouseBoomdie:a_4143 = null;
         if(!this.a_1461 && this.a_1339 <= 0 && null != parent && !this.IsBossIntruder)
         {
            stSmallMouseBoomdie = a_4143.a_3926();
            stSmallMouseBoomdie.a_1797(a_1283);
            stSmallMouseBoomdie.x = x;
            stSmallMouseBoomdie.y = y;
            parent.addChildAt(stSmallMouseBoomdie,parent.getChildIndex(this));
         }
      }
      
      public function ShowBatDieEffect() : void
      {
         var stSmallMouseBatdie:MouseMoveIntruderBatDieEffect = null;
         if(!this.a_1461 && this.a_1339 <= 0 && null != parent && !this.IsBossIntruder)
         {
            stSmallMouseBatdie = MouseMoveIntruderBatDieEffect.a_3926();
            stSmallMouseBatdie.a_1797(a_1283);
            stSmallMouseBatdie.x = x;
            stSmallMouseBatdie.y = y;
            parent.addChildAt(stSmallMouseBatdie,parent.getChildIndex(this));
            this.a_3940();
         }
      }
      
      public function CharmBoomDie() : void
      {
         var xStart:int = 0;
         var xEnd:int = 0;
         var yStart:int = 0;
         var yEnd:int = 0;
         var yIndex:int = 0;
         var xIndex:int = 0;
         var stFieldGridVector:Array = null;
         var stTargetFieldGrid:a_3491 = null;
         var arrMoveIntruder:Array = null;
         var stMoveIntruder:a_4206 = null;
         if(m_iCharmlevel == 3)
         {
            xStart = Math.max(this.m_stCurrentFieldGrid.m_iXGridNo - 2,0);
            xEnd = Math.min(this.m_stCurrentFieldGrid.m_iXGridNo + 2,BattleFieldView.a_1011 - 1);
            yStart = Math.max(this.m_stCurrentFieldGrid.m_iYGridNo - 2,0);
            yEnd = Math.min(this.m_stCurrentFieldGrid.m_iYGridNo + 2,BattleFieldView.a_1012 - 1);
         }
         else
         {
            xStart = Math.max(this.m_stCurrentFieldGrid.m_iXGridNo - 1,0);
            xEnd = Math.min(this.m_stCurrentFieldGrid.m_iXGridNo + 1,BattleFieldView.a_1011 - 1);
            yStart = Math.max(this.m_stCurrentFieldGrid.m_iYGridNo - 1,0);
            yEnd = Math.min(this.m_stCurrentFieldGrid.m_iYGridNo + 1,BattleFieldView.a_1012 - 1);
         }
         stFieldGridVector = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.stFieldGridsVector;
         for(yIndex = yStart; yIndex <= yEnd; yIndex++)
         {
            for(xIndex = xStart; xIndex <= xEnd; xIndex++)
            {
               stTargetFieldGrid = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3438(xIndex,yIndex);
               arrMoveIntruder = stTargetFieldGrid.a_1511.slice();
               for each(stMoveIntruder in arrMoveIntruder)
               {
                  if(0 == stMoveIntruder.iSpaceState && stMoveIntruder != this)
                  {
                     if(stMoveIntruder.IsElite || stMoveIntruder.isCannotSeeByInsurance)
                     {
                        stMoveIntruder.a_3969(2000);
                     }
                     else
                     {
                        stMoveIntruder.a_3969(stMoveIntruder.a_1339);
                     }
                  }
               }
            }
         }
      }
      
      public function ShowCharmBoomDieEffect() : void
      {
         var stCharmMouseBoomDie:CharmMouseBoomDie = null;
         var iPosX:int = 0;
         var iPosY:int = 0;
         if(!this.a_1461 && null != parent)
         {
            stCharmMouseBoomDie = CharmMouseBoomDie.a_3926();
            stCharmMouseBoomDie.a_1797(a_1283);
            iPosX = (this.m_stCurrentFieldGrid.m_iXGridNo + 0.5) * a_3491.a_1080;
            iPosY = this.m_stCurrentFieldGrid.m_iYGridNo * a_3491.a_1081 - 5;
            stCharmMouseBoomDie.x = x + 0.5 * (width - 54) + stDisplayBitmap.x - 20 - 28;
            stCharmMouseBoomDie.y = y + stCharmMouseBoomDie.height + stDisplayBitmap.y - 56 + 43;
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(stCharmMouseBoomDie,BattleLayerDefine.EFFECTS_BASE_TYPE,this.m_stCurrentFieldGrid);
         }
      }
      
      public function a_4210() : Boolean
      {
         if(this.BoomIsReduceLife)
         {
            this.ReduceLife2(BOOM_INJURE_LIFE,[131]);
         }
         else
         {
            this.a_1339 = 0;
         }
         this.ShowBoomDieEffect();
         if(this.a_1339 <= 0)
         {
            this.a_3940();
         }
         return true;
      }
      
      public function CharmSkill(Charmlevel:int = 1) : Boolean
      {
         m_iCharmlevel = Charmlevel;
         this.a_1470 = -1;
         this.a_1464 = true;
         this.a_1462 = true;
         if(this.m_stMeiHuoEffect == null)
         {
            this.m_stMeiHuoEffect = IntruderMeiHuoEffect.a_3926();
            this.m_stMeiHuoEffect.a_1797(true);
            this.m_stMeiHuoEffect.x = x + 0.5 * (width - 54) + stDisplayBitmap.x - 20;
            this.m_stMeiHuoEffect.y = y + this.m_stMeiHuoEffect.height + stDisplayBitmap.y - 100;
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(this.m_stMeiHuoEffect,BattleLayerDefine.EFFECTS_TOP_TYPE,this.m_stCurrentFieldGrid);
         }
         return true;
      }
      
      private function RealeasePoisonShot(stFieldGrid:a_3491) : void
      {
         if(stFieldGrid == null)
         {
            return;
         }
         var stPoisonShot:a_4348 = JiaoTigerPoisonShot.a_4344();
         stPoisonShot.iShotSequenceNum = 0;
         var iPosX:int = (stFieldGrid.m_iXGridNo + 0.5) * a_3491.a_1080 + 1;
         var iPosY:int = stFieldGrid.m_iYGridNo * a_3491.a_1081 - 6;
         stPoisonShot.a_1797(0,0,500 * 1,iPosX,iPosY,stFieldGrid.m_stCurrentBattbleFieldView,stFieldGrid);
         stFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(stPoisonShot,BattleLayerDefine.EFFECTS_BASE_TYPE,stFieldGrid);
      }
      
      public function PowerfulBombReduceLifeRate(fRate:Number = 0.3, bIsIgnoreArmor:Boolean = false) : Boolean
      {
         if(this.a_1339 <= 0)
         {
            return false;
         }
         if(this._damageParam == null)
         {
            this._damageParam = [];
         }
         this._damageParam.push(131);
         if(bIsIgnoreArmor)
         {
            this.a_4209(BOOM_INJURE_LIFE * fRate);
         }
         else
         {
            this.a_3969(BOOM_INJURE_LIFE * fRate);
         }
         this.ShowBoomDieEffect();
         if(this.a_1339 <= 0)
         {
            this.a_3940();
         }
         return true;
      }
      
      public function PowerfulBombReduceLifeRate2(fRate:Number = 0.3, damageParams:Array = null) : Boolean
      {
         return this.PowerfulBombReduceLifeRate3(fRate,false,damageParams);
      }
      
      public function PowerfulBombReduceLifeRate3(fRate:Number, bIsIgnoreArmor:Boolean, damageParams:Array = null) : Boolean
      {
         if(this.a_1339 <= 0)
         {
            return false;
         }
         if(damageParams != null)
         {
            this._damageParam = damageParams;
         }
         this.PowerfulBombReduceLifeRate(fRate,bIsIgnoreArmor);
         this._damageParam.length = 0;
         return true;
      }
      
      public function a_4211(iCutLifeValue:int) : Boolean
      {
         this.a_1339 -= iCutLifeValue;
         if(this.a_1339 <= 0)
         {
            if(this.m_stCurrentFieldGrid)
            {
               this.m_stCurrentFieldGrid.a_3457(this);
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
            }
            this.a_3940();
         }
         return true;
      }
      
      public function a_4212() : Boolean
      {
         this.a_1339 = 0;
         if(this.m_stCurrentFieldGrid)
         {
            this.m_stCurrentFieldGrid.a_3457(this);
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
         }
         this.a_3940();
         return true;
      }
      
      public function a_4213() : Boolean
      {
         return this.a_4212();
      }
      
      public function a_4214() : Boolean
      {
         return true;
      }
      
      public function a_4215(stBaseDefense:a_3962) : Boolean
      {
         BattleFieldView.ms_kenShi29.play();
         stBaseDefense.m_iDieType = 1;
         stBaseDefense.a_3969(this.a_1377);
         return true;
      }
      
      public function ShowPlayEffect(iCurrentTime:int) : Boolean
      {
         var iXGridNo:int = 0;
         var m_DropDie:Boolean = false;
         var stTargetFieldGrid:a_3491 = null;
         var xStart:int = 0;
         var xEnd:int = 0;
         var yStart:int = 0;
         var yEnd:int = 0;
         var yIndex:int = 0;
         var xIndex:int = 0;
         var stFieldGridVector:Array = null;
         var arrMoveIntruder:Array = null;
         var stMoveIntruder:a_4206 = null;
         if(m_iCharmlevel > 0)
         {
            if(this.m_stMeiHuoEffect != null)
            {
               this.m_stMeiHuoEffect.x = x + 0.5 * (width - 54) + stDisplayBitmap.x - 20;
            }
            iXGridNo = this.GetiNoX();
            if(iXGridNo <= (a_1283 ? -1 : 0) || iXGridNo >= BattleFieldView.a_1011)
            {
               trace("魅惑老鼠走出战斗区域  Realease the MoveIntruder");
               this.m_stCurrentFieldGrid.a_3457(this);
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
               this.a_3940();
               return true;
            }
            m_DropDie = false;
            arrMoveIntruder = this.m_stCurrentFieldGrid.a_1511.slice();
            for each(stMoveIntruder in arrMoveIntruder)
            {
               if(0 == stMoveIntruder.iSpaceState && stMoveIntruder != this && hitTestObject(stMoveIntruder))
               {
                  m_DropDie = true;
               }
            }
            if(m_DropDie && this.m_stCurrentFieldGrid != null)
            {
               this.CharmBoomDie();
               this.ShowCharmBoomDieEffect();
               if(m_iCharmlevel == 2)
               {
                  xStart = Math.max(this.m_stCurrentFieldGrid.m_iXGridNo - 1,0);
                  xEnd = Math.min(this.m_stCurrentFieldGrid.m_iXGridNo + 1,BattleFieldView.a_1011 - 1);
                  yStart = Math.max(this.m_stCurrentFieldGrid.m_iYGridNo - 1,0);
                  yEnd = Math.min(this.m_stCurrentFieldGrid.m_iYGridNo + 1,BattleFieldView.a_1012 - 1);
                  stFieldGridVector = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.stFieldGridsVector;
                  for(yIndex = yStart; yIndex <= yEnd; yIndex++)
                  {
                     for(xIndex = xStart; xIndex <= xEnd; xIndex++)
                     {
                        stTargetFieldGrid = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3438(xIndex,yIndex);
                        this.RealeasePoisonShot(stTargetFieldGrid);
                     }
                  }
               }
               else if(m_iCharmlevel == 3)
               {
                  xStart = Math.max(this.m_stCurrentFieldGrid.m_iXGridNo - 2,0);
                  xEnd = Math.min(this.m_stCurrentFieldGrid.m_iXGridNo + 2,BattleFieldView.a_1011 - 1);
                  yStart = Math.max(this.m_stCurrentFieldGrid.m_iYGridNo - 2,0);
                  yEnd = Math.min(this.m_stCurrentFieldGrid.m_iYGridNo + 2,BattleFieldView.a_1012 - 1);
                  stFieldGridVector = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.stFieldGridsVector;
                  for(yIndex = yStart; yIndex <= yEnd; yIndex++)
                  {
                     for(xIndex = xStart; xIndex <= xEnd; xIndex++)
                     {
                        stTargetFieldGrid = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3438(xIndex,yIndex);
                        this.RealeasePoisonShot(stTargetFieldGrid);
                     }
                  }
               }
               this.m_stCurrentFieldGrid.a_3457(this);
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
               this.a_3940();
               return true;
            }
         }
         return true;
      }
      
      protected function IsReveredGrid() : Boolean
      {
         return true;
      }
      
      public function a_2062() : void
      {
         a_1088.a_2062(this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.iTimeIntervalNum,this.m_stCurrentFieldGrid.m_iYGridNo);
      }
      
      protected function GetiNoX() : int
      {
         var iXGridNo:int = int(x / a_3491.a_1080);
         if(a_1283)
         {
            iXGridNo = BattleFieldView.a_1011 - 1 - iXGridNo;
         }
         return iXGridNo;
      }
      
      public function a_4216(iCurrentTime:int) : Boolean
      {
         var stNextFieldGrid:a_3491 = null;
         var iXGridNo:int = 0;
         var numMoveSpeed:Number = NaN;
         if(!this.a_1460)
         {
            this.a_1460 = true;
         }
         if(this.a_1468 > 0 || this.a_1469 > 0)
         {
            return true;
         }
         if(null == this.m_stCurrentFieldGrid)
         {
            return false;
         }
         if(x == (a_1283 ? 0 : BattleFieldView.a_1013) && this.m_stCurrentFieldGrid.m_stBaseLander != null)
         {
            x += a_1283 ? 2 : -2;
            this.SetClarmLanderTime();
         }
         if(!a_1283 && x <= 0 || a_1283 && x >= BattleFieldView.a_1013)
         {
            x += this.a_1350 * this.a_1470;
            if(!a_1283 && x <= -40 || a_1283 && x >= BattleFieldView.a_1013 + 40)
            {
               if(this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.isOwnBattleField)
               {
                  this.a_2062();
               }
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.m_stRowBreakDownMoveIntruderBitmap.bitmapData = stDisplayBitmap.bitmapData;
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.m_stRowBreakDownMoveIntruderBitmap.x = x + stDisplayBitmap.x + (a_1283 ? 50 : -50);
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.m_stRowBreakDownMoveIntruderBitmap.y = y + stDisplayBitmap.y;
               trace("m_isReversed && x <= -40 || !m_isReversed && x >= BattleFieldView.ms_iBattleFieldWidth + 40  Realease the MoveIntruder");
               this.m_stCurrentFieldGrid.a_3457(this);
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
               if(!this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.isOwnBattleField)
               {
                  this.a_1459 = -1;
               }
               this.a_3940();
               return true;
            }
            return true;
         }
         if(this.a_1474 <= 0 && iCurrentTime >= this.a_1472 + this.a_1471 && !this.a_1475 && ((this.m_stCurrentFieldGrid.m_stProtector == null || this.m_stCurrentFieldGrid.m_stProtector.m_isShowFrozen) && (this.m_stCurrentFieldGrid.m_stAttackFighter == null || !this.IsCanEat(this.m_stCurrentFieldGrid.m_stAttackFighter)) && (this.m_stCurrentFieldGrid.m_stFlowerDefense == null || this.m_stCurrentFieldGrid.m_stFlowerDefense.m_isShowFrozen) && (this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter == null || this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter.m_isShowFrozen) && (this.m_stCurrentFieldGrid.m_stTrayDefense == null || this.m_stCurrentFieldGrid.m_stTrayDefense.m_isShowFrozen) && (this.m_stCurrentFieldGrid.m_stBoomDefense == null || this.m_stCurrentFieldGrid.m_stBoomDefense.m_isShowFrozen || !this.m_stCurrentFieldGrid.m_stBoomDefense.isCanBeEaten) || this.a_1464))
         {
            this.CheckUpdateYPosition();
            this.a_1472 = iCurrentTime;
            this.play();
            x += this.a_1350 * this.a_1470;
            iXGridNo = this.GetiNoX();
            if(iXGridNo >= 0 && iXGridNo < BattleFieldView.a_1011 && this.m_stCurrentFieldGrid.m_iXGridNo != iXGridNo)
            {
               stNextFieldGrid = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3438(iXGridNo,this.m_stCurrentFieldGrid.m_iYGridNo);
               this.ChangeFieldGrid(stNextFieldGrid);
               if(stNextFieldGrid.m_stBaseLander != null)
               {
                  this.SetClarmLanderTime();
               }
            }
            else if(iXGridNo < (a_1283 ? -1 : 0) || iXGridNo > BattleFieldView.a_1011)
            {
               trace("iXGridNo < -1 || iXGridNo > BattleFieldView.ms_iXGridNum  Realease the MoveIntruder");
               this.m_stCurrentFieldGrid.a_3457(this);
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
               this.a_3940();
               return true;
            }
         }
         if(this.a_1474 > 0)
         {
            --this.a_1474;
            numMoveSpeed = a_3491.a_1080 / 20;
            if(!a_1283)
            {
               numMoveSpeed *= -1;
            }
            x += numMoveSpeed * this.m_fClimbWidthTick;
            y += this.GetHeightByClarmLanderTime();
            iXGridNo = this.GetiNoX();
            if(iXGridNo >= 0 && iXGridNo < BattleFieldView.a_1011 && this.m_stCurrentFieldGrid.m_iXGridNo != iXGridNo)
            {
               stNextFieldGrid = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3438(iXGridNo,this.m_stCurrentFieldGrid.m_iYGridNo);
               this.ChangeFieldGrid(stNextFieldGrid);
               if(stNextFieldGrid.m_stBaseLander != null)
               {
                  this.SetClarmLanderTime();
               }
            }
            else if(iXGridNo < (a_1283 ? -1 : 0) || iXGridNo > BattleFieldView.a_1011)
            {
               trace("iXGridNo < -1 || iXGridNo > BattleFieldView.ms_iXGridNum  Realease the MoveIntruder");
               this.m_stCurrentFieldGrid.a_3457(this);
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
               this.a_3940();
               return true;
            }
         }
         if(this.a_1473 <= 0 && this.a_1474 <= 0 && iCurrentTime >= this.a_1477 + this.a_1476 * (1 / this.a_1470) && !this.a_1464)
         {
            if(this.m_stCurrentFieldGrid.m_stBaseLander != null && this.SetClarmLanderTime())
            {
               this.a_1475 = false;
               this.ResetMovieStatus();
            }
            if(null != this.m_stCurrentFieldGrid.m_stProtector && this.IsCanEat(this.m_stCurrentFieldGrid.m_stProtector))
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stProtector);
               this.ResetMovieStatus();
            }
            else if(null != this.m_stCurrentFieldGrid.m_stAttackFighter && this.IsCanEat(this.m_stCurrentFieldGrid.m_stAttackFighter))
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stAttackFighter);
               this.ResetMovieStatus();
            }
            else if(null != this.m_stCurrentFieldGrid.m_stBoomDefense && this.m_stCurrentFieldGrid.m_stBoomDefense.isCanBeEaten && this.IsCanEat(this.m_stCurrentFieldGrid.m_stBoomDefense))
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stBoomDefense);
               this.ResetMovieStatus();
            }
            else if(null != this.m_stCurrentFieldGrid.m_stFlowerDefense && this.IsCanEat(this.m_stCurrentFieldGrid.m_stFlowerDefense))
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stFlowerDefense);
               this.ResetMovieStatus();
            }
            else if(null != this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter && this.IsCanEat(this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter))
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter);
               this.ResetMovieStatus();
            }
            else if(null != this.m_stCurrentFieldGrid.m_stTrayDefense && this.IsCanEat(this.m_stCurrentFieldGrid.m_stTrayDefense))
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stTrayDefense);
               this.ResetMovieStatus();
            }
            else if(this.a_1475)
            {
               this.a_1475 = false;
               this.ResetMovieStatus();
            }
         }
         this.EattingJudge();
         if(this.m_LastPositionX != x || this.m_LastPositionY != y)
         {
            this.m_LastPositionX = x;
            this.m_LastPositionY = y;
            this.UpdateFollowEffect();
         }
         return true;
      }
      
      protected function IsCanEat(stBaseDefense:a_3962) : Boolean
      {
         return !stBaseDefense.m_isShowFrozen && stBaseDefense.CanBeEat();
      }
      
      protected function GetHeightByClarmLanderTime() : Number
      {
         var fClimbHeight:Number = NaN;
         var fCurrentTime:Number = NaN;
         if(this.a_1474 <= 0)
         {
            return 0;
         }
         var fHalfMaxClimbTime:Number = this.m_iMaxClarmLanderTime * 0.5;
         if(this.m_bClarmLanderIsNeedParabola)
         {
            if(this.m_iMaxClarmLanderTime <= 0)
            {
               throw Error("Basemoveintruder::GetHeightByClarmLanderTime m_iMaxClarmLanderTime = " + this.m_iMaxClarmLanderTime);
            }
            fCurrentTime = (fHalfMaxClimbTime - this.a_1474) / fHalfMaxClimbTime;
            fClimbHeight = this.m_fClimbHeightTick * Math.sin(fCurrentTime);
         }
         else
         {
            fClimbHeight = this.m_fClimbHeightTick * (fHalfMaxClimbTime - this.a_1474 > 0 ? 1 : -1);
            if(fHalfMaxClimbTime - this.a_1474 == 0)
            {
               fClimbHeight = 0;
            }
         }
         return fClimbHeight;
      }
      
      public function play() : void
      {
         this.a_1482 = true;
      }
      
      public function stop() : void
      {
         this.a_1482 = false;
      }
      
      public function a_4140(iCurrentTime:int) : void
      {
         var posX:int = 0;
         this.buffCom.UpdateBuff(2);
         var shouldShow:Boolean = a_2036.getInstance().isShowIntruderLife;
         var parentIsNull:Boolean = this.m_lifeValueTxt.parent == null;
         if(shouldShow && parentIsNull)
         {
            this.m_lifeValueTxt.x = x;
            this.m_lifeValueTxt.y = y + 40;
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(this.m_lifeValueTxt,BattleLayerDefine.EFFECTS_TOP_TYPE,this.m_stCurrentFieldGrid);
         }
         else if(!shouldShow && !parentIsNull)
         {
            this.m_lifeValueTxt.parent.removeChild(this.m_lifeValueTxt);
         }
         else if(shouldShow && !parentIsNull)
         {
            posX = a_1283 || m_iCharmlevel > 0 ? int(x - a_1279) : int(x + a_1279);
            this.m_lifeValueTxt.x = x;
            this.m_lifeValueTxt.y = y + 40;
         }
         if(this.m_stMeiHuoEffect)
         {
            this.m_stMeiHuoEffect.a_4003(null);
         }
         if(Boolean(this.m_stFireBurnBuff) && this.m_stFireBurnBuff.visible)
         {
            this.m_stFireBurnBuff.x = x + 0.5 * (width - this.m_stFireBurnBuff.width) + stDisplayBitmap.x;
            this.m_stFireBurnBuff.y = y + this.m_stFireBurnBuff.height + stDisplayBitmap.y - 10;
         }
         if(this.a_1468 > 0 || this.a_1469 > 0)
         {
            if(this.a_1468 > 0)
            {
               --this.a_1468;
               this.stop();
               if(Boolean(6 == this.a_1468) && Boolean(this.m_stFreezeUpEffect) && this.m_stFreezeUpEffect.visible)
               {
                  this.m_stFreezeUpEffect.play();
               }
               if(0 == this.a_1468)
               {
                  BattleFieldView.ms_pobing81.play();
                  this.play();
               }
            }
            if(this.a_1469 > 0)
            {
               --this.a_1469;
               if(0 == this.a_1469)
               {
                  this.a_1478 = 1;
                  this.a_1470 = 1;
               }
            }
            if(Boolean(this.m_stXuanYunEffect) && this.m_stXuanYunEffect.visible)
            {
               this.m_stXuanYunEffect.a_4003(null);
            }
            return;
         }
         if(m_iImmuneFrameNum > 0)
         {
            --m_iImmuneFrameNum;
            if(Boolean(this.m_stMianYiEffect) && this.m_stMianYiEffect.visible)
            {
               this.m_stMianYiEffect.a_4003(null);
            }
         }
         else if(Boolean(this.m_stMianYiEffect) && this.m_stMianYiEffect.visible)
         {
            this.m_stMianYiEffect.a_3940();
            this.m_stMianYiEffect = null;
         }
         if(Boolean(this.m_stXuanYunEffect) && this.m_stXuanYunEffect.visible)
         {
            this.m_stXuanYunEffect.a_3940();
            this.m_stXuanYunEffect = null;
         }
         if(this.m_isShowShandian)
         {
            if(Boolean(this.m_stShanDianEffect) && this.m_stShanDianEffect.visible)
            {
               this.m_stShanDianEffect.a_4003(null);
            }
         }
         else if(Boolean(this.m_stShanDianEffect) && this.m_stShanDianEffect.visible)
         {
            this.m_stShanDianEffect.a_3940();
            this.m_stShanDianEffect = null;
         }
         if(this.a_1482)
         {
            this.a_4160(iCurrentTime);
         }
      }
      
      private function a_4160(iCurrentTime:int) : void
      {
         if(this.a_1478 > 1 && iCurrentTime < this.a_1480 + this.a_1479 * this.a_1478)
         {
            if(a_1285 > 0)
            {
               --a_1285;
            }
            if(0 == a_1285)
            {
               this.a_1478 = 1;
               this.a_1470 = 1;
            }
            return;
         }
         if(m_iFireHurtFrameNum > 0)
         {
            if(m_iFireHurtFrameNum > 0)
            {
               --m_iFireHurtFrameNum;
            }
            if(0 == m_iFireHurtFrameNum)
            {
               this.a_1478 = 1;
               this.a_1470 = 1;
            }
         }
         if(this.m_iChageSpeedNum > 0)
         {
            if(this.m_iChageSpeedNum > 0)
            {
               --this.m_iChageSpeedNum;
            }
            if(0 == this.m_iChageSpeedNum)
            {
               this.a_1478 = 1;
               this.a_1470 = 1;
            }
         }
         this.a_1480 = iCurrentTime;
         nextFrame();
         if((a_1273 == a_1274 || a_1273 == this.m_SecondDieFrame) && this.a_1339 <= 0)
         {
            this.a_3940();
            return;
         }
         if(a_1278 != null)
         {
            if(this.a_1339 <= 0)
            {
               this.a_3940();
               return;
            }
            try
            {
               gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
            }
            catch(error:Error)
            {
               throw new Error("m_iFrameLabelIndex:" + a_1275);
            }
            this.EattingJudge();
         }
      }
      
      public function SetMoveToYPosition(fYPosition:Number, iTargetYGrid:int, iMoveYTime:int = 20) : void
      {
         var fDistance:Number = NaN;
         var fMoveYSpeed:Number = NaN;
         if(this.a_1460 && !this.a_1462 && this.m_iMoveYTimes < 1 && null != this.m_stCurrentFieldGrid && this.m_stCurrentFieldGrid.m_iYGridNo != iTargetYGrid)
         {
            fDistance = Math.abs(fYPosition - y);
            if(fDistance > 2)
            {
               fMoveYSpeed = fDistance / iMoveYTime;
               if(fMoveYSpeed < 1)
               {
                  fMoveYSpeed = 1;
                  iMoveYTime = fDistance / fMoveYSpeed;
               }
               this.m_iMoveYSpeed = fMoveYSpeed;
               if(fYPosition < y)
               {
                  this.m_iMoveYSpeed = -this.m_iMoveYSpeed;
               }
               this.m_iMoveYTimes = iMoveYTime;
               this.m_iTargetYGrid = iTargetYGrid;
               this.SetCannotSeeByFighter(true);
               if(this.a_1475)
               {
                  this.a_1475 = false;
                  this.ResetMovieStatus();
               }
               trace("*********MoveToYGrid:" + fYPosition + "********m_iMoveYSpeed:" + this.m_iMoveYSpeed + "  m_iMoveYTimes:" + this.m_iMoveYTimes + "**********");
            }
         }
         else
         {
            trace("*******MoveToYGrid:" + fYPosition + "************Fail:m_stCurrentFieldGrid is null**********");
         }
      }
      
      private function CheckUpdateYPosition() : void
      {
         var stNextFielGrid:a_3491 = null;
         if(this.m_iMoveYTimes < 1)
         {
            return;
         }
         --this.m_iMoveYTimes;
         if(null == this.m_stCurrentFieldGrid)
         {
            return;
         }
         y += this.m_iMoveYSpeed;
         if(y + this.height < 0)
         {
            y = this.height;
         }
         else if(y + this.height > BattleFieldView.a_1014)
         {
            y = BattleFieldView.a_1014 - this.height;
         }
         if(0 == this.m_iMoveYTimes)
         {
            y = this.iYPosSkewing + a_3491.a_1081 * (1 + this.m_iTargetYGrid) - height - stDisplayBitmap.y;
            stNextFielGrid = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3438(this.m_stCurrentFieldGrid.m_iXGridNo,this.m_iTargetYGrid);
            this.ChangeFieldGrid(stNextFielGrid);
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(this,BattleLayerDefine.INTRUDER_LAND_TYPE,stNextFielGrid);
            this.SetCannotSeeByFighter(false);
            return;
         }
      }
      
      protected function ChangeFieldGrid(stNextFieldGrid:a_3491) : void
      {
         if(null == stNextFieldGrid)
         {
            return;
         }
         var bIsSameRow:Boolean = Boolean(stNextFieldGrid.m_iYGridNo == this.m_stCurrentFieldGrid.m_iYGridNo);
         if(!bIsSameRow)
         {
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.ReduceRowIntruderNum(this,this.m_stCurrentFieldGrid.m_iYGridNo);
         }
         stNextFieldGrid.a_3459(this);
         if(!bIsSameRow)
         {
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddRowIntruderNum(this,this.m_stCurrentFieldGrid.m_iYGridNo);
         }
      }
      
      protected function SetClarmLanderTime() : Boolean
      {
         if(this.a_1474 > 0 || 0 != this.a_1465)
         {
            return false;
         }
         this.m_bClarmLanderIsNeedParabola = this.m_stCurrentFieldGrid.m_stBaseLander.IsNeedParabola;
         this.m_iMaxClarmLanderTime = this.a_1474 = this.m_stCurrentFieldGrid.m_stBaseLander.ClimbTick;
         this.m_fClimbHeightTick = this.m_stCurrentFieldGrid.m_stBaseLander.ClimbHeight;
         this.m_fClimbWidthTick = this.m_stCurrentFieldGrid.m_stBaseLander.ClimbWidth;
         this.m_stCurrentFieldGrid.m_stBaseLander.a_3567();
         return true;
      }
      
      protected function ClearDefenseCardByGridNo(iXGridNo:int, iYGridNo:int, isCleanTray:Boolean = false) : Boolean
      {
         var stFieldGrid:a_3491 = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3438(iXGridNo,iYGridNo);
         return this.ClearFieldGridDefenseCard(stFieldGrid,isCleanTray);
      }
      
      public function AddSnakePoisonEffect() : void
      {
         if(this.m_stSnakePoisonEffect == null && this.m_stCurrentFieldGrid != null && this.a_1339 > 0 && !this.IsBossIntruder)
         {
            this.m_stSnakePoisonEffect = MageSnakeIntruderPoisonEffect.a_3926();
            this.m_stSnakePoisonEffect.stTargetMouveIntruder = this;
            this.m_stSnakePoisonEffect.a_1797(a_1283);
            this.m_stSnakePoisonEffect.x = x + 0.5 * width + stDisplayBitmap.x;
            this.m_stSnakePoisonEffect.y = y + stDisplayBitmap.y;
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(this.m_stSnakePoisonEffect,BattleLayerDefine.EFFECTS_TOP_TYPE,this.m_stCurrentFieldGrid);
         }
      }
      
      public function AddFireBurnBuff(iHurtPower:Number = 1) : void
      {
         if(!this.IsBossIntruder && this.m_stCurrentFieldGrid != null)
         {
            if(this.m_stFireBurnBuff == null)
            {
               this.m_stFireBurnBuff = FireBurnBuff.a_3926();
               this.m_stFireBurnBuff.a_1797(a_1283,1,iHurtPower);
               this.m_stFireBurnBuff.stTargetMouveIntruder = this;
               this.m_stFireBurnBuff.x = x + 0.5 * (width - this.m_stFireBurnBuff.width) + stDisplayBitmap.x;
               this.m_stFireBurnBuff.y = y + this.m_stFireBurnBuff.height + stDisplayBitmap.y - 10;
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(this.m_stFireBurnBuff,BattleLayerDefine.EFFECTS_TOP_TYPE,this.m_stCurrentFieldGrid);
            }
            this.m_stFireBurnBuff.m_BuffDurations.push(6 * 10);
            this.m_stFireBurnBuff.m_BuffPowers.push(iHurtPower);
         }
      }
      
      public function addBleedingEffect(buff:a_4108, duration:int, power:Number) : void
      {
         if(this.iLifeValue <= 0 || !visible || this.IsBossIntruder || !this.m_stCurrentFieldGrid)
         {
            return;
         }
         if(!this.m_stGeneralBloodEffect)
         {
            this.m_stGeneralBloodEffect = buff;
            buff.a_1797(a_1283);
            buff.SpecialSkillCallBack(this,duration,power);
            buff.x = this.x + 0.5 * this.width + this.stDisplayBitmap.x - 20;
            buff.y = this.y + this.stDisplayBitmap.y;
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.AddToBattleView(buff,BattleLayerDefine.EFFECTS_TOP_TYPE,this.m_stCurrentFieldGrid);
         }
         else
         {
            buff.SpecialSkillCallBack(this,duration,power);
         }
      }
      
      protected function ClearFieldGridDefenseCard(stFieldGrid:a_3491, isCleanTray:Boolean = false) : Boolean
      {
         if(null == stFieldGrid)
         {
            return false;
         }
         var bIsAttackCard:Boolean = false;
         if(null != stFieldGrid.m_stProtector)
         {
            bIsAttackCard = true;
            stFieldGrid.m_stProtector.m_iDieType = 1;
            stFieldGrid.m_stProtector.a_3969(stFieldGrid.m_stProtector.iLifeValue);
         }
         if(null != stFieldGrid.m_stAttackFighter && !(stFieldGrid.m_stAttackFighter is a_3924))
         {
            bIsAttackCard = true;
            stFieldGrid.m_stAttackFighter.m_iDieType = 1;
            stFieldGrid.m_stAttackFighter.a_3969(stFieldGrid.m_stAttackFighter.iLifeValue);
         }
         if(null != stFieldGrid.m_stBoomDefense)
         {
            bIsAttackCard = true;
            stFieldGrid.m_stBoomDefense.m_iDieType = 1;
            stFieldGrid.m_stBoomDefense.a_3969(stFieldGrid.m_stBoomDefense.iLifeValue);
         }
         if(null != stFieldGrid.m_stFlowerDefense)
         {
            bIsAttackCard = true;
            stFieldGrid.m_stFlowerDefense.m_iDieType = 1;
            stFieldGrid.m_stFlowerDefense.a_3969(stFieldGrid.m_stFlowerDefense.iLifeValue);
         }
         if(null != stFieldGrid.m_stBaseAuxiliaryFighter)
         {
            bIsAttackCard = true;
            stFieldGrid.m_stBaseAuxiliaryFighter.m_iDieType = 1;
            stFieldGrid.m_stBaseAuxiliaryFighter.a_3969(stFieldGrid.m_stBaseAuxiliaryFighter.iLifeValue);
         }
         if(isCleanTray && null != stFieldGrid.m_stTrayDefense)
         {
            bIsAttackCard = true;
            stFieldGrid.m_stTrayDefense.m_iDieType = 1;
            stFieldGrid.m_stTrayDefense.a_3969(stFieldGrid.m_stTrayDefense.iLifeValue);
         }
         return bIsAttackCard;
      }
      
      protected function EattingJudge() : void
      {
         if(this.a_1475 && this.m_stCurrentFieldGrid != null && null == this.m_stCurrentFieldGrid.m_stProtector && null == this.m_stCurrentFieldGrid.m_stAttackFighter && null == this.m_stCurrentFieldGrid.m_stFlowerDefense && null == this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter && null == this.m_stCurrentFieldGrid.m_stTrayDefense && null == this.m_stCurrentFieldGrid.m_stBoomDefense)
         {
            this.a_1475 = false;
            this.ResetMovieStatus();
         }
      }
      
      public function get IsElite() : Boolean
      {
         return this.BoomIsReduceLife || this.m_MouseArr.indexOf(this.m_stMoveIntruderTypeID) != -1 || this.IsBossIntruder;
      }
      
      protected function SetGameMapModePicnicPosition(fOrignXPos:Number) : void
      {
         if(a_1457 == b_181.a_424 && (x > a_3491.a_1080 * 4 && a_1283 || x < a_3491.a_1080 * 5 && !a_1283))
         {
            y += Math.tan(15 * Math.PI / 180) * Math.abs(fOrignXPos - x);
         }
      }
      
      public function get IsBossIntruder() : Boolean
      {
         var className:String = getQualifiedClassName(this);
         var simpleClassName:String = className.split("::").pop();
         if(simpleClassName.indexOf("Boss") != -1)
         {
            trace("The class name contains \'Boss\'");
            return true;
         }
         return false;
      }
      
      public function get IsWaterIntruder() : Boolean
      {
         return this.a_1461;
      }
      
      public function get tagCom() : TagComponent
      {
         return this._tagCom;
      }
      
      public function AddTag(iTag:int) : Boolean
      {
         return this.tagCom.AddTag(iTag);
      }
      
      public function RemoveTag(iTag:int) : Boolean
      {
         return this.tagCom.RemoveTag(iTag);
      }
      
      public function HasTag(iTag:int) : Boolean
      {
         return this.tagCom.HasTag(iTag);
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
   }
}

