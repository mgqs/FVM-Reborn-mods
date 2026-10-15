package a_4724
{
   public class AvatarDetailInfo
   {
      
      public var m_iCoverallType:int = 0;
      
      public var m_iGunType:int = 0;
      
      public var m_iShieldType:int = 0;
      
      public var m_iHatType:int = 0;
      
      public var m_iEyeGlassesType:int = 0;
      
      public var m_iFaceType:int = 0;
      
      public var m_iFaceDecorationType:int = 0;
      
      public var m_iEyeType:int = 0;
      
      public var m_iHairType:int = 0;
      
      public var m_iBodyType:int = 0;
      
      public var m_iAureolaType:int = 0;
      
      public var m_iWingType:int = 0;
      
      public var m_iLandInsuranceType:int = 0;
      
      public var m_iWaterInsuranceType:int = 0;
      
      public var m_numAttackForce:Number = 1;
      
      public var m_numDefenseForce:Number = 0;
      
      public function AvatarDetailInfo()
      {
         super();
      }
      
      public function setAvaterDeatil(arrAvatarID:Array, iGender:int) : void
      {
         var heroItem:Object = null;
         var itemID:int = 0;
         var type:int = 0;
         this.m_iEyeType = iGender == 1 ? 342884624 : 342884640;
         this.m_iBodyType = iGender == 1 ? 341836048 : 341836064;
         this.m_iHairType = iGender == 1 ? 339738896 : 339738912;
         this.m_iFaceType = iGender == 1 ? 340787216 : 340787232;
         this.m_iGunType = 336658688;
         if(arrAvatarID != null)
         {
            for each(heroItem in arrAvatarID)
            {
               itemID = int(heroItem.m_iItemID);
               type = (itemID & 0xF00000) >> 20;
               switch(type)
               {
                  case 0:
                     this.m_iAureolaType = itemID;
                     break;
                  case 1:
                     this.m_iGunType = itemID;
                     break;
                  case 2:
                     this.m_iHatType = itemID;
                     break;
                  case 3:
                     this.m_iEyeGlassesType = itemID;
                     break;
                  case 4:
                     this.m_iHairType = itemID;
                     break;
                  case 5:
                     this.m_iFaceDecorationType = itemID;
                     break;
                  case 6:
                     this.m_iBodyType = itemID;
                     break;
                  case 7:
                     this.m_iEyeType = itemID;
                     break;
                  case 8:
                     break;
                  case 9:
                     break;
                  case 10:
                     this.m_iShieldType = itemID;
                     break;
                  case 11:
                     this.m_iWingType = itemID;
                     break;
                  case 12:
                     break;
                  case 13:
                     this.m_iCoverallType = itemID;
                     break;
                  case 14:
                     if((itemID & 0x0F0000) == 65536)
                     {
                        this.m_iLandInsuranceType = itemID;
                     }
                     else
                     {
                        this.m_iWaterInsuranceType = itemID;
                     }
               }
            }
         }
      }
   }
}

