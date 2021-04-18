//+------------------------------------------------------------------+
//|                                             Robô Média Móvel.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| INCLUDES                                                         |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| INPUTS                                                           |
//+------------------------------------------------------------------+
input int lote = 5;
input int periodoMediaRapida = 9;
input int periodoMediaMedia = 21;
input int periodoMediaLonga = 50;


//define o tipo da media, se 1, media ari, se dois media exp

input int tipoMediaRapida = 1;
input int tipoMediaMedia = 1;
input int tipoMediaLonga = 1;


input int stGain = 250;
input int stLoss = 100;

//+------------------------------------------------------------------+
//| GLOBAIS                                                          |
//+------------------------------------------------------------------+
//manipuladores dos indicadores de media movel
int curtaHandle = INVALID_HANDLE;
int mediaHandle = INVALID_HANDLE;
int longaHandle = INVALID_HANDLE;

// vetores de dados dos indicadores de media movel
double mediaCurta[];
double mediaMedia[];
double mediaLonga[];

//declarando variavel controle da ordem de roteamento
CTrade trade;


MqlRates rates[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   //inverte a indexacao padrao do c de 0 para n, para n para 0
   ArraySetAsSeries(mediaCurta,true);
   ArraySetAsSeries(mediaLonga,true);
   ArraySetAsSeries(mediaMedia,true);
   
   ArraySetAsSeries(rates, true);
   
   //atribuit valores para os manipuladores de media movel
   curtaHandle = iMA(_Symbol,_Period,periodoMediaRapida,0,MODE_SMA,PRICE_CLOSE);
   mediaHandle = iMA(_Symbol,_Period,periodoMediaMedia,0,MODE_SMA,PRICE_CLOSE);
   longaHandle = iMA(_Symbol,_Period,periodoMediaLonga,0,MODE_SMA,PRICE_CLOSE);
   //---
   
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(isNewBar()) 
     {
     //executa a logica do robo soh quando existe nova barra
     //+------------------------------------------------------------------+
     //| OBTENCAO DOS DADOS                                               |
     //+------------------------------------------------------------------+
     //copia as ultima dez medias moveis no grafico
     int copied1 = CopyBuffer(curtaHandle,0,0,10,mediaCurta);
     int copied4 = CopyBuffer(mediaHandle,0,0,10,mediaMedia);
     int copied2 = CopyBuffer(longaHandle,0,0,10,mediaLonga);
     int copied3 = CopyRates(_Symbol,PERIOD_M5,0,5,rates);
     
     
     bool sinalCompra = false;
     bool sinalVenda = false;
     
     //verifica se as dez medias foram realmente copiadas
     if (copied1==10 && copied2==10 && copied4==10)
       {
       //sinal de compra
       if(mediaCurta[1]>mediaMedia[1] && mediaCurta[2]<mediaMedia[2] && mediaMedia[1]>mediaLonga[1])
         {
            sinalCompra = true;
         }
       
       
       //sinal de venda
       if(mediaCurta[1]<mediaMedia[1] && mediaCurta[2]>mediaMedia[2]  && mediaMedia[1]<mediaLonga[1])
         {
            sinalVenda = true;
            
         }
       
       }
     //+------------------------------------------------------------------+
     //| VERIFICAR SE ESTA POSICIONADO                                    |
     //+------------------------------------------------------------------+
     bool comprado = false;
     bool vendido = false;
     
     if(PositionSelect(_Symbol))
       {
       // se a posicao for comprada
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         {
            comprado=true;
         }
       // se a posicao for vendida
       if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         {
            vendido=true;
            
         }
       }
       
     //COMO SABER SE A CONTA DO MT e NETTING???
     
     //+------------------------------------------------------------------+
     //|  LOGICA DE ROTEAMENTO                                            |
     //+------------------------------------------------------------------+
     //ZERADO
     if(!comprado && !vendido)
       {
       //sinal de compra
       if(sinalCompra)
         {
         
         //int minvalueidx = ArrayMinimum(rates);
         double precoLoss = rates[1].low-150;                 
         double precoGain = rates[0].open+300;
         trade.Buy(lote,_Symbol,0,precoLoss,precoGain,"Compra a mercado");
         Comment("executada compra");
         }
       //sinal de venda
       if(sinalVenda)
         {
         double precoLoss = rates[1].high+150;                 
         double precoGain = rates[0].open-300;
         trade.Sell(lote,_Symbol,0,precoLoss,precoGain,"Venda a mercado");
         }
       }
     else 
       {
       //estou comprado
       if(comprado)
         {
         if(sinalVenda) 
           {
           trade.Sell(lote,_Symbol,0,0,"Fechamento de posicao por alteracao da media(VENDA)");
           }
         }
       //estou vendido
       else if(vendido)
         {
         if(sinalCompra)
           {
           trade.Buy(lote,_Symbol,0,0,"Fechamento de posicao por alteracao da media(COMPRA)");
           }         
         }       
       } 
      
     }       
  }
  
//+------------------------------------------------------------------+
//| Testa se eh ultima barra                                         |
//+------------------------------------------------------------------+
bool isNewBar()
  {
  //memorize the time of opening of the last bar in the static variable   
   static datetime last_time=0;
  //current time
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);
   
   //if it is the first call of the function
   if (last_time==0) 
    {
     //set the time and exit
      last_time = lastbar_time;
      return(false);
    }
    
   // if the time differs
   if (last_time != lastbar_time) 
     {
      //memorize the time and return true
      last_time=lastbar_time;
      return(true);   
   }    
    return(false);
  }
  