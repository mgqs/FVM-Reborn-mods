package com.aurora.ui.maogoutd.resource.defender.fusionCard.termiThreeShotGun
{
   import com.aurora.ui.maogoutd.resource.Intruder.a_4206;
   import com.aurora.ui.maogoutd.resource.defender.DragonYear.CandleYinDragon.FireBurnBuffMovie;
   import com.aurora.ui.maogoutd.resource.defender.SnakeYear.elementSnake.effect.HurtBuff;
   import com.aurora.ui.maogoutd.resource.effect.a_4108;
   import flash.display.BitmapData;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public class IntruderBurnEffect extends a_4108
   {
      
      private static var ms_stIntruderBurnEffectVector:Array = [];
      
      private static var a_1300:Vector.<BitmapData> = new Vector.<BitmapData>(100);
      
      private static var a_1301:Vector.<Point> = new Vector.<Point>(100);
      
      private static var a_1302:MovieClip = new FireBurnBuffMovie();
      
      private var m_iStartTime:int;
      
      public var stTargetIntruder:a_4206;
      
      private var m_Buffs:Vector.<HurtBuff> = new Vector.<HurtBuff>(0);
      
      private var m_TotalPower:Number = 0;
      
      private var m_iDamageTick:int = 10;
      
      private var m_txtBuffInfo:TextField;
      
      public function IntruderBurnEffect()
      {
         super();
         a_1279 = -24;
         m_iYDisplayCenterPos = -16;
      }
      
      public static function a_3926() : IntruderBurnEffect
      {
         var stIntruderBurnEffect:IntruderBurnEffect = ms_stIntruderBurnEffectVector.pop();
         if(stIntruderBurnEffect == null)
         {
            stIntruderBurnEffect = new IntruderBurnEffect();
         }
         return stIntruderBurnEffect;
      }
      
      override public function a_1797(isReseaved:Boolean) : Boolean
      {
         super.a_1797(isReseaved);
         this.m_iStartTime = -1;
         this.m_TotalPower = 0;
         if(this.stTargetIntruder)
         {
            this.stTargetIntruder.m_stGeneralBurnEffect = this;
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
         if(this.m_iStartTime % this.m_iDamageTick == 0 && this.stTargetIntruder != null)
         {
            this.a_4352(this.m_TotalPower);
         }
         this.updateBuffDisplay();
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
      
      private function a_4352(totalPower:Number) : void
      {
         if(this.stTargetIntruder == null)
         {
            return;
         }
         this.stTargetIntruder.a_3969(totalPower);
      }
      
      private function updateBuffDisplay() : void
      {
         var b:HurtBuff = null;
         if(!this.m_txtBuffInfo)
         {
            return;
         }
         var count:int = int(this.m_Buffs.length);
         if(count == 0)
         {
            return;
         }
         var maxSeconds:int = 0;
         for each(b in this.m_Buffs)
         {
            if(b.duration > maxSeconds)
            {
               maxSeconds = b.duration;
            }
         }
         CanAddBuffInfoManager.Get().updateBuffText(this.m_txtBuffInfo,count,maxSeconds / 10);
         if(!this.m_txtBuffInfo.parent)
         {
            this.parent.addChild(this.m_txtBuffInfo);
            this.m_txtBuffInfo.y = this.y + m_iYDisplayCenterPos;
         }
         var worldY:Number = this.y + this.height;
         this.m_txtBuffInfo.x = this.x + (this.width - this.m_txtBuffInfo.width) * 0.5 + a_1279;
      }
      
      override public function a_3940() : Boolean
      {
         super.a_3940();
         if(this.m_txtBuffInfo != null)
         {
            CanAddBuffInfoManager.Get().HideBuffText(this.m_txtBuffInfo);
            this.m_txtBuffInfo = null;
         }
         if(this.stTargetIntruder)
         {
            this.stTargetIntruder.m_stGeneralBurnEffect = null;
         }
         this.stTargetIntruder = null;
         if(ms_stIntruderBurnEffectVector.indexOf(this) == -1)
         {
            ms_stIntruderBurnEffectVector.push(this);
         }
         this.m_Buffs.length = 0;
         if(this.parent != null)
         {
            this.parent.removeChild(this);
         }
         return true;
      }
   }
}

