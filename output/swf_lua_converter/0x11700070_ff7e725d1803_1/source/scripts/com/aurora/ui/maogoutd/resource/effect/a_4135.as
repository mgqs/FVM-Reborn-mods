package com.aurora.ui.maogoutd.resource.effect
{
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.avatar.a_3924;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.utils.clearTimeout;
   
   public class a_4135 extends a_4108
   {
      
      private static var a_1420:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(20);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(20);
      
      private static var a_1302:MovieClip = new MouseEarthHoleMovie();
      
      public var m_stCurrentFieldGrid:a_3491;
      
      public var timerout:int = -1;
      
      public var m_iOldFieldGridType:int;
      
      public function a_4135()
      {
         super();
      }
      
      public static function a_3926() : a_4135
      {
         var stMouseEarthHole:a_4135 = a_1420.pop();
         if(null == stMouseEarthHole)
         {
            stMouseEarthHole = new a_4135();
         }
         return stMouseEarthHole;
      }
      
      override public function a_1797(isReversed:Boolean) : Boolean
      {
         this.m_iOldFieldGridType = -1;
         this.timerout = -1;
         this.a_3502(this.m_stCurrentFieldGrid);
         return super.a_1797(isReversed);
      }
      
      override protected function a_3911() : Vector.<BitmapData>
      {
         return a_1300;
      }
      
      override protected function a_3912() : Vector.<Point>
      {
         return a_1301;
      }
      
      override protected function a_3913() : MovieClip
      {
         return a_1302;
      }
      
      override public function a_3940() : Boolean
      {
         if(this.timerout)
         {
            clearTimeout(this.timerout);
            this.timerout = -1;
         }
         if(this.m_iOldFieldGridType != -1 && this.m_stCurrentFieldGrid != null)
         {
            this.m_stCurrentFieldGrid.m_iFieldGridType = this.m_iOldFieldGridType;
            this.m_stCurrentFieldGrid = null;
            this.m_iOldFieldGridType = -1;
         }
         super.a_3940();
         if(Boolean(parent) && parent.contains(this))
         {
            parent.removeChild(this);
         }
         return true;
      }
      
      override protected function a_4109(a_4730:Event) : void
      {
         nextFrame();
         if(a_1273 == a_1274)
         {
            stop();
         }
      }
      
      protected function ClearPigBarrierField(stFieldGrid:a_3491) : Boolean
      {
         if(stFieldGrid == null)
         {
            return false;
         }
         if(stFieldGrid.m_stMouseEarthHole)
         {
            stFieldGrid.m_stMouseEarthHole.a_3940();
            stFieldGrid.m_stMouseEarthHole = null;
         }
         if(stFieldGrid.m_stBaseLander != null)
         {
            stFieldGrid.m_stBaseLander.a_3940();
            stFieldGrid.m_stBaseLander = null;
         }
         if(this.m_iOldFieldGridType != -1)
         {
            stFieldGrid.m_iFieldGridType = this.m_iOldFieldGridType;
         }
         return true;
      }
      
      protected function a_3502(stFieldGrid:a_3491) : Boolean
      {
         if(stFieldGrid == null)
         {
            return false;
         }
         if(null != stFieldGrid.m_stProtector)
         {
            stFieldGrid.m_stProtector.m_iDieType = 1;
            stFieldGrid.m_stProtector.a_3969(stFieldGrid.m_stProtector.iLifeValue);
         }
         if(null != stFieldGrid.m_stAttackFighter && !(stFieldGrid.m_stAttackFighter is a_3924))
         {
            stFieldGrid.m_stAttackFighter.m_iDieType = 1;
            stFieldGrid.m_stAttackFighter.a_3969(stFieldGrid.m_stAttackFighter.iLifeValue);
         }
         if(null != stFieldGrid.m_stBoomDefense)
         {
            stFieldGrid.m_stBoomDefense.m_iDieType = 1;
            stFieldGrid.m_stBoomDefense.a_3969(stFieldGrid.m_stBoomDefense.iLifeValue);
         }
         if(null != stFieldGrid.m_stFlowerDefense)
         {
            stFieldGrid.m_stFlowerDefense.m_iDieType = 1;
            stFieldGrid.m_stFlowerDefense.a_3969(stFieldGrid.m_stFlowerDefense.iLifeValue);
         }
         if(null != stFieldGrid.m_stBaseAuxiliaryFighter)
         {
            stFieldGrid.m_stBaseAuxiliaryFighter.m_iDieType = 1;
            stFieldGrid.m_stBaseAuxiliaryFighter.a_3969(stFieldGrid.m_stBaseAuxiliaryFighter.iLifeValue);
         }
         if(null != stFieldGrid.m_stTrayDefense)
         {
            stFieldGrid.m_stTrayDefense.m_iDieType = 1;
            stFieldGrid.m_stTrayDefense.a_3969(stFieldGrid.m_stTrayDefense.iLifeValue);
         }
         return true;
      }
   }
}

