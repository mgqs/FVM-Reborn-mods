package com.aurora.ui.maogoutd.resource.energy
{
   public class a_4162
   {
      
      private static var a_1286:a_4162;
      
      private static var a_1439:Array = [];
      
      public function a_4162()
      {
         super();
      }
      
      public static function getInstance() : a_4162
      {
         if(null == a_1286)
         {
            a_1286 = new a_4162();
         }
         return a_1286;
      }
      
      public function a_4163(iEnergyTypeId:uint) : a_4157
      {
         if(null != a_1439[iEnergyTypeId])
         {
            return a_1439[iEnergyTypeId]();
         }
         return null;
      }
      
      public function a_4164(iEnergyTypeId:uint, fEnergyCreator:Function) : Boolean
      {
         if(null == fEnergyCreator || null != a_1439[iEnergyTypeId])
         {
            trace("RegisterEnergyCreator failed");
            return false;
         }
         a_1439[iEnergyTypeId] = fEnergyCreator;
         return true;
      }
      
      public function a_3923() : Boolean
      {
         a_1439 = [];
         return true;
      }
   }
}

