package com.aurora.ui.maogoutd.resource.defender
{
   import a_4753.b_150;
   import com.aurora.protocol.game.maogoutd.CVanishDefender;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.Bitmap;
   
   public class a_3962 extends a_3909
   {
      
      public static var a_1088:b_150;
      
      public var m_stShadowRefence:Bitmap;
      
      public var m_iDefenseGlobalID:int;
      
      public var m_iPlaceTimeIntervals:uint;
      
      protected var a_1333:Boolean = false;
      
      protected var a_1098:uint;
      
      protected var a_1095:uint;
      
      protected var a_1334:a_3491;
      
      protected var a_1337:int = 0;
      
      protected var a_1338:int = 0;
      
      protected var a_1339:int;
      
      protected var a_1340:Boolean = false;
      
      public function a_3962()
      {
         super();
         gotoAndStop(1);
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
      
      public function set iDefenseTypeID(value:uint) : void
      {
         this.a_1098 = value;
      }
      
      public function get iDefensePrice() : uint
      {
         return this.a_1095;
      }
      
      public function get iLifeValue() : int
      {
         return this.a_1339;
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
      
      public function a_1797(stFieldGrid:a_3491) : Boolean
      {
         this.m_stShadowRefence = null;
         this.a_1334 = stFieldGrid;
         if(stFieldGrid.m_stCurrentBattbleFieldView.iIntruderMoveDirection > 0)
         {
            a_1283 = true;
         }
         else
         {
            a_1283 = false;
         }
         gotoAndStop(1);
         a_1275 = 0;
         a_1282 = true;
         return true;
      }
      
      protected function a_3964() : int
      {
         return 70;
      }
      
      public function a_3969(iRduceLifeValue:int) : Boolean
      {
         var stDefenderInfo:CVanishDefender = null;
         var iVanishTimeNum:int = 0;
         this.a_1339 -= iRduceLifeValue;
         if(Boolean(this.a_1334) && this.a_1339 <= 0)
         {
            stDefenderInfo = new CVanishDefender();
            stDefenderInfo.m_iDefenderID = this.m_iDefenseGlobalID;
            stDefenderInfo.m_iDefenderTypeID = this.a_1098;
            stDefenderInfo.m_byXGridNo = this.a_1334.m_iXGridNo;
            stDefenderInfo.m_byYGridNo = this.a_1334.m_iYGridNo;
            stDefenderInfo.m_byIsTool = 0;
            iVanishTimeNum = this.a_1334.m_stCurrentBattbleFieldView.iTimeIntervalNum;
            a_1088.a_2060(iVanishTimeNum,this.a_1334.m_stCurrentBattbleFieldView.m_byTeamNo,new Array(stDefenderInfo));
         }
         return true;
      }
      
      public function a_3940() : Boolean
      {
         if(Boolean(this.a_1334) && null != this.m_stShadowRefence)
         {
            this.a_1334.m_stCurrentBattbleFieldView.removeChild(this.m_stShadowRefence);
            this.m_stShadowRefence = null;
         }
         this.a_1334 = null;
         visible = false;
         a_1283 = false;
         gotoAndStop(1);
         return true;
      }
      
      public function a_3970() : Boolean
      {
         return false;
      }
   }
}

