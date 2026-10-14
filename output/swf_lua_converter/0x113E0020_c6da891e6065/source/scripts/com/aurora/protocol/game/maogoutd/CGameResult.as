package com.aurora.protocol.game.maogoutd
{
   import com.aurora.protocol.a_2664;
   import com.aurora.protocol.common.CMessageBody;
   import flash.utils.ByteArray;
   
   public class CGameResult implements CMessageBody
   {
      
      public var m_bySeatID:int;
      
      public var m_byTeamID:int;
      
      public var m_byRolePosition:int;
      
      public var m_iTotalEnergy:int;
      
      public var m_nJoinForceBuildingCount:int;
      
      public var m_nDestroyOppBuildingCount:int;
      
      public var m_iPickUpCoinCount:int;
      
      public var m_iExpericeCount:int;
      
      public var m_iAwardCoinCount:int;
      
      public var m_iHonourCount:int;
      
      public var m_nUseCardCount:int;
      
      public var m_arrUseCardInfos:Array;
      
      private var m_stUseCard:CUseCard;
      
      public var m_szPlayeRoleName:String;
      
      public function CGameResult()
      {
         super();
      }
      
      public function encode(byte_array:ByteArray, encode_length:int) : Boolean
      {
         var propertyArray:Array = [["m_bySeatID","int8"],["m_byTeamID","int8"],["m_byRolePosition","int8"],["m_iTotalEnergy","int32"],["m_nJoinForceBuildingCount","int16"],["m_nDestroyOppBuildingCount","int16"],["m_iPickUpCoinCount","int32"],["m_iExpericeCount","int32"],["m_iAwardCoinCount","int32"],["m_iHonourCount","int32"],["m_nUseCardCount","int16"],["m_arrUseCardInfos",["object","com.aurora.protocol.game.maogoutd.CUseCard"]]];
         return a_2664.a_2665(this,propertyArray,byte_array,encode_length);
      }
      
      public function decode(byte_array:ByteArray, decode_length:int) : Boolean
      {
         var propertyArray:Array = [["m_bySeatID","int8"],["m_byTeamID","int8"],["m_byRolePosition","int8"],["m_iTotalEnergy","int32"],["m_nJoinForceBuildingCount","int16"],["m_nDestroyOppBuildingCount","int16"],["m_iPickUpCoinCount","int32"],["m_iExpericeCount","int32"],["m_iAwardCoinCount","int32"],["m_iHonourCount","int32"],["m_nUseCardCount","int16"],["m_arrUseCardInfos",["object","com.aurora.protocol.game.maogoutd.CUseCard"]]];
         return a_2664.a_2666(this,propertyArray,byte_array,decode_length);
      }
      
      public function dump() : Boolean
      {
         return false;
      }
   }
}

