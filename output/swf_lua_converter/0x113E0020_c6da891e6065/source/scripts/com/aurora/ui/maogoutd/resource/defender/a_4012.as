package com.aurora.ui.maogoutd.resource.defender
{
   import a_4718.b_179;
   import com.aurora.ui.maogoutd.resource.tools.a_4421;
   
   public class a_4012
   {
      
      private static var a_1286:a_4012;
      
      private static var a_1364:Array = [];
      
      public function a_4012()
      {
         super();
         this.a_4014(b_179.a_403,a_4421.a_3926);
      }
      
      public static function getInstance() : a_4012
      {
         if(null == a_1286)
         {
            a_1286 = new a_4012();
         }
         return a_1286;
      }
      
      public function a_4013(iDefenseTypeId:uint) : a_3962
      {
         if(null != a_1364[iDefenseTypeId])
         {
            return a_1364[iDefenseTypeId]();
         }
         return null;
      }
      
      public function a_4014(iDefenseTypeId:uint, fDefenseCreator:Function) : Boolean
      {
         if(null == fDefenseCreator || null != a_1364[iDefenseTypeId])
         {
            trace("RegisterDefenseCreator failed");
            return false;
         }
         a_1364[iDefenseTypeId] = fDefenseCreator;
         return true;
      }
      
      public function a_3923() : Boolean
      {
         a_1364 = [];
         return true;
      }
   }
}

