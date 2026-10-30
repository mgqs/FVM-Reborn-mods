package com.aurora.ui.maogoutd.game
{
   import com.aurora.ui.maogoutd.resource.Intruder.a_4206;
   import com.aurora.ui.maogoutd.resource.bitmap.a_3939;
   import com.aurora.ui.maogoutd.resource.defender.a_3953;
   import com.aurora.ui.maogoutd.resource.defender.a_3959;
   import com.aurora.ui.maogoutd.resource.defender.a_3960;
   import com.aurora.ui.maogoutd.resource.defender.a_3962;
   import com.aurora.ui.maogoutd.resource.defender.a_3971;
   import com.aurora.ui.maogoutd.resource.defender.a_3975;
   import com.aurora.ui.maogoutd.resource.defender.a_3977;
   import com.aurora.ui.maogoutd.resource.tools.a_4408;
   import com.aurora.ui.maogoutd.resource.tools.a_4409;
   
   public class a_3491
   {
      
      public static var a_1080:int;
      
      public static var a_1081:int;
      
      public var m_stCurrentBattbleFieldView:BattleFieldView;
      
      public var m_iXGridNo:int;
      
      public var m_iYGridNo:int;
      
      public var m_isNeedTray:Boolean = false;
      
      public var m_isExistMouseHole:Boolean = false;
      
      public var m_stProtector:a_3975;
      
      public var m_stAttackFighter:a_3953;
      
      public var m_stTrayDefense:a_3977;
      
      public var m_stBoomDefense:a_3960;
      
      public var m_stFlowerDefense:a_3971;
      
      public var m_stBaseAuxiliaryFighter:a_3959;
      
      public var m_stBaseLander:a_4409;
      
      public var m_stBaseFieldAlarm:a_4408;
      
      public var m_stRatEarthHole:a_3939;
      
      public var a_1511:Array = new Array();
      
      public var m_isOccupy:Boolean = false;
      
      public function a_3491(stBattleFieldView:BattleFieldView, iXGridNo:int, iYGridNo:int)
      {
         super();
         this.m_stCurrentBattbleFieldView = stBattleFieldView;
         this.m_iXGridNo = iXGridNo;
         this.m_iYGridNo = iYGridNo;
      }
      
      public function a_3492() : Boolean
      {
         return !(null == this.m_stProtector && null == this.m_stAttackFighter && null == this.m_stTrayDefense && null == this.m_stBoomDefense && null == this.m_stFlowerDefense && null == this.m_stBaseAuxiliaryFighter);
      }
      
      public function a_3494() : a_3962
      {
         var stThiefDefense:a_3962 = null;
         if(this.m_stAttackFighter)
         {
            stThiefDefense = this.m_stAttackFighter;
         }
         else if(this.m_stFlowerDefense)
         {
            stThiefDefense = this.m_stFlowerDefense;
         }
         else if(this.m_stBaseAuxiliaryFighter)
         {
            stThiefDefense = this.m_stBaseAuxiliaryFighter;
         }
         else if(this.m_stBoomDefense)
         {
            stThiefDefense = this.m_stBoomDefense;
         }
         else if(this.m_stProtector)
         {
            stThiefDefense = this.m_stProtector;
         }
         else if(this.m_stTrayDefense)
         {
            stThiefDefense = this.m_stTrayDefense;
         }
         return stThiefDefense;
      }
      
      public function a_3495() : int
      {
         var iTempIndex:int = 0;
         var iTopIndex:int = 0;
         if(this.m_stAttackFighter)
         {
            iTempIndex = this.m_stCurrentBattbleFieldView.getChildIndex(this.m_stAttackFighter);
            iTopIndex = iTopIndex < iTempIndex ? iTempIndex : iTopIndex;
         }
         if(this.m_stTrayDefense)
         {
            iTempIndex = this.m_stCurrentBattbleFieldView.getChildIndex(this.m_stTrayDefense);
            iTopIndex = iTopIndex < iTempIndex ? iTempIndex : iTopIndex;
         }
         if(this.m_stBoomDefense)
         {
            iTempIndex = this.m_stCurrentBattbleFieldView.getChildIndex(this.m_stBoomDefense);
            iTopIndex = iTopIndex < iTempIndex ? iTempIndex : iTopIndex;
         }
         if(this.m_stFlowerDefense)
         {
            iTempIndex = this.m_stCurrentBattbleFieldView.getChildIndex(this.m_stFlowerDefense);
            iTopIndex = iTopIndex < iTempIndex ? iTempIndex : iTopIndex;
         }
         if(this.m_stBaseAuxiliaryFighter)
         {
            iTempIndex = this.m_stCurrentBattbleFieldView.getChildIndex(this.m_stBaseAuxiliaryFighter);
            iTopIndex = iTopIndex < iTempIndex ? iTempIndex : iTopIndex;
         }
         return iTopIndex;
      }
      
      public function a_3442(baseProtector:a_3975) : Boolean
      {
         if(this.m_isNeedTray && null == this.m_stTrayDefense || null == baseProtector || null != this.m_stProtector || this.m_isExistMouseHole)
         {
            return false;
         }
         this.m_stProtector = baseProtector;
         return true;
      }
      
      public function a_3496(baseProtector:a_3975) : Boolean
      {
         if(null == baseProtector || null == this.m_stProtector || baseProtector != this.m_stProtector)
         {
            return false;
         }
         this.m_stProtector = null;
         return true;
      }
      
      public function a_3443(attackFighter:a_3953) : Boolean
      {
         if(null == attackFighter || null != this.m_stAttackFighter || null != this.m_stBoomDefense || null != this.m_stBaseAuxiliaryFighter || null != this.m_stFlowerDefense || !attackFighter.isCanInWater && this.m_isNeedTray && null == this.m_stTrayDefense || attackFighter.isCanInWater && (!this.m_isNeedTray || this.m_isNeedTray && null != this.m_stTrayDefense) || attackFighter.isOnlyOnTray && null == this.m_stTrayDefense || this.m_isExistMouseHole)
         {
            return false;
         }
         this.m_stAttackFighter = attackFighter;
         return true;
      }
      
      public function a_3497(attackFighter:a_3953) : Boolean
      {
         if(null == attackFighter || null == this.m_stAttackFighter || attackFighter != this.m_stAttackFighter)
         {
            return false;
         }
         this.m_stAttackFighter = null;
         return true;
      }
      
      public function a_3444(stTrayDefense:a_3977) : Boolean
      {
         if(!this.m_isNeedTray || null == stTrayDefense || null != this.m_stTrayDefense || this.m_isExistMouseHole)
         {
            return false;
         }
         this.m_stTrayDefense = stTrayDefense;
         return true;
      }
      
      public function a_3498(stTrayDefense:a_3977) : Boolean
      {
         if(null == stTrayDefense || null == this.m_stTrayDefense || stTrayDefense != this.m_stTrayDefense)
         {
            return false;
         }
         this.m_stTrayDefense = null;
         return true;
      }
      
      public function a_3446(stBoomDefense:a_3960) : Boolean
      {
         if(this.m_isNeedTray && null == this.m_stTrayDefense || null == stBoomDefense || null != this.m_stBoomDefense || null != this.m_stAttackFighter || null != this.m_stBaseAuxiliaryFighter || null != this.m_stFlowerDefense || this.m_isExistMouseHole)
         {
            return false;
         }
         this.m_stBoomDefense = stBoomDefense;
         return true;
      }
      
      public function a_3499(stBoomDefense:a_3960) : Boolean
      {
         if(null == stBoomDefense || null == this.m_stBoomDefense || stBoomDefense != this.m_stBoomDefense)
         {
            return false;
         }
         this.m_stBoomDefense = null;
         return true;
      }
      
      public function a_3447(stFlowerDefense:a_3971) : Boolean
      {
         if(this.m_isNeedTray && null == this.m_stTrayDefense || null == stFlowerDefense || null != this.m_stFlowerDefense || null != this.m_stAttackFighter || null != this.m_stBaseAuxiliaryFighter || null != this.m_stBoomDefense || this.m_isExistMouseHole)
         {
            return false;
         }
         this.m_stFlowerDefense = stFlowerDefense;
         return true;
      }
      
      public function a_3500(stFlowerDefense:a_3971) : Boolean
      {
         if(null == stFlowerDefense || null == this.m_stFlowerDefense || stFlowerDefense != this.m_stFlowerDefense)
         {
            return false;
         }
         this.m_stFlowerDefense = null;
         return true;
      }
      
      public function a_3445(stAuxiliaryFighter:a_3959) : Boolean
      {
         if(this.m_isNeedTray && null == this.m_stTrayDefense || null == stAuxiliaryFighter || null != this.m_stBaseAuxiliaryFighter || null != this.m_stAttackFighter || null != this.m_stFlowerDefense || null != this.m_stBoomDefense || this.m_isExistMouseHole)
         {
            return false;
         }
         this.m_stBaseAuxiliaryFighter = stAuxiliaryFighter;
         return true;
      }
      
      public function a_3501(stAuxiliaryFighter:a_3959) : Boolean
      {
         if(null == stAuxiliaryFighter || null == this.m_stBaseAuxiliaryFighter || stAuxiliaryFighter != this.m_stBaseAuxiliaryFighter)
         {
            return false;
         }
         this.m_stBaseAuxiliaryFighter = null;
         return true;
      }
      
      public function a_3459(stMoveIntruder:a_4206) : Boolean
      {
         if(null == stMoveIntruder || this.a_1511.indexOf(stMoveIntruder) >= 0)
         {
            trace("Error: AddMoveFighter failed, stMoveIntruder is null or stMoveIntruder exist in m_arrMoveIntruder for ID:" + stMoveIntruder.globalMoveFighterID);
            return false;
         }
         if(null != stMoveIntruder.m_stCurrentFieldGrid)
         {
            stMoveIntruder.m_stCurrentFieldGrid.a_3457(stMoveIntruder);
         }
         this.a_1511.push(stMoveIntruder);
         this.m_isOccupy = true;
         stMoveIntruder.m_stCurrentFieldGrid = this;
         return true;
      }
      
      public function a_3457(stMoveIntruder:a_4206) : Boolean
      {
         if(null == stMoveIntruder)
         {
            trace("Error: stMoveIntruder is null, RemoveMoveFighter failed");
            return false;
         }
         if(-1 != this.a_1511.indexOf(stMoveIntruder))
         {
            this.a_1511.splice(this.a_1511.indexOf(stMoveIntruder),1);
         }
         if(0 == this.a_1511.length)
         {
            this.m_isOccupy = false;
         }
         return true;
      }
      
      public function a_3502() : void
      {
         if(this.m_stBaseLander != null)
         {
            this.m_stBaseLander.a_3940();
            this.m_stBaseLander = null;
         }
         if(null != this.m_stProtector)
         {
            this.m_stProtector.a_3940();
         }
         if(null != this.m_stAttackFighter)
         {
            this.m_stAttackFighter.a_3940();
         }
         if(null != this.m_stBoomDefense && this.m_stBoomDefense.isCanBeEaten)
         {
            this.m_stBoomDefense.a_3940();
         }
         if(null != this.m_stFlowerDefense)
         {
            this.m_stFlowerDefense.a_3940();
         }
         if(null != this.m_stBaseAuxiliaryFighter)
         {
            this.m_stBaseAuxiliaryFighter.a_3940();
         }
         if(null != this.m_stTrayDefense)
         {
            this.m_stTrayDefense.a_3940();
         }
         this.m_isExistMouseHole = false;
      }
      
      public function a_3503() : Boolean
      {
         if(this.m_stRatEarthHole)
         {
            this.m_stRatEarthHole.a_3940();
            this.m_isExistMouseHole = false;
         }
         return true;
      }
   }
}

