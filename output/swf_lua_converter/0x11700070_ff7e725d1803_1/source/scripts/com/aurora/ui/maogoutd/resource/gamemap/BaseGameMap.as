package com.aurora.ui.maogoutd.resource.gamemap
{
   import com.aurora.ui.maogoutd.resource.wave.a_4450;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   
   public class BaseGameMap extends Sprite
   {
      
      public function BaseGameMap()
      {
         super();
      }
      
      public function a_4172() : BitmapData
      {
         return null;
      }
      
      public function a_4173() : BitmapData
      {
         return null;
      }
      
      public function a_4174() : BitmapData
      {
         return null;
      }
      
      public function a_4175() : a_4450
      {
         return null;
      }
      
      public function a_4176() : a_4187
      {
         return null;
      }
      
      public function a_4177() : Boolean
      {
         return false;
      }
      
      public function SetBattleFieldTerrain(stBattleFieldObject:Object) : Boolean
      {
         return false;
      }
      
      public function ChangeGameMap(stData:Object) : Boolean
      {
         return false;
      }
      
      public function OnTimeInterval(iTimeNum:uint) : void
      {
      }
      
      public function OnWaveStatusData(iWaveStatus:int) : void
      {
      }
      
      public function OnWaveStatusDataByServer(iWaveStatus:int) : void
      {
      }
   }
}

