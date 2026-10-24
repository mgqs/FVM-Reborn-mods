package com.aurora.ui.maogoutd.game
{
   import flash.display.DisplayObject;
   
   public class BattleLayerInfo
   {
      
      private static var m_vInfo:Vector.<BattleLayerInfo> = new Vector.<BattleLayerInfo>();
      
      public var m_iType:int;
      
      public var a_1598:a_3491;
      
      public var m_stDisplayObject:DisplayObject;
      
      public function BattleLayerInfo()
      {
         super();
         this.a_1598 = new a_3491(null,0,0);
      }
      
      public static function a_3926() : BattleLayerInfo
      {
         var stInfo:BattleLayerInfo = m_vInfo.pop();
         if(!stInfo)
         {
            stInfo = new BattleLayerInfo();
         }
         return stInfo;
      }
      
      public function a_4330() : void
      {
         this.m_stDisplayObject = null;
         m_vInfo.push(this);
      }
   }
}

