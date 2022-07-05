//+------------------------------------------------------------------+
//|                                         Trend Indicator A-V2.mq4 |
//|                                           Copyright 2022, SDstar |
//|                                        https://github.com/sdstar |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, SDstar"
#property link      "https://github.com/sdstar"
#property version   "1.00"
#property description "Author : Dziwne | Translate To MQL4 : SDstar"
#property strict
#property indicator_chart_window
#property indicator_buffers 2


//--- input parameters
input int            ma_period           = 7;                  // Moving Average Period
input int            ma_period_smoothing = 7;                  // Moving Average Period (Smoothing)
input ENUM_MA_METHOD ma_method           = MODE_EMA;           // Moving Average Type
input ENUM_MA_METHOD ma_smoothing_method = MODE_EMA;           // Moving Average Type (Smoothing)
input color          color_positive      = clrMediumSeaGreen;  // Positive color (Bullish)
input color          color_negative      = clrRed;             // Negative color (Bearish)
//input color    color_hl            = clrLightGray;
//input bool     show_oc_cloud       = true;


//--- main arrays
double Positive_ma[];
double Negative_ma[];

//--- calculative arrays
double o[];
double c[];
double h[];
double l[];

double ha_o[];
double ha_c[];
double ha_h[];
double ha_l[];

double ha_o_smooth[];
double ha_c_smooth[];
double ha_h_smooth[];
double ha_l_smooth[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

//--- indicator buffers mapping
   IndicatorBuffers(14);
   SetIndexBuffer(0,Positive_ma);
   SetIndexBuffer(1,Negative_ma);
   
   SetIndexBuffer(2,o);
   SetIndexBuffer(3,c);
   SetIndexBuffer(4,h);
   SetIndexBuffer(5,l);
   SetIndexBuffer(6,ha_o);
   SetIndexBuffer(7,ha_c);
   SetIndexBuffer(8,ha_h);
   SetIndexBuffer(9,ha_l);
   SetIndexBuffer(10,ha_o_smooth);
   SetIndexBuffer(11,ha_c_smooth);
   SetIndexBuffer(12,ha_h_smooth);
   SetIndexBuffer(13,ha_l_smooth);
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,color_positive);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2,color_negative);
   
   SetIndexLabel(0,"Positive Trendcloud");
   SetIndexLabel(1,"Negative Trendcloud");
   
   
//---
   return(INIT_SUCCEEDED);
  }
  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

//---

   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) return(-1);
   if(counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars == 0) limit -= ma_period;
   

   for(int i=1; i<limit; i++)
   {
   // II.1. Calculations, MA
      double openMa  = iMA(_Symbol,PERIOD_CURRENT,ma_period,0,ma_method,PRICE_OPEN,i);
      double closeMa = iMA(_Symbol,PERIOD_CURRENT,ma_period,0,ma_method,PRICE_CLOSE,i);
      double highMa  = iMA(_Symbol,PERIOD_CURRENT,ma_period,0,ma_method,PRICE_HIGH,i);
      double lowMa   = iMA(_Symbol,PERIOD_CURRENT,ma_period,0,ma_method,PRICE_LOW,i);
   
      o[i] = openMa;
      c[i] = closeMa;
      h[i] = highMa;
      l[i] = lowMa;
      
      //Print("ERR: ", GetLastError());
   }
   
   for(int i=0; i<limit; i++)
   {
   // II.2. Calculations, Heikin Ashi
      double ha_open  = NormalizeDouble((o[i+1]+c[i+1])/2, _Digits);
      double ha_close = NormalizeDouble((o[i]+h[i]+l[i]+c[i])/4, _Digits);
      double ha_high  = MathMax(h[i],MathMax(ha_open,ha_close));
      double ha_low   = MathMin(l[i],MathMin(ha_open,ha_close));
      
      ha_o[i] = ha_open;
      ha_c[i] = ha_close;
      ha_h[i] = ha_high;
      ha_l[i] = ha_low; 
      
      //Print("ERR: ", GetLastError());
   
   }
   
   for(int i=0; i<limit; i++)
   {
   // II.3. Calculations, MA (Smoothing)
      double ha_open_smooth = iMAOnArray(ha_o,0,ma_period_smoothing,0,ma_smoothing_method,i);
      double ha_close_smooth = iMAOnArray(ha_c,0,ma_period_smoothing,0,ma_smoothing_method,i);
      double ha_high_smooth = iMAOnArray(ha_h,0,ma_period_smoothing,0,ma_smoothing_method,i);
      double ha_low_smooth = iMAOnArray(ha_l,0,ma_period_smoothing,0,ma_smoothing_method,i);
      
      ha_o_smooth[i] = ha_open_smooth;
      ha_c_smooth[i] = ha_close_smooth;
      ha_h_smooth[i] = ha_high_smooth;
      ha_l_smooth[i] = ha_low_smooth;
      
      //Print("ERR: ", GetLastError());
      
   }
   
   for(int i=0; i<limit; i++)
   {
      if(ha_c_smooth[i] >= ha_o_smooth[i]) {
         if(i == 0) {Positive_ma[0] = EMPTY_VALUE;} else{
         Positive_ma[i] = ha_c_smooth[i];
         }         
         Negative_ma[i] = EMPTY_VALUE;
         //Print("ERR: ", GetLastError());
      } else {
         Positive_ma[i] = EMPTY_VALUE;
         Negative_ma[i] = ha_o_smooth[i];
         //Print("ERR: ", GetLastError());
      }
      
   }

   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
