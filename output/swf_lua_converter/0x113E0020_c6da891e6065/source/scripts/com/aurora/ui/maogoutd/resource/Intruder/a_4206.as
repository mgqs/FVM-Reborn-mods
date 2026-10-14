package com.aurora.ui.maogoutd.resource.Intruder
{
   import a_4718.b_182;
   import a_4753.b_150;
   import com.aurora.protocol.game.maogoutd.CVanishEnemy;
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import com.aurora.ui.maogoutd.resource.defender.a_3962;
   import com.aurora.ui.maogoutd.resource.effect.a_4108;
   import com.aurora.ui.maogoutd.resource.effect.a_4143;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.FrameLabel;
   import flash.display.Sprite;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   
   public class a_4206 extends a_3909
   {
      
      public static var a_1457:int;
      
      public static var a_1088:b_150;
      
      protected static var a_1458:Sprite = new Sprite();
      
      protected var a_1100:Bitmap = new Bitmap();
      
      protected var m_stFreezeUpBitmapData:BitmapData;
      
      public var m_stFreezeUpEffect:a_4108;
      
      private var a_1459:int;
      
      public var m_isRemovedFromBattaleField:Boolean;
      
      public var m_stCurrentFieldGrid:a_3491;
      
      public var m_stMoveIntruderTypeID:int;
      
      protected var a_1460:Boolean = false;
      
      protected var a_1461:Boolean = false;
      
      protected var a_1462:Boolean = false;
      
      protected var a_1465:int = 0;
      
      protected var a_1339:int = 10;
      
      protected var a_1466:int = 0;
      
      protected var a_1467:int = 0;
      
      protected var a_1470:Number = 1;
      
      protected var a_1350:Number;
      
      protected var a_1471:int = 1;
      
      protected var a_1472:int = 0;
      
      protected var a_1473:int = 0;
      
      protected var a_1474:int = 0;
      
      protected var a_1475:Boolean;
      
      protected var a_1377:int = 1;
      
      protected var a_1476:int = 12;
      
      protected var a_1477:int = 0;
      
      protected var a_1478:Number = 1;
      
      protected var a_1479:int = 2;
      
      protected var a_1480:int = 0;
      
      private var a_1482:Boolean = false;
      
      public function a_4206()
      {
         super();
         gotoAndStop(1);
      }
      
      public function get iSpaceState() : int
      {
         return this.a_1465;
      }
      
      public function get isCannotSeeByFighter() : Boolean
      {
         return this.a_1462;
      }
      
      public function get iLifeValue() : int
      {
         return this.a_1339;
      }
      
      public function get iArmorLifeValue() : int
      {
         return this.a_1466;
      }
      
      public function get isEatingDefense() : Boolean
      {
         return this.a_1475;
      }
      
      public function get iYPosSkewing() : int
      {
         return this.a_1467;
      }
      
      public function a_1797(iGlobalMoveFighterID:int, iIntruderMoveDirection:int) : Boolean
      {
         this.a_1460 = false;
         this.a_1472 = 0;
         this.a_1473 = 0;
         this.a_1474 = 0;
         this.a_1475 = false;
         this.a_1477 = 0;
         this.a_1480 = 0;
         this.m_isRemovedFromBattaleField = false;
         this.a_1459 = iGlobalMoveFighterID;
         if(iIntruderMoveDirection < 0)
         {
            a_1283 = false;
         }
         else
         {
            a_1283 = true;
         }
         this.a_1470 = 1;
         this.a_1478 = 1;
         a_1285 = 0;
         a_1284 = 0;
         gotoAndStop(1);
         a_1275 = 0;
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
      
      protected function a_3940() : Boolean
      {
         var stEnemyVanish:CVanishEnemy = null;
         var arrBaseMoveIntruderVector:Array = null;
         if(Boolean(a_1088) && Boolean(this.m_stCurrentFieldGrid))
         {
            stEnemyVanish = new CVanishEnemy();
            stEnemyVanish.m_iEnemyID = this.a_1459;
            stEnemyVanish.m_iEnemyTypeID = this.m_stMoveIntruderTypeID - 8388608;
            stEnemyVanish.m_byYGridNo = this.m_stCurrentFieldGrid.m_iYGridNo;
            stEnemyVanish.m_byXGridNo = this.m_stCurrentFieldGrid.m_iXGridNo;
            a_1088.a_2061(this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.iTimeIntervalNum,this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.m_byTeamNo,[stEnemyVanish]);
         }
         if(this.m_stCurrentFieldGrid)
         {
            arrBaseMoveIntruderVector = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.m_arrBaseMoveIntruderVector;
            if(-1 != arrBaseMoveIntruderVector.indexOf(this))
            {
               arrBaseMoveIntruderVector.splice(arrBaseMoveIntruderVector.indexOf(this),1);
            }
         }
         visible = false;
         gotoAndStop(1);
         this.m_stCurrentFieldGrid = null;
         this.stop();
         return true;
      }
      
      protected function ResetMovieStatus() : Boolean
      {
         return false;
      }
      
      public function a_4208(iEffectType:int, iEffectTime:int, stBaseEffect:a_4108 = null) : void
      {
         var stRect:Rectangle = null;
         if(b_182.a_432 == iEffectType)
         {
            a_1284 = iEffectTime;
         }
         else if(b_182.a_433 == iEffectType)
         {
            a_1284 = 1;
            if(iEffectTime > a_1285)
            {
               a_1285 = iEffectTime;
               this.a_1470 = 0.38;
               this.a_1478 = 1.5;
            }
            else if(0 == iEffectTime)
            {
               a_1285 = 0;
            }
         }
         else if(b_182.a_434 == iEffectType)
         {
            if(0 == a_1468 && iEffectTime > 0)
            {
               if(this.m_stFreezeUpBitmapData)
               {
                  this.m_stFreezeUpBitmapData.dispose();
                  this.m_stFreezeUpBitmapData = null;
               }
               if(Boolean(stDisplayBitmap && stDisplayBitmap.bitmapData) && Boolean(stDisplayBitmap.width > 0) && stDisplayBitmap.height > 0)
               {
                  this.m_stFreezeUpBitmapData = stDisplayBitmap.bitmapData.clone();
                  stRect = new Rectangle(0,0,this.m_stFreezeUpBitmapData.width,this.m_stFreezeUpBitmapData.height);
                  this.m_stFreezeUpBitmapData.colorTransform(stRect,new ColorTransform(0.1,0.8,1.6,1,-30,-30,-30,0));
                  stDisplayBitmap.bitmapData = this.m_stFreezeUpBitmapData;
               }
               if(Boolean(this.m_stFreezeUpEffect) && this.m_stFreezeUpEffect.visible)
               {
                  this.m_stFreezeUpEffect.a_3940();
                  this.m_stFreezeUpEffect = null;
               }
               this.m_stFreezeUpEffect = stBaseEffect;
               this.m_stFreezeUpEffect.a_1797(a_1283);
               this.m_stFreezeUpEffect.x = x + 0.5 * (width - this.m_stFreezeUpEffect.width) + stDisplayBitmap.x;
               this.m_stFreezeUpEffect.y = y + (height - this.m_stFreezeUpEffect.height) + stDisplayBitmap.y;
               parent.addChildAt(this.m_stFreezeUpEffect,parent.getChildIndex(this) + 1);
            }
            if(iEffectTime > a_1285)
            {
               a_1468 = iEffectTime;
            }
         }
      }
      
      public function a_3969(iRduceLifeValue:int) : Boolean
      {
         if(this.a_1466 > 0)
         {
            this.a_1466 -= iRduceLifeValue;
         }
         else
         {
            this.a_1339 -= iRduceLifeValue;
         }
         if(this.a_1339 <= 0)
         {
            a_1468 = 0;
            if(Boolean(this.m_stFreezeUpEffect) && this.m_stFreezeUpEffect.visible)
            {
               this.m_stFreezeUpEffect.a_3940();
               this.m_stFreezeUpEffect = null;
            }
         }
         if(Math.abs(iRduceLifeValue) > 1)
         {
            this.ResetMovieStatus();
         }
         return true;
      }
      
      public function a_4209(iRduceLifeValue:int) : Boolean
      {
         this.a_1339 -= iRduceLifeValue;
         if(this.a_1339 <= 0)
         {
            a_1468 = 0;
            if(Boolean(this.m_stFreezeUpEffect) && this.m_stFreezeUpEffect.visible)
            {
               this.m_stFreezeUpEffect.a_3940();
               this.m_stFreezeUpEffect = null;
            }
         }
         if(Math.abs(iRduceLifeValue) > 1)
         {
            this.ResetMovieStatus();
         }
         return true;
      }
      
      public function a_4210() : Boolean
      {
         var stSmallMouseBoomdie:a_4143 = null;
         if(this.a_1461)
         {
            this.a_3969(this.a_1339);
            this.a_3940();
         }
         else
         {
            this.a_1339 = 0;
            stSmallMouseBoomdie = a_4143.a_3926();
            stSmallMouseBoomdie.a_1797(a_1283);
            stSmallMouseBoomdie.x = x + (stSmallMouseBoomdie.width - width) + stDisplayBitmap.x;
            stSmallMouseBoomdie.y = y + (stSmallMouseBoomdie.height - height) + stDisplayBitmap.y;
            parent.addChildAt(stSmallMouseBoomdie,parent.getChildIndex(this));
            this.a_3940();
         }
         return true;
      }
      
      public function a_4211(iCutLifeValue:int) : Boolean
      {
         this.a_1339 -= iCutLifeValue;
         if(this.a_1339 <= 0)
         {
            this.m_stCurrentFieldGrid.a_3457(this);
            this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
            this.a_3940();
         }
         return true;
      }
      
      public function a_4212() : Boolean
      {
         this.a_1339 = 0;
         this.m_stCurrentFieldGrid.a_3457(this);
         this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
         this.a_3940();
         return true;
      }
      
      public function a_4215(stBaseDefense:a_3962) : Boolean
      {
         BattleFieldView.ms_kenShi29.play();
         return stBaseDefense.a_3969(this.a_1377);
      }
      
      public function a_4216(iCurrentTime:int) : Boolean
      {
         var iXGridNo:int = 0;
         var stNextFielGrid:a_3491 = null;
         var numMoveSpeed:Number = NaN;
         if(!this.a_1460)
         {
            this.a_1460 = true;
            BattleFieldView.a_1019.play();
         }
         if(a_1468 > 0)
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
            this.a_1474 = 20;
         }
         if(!a_1283 && x <= 0 || a_1283 && x >= BattleFieldView.a_1013)
         {
            x += this.a_1350 * this.a_1470;
            if(!a_1283 && x <= -40 || a_1283 && x >= BattleFieldView.a_1013 + 40)
            {
               if(this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.isOwnBattleField)
               {
                  a_1088.a_2062(this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.iTimeIntervalNum,this.m_stCurrentFieldGrid.m_iYGridNo);
               }
               trace("m_isReversed && x <= -40 || !m_isReversed && x >= BattleFieldView.ms_iBattleFieldWidth + 40  Realease the MoveIntruder");
               this.m_stCurrentFieldGrid.a_3457(this);
               this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3457(this);
               this.a_3940();
               return true;
            }
            return true;
         }
         if(this.a_1474 <= 0 && iCurrentTime >= this.a_1472 + this.a_1471 && this.m_stCurrentFieldGrid.m_stProtector == null && this.m_stCurrentFieldGrid.m_stAttackFighter == null && this.m_stCurrentFieldGrid.m_stFlowerDefense == null && this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter == null && this.m_stCurrentFieldGrid.m_stTrayDefense == null && (this.m_stCurrentFieldGrid.m_stBoomDefense == null || !this.m_stCurrentFieldGrid.m_stBoomDefense.isCanBeEaten))
         {
            this.a_1472 = iCurrentTime;
            this.play();
            x += this.a_1350 * this.a_1470;
            iXGridNo = int(x / a_3491.a_1080);
            if(a_1283)
            {
               iXGridNo = BattleFieldView.a_1011 - 1 - iXGridNo;
            }
            if(iXGridNo >= 0 && iXGridNo < BattleFieldView.a_1011 && this.m_stCurrentFieldGrid.m_iXGridNo != iXGridNo)
            {
               stNextFielGrid = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3438(iXGridNo,this.m_stCurrentFieldGrid.m_iYGridNo);
               stNextFielGrid.a_3459(this);
               if(stNextFielGrid.m_stBaseLander != null)
               {
                  this.a_1474 = 20;
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
            x += numMoveSpeed;
            y += 6 * (10 - this.a_1474 > 0 ? 1 : -1);
            iXGridNo = int(x / a_3491.a_1080);
            if(a_1283)
            {
               iXGridNo = BattleFieldView.a_1011 - 1 - iXGridNo;
            }
            if(iXGridNo >= 0 && iXGridNo < BattleFieldView.a_1011 && this.m_stCurrentFieldGrid.m_iXGridNo != iXGridNo)
            {
               stNextFielGrid = this.m_stCurrentFieldGrid.m_stCurrentBattbleFieldView.a_3438(iXGridNo,this.m_stCurrentFieldGrid.m_iYGridNo);
               stNextFielGrid.a_3459(this);
               if(stNextFielGrid.m_stBaseLander != null)
               {
                  this.a_1474 = 20;
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
         if(this.a_1473 <= 0 && this.a_1474 <= 0 && iCurrentTime >= this.a_1477 + this.a_1476 * (1 / this.a_1470))
         {
            if(this.m_stCurrentFieldGrid.m_stBaseLander != null)
            {
               this.a_1474 = 20;
               this.a_1475 = false;
               this.ResetMovieStatus();
            }
            if(null != this.m_stCurrentFieldGrid.m_stProtector)
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stProtector);
               this.ResetMovieStatus();
            }
            else if(null != this.m_stCurrentFieldGrid.m_stAttackFighter)
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stAttackFighter);
               this.ResetMovieStatus();
            }
            else if(null != this.m_stCurrentFieldGrid.m_stBoomDefense && this.m_stCurrentFieldGrid.m_stBoomDefense.isCanBeEaten)
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stBoomDefense);
               this.ResetMovieStatus();
            }
            else if(null != this.m_stCurrentFieldGrid.m_stFlowerDefense)
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stFlowerDefense);
               this.ResetMovieStatus();
            }
            else if(null != this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter)
            {
               this.a_1477 = iCurrentTime;
               this.a_1475 = true;
               this.a_4215(this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter);
               this.ResetMovieStatus();
            }
            else if(null != this.m_stCurrentFieldGrid.m_stTrayDefense)
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
         if(this.a_1475 && null == this.m_stCurrentFieldGrid.m_stProtector && null == this.m_stCurrentFieldGrid.m_stAttackFighter && null == this.m_stCurrentFieldGrid.m_stFlowerDefense && null == this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter && null == this.m_stCurrentFieldGrid.m_stTrayDefense && null == this.m_stCurrentFieldGrid.m_stBoomDefense)
         {
            this.a_1475 = false;
            this.ResetMovieStatus();
         }
         return true;
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
         if(a_1468 > 0)
         {
            --a_1468;
            this.stop();
            if(Boolean(6 == a_1468) && Boolean(this.m_stFreezeUpEffect) && this.m_stFreezeUpEffect.visible)
            {
               this.m_stFreezeUpEffect.play();
            }
            if(0 == a_1468)
            {
               BattleFieldView.ms_pobing81.play();
            }
            return;
         }
         if(this.a_1482)
         {
            this.a_4160(iCurrentTime);
         }
      }
      
      private function a_4160(iCurrentTime:int) : void
      {
         if(this.a_1478 != 1 && iCurrentTime < this.a_1480 + this.a_1479 * this.a_1478)
         {
            if(a_1285 > 0)
            {
               --a_1285;
            }
            return;
         }
         this.a_1480 = iCurrentTime;
         nextFrame();
         if(0 == a_1285)
         {
            this.a_1478 = 1;
            this.a_1470 = 1;
         }
         if(a_1273 == a_1274)
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
            gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
            if(this.a_1475 && null == this.m_stCurrentFieldGrid.m_stProtector && null == this.m_stCurrentFieldGrid.m_stAttackFighter && null == this.m_stCurrentFieldGrid.m_stFlowerDefense && null == this.m_stCurrentFieldGrid.m_stBaseAuxiliaryFighter && null == this.m_stCurrentFieldGrid.m_stTrayDefense && null == this.m_stCurrentFieldGrid.m_stBoomDefense)
            {
               this.a_1475 = false;
               this.ResetMovieStatus();
            }
         }
      }
   }
}

