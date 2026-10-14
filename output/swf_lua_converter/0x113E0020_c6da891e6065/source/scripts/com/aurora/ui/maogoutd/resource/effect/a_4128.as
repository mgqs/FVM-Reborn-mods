package com.aurora.ui.maogoutd.resource.effect
{
   import com.aurora.ui.maogoutd.game.BattleFieldView;
   import com.aurora.ui.maogoutd.game.a_3491;
   import com.aurora.ui.maogoutd.resource.bitmap.IrregularCirlceFogBitmapdata;
   import com.aurora.ui.maogoutd.resource.bitmap.RegularCirlceFogBitmapData;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Sprite;
   import flash.geom.Matrix;
   
   public class a_4128 extends Sprite
   {
      
      public static var a_1413:Boolean = false;
      
      private var a_1267:Bitmap;
      
      private var a_1414:BitmapData;
      
      private var a_1415:BitmapData;
      
      private var a_1416:BitmapData;
      
      private var a_1417:Vector.<Vector.<int>>;
      
      public function a_4128()
      {
         super();
         mouseEnabled = false;
         this.a_1267 = new Bitmap();
         addChild(this.a_1267);
      }
      
      public function a_1797() : Boolean
      {
         var j:int = 0;
         if(!a_1413)
         {
            this.a_1267.bitmapData = null;
            return true;
         }
         if(null == this.a_1415)
         {
            this.a_1415 = new RegularCirlceFogBitmapData(72,70);
         }
         if(null == this.a_1416)
         {
            this.a_1416 = new IrregularCirlceFogBitmapdata(70,69);
         }
         if(null == this.a_1414)
         {
            this.a_1414 = new BitmapData(a_3491.a_1080 * 7,a_3491.a_1081 * (BattleFieldView.a_1012 + 2));
         }
         this.a_1267.bitmapData = this.a_1414;
         if(null == this.a_1417)
         {
            this.a_1417 = new Vector.<Vector.<int>>(BattleFieldView.a_1012,true);
         }
         for(var i:int = 0; i < BattleFieldView.a_1012; i++)
         {
            if(null == this.a_1417[i])
            {
               this.a_1417[i] = new Vector.<int>(BattleFieldView.a_1011,true);
            }
            for(j = 0; j < BattleFieldView.a_1011; j++)
            {
               this.a_1417[i][j] = 2;
            }
         }
         return true;
      }
      
      public function a_4129(stFieldGridsVector:Array) : void
      {
         var i:int = 0;
         var j:int = 0;
         var yStart:int = 0;
         var xStart:int = 0;
         var yEnd:int = 0;
         var xEnd:int = 0;
         var y:int = 0;
         var x:int = 0;
         var stDrawMatrix:Matrix = null;
         if(!a_1413)
         {
            return;
         }
         this.a_1414.lock();
         this.a_1414.fillRect(this.a_1414.rect,0);
         for(i = 0; i < BattleFieldView.a_1012; i++)
         {
            for(j = 0; j < BattleFieldView.a_1011; j++)
            {
               this.a_1417[i][j] = 2;
            }
         }
         for(i = 0; i < BattleFieldView.a_1012; i++)
         {
            for(j = 0; j < BattleFieldView.a_1011; j++)
            {
               if(Boolean(stFieldGridsVector[i][j].m_stFlowerDefense) && 1 == stFieldGridsVector[i][j].m_stFlowerDefense.iEnergyTypeID)
               {
                  yStart = i - 2 < 0 ? 0 : int(i - 2);
                  xStart = j - 2 < 0 ? 0 : int(j - 2);
                  yEnd = i + 2 >= BattleFieldView.a_1012 ? int(BattleFieldView.a_1012 - 1) : int(i + 2);
                  xEnd = j + 2 >= BattleFieldView.a_1011 ? int(BattleFieldView.a_1011 - 1) : int(j + 2);
                  for(y = yStart; y <= yEnd; y++)
                  {
                     for(x = xStart; x <= xEnd; x++)
                     {
                        this.a_1417[y][x] = 0;
                     }
                  }
               }
            }
         }
         for(i = 0; i < BattleFieldView.a_1012; i++)
         {
            for(j = 5; j < BattleFieldView.a_1011; j++)
            {
               if(this.a_1417[i][j] > 0)
               {
                  stDrawMatrix = new Matrix();
                  stDrawMatrix.translate((j - 2.5) * a_3491.a_1080 - 0.5 * this.a_1415.width,(i + 1.5) * a_3491.a_1081 - 0.5 * this.a_1415.height);
                  this.a_1414.draw(this.a_1415,stDrawMatrix);
               }
            }
         }
         this.a_1414.unlock();
         this.a_1267.bitmapData = this.a_1414;
      }
      
      public function a_4130() : void
      {
         this.a_1267.bitmapData = null;
      }
   }
}

