package com.aurora.ui.maogoutd.resource.energy
{
   import a_4728.a_1778;
   import a_4753.b_150;
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.events.TimerEvent;
   import flash.geom.Point;
   import flash.utils.Timer;
   
   public class a_4157 extends a_3909
   {
      
      public static var a_1088:b_150;
      
      private var m_iGlobalID:int;
      
      private var a_1434:int;
      
      private var a_1435:Timer;
      
      private var a_1436:int;
      
      private var m_isClicked:Boolean;
      
      private var m_numXSpeed:Number;
      
      private var m_numYSpeed:Number;
      
      private var a_1437:int;
      
      public function a_4157()
      {
         super();
         this.a_1435 = new Timer(50);
         this.a_1435.addEventListener(TimerEvent.TIMER,this.a_4160);
      }
      
      public function get globalID() : int
      {
         return this.m_iGlobalID;
      }
      
      public function a_1797(iGlobalID:int, iEnergyPower:int, numXpos:Number, numYpos:Number, iYMoveDropSpeed:int = 0, iWaitClickTime:int = 153) : Boolean
      {
         this.m_iGlobalID = iGlobalID;
         this.a_1434 = iEnergyPower;
         x = numXpos;
         y = numYpos;
         gotoAndStop(1);
         visible = true;
         this.a_1436 = iWaitClickTime;
         this.m_isClicked = false;
         this.m_numXSpeed = 0;
         this.m_numYSpeed = 0;
         this.a_1437 = iYMoveDropSpeed;
         addEventListener(MouseEvent.MOUSE_DOWN,this.a_4161,false,100);
         this.a_1435.start();
         return true;
      }
      
      protected function a_3940() : Boolean
      {
         visible = false;
         removeEventListener(MouseEvent.MOUSE_DOWN,this.a_4161);
         this.a_1435.stop();
         return true;
      }
      
      private function a_4160(a_4730:Event) : void
      {
         var stDataEvent:a_1778 = null;
         var iVx:int = 0;
         var iVy:int = 0;
         if(this.m_isClicked && this.a_1436 > 0)
         {
            x += this.m_numXSpeed;
            y += this.m_numYSpeed;
            --this.a_1436;
            if(0 >= this.a_1436)
            {
               if(null != parent)
               {
                  stDataEvent = new a_1778("MoneyFlameClick");
                  stDataEvent.dataObject = this.a_1434;
                  if(root)
                  {
                     root.dispatchEvent(stDataEvent);
                  }
                  a_1088.a_2065(this.a_1434);
               }
               this.a_3940();
            }
            return;
         }
         if(0 == this.a_1436 % 2)
         {
            nextFrame();
         }
         if(!this.m_isClicked && this.a_1436 > 140)
         {
            iVx = 0.01;
            iVy = -10 + 2 * (153 - this.a_1436);
            if(this.a_1437 > 0)
            {
               x += iVx;
               y += this.a_1437;
            }
            else
            {
               x += iVx;
               y += iVy;
            }
         }
         if(this.a_1436 > 0)
         {
            --this.a_1436;
            if(a_1273 == a_1274)
            {
               gotoAndStop(1);
            }
            return;
         }
         this.a_3940();
      }
      
      protected function a_4161(a_4730:Event) : void
      {
         removeEventListener(MouseEvent.MOUSE_DOWN,this.a_4161);
         var stGlobalPoint:Point = parent.localToGlobal(new Point(x,y));
         var stRootLocalPoint:Point = root.globalToLocal(stGlobalPoint);
         x = stRootLocalPoint.x;
         y = stRootLocalPoint.y;
         (root as Sprite).addChild(this);
         var iXDistance:int = 190 - stRootLocalPoint.x;
         var iYDistance:int = 5 - stRootLocalPoint.y;
         this.a_1436 = Math.abs(iXDistance) > Math.abs(iYDistance) ? int(Math.abs(int(iXDistance / 40))) : int(Math.abs(int(iYDistance / 40)));
         this.m_isClicked = true;
         this.m_numXSpeed = iXDistance / this.a_1436;
         this.m_numYSpeed = iYDistance / this.a_1436;
         BattleFieldView.a_1025.play();
      }
   }
}

