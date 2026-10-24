package com.aurora.ui.maogoutd.resource.defender
{
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.shot.a_4348;
   import com.aurora.ui.maogoutd.resource.shot.a_4388;
   import flash.display.FrameLabel;
   
   public class a_3953 extends a_3962
   {
      
      protected var a_1304:uint = 0;
      
      protected var a_1305:Boolean = false;
      
      protected var a_1306:Boolean = false;
      
      protected var a_1307:int = 0;
      
      protected var m_iShotNum:int;
      
      protected var a_1308:int = 20;
      
      protected var a_1309:int = 26;
      
      protected var a_1310:int = 0;
      
      protected var a_1311:int = 1;
      
      protected var a_1312:int = 10;
      
      protected var a_1313:Boolean = false;
      
      protected var a_1314:Boolean = false;
      
      protected var a_1315:Boolean = false;
      
      protected var a_1316:Boolean = false;
      
      protected var a_1317:int = 0;
      
      protected var a_1318:Boolean = false;
      
      protected var a_1319:int = -1;
      
      protected var a_1320:int = 1;
      
      protected var a_1321:int = 0;
      
      protected var a_1323:int;
      
      protected var a_1324:Array = [];
      
      public function a_3953()
      {
         a_1275 = 0;
         super();
      }
      
      public function get iBattleFighterType() : int
      {
         return this.a_1320;
      }
      
      public function get iBreadFighterType() : int
      {
         return this.a_1319;
      }
      
      public function get isShotAllTheTime() : Boolean
      {
         return this.a_1313;
      }
      
      public function get isCanInWater() : Boolean
      {
         return this.a_1305;
      }
      
      public function get isOnlyOnTray() : Boolean
      {
         return this.a_1306;
      }
      
      override public function a_1797(stFieldGrid:a_3491) : Boolean
      {
         this.a_1321 = 0;
         return super.a_1797(stFieldGrid);
      }
      
      public function a_3954(iCurrentTime:int) : Boolean
      {
         var stLastWaitShot:a_4348 = null;
         var numShotXpos:Number = NaN;
         var i:int = 0;
         var stStartField:a_3491 = null;
         if(iCurrentTime > m_iPlaceTimeIntervals + this.a_1308 && iCurrentTime >= this.a_1321 + this.a_1309)
         {
            if(this.a_1316 && a_1334.m_stCurrentBattbleFieldView.a_3430(a_1334.m_iYGridNo) <= 0)
            {
               return true;
            }
            this.a_1321 = iCurrentTime;
            stLastWaitShot = a_4388.getInstance().a_4389(this.a_1304);
            if(null == stLastWaitShot)
            {
               return false;
            }
            this.a_1323 = 1;
            this.a_1324.push(stLastWaitShot);
            if(this.a_1314 || this.a_1318)
            {
               stLastWaitShot = a_4388.getInstance().a_4389(this.a_1304);
               if(null == stLastWaitShot)
               {
                  return false;
               }
               this.a_1324.push(stLastWaitShot);
            }
            else if(this.a_1316)
            {
               if(a_1334.m_iYGridNo > 0)
               {
                  stLastWaitShot = a_4388.getInstance().a_4389(this.a_1304);
                  if(null == stLastWaitShot)
                  {
                     return false;
                  }
                  this.a_1324.push(stLastWaitShot);
               }
               if(a_1334.m_iYGridNo < BattleFieldView.a_1012 - 1)
               {
                  stLastWaitShot = a_4388.getInstance().a_4389(this.a_1304);
                  if(null == stLastWaitShot)
                  {
                     return false;
                  }
                  this.a_1324.push(stLastWaitShot);
               }
            }
            else if(this.a_1315)
            {
               i = 0;
               while(true)
               {
                  if(i < 3)
                  {
                     stLastWaitShot = a_4388.getInstance().a_4389(this.a_1304);
                     if(null == stLastWaitShot)
                     {
                        break;
                     }
                     this.a_1324.push(stLastWaitShot);
                     i++;
                     continue;
                  }
               }
               return false;
            }
            this.a_1307 = a_1273;
            a_1275 = 0;
            gotoAndStop((a_1276[1] as FrameLabel).frame);
         }
         if(iCurrentTime - this.a_1321 == this.a_1310 && this.a_1324.length > 0)
         {
            numShotXpos = this.a_3955();
            if(a_1283)
            {
               numShotXpos = -numShotXpos;
            }
            stLastWaitShot = this.a_1324.pop();
            stLastWaitShot.a_1797(0,this.a_1312,this.a_1311,x + numShotXpos,y + this.a_3956(),a_1334.m_stCurrentBattbleFieldView,a_1334);
            parent.addChildAt(stLastWaitShot,a_1334.m_stCurrentBattbleFieldView.a_3433());
         }
         if(this.a_1314 && iCurrentTime - this.a_1321 == this.a_1310 + this.a_1317 && this.a_1324.length > 0)
         {
            numShotXpos = this.a_3955();
            if(a_1283)
            {
               numShotXpos = -numShotXpos;
            }
            stLastWaitShot = this.a_1324.pop();
            stLastWaitShot.a_1797(0,this.a_1312,this.a_1311,x + numShotXpos,y + this.a_3956(),a_1334.m_stCurrentBattbleFieldView,a_1334);
            stLastWaitShot.iShotSequenceNum = 1;
            parent.addChildAt(stLastWaitShot,a_1334.m_stCurrentBattbleFieldView.a_3433());
         }
         if(this.a_1316 && iCurrentTime - this.a_1321 == this.a_1310 + this.a_1317 * this.a_1323 && this.a_1324.length > 0)
         {
            numShotXpos = this.a_3955();
            if(a_1283)
            {
               numShotXpos = -numShotXpos;
            }
            if(1 == this.a_1323 && a_1334.m_iYGridNo > 0)
            {
               stLastWaitShot = this.a_1324.pop();
               stStartField = a_1334.m_stCurrentBattbleFieldView.a_3438(a_1334.m_iXGridNo,a_1334.m_iYGridNo - 1);
               stLastWaitShot.a_1797(0,this.a_1312,this.a_1311,x + numShotXpos,y + this.a_3956() - 5,a_1334.m_stCurrentBattbleFieldView,stStartField,false,1,2);
               stLastWaitShot.iShotSequenceNum = this.a_1323;
               parent.addChildAt(stLastWaitShot,a_1334.m_stCurrentBattbleFieldView.a_3433());
            }
            else if(2 == this.a_1323 && a_1334.m_iYGridNo < BattleFieldView.a_1012 - 1)
            {
               stLastWaitShot = this.a_1324.pop();
               stStartField = a_1334.m_stCurrentBattbleFieldView.a_3438(a_1334.m_iXGridNo,a_1334.m_iYGridNo + 1);
               stLastWaitShot.a_1797(0,this.a_1312,this.a_1311,x + numShotXpos,y + this.a_3956() + 5,a_1334.m_stCurrentBattbleFieldView,stStartField,false,1,3);
               stLastWaitShot.iShotSequenceNum = this.a_1323;
               parent.addChildAt(stLastWaitShot,a_1334.m_stCurrentBattbleFieldView.a_3433());
            }
            if(this.a_1324.length > 0)
            {
               ++this.a_1323;
            }
         }
         if(this.a_1315 && iCurrentTime - this.a_1321 == this.a_1310 + this.a_1317 * this.a_1323 && this.a_1324.length > 0)
         {
            numShotXpos = this.a_3955();
            if(a_1283)
            {
               numShotXpos = -numShotXpos;
            }
            stLastWaitShot = this.a_1324.pop();
            stLastWaitShot.a_1797(0,this.a_1312,this.a_1311,x + numShotXpos,y + this.a_3956(),a_1334.m_stCurrentBattbleFieldView,a_1334);
            stLastWaitShot.iShotSequenceNum = this.a_1323;
            parent.addChildAt(stLastWaitShot,a_1334.m_stCurrentBattbleFieldView.a_3433());
            if(this.a_1324.length > 0)
            {
               ++this.a_1323;
            }
         }
         if(this.a_1318 && iCurrentTime - this.a_1321 == this.a_1310 + this.a_1317 && this.a_1324.length > 0)
         {
            numShotXpos = this.a_3955();
            if(a_1283)
            {
               numShotXpos = -numShotXpos;
            }
            numShotXpos = width - numShotXpos;
            stLastWaitShot = this.a_1324.pop();
            stLastWaitShot.a_1797(0,this.a_1312,this.a_1311,x + numShotXpos,y + this.a_3956(),a_1334.m_stCurrentBattbleFieldView,a_1334,true);
            stLastWaitShot.iShotSequenceNum = 1;
            parent.addChildAt(stLastWaitShot,a_1334.m_stCurrentBattbleFieldView.a_3433());
         }
         return true;
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
      
      protected function a_3955() : Number
      {
         return width * 0.8;
      }
      
      protected function a_3956() : Number
      {
         return 0.25 * height;
      }
      
      public function a_3957(iCurrentTime:int) : void
      {
         nextFrame();
         if(a_1278 != null)
         {
            gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
         }
         if(a_1273 == a_1274)
         {
            gotoAndStop(this.a_1307);
         }
      }
      
      override public function a_3940() : Boolean
      {
         if(a_1334)
         {
            a_1334.a_3497(this);
         }
         super.a_3940();
         return true;
      }
   }
}

