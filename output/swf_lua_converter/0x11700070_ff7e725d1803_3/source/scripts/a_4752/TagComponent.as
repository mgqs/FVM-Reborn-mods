package a_4752
{
   import flash.utils.Dictionary;
   
   public class TagComponent
   {
      
      private var _tags:Array = new Array();
      
      private var _sumDict:Dictionary = new Dictionary();
      
      public function TagComponent()
      {
         super();
      }
      
      public function AddTag(iTag:int) : Boolean
      {
         if(this._tags.indexOf(iTag) == -1)
         {
            this._tags.push(iTag);
            return true;
         }
         return false;
      }
      
      public function RemoveTag(iTag:int) : Boolean
      {
         var idx:int = this._tags.indexOf(iTag);
         if(idx != -1)
         {
            this._tags.splice(idx,1);
            return true;
         }
         return false;
      }
      
      public function HasTag(iTag:int) : Boolean
      {
         return this._tags.indexOf(iTag) != -1 || this._tags.indexOf(iTag + 10000000) != -1;
      }
      
      public function ClearAll() : void
      {
         this._tags.length = 0;
         this._sumDict = new Dictionary();
      }
      
      public function AddSum(key:String) : void
      {
         if(this._sumDict[key] == null)
         {
            this._sumDict[key] = 0;
         }
         this._sumDict[key] += 1;
      }
      
      public function RemoveSum(key:String) : void
      {
         if(this._sumDict[key] == null)
         {
            return;
         }
         this._sumDict[key] = this._sumDict[key] - 1;
         if(this._sumDict[key] <= 0)
         {
            this.DeleteSum(key);
         }
      }
      
      public function DeleteSum(key:String) : void
      {
         if(this._sumDict[key] != null)
         {
            delete this._sumDict[key];
         }
      }
      
      public function GetSum(key:String) : int
      {
         return Math.max(0,this._sumDict[key] == null ? 0 : Number(this._sumDict[key]));
      }
      
      public function HasSum(key:String) : Boolean
      {
         return this.GetSum(key) > 0;
      }
   }
}

