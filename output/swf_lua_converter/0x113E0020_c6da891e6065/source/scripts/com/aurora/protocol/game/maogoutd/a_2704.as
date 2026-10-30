package com.aurora.protocol.game.maogoutd
{
   import com.aurora.protocol.a_2664;
   import com.aurora.protocol.common.CMessageBody;
   import flash.utils.ByteArray;
   
   public class a_2704 implements CMessageBody
   {
      
      public var m_uiTickCount:uint;
      
      public var m_byPlayerSeatID:uint;
      
      public var m_uiGlobalID:uint;
      
      public var m_uiTypeID:uint;
      
      public var m_byRow:uint;
      
      public var m_byColumn:uint;
      
      public function a_2704()
      {
         super();
      }
      
      public function encode(byte_array:ByteArray, encode_length:int) : Boolean
      {
         var propertyArray:Array = [["m_uiTickCount","uint32"],["m_byPlayerSeatID","uint8"],["m_uiGlobalID","uint32"],["m_uiTypeID","uint32"],["m_byRow","uint8"],["m_byColumn","uint8"]];
         return a_2664.a_2665(this,propertyArray,byte_array,encode_length);
      }
      
      public function decode(byte_array:ByteArray, decode_length:int) : Boolean
      {
         var propertyArray:Array = [["m_uiTickCount","uint32"],["m_byPlayerSeatID","uint8"],["m_uiGlobalID","uint32"],["m_uiTypeID","uint32"],["m_byRow","uint8"],["m_byColumn","uint8"]];
         return a_2664.a_2666(this,propertyArray,byte_array,decode_length);
      }
      
      public function dump() : Boolean
      {
         return false;
      }
   }
}

