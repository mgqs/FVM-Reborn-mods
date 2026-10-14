package com.aurora.protocol.game.maogoutd
{
   import com.aurora.protocol.a_2664;
   import com.aurora.protocol.common.CMessageBody;
   import flash.utils.ByteArray;
   
   public class CVanishDefender implements CMessageBody
   {
      
      public var m_iDefenderID:int;
      
      public var m_iDefenderTypeID:int;
      
      public var m_byYGridNo:int;
      
      public var m_byXGridNo:int;
      
      public var m_byIsTool:int;
      
      public function CVanishDefender()
      {
         super();
      }
      
      public function encode(byte_array:ByteArray, encode_length:int) : Boolean
      {
         var propertyArray:Array = [["m_iDefenderID","int32"],["m_iDefenderTypeID","int32"],["m_byYGridNo","int8"],["m_byXGridNo","int8"],["m_byIsTool","int8"]];
         return a_2664.a_2665(this,propertyArray,byte_array,encode_length);
      }
      
      public function decode(byte_array:ByteArray, decode_length:int) : Boolean
      {
         var propertyArray:Array = [["m_iDefenderID","int32"],["m_iDefenderTypeID","int32"],["m_byYGridNo","int8"],["m_byXGridNo","int8"],["m_byIsTool","int8"]];
         return a_2664.a_2666(this,propertyArray,byte_array,decode_length);
      }
      
      public function dump() : Boolean
      {
         return false;
      }
   }
}

