package com.aurora.ui.maogoutd.resource.defender.HorseYear.stardome
{
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.defender.SnakeYear.elementSnake.effect.HurtBuff;
   import com.aurora.ui.maogoutd.resource.defender.a_3962;
   import com.aurora.ui.maogoutd.resource.effect.a_4108;
   import flash.display.BitmapData;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class ImperialStrikeHurtBuff extends a_4108
   {
      
      private static var ms_stImperialStrikeHurtBuffVector:Array = new Array();
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(50);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(50);
      
      private static var a_1302:MovieClip = new ImperialStrikeHurtBuffMovie();
      
      private var m_iStartTime:int;
      
      public var stOriginalFieldGrid:a_3491;
      
      public var m_BaseDefense:a_3962;
      
      private var m_Buffs:Vector.<HurtBuff> = new Vector.<HurtBuff>(0);
      
      private var m_TotalPower:Number = 0;
      
      public function ImperialStrikeHurtBuff()
      {
         super();
      }
      
      public static function a_3926() : ImperialStrikeHurtBuff
      {
         var stImperialStrikeHurtBuff:ImperialStrikeHurtBuff = ms_stImperialStrikeHurtBuffVector.pop();
         if(null == stImperialStrikeHurtBuff)
         {
            stImperialStrikeHurtBuff = new ImperialStrikeHurtBuff();
         }
         return stImperialStrikeHurtBuff;
      }
      
      override public function a_1797(isReversed:Boolean) : Boolean
      {
         super.a_1797(isReversed);
         this.m_iStartTime = 0;
         if(this.m_BaseDefense)
         {
            this.addShield(this.m_BaseDefense.stFieldGrid);
            this.m_BaseDefense.m_FangyuBuff = this;
         }
         play();
         return true;
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
      
      public function AddBuff(duration:int, power:Number) : void
      {
         this.m_Buffs.push(new HurtBuff(duration,power));
         this.m_TotalPower += power;
      }
      
      override protected function a_4109(a_4730:Event) : void
      {
         var buff:HurtBuff = null;
         ++this.m_iStartTime;
         nextFrame();
         if(a_1273 == a_1274 || a_1278 != null)
         {
            gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
         }
         for(var i:* = int(this.m_Buffs.length - 1); i >= 0; i--)
         {
            buff = this.m_Buffs[i];
            if(--buff.duration <= 0)
            {
               this.m_TotalPower -= buff.power;
               this.m_Buffs[i] = this.m_Buffs[this.m_Buffs.length - 1];
               this.m_Buffs.pop();
            }
         }
         if(this.m_Buffs.length == 0)
         {
            this.a_3940();
            return;
         }
      }
      
      protected function addShield(stFieldGrid:a_3491) : Boolean
      {
         if(stFieldGrid)
         {
            if(stFieldGrid.m_stCurrentBattbleFieldView.GetGameMoveMap())
            {
               stFieldGrid.m_stCurrentBattbleFieldView.GetGameMoveMap().AddMoveDisplayObject(this,stFieldGrid.m_iXGridNo,stFieldGrid.m_iYGridNo);
            }
         }
         return true;
      }
      
      protected function ClearShield(stFieldGrid:a_3491) : Boolean
      {
         if(stFieldGrid)
         {
            if(stFieldGrid.m_stCurrentBattbleFieldView.GetGameMoveMap())
            {
               stFieldGrid.m_stCurrentBattbleFieldView.GetGameMoveMap().RemoveMoveDisplayObject(this);
            }
         }
         return true;
      }
      
      override public function a_3940() : Boolean
      {
         if(this.m_BaseDefense)
         {
            this.ClearShield(this.m_BaseDefense.stFieldGrid);
            this.m_BaseDefense.m_FangyuBuff = null;
            this.m_BaseDefense = null;
         }
         super.a_3940();
         if(-1 == ms_stImperialStrikeHurtBuffVector.indexOf(this))
         {
            ms_stImperialStrikeHurtBuffVector.push(this);
         }
         if(Boolean(parent) && parent.contains(this))
         {
            parent.removeChild(this);
         }
         return true;
      }
   }
}

