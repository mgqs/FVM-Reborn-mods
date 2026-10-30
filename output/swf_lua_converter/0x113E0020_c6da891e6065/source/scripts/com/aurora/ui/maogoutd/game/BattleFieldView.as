package com.aurora.ui.maogoutd.game
{
   import a_4718.b_180;
   import a_4718.b_181;
   import a_4718.b_203;
   import com.aurora.ui.maogoutd.b_147;
   import com.aurora.ui.maogoutd.resource.ISmallGameDetailInfoMap;
   import com.aurora.ui.maogoutd.resource.Intruder.a_4206;
   import com.aurora.ui.maogoutd.resource.Intruder.a_4255;
   import com.aurora.ui.maogoutd.resource.Intruder.a_4258;
   import com.aurora.ui.maogoutd.resource.Intruder.a_4269;
   import com.aurora.ui.maogoutd.resource.bitmap.a_3939;
   import com.aurora.ui.maogoutd.resource.defender.a_3953;
   import com.aurora.ui.maogoutd.resource.defender.a_3959;
   import com.aurora.ui.maogoutd.resource.defender.a_3960;
   import com.aurora.ui.maogoutd.resource.defender.a_3962;
   import com.aurora.ui.maogoutd.resource.defender.a_3971;
   import com.aurora.ui.maogoutd.resource.defender.a_3972;
   import com.aurora.ui.maogoutd.resource.defender.a_3975;
   import com.aurora.ui.maogoutd.resource.defender.a_3976;
   import com.aurora.ui.maogoutd.resource.defender.a_3977;
   import com.aurora.ui.maogoutd.resource.defender.a_4012;
   import com.aurora.ui.maogoutd.resource.effect.a_4111;
   import com.aurora.ui.maogoutd.resource.effect.a_4128;
   import com.aurora.ui.maogoutd.resource.effect.a_4142;
   import com.aurora.ui.maogoutd.resource.energy.a_4157;
   import com.aurora.ui.maogoutd.resource.energy.a_4162;
   import com.aurora.ui.maogoutd.resource.props.IBaseProp;
   import com.aurora.ui.maogoutd.resource.shot.a_4348;
   import com.aurora.ui.maogoutd.resource.tools.a_4408;
   import com.aurora.ui.maogoutd.resource.tools.a_4440;
   import flash.display.Bitmap;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.media.Sound;
   import flash.utils.Timer;
   
   public class BattleFieldView extends Sprite
   {
      
      public static var a_1011:int;
      
      public static var a_1012:int;
      
      public static var a_1013:int;
      
      public static var a_1014:int;
      
      public static var a_1054:ISmallGameDetailInfoMap;
      
      public static var a_1015:Sound = new Sound();
      
      public static var a_1016:Sound = new Sound();
      
      public static var a_1017:Sound = new Sound();
      
      public static var a_1018:Sound = new Sound();
      
      public static var a_1019:Sound = new Sound();
      
      public static var ms_kenShi29:Sound = new Sound();
      
      public static var a_1020:Sound = new Sound();
      
      public static var ms_naka13:Sound = new Sound();
      
      public static var a_1022:Sound = new Sound();
      
      public static var a_1023:Sound = new Sound();
      
      public static var a_1024:Sound = new Sound();
      
      public static var a_1025:Sound = new Sound();
      
      public static var a_1026:Sound = new Sound();
      
      public static var a_1027:Sound = new Sound();
      
      public static var a_1028:Sound = new Sound();
      
      public static var a_1029:Sound = new Sound();
      
      public static var a_1030:Sound = new Sound();
      
      public static var a_1031:Sound = new Sound();
      
      public static var a_1032:Sound = new Sound();
      
      public static var a_1033:Sound = new Sound();
      
      public static var a_1034:Sound = new Sound();
      
      public static var a_1035:Sound = new Sound();
      
      public static var a_1036:Sound = new Sound();
      
      public static var a_1038:Sound = new Sound();
      
      public static var a_1039:Sound = new Sound();
      
      public static var a_1040:Sound = new Sound();
      
      public static var a_1041:Sound = new Sound();
      
      public static var a_1042:Sound = new Sound();
      
      public static var a_1043:Sound = new Sound();
      
      public static var a_1045:Sound = new Sound();
      
      public static var a_1046:Sound = new Sound();
      
      public static var a_1047:Sound = new Sound();
      
      public static var a_1048:Sound = new Sound();
      
      public static var a_1049:Sound = new Sound();
      
      public static var a_1050:Sound = new Sound();
      
      public static var a_1051:Sound = new Sound();
      
      public static var a_1052:Sound = new Sound();
      
      public static var ms_pobing81:Sound = new Sound();
      
      public static var a_1055:int = 0;
      
      public static var a_1056:Boolean = false;
      
      public var m_stOpponentBattleFieldInstance:BattleFieldView;
      
      public var m_isOwnBattleField:Boolean = false;
      
      public var m_byTeamNo:int = -1;
      
      public var m_isAllowStartDropEnergy:Boolean = true;
      
      public var m_stMoveIntruderManage:a_4258;
      
      public var m_stMoveIntruderFactory:a_4255;
      
      private var a_1057:b_147;
      
      private var a_1058:Array;
      
      private var a_1059:Vector.<int>;
      
      public var m_stBaseShotVector:Array;
      
      public var m_arrBaseInsuranceVector:Array;
      
      public var m_arrBaseMoveIntruderVector:Array;
      
      public var m_stLargeFogEffect:a_4128;
      
      private var a_1060:Vector.<Bitmap>;
      
      private var a_1061:Vector.<Bitmap>;
      
      private var a_1062:Bitmap;
      
      private var a_1063:Bitmap;
      
      private var a_763:int = 0;
      
      private var m_iStartTimestamp:Number = 0;
      
      private var a_1066:int = 0;
      
      private var a_1067:int = 0;
      
      private var a_1069:Timer;
      
      private var a_1070:Array = [];
      
      private var a_1071:int;
      
      private var a_1072:Boolean;
      
      private var a_1073:int;
      
      public function BattleFieldView()
      {
         super();
         cacheAsBitmap = true;
         this.a_1072 = false;
      }
      
      public function get arrBackDepthBitmap() : Vector.<Bitmap>
      {
         return this.a_1061;
      }
      
      public function get arrFrontDepthBitmap() : Vector.<Bitmap>
      {
         return this.a_1060;
      }
      
      public function get stFieldRowIntruderStatusArray() : Vector.<int>
      {
         return this.a_1059;
      }
      
      public function get iBattleFieldStageType() : int
      {
         return a_1055;
      }
      
      public function get isOwnBattleField() : Boolean
      {
         return this.m_isOwnBattleField;
      }
      
      public function get iIntruderMoveDirection() : int
      {
         return this.a_1071;
      }
      
      public function get stFieldGridsVector() : Array
      {
         return this.a_1058;
      }
      
      public function get iTimeIntervalNum() : int
      {
         return this.a_1066;
      }
      
      public function a_3423() : int
      {
         var i:int = 0;
         var j:int = 0;
         var iTotalGridNum:int = 0;
         for(i = 0; i < a_1012; i++)
         {
            for(j = 0; j < a_1011; j++)
            {
               if(this.a_1058[i][j].a_3492())
               {
                  iTotalGridNum++;
               }
            }
         }
         return iTotalGridNum;
      }
      
      public function a_3424() : int
      {
         var i:int = 0;
         var j:int = 0;
         var iTotalGridNum:int = 0;
         for(i = 0; i < a_1012; i++)
         {
            for(j = 0; j < a_1011; j++)
            {
               if(!this.a_1058[i][j].a_3492() && !this.a_1058[i][j].m_isExistMouseHole)
               {
                  iTotalGridNum++;
               }
            }
         }
         return iTotalGridNum;
      }
      
      public function a_3426(iYGridNo:uint) : int
      {
         var j:int = 0;
         if(iYGridNo >= a_1012)
         {
            return 0;
         }
         var iTotalGridNum:int = 0;
         for(j = 0; j < a_1011; j++)
         {
            if(this.a_1058[iYGridNo][j].a_3492())
            {
               iTotalGridNum++;
            }
         }
         return iTotalGridNum;
      }
      
      public function a_3427(iOrderNum:int) : a_3491
      {
         var i:int = 0;
         var j:int = 0;
         if(iOrderNum < 0 || iOrderNum > this.a_3423() - 1)
         {
            return null;
         }
         loop0:
         for(i = 0; i < a_1012; )
         {
            j = 0;
            while(true)
            {
               if(j >= a_1011)
               {
                  i++;
                  continue loop0;
               }
               if(this.a_1058[i][j].a_3492())
               {
                  if(0 == iOrderNum)
                  {
                     break;
                  }
                  iOrderNum--;
               }
               j++;
            }
            return this.a_1058[i][j];
         }
         return null;
      }
      
      public function a_3428(iOrderNum:int) : a_3491
      {
         var i:int = 0;
         var j:int = 0;
         if(iOrderNum < 0 || iOrderNum > this.a_3424() - 1)
         {
            return null;
         }
         loop0:
         for(i = 0; i < a_1012; )
         {
            j = 0;
            while(true)
            {
               if(j >= a_1011)
               {
                  i++;
                  continue loop0;
               }
               if(!this.a_1058[i][j].a_3492() && !this.a_1058[i][j].m_isExistMouseHole)
               {
                  if(0 == iOrderNum)
                  {
                     break;
                  }
                  iOrderNum--;
               }
               j++;
            }
            return this.a_1058[i][j];
         }
         return null;
      }
      
      public function a_3430(iCenterRowNum:int) : int
      {
         var iTotalIntruderNum:int = 0;
         if(iCenterRowNum >= 0 && iCenterRowNum < BattleFieldView.a_1012)
         {
            iTotalIntruderNum += this.stFieldRowIntruderStatusArray[iCenterRowNum];
         }
         if(iCenterRowNum + 1 >= 0 && iCenterRowNum + 1 < BattleFieldView.a_1012)
         {
            iTotalIntruderNum += this.stFieldRowIntruderStatusArray[iCenterRowNum + 1];
         }
         if(iCenterRowNum - 1 >= 0 && iCenterRowNum - 1 < BattleFieldView.a_1012)
         {
            iTotalIntruderNum += this.stFieldRowIntruderStatusArray[iCenterRowNum - 1];
         }
         return iTotalIntruderNum;
      }
      
      public function a_3431() : a_4206
      {
         var stNearestMoveIntruder:a_4206 = null;
         var stMoveIntruder:a_4206 = null;
         for each(stMoveIntruder in this.m_arrBaseMoveIntruderVector)
         {
            if(stMoveIntruder.iLifeValue > 0)
            {
               if(null == stNearestMoveIntruder)
               {
                  stNearestMoveIntruder = stMoveIntruder;
               }
               if(this.a_1071 < 0 && stMoveIntruder.x < stNearestMoveIntruder.x)
               {
                  stNearestMoveIntruder = stMoveIntruder;
               }
               else if(this.a_1071 > 0 && stMoveIntruder.x > stNearestMoveIntruder.x)
               {
                  stNearestMoveIntruder = stMoveIntruder;
               }
            }
         }
         return stNearestMoveIntruder;
      }
      
      public function a_1797(iIntruderMoveDirection:int, stTDGameBattleUI:b_147) : Boolean
      {
         var i:int = 0;
         var j:int = 0;
         if(null == stTDGameBattleUI)
         {
            trace("null == stTDGameBattleUI return false");
            return false;
         }
         this.a_1057 = stTDGameBattleUI;
         if(!this.a_1072)
         {
            this.m_stBaseShotVector = new Array();
            this.a_1058 = new Array();
            this.m_arrBaseInsuranceVector = new Array();
            this.m_arrBaseMoveIntruderVector = new Array();
            this.a_1060 = new Vector.<Bitmap>(a_1012,true);
            this.a_1061 = new Vector.<Bitmap>(a_1012,true);
            for(i = 0; i < a_1012; i++)
            {
               this.m_stBaseShotVector[i] = new Array();
               this.a_1058[i] = new Array();
               for(j = 0; j < a_1011; j++)
               {
                  this.a_1058[i][j] = new a_3491(this,j,i);
               }
               this.a_1060[i] = new Bitmap();
               addChild(this.a_1060[i]);
               this.a_1061[i] = new Bitmap();
               addChild(this.a_1061[i]);
            }
            this.a_1062 = new Bitmap();
            addChild(this.a_1062);
            this.a_1063 = new Bitmap();
            addChild(this.a_1063);
            this.a_1059 = new Vector.<int>(a_1012);
            this.m_stMoveIntruderManage = new a_4258();
            this.m_stMoveIntruderFactory = a_4255.getInstance();
            this.a_1069 = new Timer(50);
            this.m_stLargeFogEffect = new a_4128();
         }
         for(i = 0; i < a_1012; i++)
         {
            this.a_1059[i] = 0;
         }
         this.a_1071 = iIntruderMoveDirection;
         this.a_1069.addEventListener(TimerEvent.TIMER,this.a_3416);
         parent.addChild(this.m_stLargeFogEffect);
         this.a_1072 = true;
         return true;
      }
      
      public function a_3432() : void
      {
         var i:int = 0;
         var stBaseInsurance:a_3972 = null;
         var j:int = 0;
         var stBaseShot:a_4348 = null;
         var stBaseMoveIntruder:a_4206 = null;
         i = 0;
         while(Boolean(this.m_arrBaseInsuranceVector) && i < this.m_arrBaseInsuranceVector.length)
         {
            stBaseInsurance = this.m_arrBaseInsuranceVector[i];
            if(stBaseInsurance)
            {
               stBaseInsurance.a_3940();
            }
            i++;
         }
         i = 0;
         while(Boolean(this.a_1058) && i < a_1012)
         {
            for(j = 0; j < a_1011; j++)
            {
               this.a_1058[i][j].a_3502();
            }
            i++;
         }
         for(i = 0; i < a_1012; i++)
         {
            if(Boolean(this.m_stBaseShotVector) && Boolean(this.m_stBaseShotVector[i]) && this.m_stBaseShotVector[i].length > 0)
            {
               for each(stBaseShot in this.m_stBaseShotVector[i].slice())
               {
                  stBaseShot.a_4350();
               }
            }
         }
         if(this.m_stMoveIntruderManage)
         {
            this.m_stMoveIntruderManage.a_1797();
         }
         if(this.m_arrBaseMoveIntruderVector)
         {
            for each(stBaseMoveIntruder in this.m_arrBaseMoveIntruderVector.slice())
            {
               stBaseMoveIntruder.a_4212();
            }
         }
         if(this.a_1058)
         {
            this.a_3415(0);
         }
      }
      
      public function a_3433() : int
      {
         return getChildIndex(this.a_1062);
      }
      
      public function a_3434() : int
      {
         return getChildIndex(this.a_1063);
      }
      
      public function a_3415(iGameMode:int) : Boolean
      {
         var i:int = 0;
         var j:int = 0;
         for(i = 0; i < a_1012; i++)
         {
            for(j = 0; j < a_1011; j++)
            {
               this.a_1058[i][j].m_isNeedTray = false;
            }
         }
         if(1 == iGameMode)
         {
            for(j = 0; j < a_1011; j++)
            {
               this.a_1058[2][j].m_isNeedTray = true;
               this.a_1058[3][j].m_isNeedTray = true;
            }
         }
         else if(2 == iGameMode)
         {
            for(j = 0; j < a_1011; j++)
            {
               this.a_1058[2][j].m_isNeedTray = true;
               this.a_1058[3][j].m_isNeedTray = true;
               this.a_1058[4][j].m_isNeedTray = true;
            }
         }
         else if(3 == iGameMode)
         {
            for(j = 0; j < a_1011; j++)
            {
               this.a_1058[0][j].m_isNeedTray = true;
               this.a_1058[1][j].m_isNeedTray = true;
               this.a_1058[5][j].m_isNeedTray = true;
               this.a_1058[6][j].m_isNeedTray = true;
            }
         }
         else if(4 == iGameMode)
         {
            for(i = 0; i < a_1012; i++)
            {
               for(j = 0; j < a_1011; j++)
               {
                  this.a_1058[i][j].m_isNeedTray = true;
               }
            }
         }
         else if(5 == iGameMode)
         {
            a_1056 = true;
         }
         this.m_stLargeFogEffect.x = x + 4 * a_3491.a_1080;
         this.m_stLargeFogEffect.y = y - a_3491.a_1081;
         this.m_stLargeFogEffect.a_1797();
         this.m_stLargeFogEffect.a_4129(this.a_1058);
         return true;
      }
      
      public function a_3435() : Boolean
      {
         var stBaseInsurance:a_3972 = null;
         var iDepthIndex:int = 0;
         this.a_1066 = 0;
         this.a_1067 = 0;
         this.m_iStartTimestamp = new Date().time;
         this.a_1069.start();
         for(var i:int = 0; i < a_1012; i++)
         {
            if(this.a_1058[i][0].m_isNeedTray)
            {
               stBaseInsurance = a_4012.getInstance().a_4013(285212672) as a_3972;
            }
            else
            {
               stBaseInsurance = a_4012.getInstance().a_4013(285212673) as a_3972;
            }
            if(null != stBaseInsurance)
            {
               stBaseInsurance.iDefenseTypeID = 285212672;
               stBaseInsurance.a_1797(this.a_1058[i][0]);
               stBaseInsurance.x = this.a_1071 > 0 ? a_1013 + stBaseInsurance.width : -stBaseInsurance.width;
               stBaseInsurance.y = a_3491.a_1081 * i + (a_3491.a_1081 - stBaseInsurance.height);
               iDepthIndex = getChildIndex(this.a_1061[i]);
               addChildAt(stBaseInsurance,iDepthIndex);
               this.m_arrBaseInsuranceVector[i] = stBaseInsurance;
               if(!this.isOwnBattleField && Boolean(a_1054))
               {
                  a_1054.a_3575(b_203.a_439,0,i);
               }
            }
         }
         return true;
      }
      
      public function a_1847() : Boolean
      {
         var i:int = 0;
         var j:int = 0;
         var stMoveIntruder:a_4206 = null;
         this.a_1069.stop();
         for(i = 0; i < a_1012; i++)
         {
            for(j = 0; j < a_1011; j++)
            {
               if(this.a_1058[i][j].m_isOccupy)
               {
                  for each(stMoveIntruder in this.a_1058[i][j].a_1511)
                  {
                     stMoveIntruder.stop();
                  }
               }
            }
         }
         return true;
      }
      
      public function a_3436(uiTickCount:int, iDefenseType:int, byXGridNo:int, byYGridNo:int) : Boolean
      {
         var stFieldGrid:a_3491 = this.a_3438(byXGridNo,byYGridNo);
         if(null == stFieldGrid)
         {
            return false;
         }
         if(null != stFieldGrid.m_stAttackFighter && stFieldGrid.m_stAttackFighter.a_3512() == iDefenseType)
         {
            return this.a_3450(byXGridNo,byYGridNo);
         }
         if(null != stFieldGrid.m_stProtector && stFieldGrid.m_stProtector.a_3512() == iDefenseType)
         {
            return this.a_3449(byXGridNo,byYGridNo);
         }
         if(null != stFieldGrid.m_stTrayDefense && stFieldGrid.m_stTrayDefense.a_3512() == iDefenseType)
         {
            return this.a_3451(byXGridNo,byYGridNo);
         }
         if(null != stFieldGrid.m_stBoomDefense && stFieldGrid.m_stBoomDefense.a_3512() == iDefenseType)
         {
            return this.a_3453(byXGridNo,byYGridNo);
         }
         if(null != stFieldGrid.m_stFlowerDefense && stFieldGrid.m_stFlowerDefense.a_3512() == iDefenseType)
         {
            return this.a_3454(byXGridNo,byYGridNo);
         }
         if(null != stFieldGrid.m_stBaseAuxiliaryFighter && stFieldGrid.m_stBaseAuxiliaryFighter.a_3512() == iDefenseType)
         {
            return this.a_3452(byXGridNo,byYGridNo);
         }
         return false;
      }
      
      public function a_2180() : int
      {
         return this.a_763++;
      }
      
      private function a_3416(a_4730:Event) : void
      {
         this.a_1066 = int((new Date().time - this.m_iStartTimestamp) / 50);
         var iCheckTimes:* = int(this.a_1066 - this.a_1067);
         while(iCheckTimes-- > 0)
         {
            this.a_3437(++this.a_1067);
         }
      }
      
      private function a_3437(iTimeIntervalNum:int) : Boolean
      {
         var i:int = 0;
         var j:int = 0;
         var stBaseShot:a_4348 = null;
         var stAttackFighter:a_3953 = null;
         var stMoveIntruder:a_4206 = null;
         var stBaseMoveIntruder:a_4206 = null;
         var stFreeEnergy:a_4157 = null;
         var iDropEnergyValue:int = 0;
         var stGameBasePop:IBaseProp = null;
         var stPropDisplayEffect:MovieClip = null;
         var stPendingAddIntruder:Object = this.m_stMoveIntruderManage.a_4259(iTimeIntervalNum);
         if(null != stPendingAddIntruder)
         {
            this.a_3456(stPendingAddIntruder);
         }
         for(i = 0; i < a_1012; i++)
         {
            if(this.m_stBaseShotVector[i].length > 0)
            {
               for each(stBaseShot in this.m_stBaseShotVector[i].slice())
               {
                  stBaseShot.a_4216(iTimeIntervalNum);
               }
            }
            for(j = 0; j < a_1011; j++)
            {
               stAttackFighter = this.a_1058[i][j].m_stAttackFighter;
               if(stAttackFighter != null)
               {
                  if(stAttackFighter.isShotAllTheTime || this.a_1059[i] > 0)
                  {
                     stAttackFighter.a_3954(iTimeIntervalNum);
                  }
                  stAttackFighter.a_3957(iTimeIntervalNum);
               }
               if(this.a_1058[i][j].m_stTrayDefense)
               {
                  this.a_1058[i][j].m_stTrayDefense.a_3957(iTimeIntervalNum);
               }
               if(this.a_1058[i][j].m_stBaseAuxiliaryFighter)
               {
                  this.a_1058[i][j].m_stBaseAuxiliaryFighter.a_3957(iTimeIntervalNum);
               }
               if(this.a_1058[i][j].m_stFlowerDefense)
               {
                  this.a_1058[i][j].m_stFlowerDefense.a_3957(iTimeIntervalNum);
               }
               if(this.a_1058[i][j].m_stProtector)
               {
                  this.a_1058[i][j].m_stProtector.a_3957(iTimeIntervalNum);
               }
               if(this.a_1058[i][j].m_isOccupy)
               {
                  for each(stMoveIntruder in this.a_1058[i][j].a_1511.slice())
                  {
                     stMoveIntruder.a_4216(iTimeIntervalNum);
                  }
               }
               if(this.a_1058[i][j].m_stBoomDefense)
               {
                  this.a_1058[i][j].m_stBoomDefense.a_3961(iTimeIntervalNum);
               }
            }
            if(null != this.m_arrBaseInsuranceVector[i])
            {
               this.m_arrBaseInsuranceVector[i].a_3973(iTimeIntervalNum);
            }
         }
         if(iTimeIntervalNum % 2 == 0)
         {
            for each(stBaseMoveIntruder in this.m_arrBaseMoveIntruderVector.slice())
            {
               stBaseMoveIntruder.a_4140(iTimeIntervalNum);
            }
         }
         if(1 == a_1055 && iTimeIntervalNum % 140 == 0 && iTimeIntervalNum > 0 && this.m_isAllowStartDropEnergy)
         {
            stFreeEnergy = a_4162.getInstance().a_4163(b_180.a_420);
            if(null != stFreeEnergy)
            {
               iDropEnergyValue = this.isOwnBattleField ? int(a_3971.a_1341 * 25) : 5;
               stGameBasePop = this.a_1070.pop();
               if(stGameBasePop)
               {
                  iDropEnergyValue += stGameBasePop.a_4328().m_iEffectValue;
               }
               stFreeEnergy.a_1797(0,iDropEnergyValue,0.6 * a_1013 * Math.random(),-50,a_3491.a_1081 / 30,160 + 160 * Math.random());
               addChild(stFreeEnergy);
               if(stGameBasePop)
               {
                  stPropDisplayEffect = stGameBasePop.a_4327();
                  stPropDisplayEffect.x = stFreeEnergy.width;
                  stPropDisplayEffect.y = -20;
                  stFreeEnergy.addChild(stPropDisplayEffect);
               }
            }
         }
         if(this.a_1073 > 0)
         {
            if(2 == this.a_1073)
            {
               x += 5;
               y += 5;
            }
            else if(1 == this.a_1073)
            {
               x -= 5;
               y -= 5;
            }
            --this.a_1073;
         }
         return true;
      }
      
      public function a_3438(iXGridNo:int, iYGridNo:int) : a_3491
      {
         if(iXGridNo < 0 || iXGridNo >= a_1011 || iYGridNo < 0 || iYGridNo >= a_1012)
         {
            return null;
         }
         return this.a_1058[iYGridNo][iXGridNo];
      }
      
      public function a_3441(stBaseDefense:a_3962, iXGridNo:int, iYGridNo:int) : Boolean
      {
         var stBaseTray:a_3977 = null;
         var stWaterPlacementEffect:a_4111 = null;
         var stPlacementEffect:a_4142 = null;
         if(null == stBaseDefense)
         {
            trace("null == stBaseDefense, AddBaseDefense failed");
            return false;
         }
         var addResult:Boolean = false;
         if(stBaseDefense is a_3975)
         {
            addResult = this.a_3442(stBaseDefense as a_3975,iXGridNo,iYGridNo);
         }
         else if(stBaseDefense is a_3953)
         {
            addResult = this.a_3443(stBaseDefense as a_3953,iXGridNo,iYGridNo);
         }
         else if(stBaseDefense is a_3977)
         {
            addResult = this.a_3444(stBaseDefense as a_3977,iXGridNo,iYGridNo);
         }
         else if(stBaseDefense is a_3959)
         {
            addResult = this.a_3445(stBaseDefense as a_3959,iXGridNo,iYGridNo);
         }
         else if(stBaseDefense is a_3960)
         {
            addResult = this.a_3446(stBaseDefense as a_3960,iXGridNo,iYGridNo);
         }
         else if(stBaseDefense is a_3971)
         {
            addResult = this.a_3447(stBaseDefense as a_3971,iXGridNo,iYGridNo);
         }
         else if(stBaseDefense is a_3976)
         {
            addResult = this.a_3448(stBaseDefense as a_3976,iXGridNo,iYGridNo);
         }
         if(addResult)
         {
            if(this.iIntruderMoveDirection < 0)
            {
               stBaseDefense.x = stBaseDefense.iXPosSheft + iXGridNo * a_3491.a_1080 + (a_3491.a_1080 - stBaseDefense.width) / 2;
            }
            else
            {
               stBaseDefense.x = a_1013 - (stBaseDefense.iXPosSheft + iXGridNo * a_3491.a_1080 + (a_3491.a_1080 - stBaseDefense.width) / 2);
            }
            stBaseTray = this.a_3438(iXGridNo,iYGridNo).m_stTrayDefense;
            if(Boolean(stBaseTray) && !(stBaseDefense is a_3977))
            {
               stBaseDefense.y = stBaseTray.y + stBaseTray.height - stBaseDefense.height - 20;
            }
            else
            {
               stBaseDefense.y = stBaseDefense.iYPosSheft + iYGridNo * a_3491.a_1081 + (a_3491.a_1081 - stBaseDefense.height - 5);
            }
            stBaseDefense.y -= stBaseDefense.stDisplayBitmap.y;
            if(!this.m_isOwnBattleField && Boolean(a_1054))
            {
               if(stBaseDefense is a_3971)
               {
                  a_1054.a_3575(b_203.a_441,iXGridNo,iYGridNo);
               }
               else if(stBaseDefense is a_3953)
               {
                  if((stBaseDefense as a_3953).iBreadFighterType > 1)
                  {
                     a_1054.a_3575(b_203.a_443,iXGridNo,iYGridNo);
                  }
                  else
                  {
                     a_1054.a_3575(b_203.a_444,iXGridNo,iYGridNo);
                  }
               }
               else if(stBaseDefense is a_3977 || stBaseDefense is a_3959 || stBaseDefense is a_3960 && (stBaseDefense as a_3960).isCanBeEaten)
               {
                  a_1054.a_3575(b_203.a_444,iXGridNo,iYGridNo);
               }
            }
            if(Boolean(this.m_isOwnBattleField && a_1054) && Boolean(stBaseDefense is a_3953) && (stBaseDefense as a_3953).iBattleFighterType > 1)
            {
               a_1054.a_3575(b_203.a_442,a_1011 - iXGridNo - 1,iYGridNo);
            }
            if(this.a_1058[iYGridNo][iXGridNo].m_isNeedTray)
            {
               stWaterPlacementEffect = a_4111.a_3926();
               stWaterPlacementEffect.a_1797(!this.isOwnBattleField);
               stWaterPlacementEffect.x = a_3491.a_1080 * (iXGridNo + 0.5) - 0.5 * stWaterPlacementEffect.width;
               if(!this.isOwnBattleField)
               {
                  stWaterPlacementEffect.x = a_1013 - stWaterPlacementEffect.x;
               }
               stWaterPlacementEffect.y = a_3491.a_1081 * (iYGridNo + 0.7);
               addChild(stWaterPlacementEffect);
               BattleFieldView.a_1024.play();
            }
            else
            {
               stPlacementEffect = a_4142.a_3926();
               stPlacementEffect.a_1797();
               stPlacementEffect.x = a_3491.a_1080 * (iXGridNo + 0.5) - 0.5 * stPlacementEffect.width;
               if(!this.isOwnBattleField)
               {
                  stPlacementEffect.x = a_1013 - stPlacementEffect.x;
               }
               stPlacementEffect.y = a_3491.a_1081 * (iYGridNo + 0.7);
               addChild(stPlacementEffect);
               BattleFieldView.a_1023.play();
            }
         }
         return addResult;
      }
      
      public function a_3442(baseProtector:a_3975, iXGridNo:int, iYGridNo:int) : Boolean
      {
         var iDepthIndex:int = 0;
         if(this.a_1058[iYGridNo][iXGridNo].a_3442(baseProtector))
         {
            baseProtector.a_1797(this.a_1058[iYGridNo][iXGridNo]);
            iDepthIndex = getChildIndex(this.a_1060[iYGridNo]);
            if(iDepthIndex < this.a_1058[iYGridNo][iXGridNo].a_3495())
            {
               iDepthIndex = int(this.a_1058[iYGridNo][iXGridNo].a_3495());
            }
            addChildAt(baseProtector,iDepthIndex + 1);
            return true;
         }
         return false;
      }
      
      public function a_3443(attackFighter:a_3953, iXGridNo:int, iYGridNo:int) : Boolean
      {
         var iDepthIndex:int = 0;
         if(this.a_1058[iYGridNo][iXGridNo].a_3443(attackFighter))
         {
            attackFighter.a_1797(this.a_1058[iYGridNo][iXGridNo]);
            iDepthIndex = getChildIndex(this.a_1060[iYGridNo]);
            addChildAt(attackFighter,iDepthIndex + 1);
            return true;
         }
         return false;
      }
      
      public function a_3444(stTrayDefense:a_3977, iXGridNo:int, iYGridNo:int) : Boolean
      {
         var iDepthIndex:int = 0;
         if(this.a_1058[iYGridNo][iXGridNo].a_3444(stTrayDefense))
         {
            stTrayDefense.a_1797(this.a_1058[iYGridNo][iXGridNo]);
            iDepthIndex = getChildIndex(this.a_1060[iYGridNo]);
            addChildAt(stTrayDefense,iDepthIndex);
            return true;
         }
         return false;
      }
      
      public function a_3445(baseAuxiliaryFighter:a_3959, iXGridNo:int, iYGridNo:int) : Boolean
      {
         var iDepthIndex:int = 0;
         if(this.a_1058[iYGridNo][iXGridNo].a_3445(baseAuxiliaryFighter))
         {
            baseAuxiliaryFighter.a_1797(this.a_1058[iYGridNo][iXGridNo]);
            iDepthIndex = getChildIndex(this.a_1060[iYGridNo]);
            addChildAt(baseAuxiliaryFighter,iDepthIndex + 1);
            return true;
         }
         return false;
      }
      
      public function a_3446(stBoomDefense:a_3960, iXGridNo:int, iYGridNo:int) : Boolean
      {
         var iDepthIndex:int = 0;
         if(this.a_1058[iYGridNo][iXGridNo].a_3446(stBoomDefense))
         {
            stBoomDefense.a_1797(this.a_1058[iYGridNo][iXGridNo]);
            iDepthIndex = getChildIndex(this.a_1060[iYGridNo]);
            addChildAt(stBoomDefense,iDepthIndex + 1);
            return true;
         }
         return false;
      }
      
      public function a_3447(stBaseFlowerDefense:a_3971, iXGridNo:int, iYGridNo:int) : Boolean
      {
         var iDepthIndex:int = 0;
         if(this.a_1058[iYGridNo][iXGridNo].a_3447(stBaseFlowerDefense))
         {
            stBaseFlowerDefense.a_1797(this.a_1058[iYGridNo][iXGridNo]);
            iDepthIndex = getChildIndex(this.a_1060[iYGridNo]);
            addChildAt(stBaseFlowerDefense,iDepthIndex + 1);
            return true;
         }
         return false;
      }
      
      public function a_3448(stToolDefense:a_3976, iXGridNo:int, iYGridNo:int) : Boolean
      {
         stToolDefense.a_1797(this.a_1058[iYGridNo][iXGridNo]);
         var iDepthIndex:int = getChildIndex(this.a_1061[iYGridNo]);
         addChildAt(stToolDefense,iDepthIndex);
         return true;
      }
      
      protected function a_3449(iXGridNo:int, iYGridNo:int) : Boolean
      {
         var baseProtector:a_3975 = this.a_1058[iYGridNo][iXGridNo].m_stProtector;
         this.a_1058[iYGridNo][iXGridNo].a_3496(baseProtector);
         removeChild(baseProtector);
         baseProtector.a_3940();
         return this.a_1057.a_3477(baseProtector.a_3512());
      }
      
      protected function a_3450(iXGridNo:int, iYGridNo:int) : Boolean
      {
         var baseAttackFighter:a_3953 = this.a_1058[iYGridNo][iXGridNo].m_stAttackFighter;
         this.a_1058[iYGridNo][iXGridNo].a_3497(baseAttackFighter);
         removeChild(baseAttackFighter);
         baseAttackFighter.a_3940();
         return this.a_1057.a_3477(baseAttackFighter.a_3512());
      }
      
      protected function a_3451(iXGridNo:int, iYGridNo:int) : Boolean
      {
         var stTrayDefense:a_3977 = this.a_1058[iYGridNo][iXGridNo].m_stTrayDefense;
         this.a_1058[iYGridNo][iXGridNo].a_3498(stTrayDefense);
         removeChild(stTrayDefense);
         stTrayDefense.a_3940();
         return this.a_1057.a_3477(stTrayDefense.a_3512());
      }
      
      protected function a_3452(iXGridNo:int, iYGridNo:int) : Boolean
      {
         var baseAuxiliaryFighter:a_3959 = this.a_1058[iYGridNo][iXGridNo].m_stBaseAuxiliaryFighter;
         this.a_1058[iYGridNo][iXGridNo].a_3501(baseAuxiliaryFighter);
         removeChild(baseAuxiliaryFighter);
         baseAuxiliaryFighter.a_3940();
         return this.a_1057.a_3477(baseAuxiliaryFighter.a_3512());
      }
      
      protected function a_3453(iXGridNo:int, iYGridNo:int) : Boolean
      {
         var baseBoomDefense:a_3960 = this.a_1058[iYGridNo][iXGridNo].m_stBoomDefense;
         this.a_1058[iYGridNo][iXGridNo].a_3499(baseBoomDefense);
         removeChild(baseBoomDefense);
         baseBoomDefense.a_3940();
         return this.a_1057.a_3477(baseBoomDefense.a_3512());
      }
      
      protected function a_3454(iXGridNo:int, iYGridNo:int) : Boolean
      {
         var baseFlowerDefense:a_3971 = this.a_1058[iYGridNo][iXGridNo].m_stFlowerDefense;
         this.a_1058[iYGridNo][iXGridNo].a_3500(baseFlowerDefense);
         removeChild(baseFlowerDefense);
         baseFlowerDefense.a_3940();
         return this.a_1057.a_3477(baseFlowerDefense.a_3512());
      }
      
      public function a_3455(iDefenseGlobalID:int, iDefenseTypeID:int, iXGridNo:int, iYGridNo:int) : Boolean
      {
         var baseAttackFighter:a_3953 = this.a_1058[iYGridNo][iXGridNo].m_stAttackFighter;
         var baseBoomDefense:a_3960 = this.a_1058[iYGridNo][iXGridNo].m_stBoomDefense;
         var baseProtector:a_3975 = this.a_1058[iYGridNo][iXGridNo].m_stProtector;
         var stTrayDefense:a_3977 = this.a_1058[iYGridNo][iXGridNo].m_stTrayDefense;
         var baseAuxiliaryFighter:a_3959 = this.a_1058[iYGridNo][iXGridNo].m_stBaseAuxiliaryFighter;
         var baseFlowerDefense:a_3971 = this.a_1058[iYGridNo][iXGridNo].m_stFlowerDefense;
         var baseInsureance:a_3972 = this.m_arrBaseInsuranceVector[iYGridNo];
         if(Boolean(baseAttackFighter) && iDefenseTypeID == baseAttackFighter.a_3512())
         {
            baseAttackFighter.a_3969(baseAttackFighter.iLifeValue);
            removeChild(baseAttackFighter);
         }
         else if(Boolean(baseProtector) && iDefenseTypeID == baseProtector.a_3512())
         {
            baseProtector.a_3969(baseProtector.iLifeValue);
            removeChild(baseProtector);
         }
         else if(Boolean(stTrayDefense) && iDefenseTypeID == stTrayDefense.a_3512())
         {
            stTrayDefense.a_3969(stTrayDefense.iLifeValue);
            removeChild(stTrayDefense);
         }
         else if(Boolean(baseAuxiliaryFighter) && iDefenseTypeID == baseAuxiliaryFighter.a_3512())
         {
            baseAuxiliaryFighter.a_3969(baseAuxiliaryFighter.iLifeValue);
            removeChild(baseAuxiliaryFighter);
         }
         else if(Boolean(baseFlowerDefense) && iDefenseTypeID == baseFlowerDefense.a_3512())
         {
            baseFlowerDefense.a_3969(baseFlowerDefense.iLifeValue);
            removeChild(baseFlowerDefense);
         }
         else if(Boolean(baseInsureance) && iDefenseTypeID == baseInsureance.a_3512())
         {
            baseInsureance.a_3974();
         }
         else if(Boolean(baseBoomDefense) && Boolean(baseBoomDefense.isCanBeEaten) && iDefenseTypeID == baseBoomDefense.a_3512())
         {
            baseBoomDefense.a_3969(baseBoomDefense.iLifeValue);
            removeChild(baseBoomDefense);
         }
         if(!this.m_isOwnBattleField && Boolean(a_1054))
         {
            if(Boolean(baseInsureance) && iDefenseTypeID == baseInsureance.a_3512())
            {
               a_1054.a_3577(iYGridNo);
               return true;
            }
            a_1054.a_3576(iXGridNo,iYGridNo);
            baseAttackFighter = this.a_1058[iYGridNo][iXGridNo].m_stAttackFighter;
            baseBoomDefense = this.a_1058[iYGridNo][iXGridNo].m_stBoomDefense;
            baseProtector = this.a_1058[iYGridNo][iXGridNo].m_stProtector;
            stTrayDefense = this.a_1058[iYGridNo][iXGridNo].m_stTrayDefense;
            baseAuxiliaryFighter = this.a_1058[iYGridNo][iXGridNo].m_stBaseAuxiliaryFighter;
            baseFlowerDefense = this.a_1058[iYGridNo][iXGridNo].m_stFlowerDefense;
            baseInsureance = this.m_arrBaseInsuranceVector[iYGridNo];
            if(baseFlowerDefense)
            {
               a_1054.a_3575(b_203.a_441,iXGridNo,iYGridNo);
            }
            else if(baseAttackFighter)
            {
               if(baseAttackFighter.iBreadFighterType > 1)
               {
                  a_1054.a_3575(b_203.a_443,iXGridNo,iYGridNo);
               }
               else if(baseAttackFighter.iBattleFighterType > 1)
               {
                  a_1054.a_3575(b_203.a_442,iXGridNo,iYGridNo);
               }
               else
               {
                  a_1054.a_3575(b_203.a_444,iXGridNo,iYGridNo);
               }
            }
            else if(Boolean(baseProtector && stTrayDefense) || Boolean(baseAuxiliaryFighter) || Boolean(baseBoomDefense) && Boolean(baseBoomDefense.isCanBeEaten))
            {
               a_1054.a_3575(b_203.a_444,iXGridNo,iYGridNo);
            }
         }
         if(Boolean(this.m_isOwnBattleField) && Boolean(a_1054) && null == baseAttackFighter)
         {
            a_1054.a_3578(a_1011 - iXGridNo - 1,iYGridNo);
         }
         return true;
      }
      
      public function a_3456(addedMoveIntruder:Object) : Boolean
      {
         var stAddedMoveIntruder:a_4269 = null;
         var stBaseMoveIntruder:a_4206 = null;
         var iDepthIndex:int = 0;
         if(addedMoveIntruder is a_4269)
         {
            stAddedMoveIntruder = addedMoveIntruder as a_4269;
            stBaseMoveIntruder = this.m_stMoveIntruderFactory.a_4256(stAddedMoveIntruder.m_iIntruderType);
            if(null != stBaseMoveIntruder)
            {
               if(stAddedMoveIntruder.m_iIntruderYGridNo >= a_1012)
               {
                  stAddedMoveIntruder.m_iIntruderYGridNo = a_1012 - 1;
               }
               stBaseMoveIntruder.a_1797(stAddedMoveIntruder.m_iIntruderGlobalNo,this.a_1071);
               if(-1 != this.m_arrBaseMoveIntruderVector.indexOf(stBaseMoveIntruder))
               {
                  throw new Error("-1 != m_arrBaseMoveIntruderVector.indexOf(stBaseMoveIntruder)");
               }
               this.m_arrBaseMoveIntruderVector.push(stBaseMoveIntruder);
               stBaseMoveIntruder.m_stMoveIntruderTypeID = stAddedMoveIntruder.m_iIntruderType;
               stBaseMoveIntruder.x = this.a_1071 > 0 ? 0 : a_1013;
               stBaseMoveIntruder.y = stBaseMoveIntruder.iYPosSkewing + a_3491.a_1081 * stAddedMoveIntruder.m_iIntruderYGridNo + (a_3491.a_1081 - stBaseMoveIntruder.height);
               iDepthIndex = getChildIndex(this.a_1061[stAddedMoveIntruder.m_iIntruderYGridNo]);
               addChildAt(stBaseMoveIntruder,iDepthIndex);
               trace("IsOwnBattleField:" + this.m_isOwnBattleField.toString() + "  stBaseMoveIntruder: MoveIntruderTypeID: " + stBaseMoveIntruder.m_stMoveIntruderTypeID.toString(16) + " stBaseMoveIntruder.height:" + stBaseMoveIntruder.height + ", m_iAppearTime:" + stAddedMoveIntruder.m_iAppearTime + " X[" + stBaseMoveIntruder.x + "], Y[" + stBaseMoveIntruder.y + "] , stAddedMoveIntruder.m_iIntruderYGridNo:" + stAddedMoveIntruder.m_iIntruderYGridNo);
               this.a_1058[stAddedMoveIntruder.m_iIntruderYGridNo][stAddedMoveIntruder.m_iIntruderXGridNo].a_3459(stBaseMoveIntruder);
               if(!stBaseMoveIntruder.isCannotSeeByFighter)
               {
                  this.a_1059[stAddedMoveIntruder.m_iIntruderYGridNo] += 1;
               }
            }
            else
            {
               trace("IntruderFactory.GetMoveIntruder failed for IntruderType:" + stAddedMoveIntruder.m_iIntruderType.toString(16));
            }
         }
         else if(addedMoveIntruder is Array)
         {
            for each(stAddedMoveIntruder in addedMoveIntruder)
            {
               stBaseMoveIntruder = this.m_stMoveIntruderFactory.a_4256(stAddedMoveIntruder.m_iIntruderType);
               if(null != stBaseMoveIntruder)
               {
                  if(stAddedMoveIntruder.m_iIntruderYGridNo >= a_1012)
                  {
                     stAddedMoveIntruder.m_iIntruderYGridNo = a_1012 - 1;
                  }
                  stBaseMoveIntruder.a_1797(stAddedMoveIntruder.m_iIntruderGlobalNo,this.a_1071);
                  if(-1 != this.m_arrBaseMoveIntruderVector.indexOf(stBaseMoveIntruder))
                  {
                     throw new Error("-1 != m_arrBaseMoveIntruderVector.indexOf(stBaseMoveIntruder)");
                  }
                  this.m_arrBaseMoveIntruderVector.push(stBaseMoveIntruder);
                  stBaseMoveIntruder.m_stMoveIntruderTypeID = stAddedMoveIntruder.m_iIntruderType;
                  stBaseMoveIntruder.x = this.a_1071 > 0 ? 0 : a_1013;
                  stBaseMoveIntruder.y = stBaseMoveIntruder.iYPosSkewing + a_3491.a_1081 * stAddedMoveIntruder.m_iIntruderYGridNo + (a_3491.a_1081 - stBaseMoveIntruder.height);
                  iDepthIndex = getChildIndex(this.a_1061[stAddedMoveIntruder.m_iIntruderYGridNo]);
                  addChildAt(stBaseMoveIntruder,iDepthIndex);
                  trace("IsOwnBattleField:" + this.m_isOwnBattleField.toString() + "  stBaseMoveIntruder: MoveIntruderTypeID: " + stBaseMoveIntruder.m_stMoveIntruderTypeID.toString(16) + " stBaseMoveIntruder.height:" + stBaseMoveIntruder.height + ", m_iAppearTime:" + stAddedMoveIntruder.m_iAppearTime + " X[" + stBaseMoveIntruder.x + "], Y[" + stBaseMoveIntruder.y + "] , stAddedMoveIntruder.m_iIntruderYGridNo:" + stAddedMoveIntruder.m_iIntruderYGridNo);
                  this.a_1058[stAddedMoveIntruder.m_iIntruderYGridNo][stAddedMoveIntruder.m_iIntruderXGridNo].a_3459(stBaseMoveIntruder);
                  if(!stBaseMoveIntruder.isCannotSeeByFighter)
                  {
                     this.a_1059[stAddedMoveIntruder.m_iIntruderYGridNo] += 1;
                  }
               }
               else
               {
                  trace("IntruderFactory.GetMoveIntruder failed for IntruderType:" + stAddedMoveIntruder.m_iIntruderType.toString(16));
               }
            }
         }
         return true;
      }
      
      public function a_3457(stMoveIntruder:a_4206) : Boolean
      {
         if(null == stMoveIntruder || this != stMoveIntruder.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView)
         {
            trace("Error: RemoveMoveIntruder Failed, null == stMoveIntruder || this != stMoveIntruder.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView");
            return false;
         }
         if(!stMoveIntruder.m_isRemovedFromBattaleField && -1 != this.m_arrBaseMoveIntruderVector.indexOf(stMoveIntruder))
         {
            stMoveIntruder.m_isRemovedFromBattaleField = true;
            if(!stMoveIntruder.isCannotSeeByFighter)
            {
               this.a_1059[stMoveIntruder.m_stCurrentFieldGrid.m_iYGridNo] = this.a_1059[stMoveIntruder.m_stCurrentFieldGrid.m_iYGridNo] - 1;
            }
         }
         return true;
      }
      
      public function a_3458(iIntruderGlobalID:int) : Boolean
      {
         var stBaseMoveIntruder:a_4206 = null;
         for each(stBaseMoveIntruder in this.m_arrBaseMoveIntruderVector.slice())
         {
            if(stBaseMoveIntruder.globalMoveFighterID == iIntruderGlobalID)
            {
               stBaseMoveIntruder.a_4212();
               return true;
            }
         }
         return false;
      }
      
      public function a_3459(stBaseMoveIntruder:a_4206, stFieldGrid:a_3491) : Boolean
      {
         var iDepthIndex:int = 0;
         if(null != stBaseMoveIntruder && null != stFieldGrid)
         {
            stBaseMoveIntruder.a_1797(stBaseMoveIntruder.globalMoveFighterID,this.a_1071);
            if(-1 == this.m_arrBaseMoveIntruderVector.indexOf(stBaseMoveIntruder))
            {
               this.m_arrBaseMoveIntruderVector.push(stBaseMoveIntruder);
               stBaseMoveIntruder.y = stBaseMoveIntruder.iYPosSkewing + a_3491.a_1081 * stFieldGrid.m_iYGridNo + (a_3491.a_1081 - stBaseMoveIntruder.height);
               iDepthIndex = getChildIndex(this.a_1061[stFieldGrid.m_iYGridNo]);
               addChildAt(stBaseMoveIntruder,iDepthIndex);
               stFieldGrid.a_3459(stBaseMoveIntruder);
               this.a_1059[stFieldGrid.m_iYGridNo] += 1;
               return true;
            }
            throw new Error("BattleField AddMoveIntruder Failed: -1 != m_arrBaseMoveIntruderVector.indexOf(stBaseMoveIntruder)");
         }
         return false;
      }
      
      public function a_3460(iXGridNo:int, iYGridNo:int) : Boolean
      {
         var stFieldGrid:a_3491 = this.a_3438(iXGridNo,iYGridNo);
         if(null == stFieldGrid)
         {
            return false;
         }
         if(Boolean(stFieldGrid) && Boolean(stFieldGrid.m_stBaseFieldAlarm) && stFieldGrid.m_stBaseFieldAlarm is a_4440)
         {
            return true;
         }
         this.a_3461(iXGridNo,iYGridNo);
         var stBaseFieldAlarm:a_4408 = a_4440.a_3926();
         stBaseFieldAlarm.x = a_3491.a_1080 * iXGridNo;
         stBaseFieldAlarm.y = a_3491.a_1081 * iYGridNo + 10;
         if(this.a_1071 > 0)
         {
            stBaseFieldAlarm.x = a_3491.a_1080 * (a_1011 - iXGridNo - 1);
         }
         var iDepthIndex:int = getChildIndex(this.a_1060[iYGridNo]);
         if(stFieldGrid.m_stTrayDefense)
         {
            iDepthIndex = getChildIndex(stFieldGrid.m_stTrayDefense) + 1;
         }
         addChildAt(stBaseFieldAlarm,iDepthIndex);
         stFieldGrid.m_stBaseFieldAlarm = stBaseFieldAlarm;
         return true;
      }
      
      public function a_3461(iXGridNo:int, iYGridNo:int) : Boolean
      {
         var stFieldGrid:a_3491 = this.a_3438(iXGridNo,iYGridNo);
         if(null == stFieldGrid)
         {
            return false;
         }
         if(stFieldGrid.m_stBaseFieldAlarm)
         {
            if(contains(stFieldGrid.m_stBaseFieldAlarm))
            {
               removeChild(stFieldGrid.m_stBaseFieldAlarm);
            }
            stFieldGrid.m_stBaseFieldAlarm.a_3940();
            stFieldGrid.m_stBaseFieldAlarm = null;
         }
         return true;
      }
      
      public function a_3462() : Boolean
      {
         this.m_stLargeFogEffect.a_4129(this.a_1058);
         return true;
      }
      
      public function a_3463(iHoleRadomID:int) : Boolean
      {
         var iTatolFreeGrid:int = this.a_3424();
         if(iTatolFreeGrid <= 0)
         {
            return false;
         }
         var stTempFieldGrid:a_3491 = this.a_3428(iHoleRadomID % iTatolFreeGrid);
         if(null == stTempFieldGrid)
         {
            return false;
         }
         stTempFieldGrid.m_isExistMouseHole = true;
         var stRatEarthHole:a_3939 = a_3939.a_3926();
         stRatEarthHole.x = a_3491.a_1080 * stTempFieldGrid.m_iXGridNo;
         stRatEarthHole.y = a_3491.a_1081 * (stTempFieldGrid.m_iYGridNo + 1) - stRatEarthHole.height + 10;
         if(this.a_1071 > 0)
         {
            stRatEarthHole.x = a_3491.a_1080 * (a_1011 - stTempFieldGrid.m_iXGridNo - 1);
         }
         addChildAt(stRatEarthHole,0);
         stTempFieldGrid.m_stRatEarthHole = stRatEarthHole;
         return true;
      }
      
      public function a_3466() : Boolean
      {
         if(0 == this.a_1073)
         {
            this.a_1073 = 2;
         }
         return true;
      }
      
      public function a_3467(iChangeLifeValue:int, stGameBasePop:IBaseProp) : Boolean
      {
         var stBaseMoveIntruder:a_4206 = null;
         var stPropDisplayEffect:MovieClip = null;
         if(this.m_arrBaseMoveIntruderVector.length > 0)
         {
            for each(stBaseMoveIntruder in this.m_arrBaseMoveIntruderVector.slice())
            {
               if(stBaseMoveIntruder.iLifeValue > 0)
               {
                  stBaseMoveIntruder.a_3969(-1 * iChangeLifeValue);
                  stPropDisplayEffect = stGameBasePop.a_4327();
                  stPropDisplayEffect.x = stBaseMoveIntruder.width;
                  stPropDisplayEffect.y = -20;
                  stBaseMoveIntruder.addChild(stPropDisplayEffect);
               }
            }
         }
         return true;
      }
      
      public function a_3468(stGameBasePop:IBaseProp) : Boolean
      {
         this.a_1070.push(stGameBasePop);
         return true;
      }
      
      public function a_3469(stGameBasePop:IBaseProp) : Boolean
      {
         var stFieldGrid:a_3491 = null;
         var j:int = 0;
         for(var i:int = 0; i < a_1012; i++)
         {
            for(j = 0; j < a_1011; j++)
            {
               stFieldGrid = this.a_1058[i][j];
               if(null != stFieldGrid.m_stFlowerDefense)
               {
                  stFieldGrid.m_stFlowerDefense.m_arrEnergyAddValueProp.push(stGameBasePop);
               }
            }
         }
         return true;
      }
      
      public function a_3470(iChangeLifeValue:int, stGameBasePop:IBaseProp) : Boolean
      {
         var stFieldGrid:a_3491 = null;
         var stPropDisplayEffect:MovieClip = null;
         var j:int = 0;
         for(var i:int = 0; i < a_1012; i++)
         {
            for(j = 0; j < a_1011; j++)
            {
               stFieldGrid = this.a_1058[i][j];
               if(null != stFieldGrid.m_stProtector)
               {
                  stFieldGrid.m_stProtector.a_3969(-1 * iChangeLifeValue);
                  stPropDisplayEffect = stGameBasePop.a_4327();
                  stPropDisplayEffect.x = stFieldGrid.m_stProtector.width;
                  stPropDisplayEffect.y = -20;
                  stFieldGrid.m_stProtector.addChild(stPropDisplayEffect);
               }
               if(null != stFieldGrid.m_stAttackFighter && stFieldGrid.m_stAttackFighter.iBreadFighterType > 0)
               {
                  stFieldGrid.m_stAttackFighter.a_3969(-1 * iChangeLifeValue);
                  stPropDisplayEffect = stGameBasePop.a_4327();
                  stPropDisplayEffect.x = stFieldGrid.m_stAttackFighter.width;
                  stPropDisplayEffect.y = -20;
                  stFieldGrid.m_stAttackFighter.addChild(stPropDisplayEffect);
               }
            }
         }
         return true;
      }
      
      private function a_3471(iCurrentTime:int) : void
      {
         var pendingAddMoveIntruderVector:Vector.<a_4269> = null;
         var pendingIntruder:a_4269 = null;
         if(iCurrentTime % 400 == 0)
         {
            pendingAddMoveIntruderVector = new Vector.<a_4269>();
            pendingIntruder = new a_4269();
            pendingIntruder.m_iAppearTime = iCurrentTime + 100;
            pendingIntruder.m_iIntruderGlobalNo = this.a_2180();
            pendingIntruder.m_iIntruderType = 8388613;
            pendingIntruder.m_iIntruderXGridNo = BattleFieldView.a_1011 - 1;
            pendingIntruder.m_iIntruderYGridNo = a_4206.a_1457 == b_181.a_424 ? int(Math.random() * 5) : int(Math.random() * 6);
            if(pendingIntruder.m_iIntruderType >= 8388864)
            {
               pendingIntruder.m_iIntruderYGridNo = 2 + Math.random() * 2;
            }
            pendingAddMoveIntruderVector.push(pendingIntruder);
            this.m_stMoveIntruderManage.a_3608(pendingAddMoveIntruderVector);
         }
      }
   }
}

