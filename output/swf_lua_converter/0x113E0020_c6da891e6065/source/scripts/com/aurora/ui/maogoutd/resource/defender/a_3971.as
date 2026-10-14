package com.aurora.ui.maogoutd.resource.defender
{
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.energy.a_4157;
   import com.aurora.ui.maogoutd.resource.energy.a_4162;
   import com.aurora.ui.maogoutd.resource.props.IBaseProp;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   
   public class a_3971 extends a_3962
   {
      
      public static var a_1341:Number = 1;
      
      protected var a_1342:int;
      
      protected var a_1343:int;
      
      protected var a_1344:int;
      
      protected var a_1345:int = 25;
      
      public var m_arrEnergyAddValueProp:Array = [];
      
      public function a_3971()
      {
         super();
      }
      
      public function get iEnergyTypeID() : int
      {
         return this.a_1344;
      }
      
      override public function a_1797(stFieldGrid:a_3491) : Boolean
      {
         super.a_1797(stFieldGrid);
         this.a_1342 = 0;
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
         return width * 0.1;
      }
      
      protected function a_3956() : Number
      {
         return 0.25 * height;
      }
      
      public function a_3957(iCurrentTime:int) : void
      {
         var stFreeEnergy:a_4157 = null;
         var iEnergyValue:int = 0;
         var stGameBasePop:IBaseProp = null;
         var stPropDisplayEffect:MovieClip = null;
         nextFrame();
         if(a_1278 != null)
         {
            gotoAndStop((a_1276[a_1275] as FrameLabel).frame);
         }
         if(a_1273 == a_1274 || iCurrentTime > this.a_1343 && iCurrentTime - this.a_1342 < 60 && a_1278 != null)
         {
            gotoAndStop(1);
            stFreeEnergy = a_4162.getInstance().a_4163(this.a_1344);
            if(null != stFreeEnergy)
            {
               iEnergyValue = a_1334.m_stCurrentBattbleFieldView.isOwnBattleField ? int(a_1341 * this.a_1345) : 5;
               stGameBasePop = this.m_arrEnergyAddValueProp.pop();
               if(stGameBasePop)
               {
                  iEnergyValue += stGameBasePop.a_4328().m_iEffectValue;
               }
               stFreeEnergy.a_1797(0,iEnergyValue,x + this.a_3955(),y + this.a_3956());
               parent.addChild(stFreeEnergy);
               if(stGameBasePop)
               {
                  stPropDisplayEffect = stGameBasePop.a_4327();
                  stPropDisplayEffect.x = stFreeEnergy.width;
                  stPropDisplayEffect.y = -20;
                  stFreeEnergy.addChild(stPropDisplayEffect);
               }
            }
         }
         if(0 == this.a_1342)
         {
            this.a_1342 = iCurrentTime;
         }
         if(iCurrentTime > this.a_1342 + this.a_1343)
         {
            this.a_1342 = iCurrentTime;
            a_1275 = 0;
            gotoAndStop((a_1276[1] as FrameLabel).frame);
         }
      }
      
      override public function a_3940() : Boolean
      {
         if(a_1334)
         {
            a_1334.a_3500(this);
         }
         super.a_3940();
         return true;
      }
   }
}

