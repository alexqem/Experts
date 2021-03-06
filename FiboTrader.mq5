//+------------------------------------------------------------------+
//|                                                    FiboTrader.mq5 |
//|                                            Alexander Schastliviy |
//|                                               vk.com/aVirginGirl |
//+------------------------------------------------------------------+
#property copyright "Alexander Schastliviy"
#property link      "vk.com/aVirginGirl"

#property version   "1.00"

#property description "Глубина понимания определяет широту применения."

input int             Lot=1; // Лотность

input color           f1= clrOrangeRed;            // Цвет 1й фибы
input color           f2= clrRoyalBlue;            // Цвет 2й фибы
input int             Bold1=1;                      // Толщина линии 1й фибы
input int             Bold2=1;                      // Толщина линии 2й фибы
input bool            InpRayRight=false;            // Тянуть до правого края?
//----------------
input string           InpName="F1";            // Имя кнопки 
input string           InpName2="F2";            // Имя кнопки 
input ENUM_BASE_CORNER InpCorner=CORNER_LEFT_LOWER; // Угол графика для привязки 

input string           InpFont="Calibri";             // Шрифт 
input int              InpFontSize=9;              // Размер шрифта 
input color            InpColor=clrBlack;           // Цвет текста 
input color            InpBackColor=C'236,233,216'; // Цвет фона 
input bool             InpBack=false;               // Объект на заднем плане 
input bool             InpSelection=false;          // Выделить для перемещений 
input int              bwidth = 25;
input int              bheight = 16;
input int              bwidth2 = 25;
input int              bheight2 = 16;
input int              x = 5;
input int              y = 20;
input int              x2 = 35;
input int              y2 = 20;

int   Myspread              = (int)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD) ;    // от проскальзывания


//+------------------------------------------------------------------------------
// Подключаем классы
#include <Trade\SymbolInfo.mqh>
CSymbolInfo SyInfo;

#include <Trade\Trade.mqh>
CTrade Trade;

#include <Trade\PositionInfo.mqh>
CPositionInfo PosInfo;

#include <Trade\OrderInfo.mqh>
COrderInfo OrderInfo;

#include <Trade\HistoryOrderInfo.mqh>
CHistoryOrderInfo HistoryInfo;

#include <ChartObjects\ChartObject.mqh>   
CChartObject ChartObject;

MqlTick         tick;     // Структура тика
MqlTradeRequest mtrade;   // Запрос
MqlTradeResult  mresult;  // Результаты выполнения торговых запросов



//+------------------------------------------------------------------+ 
//| Создает кнопку                                                   | 
//+------------------------------------------------------------------+ 
bool ButtonCreate(const long              chart_ID=0,               // ID графика 
                  const string            name="Button",            // имя кнопки 
                  const int               sub_window=0,             // номер подокна 
                  const int               yx=0,                      // координата по оси X 
                  const int               yy=0,                      // координата по оси Y 
                  const int               width=50,                 // ширина кнопки 
                  const int               height=18,                // высота кнопки 
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_LOWER, // угол графика для привязки 
                  const string            text="Button",            // текст 
                  const string            font="Arial",             // шрифт 
                  const int               font_size=10,             // размер шрифта 
                  const color             clr=clrBlack,             // цвет текста 
                  const color             back_clr=C'236,233,216',  // цвет фона 
                  const color             border_clr=clrNONE,       // цвет границы 
                  const bool              state=false,              // нажата/отжата 
                  const bool              back=false,               // на заднем плане 
                  const bool              selection=false,          // выделить для перемещений 
                  const bool              hidden=true,              // скрыт в списке объектов 
                  const long              z_order=0)                // приоритет на нажатие мышью 
  { 
//--- сбросим значение ошибки 
   ResetLastError(); 
//--- создадим кнопку 
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать кнопку! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
//--- установим координаты кнопки 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,yx); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,yy); 
//--- установим размер кнопки 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height); 
//--- установим угол графика, относительно которого будут определяться координаты точки 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
//--- установим текст 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- установим шрифт текста 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- установим размер шрифта 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- установим цвет текста 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- установим цвет фона 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
//--- установим цвет границы 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr); 
//--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- переведем кнопку в заданное состояние 
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state); 
//--- включим (true) или отключим (false) режим перемещения кнопки мышью 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,InpSelection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false); 
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- установим приоритет на получение события нажатия мыши на графике 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- успешное выполнение 
   return(true); 
  } 


///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
int OnInit()
  {
   //--- indicator buffers mapping
      
   ButtonCreate(0,InpName,0,x,y,bwidth, bheight,InpCorner,InpName,InpFont,InpFontSize, 
         f1,InpBackColor,clrNONE,false,false,false,false,0);
   ButtonCreate(0,InpName2,0,x2,y2,bwidth2,bheight2,InpCorner,InpName2,InpFont,InpFontSize, 
         f2,InpBackColor,clrNONE,false,false,false,false,0);
    
   ChartRedraw(); 
   
//---
   return(INIT_SUCCEEDED);
  }

///////////////////////////////////////////////////////////////////////////////////
void OnDeinit(const int reason)
  {
   
  }
  

///////////////////////////////////////////////////////////////////////////////////
bool FiboLevelsCreate(const long            chart_ID=0,        // ID графика 
                      const string          name="FiboLevels", // имя объекта 
                      const int             sub_window=0,      // номер подокна  
                      datetime              time1=0,           // время первой точки 
                      double                price1=0,          // цена первой точки 
                      datetime              time2=0,           // время второй точки 
                      double                price2=0,          // цена второй точки 
                      const color           clr=clrRed,        // цвет объекта 
                      const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии объекта 
                      const int             width=1,           // толщина линии объекта 
                      const bool            back=false,        // на заднем плане 
                      const bool            selection=false,    // выделить для перемещений 
                      const bool            ray_left=false,    // продолжение объекта влево 
                      const bool            ray_right=false,   // продолжение объекта вправо 
                      const bool            hidden=true,       // скрыт в списке объектов 
                      const long            z_order=0)         // приоритет на нажатие мышью 
  { 
//--- установим координаты точек привязки, если они не заданы 
   ChangeFiboLevelsEmptyPoints(time1,price1,time2,price2); 
//--- сбросим значение ошибки 
   ResetLastError(); 
//--- создадим "Уровни Фибоначчи" по заданным координатам 
   if(!ObjectCreate(chart_ID,name,OBJ_FIBO,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": не удалось создать \"Уровни Фибоначчи\"! Код ошибки = ",GetLastError()); 
      return(false); 
     } 
//--- установим цвет 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- установим стиль линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- установим толщину линии 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- отобразим на переднем (false) или заднем (true) плане 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- включим (true) или отключим (false) режим выделения объекта для перемещений 
//--- при создании графического объекта функцией ObjectCreate, по умолчанию объект 
//--- нельзя выделить и перемещать. Внутри же этого метода параметр selection 
//--- по умолчанию равен true, что позволяет выделять и перемещать этот объект 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- включим (true) или отключим (false) режим продолжения отображения объекта влево 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left); 
//--- включим (true) или отключим (false) режим продолжения отображения объекта вправо 
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right); 
//--- скроем (true) или отобразим (false) имя графического объекта в списке объектов 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- установи приоритет на получение события нажатия мыши на графике 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- успешное выполнение 
   return(true); 
  } 

///////////////////////////////
bool FiboLevelsSet(int             levels,            // количество линий уровня 
                   double          &values[],         // значения линий уровня 
                   color           colors,         // цвет линий уровня 
                   int             widths,         // толщина линий уровня 
                   const long      chart_ID=0,        // ID графика 
                   const string    name="FiboLevels") // имя объекта 
  { 
//--- установим количество уровней 
   ObjectSetInteger(chart_ID,name,OBJPROP_LEVELS,levels); 
//--- установим свойства уровней в цикле 
   for(int i=0;i<levels;i++) 
     { 
      //--- значение уровня 
      ObjectSetDouble(chart_ID,name,OBJPROP_LEVELVALUE,i,values[i]); 
      //--- цвет уровня 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,i,colors); 
      //--- толщина уровня 
      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELWIDTH,i,widths); 
      //--- описание уровня 
      string Fname = DoubleToString(10*values[i],1);
      Fname = Fname+" - %$";
      ObjectSetString(chart_ID,name,OBJPROP_LEVELTEXT,i,Fname); 
     } 
//--- успешное выполнение 
   return(true); 
  } 
///////////////////////////////
 void ChangeFiboLevelsEmptyPoints(datetime &time1,double &price1, 
                                 datetime &time2,double &price2) 
  { 
//--- если время второй точки не задано, то она будет на текущем баре 
   if(!time2) 
      time2=TimeCurrent(); 
//--- если цена второй точки не задана, то она будет иметь значение Bid 
   if(!price2) 
      price2=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- если время первой точки не задано, то она лежит на 9 баров левее второй 
   if(!time1) 
     { 
      //--- массив для приема времени открытия 10 последних баров 
      datetime temp[15]; 
      CopyTime(Symbol(),Period(),time2,15,temp); 
      //--- установим первую точку на 9 баров левее второй 
      time1=temp[0]; 
     } 
//--- если цена первой точки не задана, то сдвинем ее на 200 пунктов ниже второй 
   if(!price1) 
      price1=price2-200*SymbolInfoDouble(Symbol(),SYMBOL_POINT); 
  } 
///////////////////////////////
void OnTick()
   {
   //---
   

   //---
   } //OnTick
//+------------------------------------------------------------------+

void OnChartEvent(const int id,           // идентификатор события
                  const long &lparam,     // параметр события типа long
                  const double &dparam,   // параметр события типа double
                  const string &sparam)   // параметр события типа string
  {
  
 if(id==CHARTEVENT_OBJECT_CLICK)    {
     
      double lvls[5];
      lvls[0]=0;lvls[1]=0.25;lvls[2]=0.5;lvls[3]=0.75;lvls[4]=1;
      
      //--- Если кликнули по кнопке
      if(sparam == InpName) {
           ObjectSetInteger(0,InpName,OBJPROP_STATE,false); 
           
           int rand = MathRand();
           string name=InpName+(string)rand;
           FiboLevelsCreate(0,name,0,0,0,0,0,f1, 0,1,false,true,false,InpRayRight,false,0);
           FiboLevelsSet(5,lvls,f1,Bold1,0,name);
        }
      
       if(sparam == InpName2) {
           ObjectSetInteger(0,InpName2,OBJPROP_STATE,false); 
         
           int rand = MathRand();
           string name=InpName2+(string)rand;
           FiboLevelsCreate(0,name,0,0,0,0,0,f2, 0,1,false,true,false,InpRayRight,false,0);
           FiboLevelsSet(5,lvls,f2,Bold2,0,name);
           
        }
      
      ChartRedraw();
      return;
} //if 

 if(id==CHARTEVENT_OBJECT_DRAG) {
  
    // get fibo vars
    double HighLevel = ObjectGetDouble(0,sparam,OBJPROP_PRICE, 1);
    double LowLevel  = ObjectGetDouble(0,sparam,OBJPROP_PRICE, 0);
    int    HighTime  = (int)ObjectGetInteger(0,sparam,OBJPROP_TIME,1);
    int    LowTime   = (int)ObjectGetInteger(0,sparam,OBJPROP_TIME,0);
    
    Trade.OrderOpen(_Symbol, ORDER_TYPE_BUY_LIMIT, Lot, 0, LowLevel, 0, 0, ORDER_TIME_DAY, 0, "");
    if (Trade.ResultRetcode() < 10008 && Trade.ResultRetcode() >  10009) { Alert("!!!Ахтунг, ошибка - ",Trade.ResultRetcode());}
    
    Comment(LowTime);
    return;
     
} //if
     
}  /////// OnChartEvent
     

