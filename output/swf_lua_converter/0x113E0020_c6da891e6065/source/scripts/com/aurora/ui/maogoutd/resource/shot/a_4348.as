package com.aurora.ui.maogoutd.resource.shot
{
   import a_4718.b_182;
   import a_4718.b_183;
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.Intruder.a_4206;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.FrameLabel;
   
   public class a_4348 extends a_3909
   {
      
      protected var m_iGlobalID:int;
      
      protected var a_1304:int;
      
      protected var a_1325:Number;
      
      protected var a_1326:Number;
      
      protected var a_1327:Number;
      
      protected var a_1571:int;
      
      protected var a_1572:int = 0;
      
      protected var a_1573:int = 0;
      
      protected var a_1574:int = 0;
      
      protected var a_1576:Boolean = false;
      
      protected var a_1577:Boolean = true;
      
      protected var a_1578:Boolean = false;
      
      protected var a_1579:int = 0;
      
      protected var a_1580:int;
      
      protected var m_numXSpeed:Number;
      
      protected var m_numYSpeed:Number;
      
      protected var a_1447:int;
      
      protected var a_1581:int;
      
      protected var a_1582:int;
      
      protected var a_1583:BattleFieldView;
      
      protected var m_iYGridNo:int;
      
      protected var a_1584:a_3491;
      
      protected var a_1585:int;
      
      protected var a_1586:int;
      
      protected var m_isHited:Boolean;
      
      protected var a_1587:int = 0;
      
      protected var a_1588:Boolean = false;
      
      public function a_4348()
      {
         super();
      }
      
      public function set iShotSequenceNum(value:int) : void
      {
         this.a_1580 = value;
      }
      
      public function get globalID() : int
      {
         return this.m_iGlobalID;
      }
      
      public function a_1797(iGlobalID:int, numSpeed:Number, iHurtPower:int, iXpos:int, iYpos:int, stCurrentBattleView:BattleFieldView, stStartFieldGrid:a_3491, isBothWayShot:Boolean = false, numHotMultiplier:Number = 1, iThreeRowShotType:int = 0) : Boolean
      {
         this.m_iGlobalID = iGlobalID;
         this.a_1447 = 0;
         this.a_1580 = 0;
         this.m_numYSpeed = 0;
         this.m_numXSpeed = numSpeed;
         if(stCurrentBattleView.iIntruderMoveDirection > 0)
         {
            this.m_numXSpeed *= -1;
            a_1283 = true;
         }
         else
         {
            a_1283 = false;
         }
         if(isBothWayShot)
         {
            this.m_numXSpeed *= -1;
         }
         this.a_1325 = numHotMultiplier;
         this.a_1326 = 1;
         this.a_1327 = 1;
         this.a_1571 = -1;
         this.a_1579 = iHurtPower;
         x = iXpos;
         y = iYpos;
         this.a_1585 = iXpos;
         this.a_1586 = iYpos;
         this.a_1583 = stCurrentBattleView;
         this.m_iYGridNo = stStartFieldGrid.m_iYGridNo;
         this.a_1584 = stStartFieldGrid;
         this.a_1582 = iThreeRowShotType;
         gotoAndStop(1);
         visible = true;
         this.m_isHited = false;
         this.a_1583.m_stBaseShotVector[this.m_iYGridNo].push(this);
         if(this.a_1576)
         {
            this.a_4349();
         }
         if(2 == this.a_1582)
         {
            this.m_numYSpeed = -1 * Math.abs(this.m_numXSpeed);
         }
         else if(3 == this.a_1582)
         {
            this.m_numYSpeed = 1 * Math.abs(this.m_numXSpeed);
         }
         if(Boolean(this.a_1583) && this.a_1583.isOwnBattleField)
         {
            BattleFieldView.a_1028.play();
         }
         return true;
      }
      
      protected function a_4349() : Boolean
      {
         var iXGridNo:int = 0;
         var stFieldGrid:a_3491 = null;
         var stMoveIntrude:a_4206 = null;
         var arrMoveIntruder:Array = null;
         var numDistance:Number = NaN;
         if(a_1283)
         {
            iXGridNo = BattleFieldView.a_1011 - 1 - int(x / a_3491.a_1080);
         }
         else
         {
            iXGridNo = int(x / a_3491.a_1080);
         }
         for(var i:int = iXGridNo; i < BattleFieldView.a_1011; i++)
         {
            stFieldGrid = this.a_1583.a_3438(i,this.m_iYGridNo);
            if(Boolean(stFieldGrid) && stFieldGrid.a_1511.length > 0)
            {
               arrMoveIntruder = stFieldGrid.a_1511;
               if(stFieldGrid.m_stCurrentBattbleFieldView.iIntruderMoveDirection > 0)
               {
                  arrMoveIntruder.sortOn("x",Array.DESCENDING | Array.NUMERIC);
               }
               else
               {
                  arrMoveIntruder.sortOn("x",Array.NUMERIC);
               }
               stMoveIntrude = arrMoveIntruder[0];
               break;
            }
         }
         if(stMoveIntrude)
         {
            numDistance = Math.abs(stMoveIntrude.x - x) - 0.2 * stMoveIntrude.width;
            this.a_1581 = Math.abs(int(numDistance / this.m_numXSpeed));
            if(numDistance < a_3491.a_1080)
            {
               this.a_1581 = 1;
               this.m_numYSpeed = 0;
            }
            else
            {
               this.m_numYSpeed = 3 * a_3491.a_1081 / this.a_1581;
            }
         }
         return true;
      }
      
      protected function a_3940() : Boolean
      {
         visible = false;
         var stVector:Array = this.a_1583.m_stBaseShotVector[this.m_iYGridNo];
         stVector.splice(stVector.indexOf(this),1);
         return true;
      }
      
      public function a_4350() : Boolean
      {
         return this.a_3940();
      }
      
      public function a_4216(iCurrentTime:int) : void
      {
         var stMoveIntruder:a_4206 = null;
         var numXDistance:Number = NaN;
         var numYDistance:Number = NaN;
         var iMaxConstTime:int = 0;
         var numXSpeed:Number = NaN;
         var numYSpeed:Number = NaN;
         var iModNum:int = 0;
         var numYMove:Number = NaN;
         if(this.m_isHited)
         {
            nextFrame();
            if(a_1273 == a_1274 || a_1278 != null)
            {
               this.a_3940();
            }
            return;
         }
         if(this.a_1588)
         {
            nextFrame();
            if(a_1273 == a_1274 || a_1278 != null)
            {
               gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
            }
         }
         if(0 == this.a_1447)
         {
            this.a_1447 = iCurrentTime;
         }
         this.a_4351();
         if(this.a_1578)
         {
            stMoveIntruder = this.a_1583.a_3431();
            if(stMoveIntruder)
            {
               numXDistance = stMoveIntruder.x - x;
               numYDistance = stMoveIntruder.y + 0.5 * stMoveIntruder.width - y;
               iMaxConstTime = (Math.abs(numXDistance) > Math.abs(numYDistance) ? Math.abs(numXDistance) : Math.abs(numYDistance)) / 10;
               numXSpeed = numXDistance / iMaxConstTime;
               numYSpeed = numYDistance / iMaxConstTime;
               if(this.m_numXSpeed != numXSpeed)
               {
                  iModNum = Math.abs(int(numXSpeed - this.m_numXSpeed)) > 0 ? int(Math.abs(int(numXSpeed - this.m_numXSpeed))) : 1;
                  this.m_numXSpeed += (numXSpeed - this.m_numXSpeed) % iModNum;
               }
               if(this.m_numYSpeed != numYSpeed)
               {
                  iModNum = Math.abs(int(numYSpeed - this.m_numYSpeed)) > 0 ? int(Math.abs(int(numYSpeed - this.m_numYSpeed))) : 1;
                  this.m_numYSpeed += (numYSpeed - this.m_numYSpeed) % iModNum;
               }
            }
            y += this.m_numYSpeed;
         }
         x += this.m_numXSpeed;
         if(2 == this.a_1582 && y > this.a_1586 - a_3491.a_1081 * 0.9)
         {
            y += this.m_numYSpeed;
         }
         else if(3 == this.a_1582 && y < this.a_1586 + a_3491.a_1081 * 0.9)
         {
            y += this.m_numYSpeed;
         }
         if(this.a_1576)
         {
            numYMove = 2 * this.m_numYSpeed * (iCurrentTime - this.a_1447) / this.a_1581 - this.m_numYSpeed;
            y += numYMove > 30 ? 30 : numYMove;
         }
      }
      
      protected function a_4351() : void
      {
         var iXGridNo:int = 0;
         var arrMoveIntruder:Array = null;
         var iArrMoveIntruderLength:int = 0;
         var stMoveIntruder:a_4206 = null;
         var numHotMultiplier:Number = NaN;
         var numColdSlowMultiplier:Number = NaN;
         var stLastWaitShot:a_4348 = null;
         var iNewShotXpos:int = 0;
         var i:int = 0;
         if(a_1283)
         {
            iXGridNo = BattleFieldView.a_1011 - 1 - int(x / a_3491.a_1080);
         }
         else
         {
            iXGridNo = int(x / a_3491.a_1080);
         }
         var iYGridNo:int = this.m_iYGridNo;
         if(x < 0 || x >= BattleFieldView.a_1013 || this.a_1576 && y > a_3491.a_1081 * (this.m_iYGridNo + 1))
         {
            trace("x < 0 || x >= BattleFieldView.ms_iBattleFieldWidth, HitTest failed. x:" + x + ", BattleFieldView.ms_iBattleFieldWidth:" + BattleFieldView.a_1013);
            this.a_3940();
            return;
         }
         var stFieldGrid:a_3491 = this.a_1583.a_3438(iXGridNo,iYGridNo);
         if(!this.a_1576 && this.a_1577 && this.a_1571 != iXGridNo && this.a_1584 != stFieldGrid && null != stFieldGrid.m_stBaseAuxiliaryFighter)
         {
            this.a_1571 = iXGridNo;
            numHotMultiplier = stFieldGrid.m_stBaseAuxiliaryFighter.numHotMultiplier;
            if(numHotMultiplier > 1)
            {
               if(this.a_1574 * this.a_1326 > 0)
               {
                  this.a_1326 = 0;
                  numHotMultiplier = 1;
                  stLastWaitShot = a_4388.getInstance().a_4389(b_183.b_184);
                  if(null != stLastWaitShot)
                  {
                     iNewShotXpos = x + (a_1283 ? -30 : 30);
                     stLastWaitShot.a_1797(0,15,this.a_1579,iNewShotXpos,y,this.a_1583,stFieldGrid,false,this.a_1325);
                     parent.addChild(stLastWaitShot);
                     this.a_3940();
                  }
               }
               else if(numHotMultiplier > this.a_1325)
               {
                  this.a_1325 = numHotMultiplier;
                  stLastWaitShot = a_4388.getInstance().a_4389(b_183.b_189);
                  if(null != stLastWaitShot)
                  {
                     stLastWaitShot.a_1797(0,15,this.a_1579,x,y,this.a_1583,stFieldGrid,false,this.a_1325);
                     parent.addChild(stLastWaitShot);
                     this.a_3940();
                     if(Boolean(this.a_1583) && this.a_1583.isOwnBattleField)
                     {
                        BattleFieldView.a_1029.play();
                     }
                  }
               }
            }
            numColdSlowMultiplier = stFieldGrid.m_stBaseAuxiliaryFighter.numColdSlowMultiplier;
            if(numColdSlowMultiplier > 1)
            {
               if(this.a_1325 > 1)
               {
                  this.a_1326 = 0;
                  numHotMultiplier = 1;
               }
               else if(numColdSlowMultiplier >= this.a_1326)
               {
                  this.a_1326 = numColdSlowMultiplier;
               }
            }
         }
         if(stFieldGrid.m_isOccupy)
         {
            arrMoveIntruder = stFieldGrid.a_1511.slice();
            if(stFieldGrid.m_stCurrentBattbleFieldView.iIntruderMoveDirection > 0)
            {
               arrMoveIntruder.sortOn("x",Array.DESCENDING | Array.NUMERIC);
            }
            else
            {
               arrMoveIntruder.sortOn("x",Array.NUMERIC);
            }
            iArrMoveIntruderLength = int(arrMoveIntruder.length);
            for(i = 0; i < iArrMoveIntruderLength; i++)
            {
               stMoveIntruder = arrMoveIntruder[i];
               if(!stMoveIntruder.isCannotSeeByFighter && (0 == stMoveIntruder.iSpaceState || 2 == stMoveIntruder.iSpaceState && this.a_1576) && hitTestObject(stMoveIntruder))
               {
                  if(Boolean(this.a_1583) && this.a_1583.isOwnBattleField)
                  {
                     BattleFieldView.a_1045.play();
                  }
                  this.a_4352(stMoveIntruder);
                  this.m_isHited = true;
                  if(a_1276.length > 0)
                  {
                     gotoAndStop((a_1276[this.a_1587] as FrameLabel).frame);
                  }
                  return;
               }
            }
         }
         if(a_1283)
         {
            stFieldGrid = this.a_1583.a_3438(iXGridNo + 1,iYGridNo);
         }
         else
         {
            stFieldGrid = this.a_1583.a_3438(iXGridNo - 1,iYGridNo);
         }
         if(null != stFieldGrid && stFieldGrid.m_isOccupy)
         {
            arrMoveIntruder = stFieldGrid.a_1511.slice();
            if(stFieldGrid.m_stCurrentBattbleFieldView.iIntruderMoveDirection > 0)
            {
               arrMoveIntruder.sortOn("x",Array.DESCENDING | Array.NUMERIC);
            }
            else
            {
               arrMoveIntruder.sortOn("x",Array.NUMERIC);
            }
            iArrMoveIntruderLength = int(arrMoveIntruder.length);
            for(i = 0; i < iArrMoveIntruderLength; i++)
            {
               stMoveIntruder = arrMoveIntruder[i];
               if(!stMoveIntruder.isCannotSeeByFighter && (0 == stMoveIntruder.iSpaceState || 2 == stMoveIntruder.iSpaceState && this.a_1576) && hitTestObject(stMoveIntruder))
               {
                  if(Boolean(this.a_1583) && this.a_1583.isOwnBattleField)
                  {
                     BattleFieldView.a_1045.play();
                  }
                  this.a_4352(stMoveIntruder);
                  this.m_isHited = true;
                  if(a_1276.length > 0)
                  {
                     gotoAndStop((a_1276[this.a_1587] as FrameLabel).frame);
                  }
                  return;
               }
            }
         }
      }
      
      public function a_4352(baseMoveIntruder:a_4206) : Boolean
      {
         if(this.a_1576)
         {
            baseMoveIntruder.a_4209(this.a_1579 * this.a_1325);
         }
         else
         {
            baseMoveIntruder.a_3969(this.a_1579 * this.a_1325);
         }
         if(this.a_1573 > 0)
         {
            baseMoveIntruder.a_4208(b_182.a_432,this.a_1573);
         }
         if(this.a_1574 > 0)
         {
            if(baseMoveIntruder.iArmorLifeValue <= 0 || this.a_1576)
            {
               baseMoveIntruder.a_4208(b_182.a_433,this.a_1574 * this.a_1326);
            }
         }
         if(this.a_1325 > 1)
         {
            baseMoveIntruder.a_4208(b_182.a_433,0);
         }
         return true;
      }
   }
}

