package com.aurora.ui.maogoutd.resource.Intruder
{
   public class a_4255
   {
      
      private static var a_1286:a_4255;
      
      private static var a_1510:Array = [];
      
      public function a_4255()
      {
         super();
      }
      
      public static function getInstance() : a_4255
      {
         if(null == a_1286)
         {
            a_1286 = new a_4255();
         }
         return a_1286;
      }
      
      public function a_4256(iMoveIntruderTypeId:uint) : a_4206
      {
         if(null != a_1510[iMoveIntruderTypeId])
         {
            return a_1510[iMoveIntruderTypeId]();
         }
         return null;
      }
      
      public function a_4257(iMoveIntruderTypeId:uint, fMoveIntruderCreator:Function) : Boolean
      {
         if(null == fMoveIntruderCreator || null != a_1510[iMoveIntruderTypeId])
         {
            trace("RegisterMoveIntruderCreator failed");
            return false;
         }
         a_1510[iMoveIntruderTypeId] = fMoveIntruderCreator;
         return true;
      }
      
      public function a_3923() : Boolean
      {
         a_1510 = [];
         return true;
      }
   }
}

