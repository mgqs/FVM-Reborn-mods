package com.aurora.ui.maogoutd.game.Buff
{
   import a_4752.TagComponent;
   import com.aurora.ui.maogoutd.resource.EffectManager;
   import com.aurora.ui.maogoutd.resource.a_3909;
   import com.aurora.ui.maogoutd.resource.effect.BaseGameEffect;
   import flash.utils.Dictionary;
   
   public class BuffComponent
   {
      
      private var _tagCom:TagComponent;
      
      private var _display:a_3909;
      
      private var _dictBuff:Dictionary = new Dictionary();
      
      public function BuffComponent()
      {
         super();
      }
      
      public function a_3014(tagCom:TagComponent, display:a_3909) : void
      {
         this._tagCom = tagCom;
         this._display = display;
      }
      
      public function AddBuff(tag:int, duration:int, params:BattleBuffParams = null) : BattleBuffData
      {
         var stEffect:BaseGameEffect = null;
         tag += 10000000;
         var buffData:BattleBuffData = this._dictBuff[tag];
         if(this._tagCom.HasTag(tag) && buffData != null)
         {
            if(buffData.duration < duration)
            {
               buffData.duration = duration;
            }
            ++buffData.value;
            return null;
         }
         this._tagCom.AddTag(tag);
         buffData = new BattleBuffData();
         if(params != null)
         {
            if(params.gameMoveClipClass != null)
            {
               stEffect = EffectManager.getInstance().CheckOutOne(params.effectClass,params.gameMoveClipClass);
               stEffect.SetAnimation(0);
               buffData.stEffect = stEffect;
               this.UpdateBuffPos(stEffect,params);
            }
            else
            {
               buffData.stEffect = null;
            }
         }
         buffData.duration = duration;
         buffData.params = params;
         buffData.tag = tag;
         this._dictBuff[tag] = buffData;
         return buffData;
      }
      
      public function UpdateBuff(removeTick:int = 1) : void
      {
         var buffData:BattleBuffData = null;
         var i:int = 0;
         var arrDelete:Array = [];
         for each(buffData in this._dictBuff)
         {
            if(buffData != null)
            {
               buffData.duration -= removeTick;
               if(buffData.duration <= 0)
               {
                  arrDelete.push(buffData.tag);
                  this._RemoveBuff(buffData);
               }
               else
               {
                  this.UpdateBuffPos(buffData.stEffect,buffData.params);
               }
            }
         }
         if(arrDelete.length > 0)
         {
            for(i = 0; i < arrDelete.length; i++)
            {
               this._dictBuff[arrDelete[i]] = null;
            }
         }
      }
      
      private function UpdateBuffPos(stEffect:BaseGameEffect, params:BattleBuffParams) : void
      {
         if(stEffect == null)
         {
            return;
         }
         if(this._display == null)
         {
            return;
         }
         if(params == null)
         {
            stEffect.x = this._display.x;
            stEffect.y = this._display.y;
         }
         else if(params.offsetType != -1)
         {
            if(params.offsetType == 0)
            {
               stEffect.x = this._display.x + params.x;
               stEffect.y = this._display.y + params.y;
            }
            else if(params.offsetType == 1)
            {
               stEffect.x = this._display.x + 0.5 * (this._display.width - stEffect.width) + this._display.stDisplayBitmap.x + params.x;
               stEffect.y = this._display.y + stEffect.height + this._display.stDisplayBitmap.y + params.y;
            }
            else if(params.offsetType == 2)
            {
               stEffect.x = this._display.x + this._display.width * 0.5 + params.x;
               stEffect.y = this._display.y + params.y;
            }
         }
      }
      
      private function _RemoveBuff(buffData:BattleBuffData) : void
      {
         this._tagCom.RemoveTag(buffData.tag);
         if(buffData.stEffect != null)
         {
            buffData.stEffect.a_3940();
            buffData.stEffect = null;
         }
         if(buffData.params == null)
         {
            return;
         }
         if(buffData.params.endCallBack != null)
         {
            buffData.params.endCallBack();
         }
      }
      
      public function RemoveBuff(tag:int) : Boolean
      {
         tag += 10000000;
         if(this._dictBuff[tag] == null)
         {
            return false;
         }
         var buffObj:Object = this._dictBuff[tag];
         this._RemoveBuff(this._dictBuff[tag]);
         this._dictBuff[tag] = null;
         return true;
      }
      
      public function ClearAll() : void
      {
         var buffData:BattleBuffData = null;
         for each(buffData in this._dictBuff)
         {
            if(buffData != null && buffData.stEffect != null)
            {
               buffData.stEffect.a_3940();
            }
         }
         this._dictBuff = new Dictionary();
      }
   }
}

