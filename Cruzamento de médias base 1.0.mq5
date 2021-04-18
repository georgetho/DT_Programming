//+------------------------------------------------------------------+
//|                                       Cruzamento de médias 2.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Edmundo Costa"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

void OnTick()
  {
      // Variação do Preço
      double myMovingAverageArray1[], myMovingAverageArray2[];
            
      // Definir as especificações da Média1
      int movingAverageDefinition1 = iMA(_Symbol,_Period,9,0,MODE_EMA,PRICE_CLOSE);
      
      // Definir as especificações da Média2
      int movingAverageDefinition2 = iMA(_Symbol,_Period,21,0,MODE_EMA,PRICE_CLOSE);
      
      // Primeira variação
      ArraySetAsSeries(myMovingAverageArray1,true);
      
      // Segunda variação
      ArraySetAsSeries (myMovingAverageArray2,true);
      
      //Definição da Média Curta
      CopyBuffer(movingAverageDefinition1,0,0,3, myMovingAverageArray1);
      
      //Definição da Média Intermédiária
      CopyBuffer(movingAverageDefinition2,0,0,3, myMovingAverageArray2);
      
         if ( //Condição primária - Média de 9 acima da média de 21
              (myMovingAverageArray1 [0] > myMovingAverageArray2 [0])
          &&  (myMovingAverageArray1 [1] < myMovingAverageArray2 [1])
         
         )
         
         {
        Comment("Compra");
          }
      
         if (  //Condição Secundária - Média de 21 acima da média de 9
               (myMovingAverageArray1[0]<myMovingAverageArray2[0])
          &&   (myMovingAverageArray1[1]>myMovingAverageArray2[1])
           )
            
             {
        Comment("Venda");
          }
            
           }
  

