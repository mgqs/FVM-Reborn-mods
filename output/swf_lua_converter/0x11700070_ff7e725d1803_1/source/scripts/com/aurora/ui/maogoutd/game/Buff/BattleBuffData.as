package com.aurora.ui.maogoutd.game.Buff
{
   import com.aurora.ui.maogoutd.resource.effect.BaseGameEffect;
   
   public class BattleBuffData
   {
      
      public var tag:int = 0;
      
      public var value:int = 1;
      
      public var duration:int = 0;
      
      public var params:BattleBuffParams = null;
      
      public var stEffect:BaseGameEffect;
      
      public function BattleBuffData()
      {
         super();
      }
   }
}

