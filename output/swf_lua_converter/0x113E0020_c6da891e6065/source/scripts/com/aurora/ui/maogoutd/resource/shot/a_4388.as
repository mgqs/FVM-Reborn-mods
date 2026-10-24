package com.aurora.ui.maogoutd.resource.shot
{
   public class a_4388
   {
      
      private static var a_1286:a_4388;
      
      private static var a_1604:Array = [];
      
      public function a_4388()
      {
         super();
      }
      
      public static function getInstance() : a_4388
      {
         if(null == a_1286)
         {
            a_1286 = new a_4388();
         }
         return a_1286;
      }
      
      public function a_4389(iShotTypeId:uint) : a_4348
      {
         if(null != a_1604[iShotTypeId])
         {
            return a_1604[iShotTypeId]();
         }
         return null;
      }
      
      public function a_4390(iShotTypeId:uint, fShotCreator:Function) : Boolean
      {
         if(null == fShotCreator || null != a_1604[iShotTypeId])
         {
            trace("RegisterShotCreator failed");
            return false;
         }
         a_1604[iShotTypeId] = fShotCreator;
         return true;
      }
      
      public function a_3923() : Boolean
      {
         a_1604 = [];
         return true;
      }
   }
}

