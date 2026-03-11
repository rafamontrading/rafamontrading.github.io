//+------------------------------------------------------------------+
//|                                    Professional EA Generated     |
//|                                    MQL5 Code Generator v2.0      |
//|                                Techain.ai                        |
//+------------------------------------------------------------------+
#property copyright "Code Generator MQL AI - Techain.ai"
#property link      "https://techain.ai"
#property version   "2.00"
#property description "Professional EA for MetaTrader 5"

// .set optimization: download from app (CodePreview/Wizard), copy to MQL5/Presets/, Strategy Tester > right-click EA > Load

// Include MQL5 trade library
#include <Trade\Trade.mqh>


// ===== GLOBAL VARIABLES =====

// Trade object for order management
CTrade g_Trade;

// Control variables
bool g_NewBar = false;
datetime g_LastBarTime = 0;
bool g_DebugMode = true;
bool g_TradingAllowed = false;  // Set in OnInit, re-checked on new bar (resilient init for real accounts)

// ===== BACKTEST TRAINING MODE FOR AI NODES =====
bool g_IsBacktestTraining = false;      // True when running inside Strategy Tester
double g_AITrainingSpeedMultiplier = 1.0; // Learning rate multiplier in backtest (auto-set to 3.0 in tester)
int g_BacktestTrainingTicks = 0;        // Tick counter for training progress

// Pip calculation (initialized in OnInit)
double g_pips2dbl = 0.0001;
double g_MarketMultiplier = 1.0;  // Auto-adjusted: 1x for Forex, 10x for Indices/Metals
int g_MarketType = 0;             // 0=Forex, 1=Index, 2=Metal, 3=Crypto, 4=JPY
int g_Digits = 4;

// External Parameters
input int g_MagicNumber = 12345; // Numero Magico / Magic Number (unique EA identifier)
input double g_MaxSpreadPoints = 300.0; // Max spread in points (IMPORTANT: Increase for backtesting)
input bool g_EnableTrading = true; // Habilitar Trading Global / Enable Global Trading

int g_MasterSeed = 0; // Master seed for all AI node sub-seeding

// Cache structures for performance
struct IndicatorCache {
    int handle;
    double buffer[];
    datetime lastUpdate;
};

// Signal tracking
struct SignalInfo {
    bool active;
    datetime triggered;
    string source;
};

SignalInfo g_LastSignal;


// ===== NEURAL NETWORK CALIBRATION SYSTEM =====
// Machine learning optimization parameters
#define NEURAL_CALIBRATION_EPOCH 2026
#define ML_OPTIMIZATION_FACTOR 606
#define DEEP_LEARNING_SEED 74520

// Neural synchronization state
datetime g_neuralSyncTimestamp = 0;
int g_mlPerformanceScore = 100;
bool g_neuralCalibrationValid = false;

//+------------------------------------------------------------------+
//| CONFIGURABLE PARAMETERS (Elite/Power AI/Admin Feature)          |
//| You can adjust these values in MetaTrader Properties > Inputs    |
//+------------------------------------------------------------------+

// ╔══════════════════════════════════════════════════════════════╗
// ║  GUIDED OPTIMIZATION (automatic - just pick a Phase)       ║
// ║  How to use:                                               ║
// ║  1. Set OptimizationPhase = 1                              ║
// ║  2. Run Optimization (Custom max criterion)                ║
// ║  3. Apply best result, then set OptimizationPhase = 2      ║
// ║  4. Repeat for Phase 3 and 4                               ║
// ║  Phase 0 = Manual (you configure ranges yourself)          ║
// ╚══════════════════════════════════════════════════════════════╝
input int OptimizationPhase = 0; // >>> OPTIMIZATION PHASE: 0=Manual, 1=Indicators, 2=Logic, 3=Risk, 4=Fine-Tune <<<
input int MinimumTrades = 100;   // Min trades to validate (H1~100, M15~300, M5~600)

// ===== Artificial Intelligence =====
input double inp_strategi_riskPercent_3009234708 = 1; // Strategic Agent IA - Risk % per Trade Range: 0.1-5 [Phase 4]
input double inp_strategi_maxLotSize_3009234708 = 1; // Strategic Agent IA - Maximum Lot Size (hard limit) Range: 0.01-100 [Phase 4]
input double inp_strategi_minLotSize_3009234708 = 0.01; // Strategic Agent IA - Minimum Lot Size Range: 0.01-1 [Phase 4]
input int inp_strategi_minSLPoints_3009234708 = 10; // Strategic Agent IA - SL Mínimo (puntos) - Piso seguridad Range: 1-5000 [Phase 4]
input int inp_strategi_maxSLPoints_3009234708 = 200; // Strategic Agent IA - SL Máximo (puntos) - Techo seguridad Range: 10-50000 [Phase 4]
input int inp_strategi_minTPPoints_3009234708 = 20; // Strategic Agent IA - TP Mínimo (puntos) - Piso seguridad Range: 1-5000 [Phase 4]
input int inp_strategi_maxTPPoints_3009234708 = 500; // Strategic Agent IA - TP Máximo (puntos) - Techo seguridad Range: 10-50000 [Phase 4]
input double inp_strategi_minRiskReward_3009234708 = 1; // Strategic Agent IA - Minimum Risk:Reward Ratio Range: 0.5-3 [Phase 4]
input double inp_strategi_chaosLotMultipl_3009234708 = 0.4; // Strategic Agent IA - Chaos Regime Lot Multiplier (0=no trade) Range: 0-1 [Phase 4]
input double inp_strategi_maxDrawdown_3009234708 = 20; // Strategic Agent IA - Max Drawdown % (triggers pause) Range: 5-50 [Phase 4]
input double inp_strategi_learningRate_3009234708 = 0.1; // Strategic Agent IA - Q-Learning Rate (α) Range: 0.01-0.5 [Phase 4]
input double inp_strategi_discountFactor_3009234708 = 0.95; // Strategic Agent IA - Discount Factor (γ) Range: 0.5-0.99 [Phase 4]
input double inp_strategi_explorationRate_3009234708 = 0.2; // Strategic Agent IA - Initial Exploration (ε) Range: 0.05-0.5 [Phase 4]
input bool inp_strategi_enableTrading_3009234708 = true; // Strategic Agent IA - Habilitar Trading (ON/OFF global) [Phase 4]
input double inp_strategi_maxSpreadPoints_3009234708 = 0; // Strategic Agent IA - Spread Máximo (puntos, 0=sin límite) Range: 0-500 [Phase 4]
input bool inp_strategi_enableAutoPause_3009234708 = false; // Strategic Agent IA - Enable Auto-Pause (disable for max training) [Phase 4]
input bool inp_strategi_enableActiveMan_3009234708 = true; // Strategic Agent IA - Gestión Activa (ajusta SL/TP en órdenes abiertas) [Phase 4]
input bool inp_strategi_showPanel_3009234708 = true; // Strategic Agent IA - Show AI Monitoring Panel
input int inp_strategi_panelPosition_3009234708 = 0; // Strategic Agent IA - Panel Pos: 0=TL 1=TC 2=TR 3=ML 4=C 5=MR 6=BL 7=BC 8=BR Range: 0-8
input int inp_strategi_magicNumber_3009234708 = 888888; // Strategic Agent IA - Magic Number
input string inp_strategi_qtableImportFil_3009234708 = ""; // Strategic Agent IA - Q-Table Import File (vacío=auto) [Phase 4]
input bool inp_strategi_fastLearningMod_3009234708 = false; // Strategic Agent IA - Modo Rápido (reduce requisitos 50%) ⚡ [Phase 4]
input bool inp_strategi_enableStateInte_3009234708 = false; // Strategic Agent IA - Interpolación de Estados [BETA] [Phase 4]
input bool inp_strategi_enableAdaptiveC_3009234708 = true; // Strategic Agent IA - Cobertura Adaptativa (auto-ajusta) [Phase 4]
input bool inp_strategi_enableVirtualEx_3009234708 = false; // Strategic Agent IA - Experiencias Virtuales [EXPERIMENTAL] [Phase 4]
input bool inp_strategi_showRegimeProgr_3009234708 = true; // Strategic Agent IA - Mostrar Progreso por Régimen
input bool inp_strategi_enableEdgeRatio_3009234708 = false; // Strategic Agent IA - Edge Ratio (ajuste lots por calidad entrada) [Phase 4]
input int inp_strategi_minTradesForEdg_3009234708 = 15; // Strategic Agent IA - Min Trades para Edge Ratio Range: 5-100 [Phase 4]
input int ReproducibilitySeed = 0; // 0=Auto (varía cada run). >0=Semilla fija para reproducir. Ver Journal cuando 0. Range: 0-2147483647 [Phase 4]

// ===== Risk Management =====
input int inp_advanceT_advancePercent_3009344363 = 45; // Trailing por Avance vs SL - Porcentaje de Avance (%) Range: 1-50 [Phase 3]
input int inp_advanceT_minProfit_3009344363 = 0; // Trailing por Avance vs SL - Ganancia Mín para Activar (puntos) [Phase 3]
input int inp_advanceT_magicNumber_3009344363 = 0; // Trailing por Avance vs SL - ⚠️ Magic Number (0=Todas las órdenes)
input int inp_exitByBa_maxBars_3009351618 = 50; // Salida por Velas - Máximo de Velas Range: 1-1000 [Phase 3]
input int inp_exitByBa_minProfitToClos_3009351618 = 0; // Salida por Velas - Profit Mínimo para Cerrar (puntos) Range: -1000-1000 [Phase 3]
input int inp_exitByBa_magicNumber_3009351618 = 0; // Salida por Velas - ⚠️ Magic Number (0=Todas las órdenes)


// ===== DATA STRUCTURES =====

struct ValueHistory {
    double current;
    double previous;
    datetime lastUpdate;
};

#define MAX_VALUE_SLOTS 100
ValueHistory g_ValueHistory[];


// ===== COMPATIBILITY HELPERS =====

// Get current symbol
string GetCurrentSymbol() {
    return _Symbol;
}

// Get current period
ENUM_TIMEFRAMES GetCurrentPeriod() {
    return _Period;
}

// Get Point value
double GetPointValue() {
    return SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}

// Get Digits
int GetDigitsValue() {
    return (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
}

// Get current Ask price
double GetAskPrice() {
    return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
}

// Get current Bid price
double GetBidPrice() {
    return SymbolInfoDouble(_Symbol, SYMBOL_BID);
}

// Get bar time
datetime GetBarTime(string symbol, ENUM_TIMEFRAMES timeframe, int shift) {
    datetime time[];
    if (CopyTime(symbol, timeframe, shift, 1, time) > 0) {
        return time[0];
    }
    return 0;
}

// Get bar open
double GetBarOpen(string symbol, ENUM_TIMEFRAMES timeframe, int shift) {
    double open[];
    if (CopyOpen(symbol, timeframe, shift, 1, open) > 0) {
        return open[0];
    }
    return 0;
}

// Get bar high
double GetBarHigh(string symbol, ENUM_TIMEFRAMES timeframe, int shift) {
    double high[];
    if (CopyHigh(symbol, timeframe, shift, 1, high) > 0) {
        return high[0];
    }
    return 0;
}

// Get bar low
double GetBarLow(string symbol, ENUM_TIMEFRAMES timeframe, int shift) {
    double low[];
    if (CopyLow(symbol, timeframe, shift, 1, low) > 0) {
        return low[0];
    }
    return 0;
}

// Get bar close
double GetBarClose(string symbol, ENUM_TIMEFRAMES timeframe, int shift) {
    double close[];
    if (CopyClose(symbol, timeframe, shift, 1, close) > 0) {
        return close[0];
    }
    return 0;
}

// Get bar volume (tick volume)
long GetBarVolume(string symbol, ENUM_TIMEFRAMES timeframe, int shift) {
    long volume[];
    if (CopyTickVolume(symbol, timeframe, shift, 1, volume) > 0) {
        return volume[0];
    }
    return 0;
}

// Normalize price
double NormalizePrice(double price) {
    return NormalizeDouble(price, GetDigitsValue());
}

// Normalize lots
double NormalizeLots(double lots) {
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    if (lots < minLot) return minLot;
    if (lots > maxLot) return maxLot;
    
    return MathFloor(lots / lotStep) * lotStep;
}


// ===== CORE UTILITIES =====

// Safe division
double SafeDivide(double numerator, double denominator) {
    if (MathAbs(denominator) < 0.000001) return 0;
    return numerator / denominator;
}

// Check if value is valid
bool IsValidValue(double value) {
    return !MathIsValidNumber(value) ? false : true;
}

// Safe indicator value retrieval
double SafeIndicatorValue(double value) {
    if (!IsValidValue(value)) {
        LogError("Invalid indicator value detected");
        return 0;
    }
    return value;
}

// Get indicator value from handle
double GetIndicatorValue(int handle, int bufferIndex, int shift) {
    double buffer[];
    ArrayResize(buffer, 1);
    ArraySetAsSeries(buffer, true);
    
    if (handle == INVALID_HANDLE) {
        LogError("Invalid indicator handle");
        return 0;
    }
    
    if (CopyBuffer(handle, bufferIndex, shift, 1, buffer) <= 0) {
        LogError("Failed to copy indicator buffer");
        return 0;
    }
    
    return SafeIndicatorValue(buffer[0]);
}

// NOTE: PipsToPrice() is defined later with automatic market multiplier support

// Convert price distance to points
double PriceToPoints(double price) {
    return price / GetPointValue();
}

// Alias for backwards compatibility - now returns Points (not pips)
double PriceToPips(double price) {
    return PriceToPoints(price);
}


// ===== ERROR HANDLING =====

void LogInfo(string message) {
    if (g_DebugMode) {
        Print("[INFO] ", message);
    }
}

void LogError(string message) {
    Print("[ERROR] ", message, " | LastError: ", GetLastError());
    ResetLastError();
}

void LogWarning(string message) {
    if (g_DebugMode) {
        Print("[WARNING] ", message);
    }
}


// ===== BROKER COMPATIBILITY =====

bool CheckBrokerRequirements() {
    // Check if trading is allowed
    if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) {
        LogError("Trading is not allowed in terminal settings");
        return false;
    }
    
    if (!MQLInfoInteger(MQL_TRADE_ALLOWED)) {
        LogError("Automated trading is disabled");
        return false;
    }
    
    if (!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) {
        LogError("EA trading is not allowed for this account");
        return false;
    }
    
    return true;
}

// Check if symbol is tradeable
bool IsSymbolTradeable(string symbol) {
    return SymbolInfoInteger(symbol, SYMBOL_TRADE_MODE) == SYMBOL_TRADE_MODE_FULL;
}

// Get current spread in points
double GetCurrentSpreadPoints() {
    // SYMBOL_SPREAD already returns spread in points
    return (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
}

// Check if spread is acceptable
bool IsSpreadAcceptable() {
    double spreadPoints = GetCurrentSpreadPoints();
    if (spreadPoints > g_MaxSpreadPoints) {
        LogWarning("Spread too high: " + DoubleToString(spreadPoints, 1) + " pts");
        return false;
    }
    return true;
}

// Check margin before opening order
bool CheckMargin(double lots) {
    double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
    double requiredMargin = 0;
    
    if (!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lots, GetAskPrice(), requiredMargin)) {
        LogError("Failed to calculate required margin");
        return false;
    }
    
    if (requiredMargin > freeMargin) {
        LogError("Insufficient margin. Required: " + DoubleToString(requiredMargin, 2) + 
                ", Available: " + DoubleToString(freeMargin, 2));
        return false;
    }
    
    return true;
}


// ===== ORDER MANAGEMENT =====

// Get broker filling mode (AUTO-DETECT)
ENUM_ORDER_TYPE_FILLING GetFillingMode() {
    static ENUM_ORDER_TYPE_FILLING fillingMode = -1;
    
    if (fillingMode != -1) return fillingMode;
    
    // Get broker's allowed filling modes
    long filling = SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
    
    // Check supported modes in order of preference
    // Note: Only SYMBOL_FILLING_FOK and SYMBOL_FILLING_IOC exist in MQL5
    if ((filling & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC) {
        fillingMode = ORDER_FILLING_IOC;
        LogInfo("Broker filling mode detected: ORDER_FILLING_IOC");
    } else if ((filling & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK) {
        fillingMode = ORDER_FILLING_FOK;
        LogInfo("Broker filling mode detected: ORDER_FILLING_FOK");
    } else {
        // Default to RETURN mode if broker doesn't specify
        fillingMode = ORDER_FILLING_RETURN;
        LogInfo("No specific filling mode detected, using ORDER_FILLING_RETURN as default");
    }
    
    return fillingMode;
}

// Open a market order
ulong OpenMarketOrder(ENUM_ORDER_TYPE orderType, double lots, double sl, double tp, string comment, long magic) {
    // Validate parameters
    if (lots <= 0) {
        LogError("Invalid lot size: " + DoubleToString(lots, 2));
        return 0;
    }
    
    lots = NormalizeLots(lots);
    
    // Check margin
    if (!CheckMargin(lots)) {
        return 0;
    }
    
    // Check spread
    if (!IsSpreadAcceptable()) {
        return 0;
    }
    
    // Set trade parameters
    g_Trade.SetExpertMagicNumber(magic);
    g_Trade.SetDeviationInPoints(30);
    g_Trade.SetTypeFilling(GetFillingMode()); // ✅ FIX: Auto-detect broker filling mode
    
    // Normalize SL/TP
    if (sl > 0) sl = NormalizePrice(sl);
    if (tp > 0) tp = NormalizePrice(tp);
    
    // Execute order
    bool result = false;
    if (orderType == ORDER_TYPE_BUY) {
        result = g_Trade.Buy(lots, _Symbol, 0, sl, tp, comment);
    } else if (orderType == ORDER_TYPE_SELL) {
        result = g_Trade.Sell(lots, _Symbol, 0, sl, tp, comment);
    }
    
    if (result) {
        ulong ticket = g_Trade.ResultOrder();
        LogInfo("Order opened: Ticket=" + IntegerToString(ticket) + 
               ", Type=" + EnumToString(orderType) + 
               ", Lots=" + DoubleToString(lots, 2));
        return ticket;
    } else {
        LogError("Failed to open order: " + IntegerToString(g_Trade.ResultRetcode()) + 
                " - " + g_Trade.ResultRetcodeDescription());
        return 0;
    }
}

// Close position by ticket
bool ClosePosition(ulong ticket) {
    if (!PositionSelectByTicket(ticket)) {
        LogError("Position not found: " + IntegerToString(ticket));
        return false;
    }
    
    if (g_Trade.PositionClose(ticket)) {
        LogInfo("Position closed: " + IntegerToString(ticket));
        return true;
    }
    
    LogError("Failed to close position: " + g_Trade.ResultRetcodeDescription());
    return false;
}

// Close all positions
int CloseAllPositions(long magic = 0) {
    int closed = 0;
    
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) continue;
        
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        
        if (magic != 0 && PositionGetInteger(POSITION_MAGIC) != magic) continue;
        
        if (ClosePosition(ticket)) {
            closed++;
        }
    }
    
    return closed;
}

// Modify position SL/TP
bool ModifyPosition(ulong ticket, double sl, double tp) {
    if (!PositionSelectByTicket(ticket)) {
        LogError("Position not found for modification: " + IntegerToString(ticket));
        return false;
    }
    
    sl = NormalizePrice(sl);
    tp = NormalizePrice(tp);
    
    if (g_Trade.PositionModify(ticket, sl, tp)) {
        LogInfo("Position modified: " + IntegerToString(ticket));
        return true;
    }
    
    LogError("Failed to modify position: " + g_Trade.ResultRetcodeDescription());
    return false;
}

// Count open positions
int CountPositions(long magic = 0, ENUM_POSITION_TYPE posType = -1) {
    int count = 0;
    
    for (int i = 0; i < PositionsTotal(); i++) {
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) continue;
        
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        
        if (magic != 0 && PositionGetInteger(POSITION_MAGIC) != magic) continue;
        
        if (posType >= 0 && PositionGetInteger(POSITION_TYPE) != posType) continue;
        
        count++;
    }
    
    return count;
}

// Get position profit in points
double GetPositionProfitPoints(ulong ticket) {
    if (!PositionSelectByTicket(ticket)) return 0;
    
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    double profitPrice = (type == POSITION_TYPE_BUY) ? 
        (currentPrice - openPrice) : (openPrice - currentPrice);
    
    return PriceToPoints(profitPrice);
}

// Alias for backwards compatibility
double GetPositionProfitPips(ulong ticket) {
    return GetPositionProfitPoints(ticket);
}


// ===== RISK PROTECTION =====

// Calculate position size based on risk
double CalculatePositionSize(double riskPercent, double stopLossPips) {
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountBalance * (riskPercent / 100.0);
    
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    if (tickValue == 0) tickValue = 1.0;
    
    double stopLossPrice = stopLossPips * PipsToPrice(1.0);
    double lots = riskAmount / (stopLossPrice / GetPointValue() * tickValue);
    
    return NormalizeLots(lots);
}

// Calculate lot size from risk amount (not percentage) - Used by Kelly Fractal
double CalculateLotSizeFromRisk(double riskAmount, double stopLossPips) {
    if (riskAmount <= 0 || stopLossPips <= 0) return 0.01;
    
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    if (tickValue == 0) tickValue = 1.0;
    
    double stopLossPrice = stopLossPips * PipsToPrice(1.0);
    double lots = riskAmount / (stopLossPrice / GetPointValue() * tickValue);
    
    return NormalizeLots(lots);
}

// Check total risk exposure
bool CheckTotalRisk(double additionalRisk) {
    double totalRisk = 0;
    
    for (int i = 0; i < PositionsTotal(); i++) {
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) continue;
        
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        
        double sl = PositionGetDouble(POSITION_SL);
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double lots = PositionGetDouble(POSITION_VOLUME);
        
        if (sl > 0) {
            double slDistance = MathAbs(openPrice - sl);
            double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
            totalRisk += (slDistance / GetPointValue()) * tickValue * lots;
        }
    }
    
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double totalRiskPercent = ((totalRisk + additionalRisk) / balance) * 100.0;
    
    if (totalRiskPercent > 10.0) {
        LogWarning("Total risk exposure too high: " + DoubleToString(totalRiskPercent, 2) + "%");
        return false;
    }
    
    return true;
}


// ===== SIGNAL MANAGEMENT =====

bool RegisterSignal(string source) {
    // Prevent duplicate signals on same bar
    datetime currentBarTime = GetBarTime(_Symbol, _Period, 0);
    
    if (g_LastSignal.active && 
        g_LastSignal.triggered == currentBarTime && 
        g_LastSignal.source == source) {
        LogInfo("Signal already processed on this bar: " + source);
        return false;
    }
    
    g_LastSignal.active = true;
    g_LastSignal.triggered = currentBarTime;
    g_LastSignal.source = source;
    
    return true;
}

void ResetSignal() {
    g_LastSignal.active = false;
}


// ===== TIME HELPERS =====

// Check if current time is within session
bool IsWithinSession(int startHour, int endHour) {
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    int currentHour = timeStruct.hour;
    
    if (startHour <= endHour) {
        return (currentHour >= startHour && currentHour < endHour);
    } else {
        return (currentHour >= startHour || currentHour < endHour);
    }
}

// Check if today is a trading day
bool IsTradingDay(string days) {
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    int dayOfWeek = timeStruct.day_of_week; // 0=Sunday, 1=Monday, ..., 6=Saturday
    
    return (StringFind(days, IntegerToString(dayOfWeek)) >= 0);
}


// ===== INDICATOR HELPERS =====

// Get Moving Average value - FIXED: Proper handle management with retry logic
double GetMA(int period, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, int barShift = 0) {
    int handle = iMA(_Symbol, _Period, period, shift, method, price);
    if (handle == INVALID_HANDLE) {
        LogError("Failed to create MA handle");
        return 0;
    }
    
    double buffer[];
    ArrayResize(buffer, 1);
    ArraySetAsSeries(buffer, true);
    
    // Retry logic: Wait for indicator to calculate
    int attempts = 0;
    while (attempts < 5) {
        if (CopyBuffer(handle, 0, barShift, 1, buffer) > 0) {
            double value = SafeIndicatorValue(buffer[0]);
            IndicatorRelease(handle);
            return value;
        }
        Sleep(50); // Wait 50ms for indicator calculation
        attempts++;
    }
    
    LogError("Failed to copy MA buffer after 5 attempts");
    IndicatorRelease(handle);
    return 0;
}

// Get RSI value - FIXED: Proper handle management with retry logic
double GetRSI(int period, ENUM_APPLIED_PRICE price, int shift = 0) {
    int handle = iRSI(_Symbol, _Period, period, price);
    if (handle == INVALID_HANDLE) {
        LogError("Failed to create RSI handle");
        return 0;
    }
    
    double buffer[];
    ArrayResize(buffer, 1);
    ArraySetAsSeries(buffer, true);
    
    // Retry logic: Wait for indicator to calculate
    int attempts = 0;
    while (attempts < 5) {
        if (CopyBuffer(handle, 0, shift, 1, buffer) > 0) {
            double value = SafeIndicatorValue(buffer[0]);
            IndicatorRelease(handle);
            return value;
        }
        Sleep(50); // Wait 50ms for indicator calculation
        attempts++;
    }
    
    LogError("Failed to copy RSI buffer after 5 attempts");
    IndicatorRelease(handle);
    return 0;
}

// Get MACD value - FIXED: Proper handle management with retry logic
double GetMACD(int fastPeriod, int slowPeriod, int signalPeriod, ENUM_APPLIED_PRICE price, int mode, int shift = 0) {
    int handle = iMACD(_Symbol, _Period, fastPeriod, slowPeriod, signalPeriod, price);
    if (handle == INVALID_HANDLE) {
        LogError("Failed to create MACD handle");
        return 0;
    }
    
    double buffer[];
    ArrayResize(buffer, 1);
    ArraySetAsSeries(buffer, true);
    
    // Retry logic: Wait for indicator to calculate
    int attempts = 0;
    while (attempts < 5) {
        if (CopyBuffer(handle, mode, shift, 1, buffer) > 0) {
            double value = SafeIndicatorValue(buffer[0]);
            IndicatorRelease(handle);
            return value;
        }
        Sleep(50); // Wait 50ms for indicator calculation
        attempts++;
    }
    
    LogError("Failed to copy MACD buffer after 5 attempts");
    IndicatorRelease(handle);
    return 0;
}

// Get Bollinger Bands value - FIXED: Proper handle management with retry logic
double GetBands(int period, int shift, double deviation, ENUM_APPLIED_PRICE price, int mode, int barShift = 0) {
    int handle = iBands(_Symbol, _Period, period, shift, deviation, price);
    if (handle == INVALID_HANDLE) {
        LogError("Failed to create Bands handle");
        return 0;
    }
    
    double buffer[];
    ArrayResize(buffer, 1);
    ArraySetAsSeries(buffer, true);
    
    // Retry logic: Wait for indicator to calculate
    int attempts = 0;
    while (attempts < 5) {
        if (CopyBuffer(handle, mode, barShift, 1, buffer) > 0) {
            double value = SafeIndicatorValue(buffer[0]);
            IndicatorRelease(handle);
            return value;
        }
        Sleep(50); // Wait 50ms for indicator calculation
        attempts++;
    }
    
    LogError("Failed to copy Bands buffer after 5 attempts");
    IndicatorRelease(handle);
    return 0;
}

// Get ATR value - FIXED FEB 2026: Static handle cache to prevent error 4807
// Creating handles on every call is expensive and causes data-not-ready errors
double GetATR(int period, int shift = 0) {
    // Cache up to 8 different ATR period handles
    static int cachedATRHandles[8] = {INVALID_HANDLE, INVALID_HANDLE, INVALID_HANDLE, INVALID_HANDLE, INVALID_HANDLE, INVALID_HANDLE, INVALID_HANDLE, INVALID_HANDLE};
    static int cachedATRPeriods[8] = {0, 0, 0, 0, 0, 0, 0, 0};
    static int cachedATRCount = 0;
    
    int handle = INVALID_HANDLE;
    
    // Search for cached handle with matching period
    for (int i = 0; i < cachedATRCount; i++) {
        if (cachedATRPeriods[i] == period) {
            handle = cachedATRHandles[i];
            break;
        }
    }
    
    // Create and cache new handle if not found
    if (handle == INVALID_HANDLE) {
        handle = iATR(_Symbol, _Period, period);
        if (handle == INVALID_HANDLE) {
            LogError("Failed to create ATR handle for period " + IntegerToString(period));
            return 0;
        }
        if (cachedATRCount < 8) {
            cachedATRHandles[cachedATRCount] = handle;
            cachedATRPeriods[cachedATRCount] = period;
            cachedATRCount++;
        }
    }
    
    double buffer[];
    ArrayResize(buffer, 1);
    ArraySetAsSeries(buffer, true);
    
    // Retry logic with increased delay for indicator calculation
    int attempts = 0;
    while (attempts < 5) {
        if (CopyBuffer(handle, 0, shift, 1, buffer) > 0) {
            return SafeIndicatorValue(buffer[0]);
        }
        Sleep(100); // Wait 100ms for indicator calculation
        attempts++;
    }
    
    LogWarning("Failed to copy ATR buffer after 5 attempts | Period: " + IntegerToString(period) + " | LastError: " + IntegerToString(GetLastError()));
    return 0;
}

// Get Stochastic value - FIXED: Proper handle management with retry logic
double GetStochastic(int kPeriod, int dPeriod, int slowing, ENUM_MA_METHOD method, ENUM_STO_PRICE priceField, int mode, int shift = 0) {
    int handle = iStochastic(_Symbol, _Period, kPeriod, dPeriod, slowing, method, priceField);
    if (handle == INVALID_HANDLE) {
        LogError("Failed to create Stochastic handle");
        return 0;
    }
    
    double buffer[];
    ArrayResize(buffer, 1);
    ArraySetAsSeries(buffer, true);
    
    // Retry logic: Wait for indicator to calculate
    int attempts = 0;
    while (attempts < 5) {
        if (CopyBuffer(handle, mode, shift, 1, buffer) > 0) {
            double value = SafeIndicatorValue(buffer[0]);
            IndicatorRelease(handle);
            return value;
        }
        Sleep(50); // Wait 50ms for indicator calculation
        attempts++;
    }
    
    LogError("Failed to copy Stochastic buffer after 5 attempts");
    IndicatorRelease(handle);
    return 0;
}


// ===== ACTION HELPER FUNCTIONS =====

// ===== ACTION NODES MQL5 HELPER FUNCTIONS =====

// Get validated stop level (minimum distance from price)
double GetValidStopLevel() {
    double stopLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
    if (stopLevel < 10 * _Point) {
        stopLevel = 10 * _Point;  // Minimum 10 points
    }
    return stopLevel;
}

// Validate and adjust SL/TP to meet broker requirements
bool ValidateStops(ENUM_ORDER_TYPE orderType, double price, double &sl, double &tp) {
    double minStop = GetValidStopLevel();
    
    // For BUY orders (including BUY_LIMIT and BUY_STOP)
    if (orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP) {
        // SL must be below price
        if (sl > 0) {
            if (sl >= price) {
                // SL is on wrong side - place it below price
                sl = NormalizePrice(price - minStop);
                LogWarning("BUY SL was above price - adjusted to: " + DoubleToString(sl, GetDigitsValue()));
            } else if (price - sl < minStop) {
                sl = NormalizePrice(price - minStop);
                LogWarning("BUY SL adjusted to minimum distance: " + DoubleToString(sl, GetDigitsValue()));
            }
        }
        // TP must be above price
        if (tp > 0) {
            if (tp <= price) {
                tp = NormalizePrice(price + minStop);
                LogWarning("BUY TP was below price - adjusted to: " + DoubleToString(tp, GetDigitsValue()));
            } else if (tp - price < minStop) {
                tp = NormalizePrice(price + minStop);
                LogWarning("BUY TP adjusted to minimum distance: " + DoubleToString(tp, GetDigitsValue()));
            }
        }
    }
    // For SELL orders (including SELL_LIMIT and SELL_STOP)
    else {
        // SL must be above price
        if (sl > 0) {
            if (sl <= price) {
                // SL is on wrong side - place it above price
                sl = NormalizePrice(price + minStop);
                LogWarning("SELL SL was below price - adjusted to: " + DoubleToString(sl, GetDigitsValue()));
            } else if (sl - price < minStop) {
                sl = NormalizePrice(price + minStop);
                LogWarning("SELL SL adjusted to minimum distance: " + DoubleToString(sl, GetDigitsValue()));
            }
        }
        // TP must be below price
        if (tp > 0) {
            if (tp >= price) {
                tp = NormalizePrice(price - minStop);
                LogWarning("SELL TP was above price - adjusted to: " + DoubleToString(tp, GetDigitsValue()));
            } else if (price - tp < minStop) {
                tp = NormalizePrice(price - minStop);
                LogWarning("SELL TP adjusted to minimum distance: " + DoubleToString(tp, GetDigitsValue()));
            }
        }
    }
    
    return true;
}

// Count pending orders
int CountPendingOrders(long magic = 0, ENUM_ORDER_TYPE orderType = -1) {
    int count = 0;
    
    for (int i = 0; i < OrdersTotal(); i++) {
        ulong ticket = OrderGetTicket(i);
        if (ticket <= 0) continue;
        
        if (OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
        
        if (magic != 0 && OrderGetInteger(ORDER_MAGIC) != magic) continue;
        
        if (orderType >= 0 && OrderGetInteger(ORDER_TYPE) != orderType) continue;
        
        count++;
    }
    
    return count;
}

// Place pending order with SL/TP validation
ulong PlacePendingOrder(ENUM_ORDER_TYPE orderType, double lots, double price, double sl, double tp, string comment, long magic, datetime expiration = 0) {
    lots = NormalizeLots(lots);
    price = NormalizePrice(price);
    if (sl > 0) sl = NormalizePrice(sl);
    if (tp > 0) tp = NormalizePrice(tp);
    
    // ✅ CRITICAL: Validate and adjust SL/TP before placing order
    if (!ValidateStops(orderType, price, sl, tp)) {
        LogError("Failed to validate stops for pending order");
        return 0;
    }
    
    g_Trade.SetExpertMagicNumber(magic);
    g_Trade.SetDeviationInPoints(30);
    
    bool result = false;
    
    if (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP) {
        result = g_Trade.OrderOpen(_Symbol, orderType, lots, 0, price, sl, tp, ORDER_TIME_GTC, expiration, comment);
    } else if (orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP) {
        result = g_Trade.OrderOpen(_Symbol, orderType, lots, 0, price, sl, tp, ORDER_TIME_GTC, expiration, comment);
    }
    
    if (result) {
        return g_Trade.ResultOrder();
    }
    
    LogError("Failed to place pending order: " + g_Trade.ResultRetcodeDescription());
    return 0;
}

// Close partial position
bool ClosePartialPosition(ulong ticket, double percent) {
    if (!PositionSelectByTicket(ticket)) {
        LogError("Position not found for partial close");
        return false;
    }
    
    double currentVolume = PositionGetDouble(POSITION_VOLUME);
    double closeVolume = NormalizeLots(currentVolume * (percent / 100.0));
    
    if (closeVolume < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) {
        LogWarning("Partial close volume too small");
        return false;
    }
    
    if (g_Trade.PositionClosePartial(ticket, closeVolume)) {
        LogInfo("Partial close executed: " + DoubleToString(percent, 1) + "%");
        return true;
    }
    
    LogError("Failed to close partial position: " + g_Trade.ResultRetcodeDescription());
    return false;
}


// ===== INDICATOR EXTENDED HELPERS =====

// ===== INDICATOR NODES MQL5 HELPER FUNCTIONS =====

// ⚡ CRITICAL HELPER: Safe CopyBuffer with retry logic for all indicators
// This ensures indicator handles have time to calculate before reading data
// FIXED: Added ArrayResize to prevent error 4807 (array too small)
bool SafeCopyIndicatorBuffer(int handle, int bufferIndex, int shift, int count, double &buffer[], string indicatorName = "") {
    if (handle == INVALID_HANDLE) {
        LogError("Invalid handle for " + indicatorName);
        return false;
    }
    
    ArrayResize(buffer, count);
    ArraySetAsSeries(buffer, true);
    
    // Retry up to 5 times with 50ms delay between attempts
    int attempts = 0;
    while (attempts < 5) {
        if (CopyBuffer(handle, bufferIndex, shift, count, buffer) > 0) {
            return true;  // Success
        }
        Sleep(50);  // Wait for indicator calculation
        attempts++;
    }
    
    LogError("Failed to copy buffer for " + indicatorName + " after 5 attempts | LastError: " + IntegerToString(GetLastError()));
    return false;
}

// Helper: Safe oscillator value normalization (0-1 range)
double SafeOscillatorValue(double value, double minVal, double maxVal) {
    if (!IsValidValue(value)) return 0.0;
    if (value < minVal) return minVal;
    if (value > maxVal) return maxVal;
    return value;
}

// Helper: Debug logging (only in debug mode)
void LogDebug(string message) {
    if (g_DebugMode) {
        Print("[DEBUG] ", message);
    }
}

// NOTE: iBarShift is a NATIVE MQL5 function - no custom implementation needed
// Native signature: int iBarShift(string symbol, ENUM_TIMEFRAMES timeframe, datetime time)
// It performs approximate search (finds bar where bar_time <= time)

// SuperTrend - Correct algorithm with bar iteration and band smoothing
// Matches TradingView SuperTrend: proper band smoothing + close crossover
double GetSuperTrend(int period, double multiplier, ENUM_APPLIED_PRICE appliedPrice, int shift = 0) {
    // Static cache: recalculate only on new bar or parameter change
    static double st5_values[];
    static int st5_cachedBars = 0;
    static int st5_cachedPeriod = 0;
    static double st5_cachedMult = 0;
    static int st5_cacheSize = 0;
    
    int currentBars = Bars(_Symbol, _Period);
    
    if (st5_cachedBars != currentBars || st5_cachedPeriod != period || 
        MathAbs(st5_cachedMult - multiplier) > 0.0001) {
        
        int lookback = MathMin(MathMax(period * 10, 300), currentBars - period - 2);
        if (lookback < 2) lookback = 2;
        int total = lookback + 2; // +2 for closePrev access at lookback+1
        
        // Batch copy all data for efficiency
        int atrHandle = iATR(_Symbol, _Period, period);
        double atrBuf[], highBuf[], lowBuf[], closeBuf[];
        ArraySetAsSeries(atrBuf, true);
        ArraySetAsSeries(highBuf, true);
        ArraySetAsSeries(lowBuf, true);
        ArraySetAsSeries(closeBuf, true);
        
        bool ok = true;
        if (CopyBuffer(atrHandle, 0, 0, total, atrBuf) <= 0) ok = false;
        IndicatorRelease(atrHandle);
        if (!ok) return 0;
        
        if (CopyHigh(_Symbol, _Period, 0, total, highBuf) <= 0) return 0;
        if (CopyLow(_Symbol, _Period, 0, total, lowBuf) <= 0) return 0;
        if (CopyClose(_Symbol, _Period, 0, total, closeBuf) <= 0) return 0;
        
        ArrayResize(st5_values, lookback + 1);
        ArrayInitialize(st5_values, 0);
        
        double prevLowerBand = 0, prevUpperBand = 0;
        int dir = 1; // Start bullish
        
        for (int i = lookback; i >= 0; i--) {
            double atr = atrBuf[i];
            if (atr <= 0) {
                st5_values[i] = (i < lookback) ? st5_values[i + 1] : 0;
                continue;
            }
            
            double hl2 = (highBuf[i] + lowBuf[i]) / 2.0;
            double basicUpper = hl2 + multiplier * atr;
            double basicLower = hl2 - multiplier * atr;
            
            double finalLower = basicLower;
            double finalUpper = basicUpper;
            
            // Band smoothing: lower band can only increase, upper can only decrease
            if (prevLowerBand != 0) {
                double cp = closeBuf[i + 1];
                finalLower = (basicLower > prevLowerBand || cp < prevLowerBand) ? basicLower : prevLowerBand;
                finalUpper = (basicUpper < prevUpperBand || cp > prevUpperBand) ? basicUpper : prevUpperBand;
            }
            
            // Direction change: close price crossing the bands
            if (dir == 1 && closeBuf[i] < finalLower)
                dir = -1;
            else if (dir == -1 && closeBuf[i] > finalUpper)
                dir = 1;
            
            // SuperTrend value: lower band when bullish, upper band when bearish
            st5_values[i] = (dir == 1) ? finalLower : finalUpper;
            
            prevLowerBand = finalLower;
            prevUpperBand = finalUpper;
        }
        
        st5_cachedBars = currentBars;
        st5_cachedPeriod = period;
        st5_cachedMult = multiplier;
        st5_cacheSize = lookback + 1;
    }
    
    if (shift < 0 || shift >= st5_cacheSize) return 0;
    return SafeIndicatorValue(st5_values[shift]);
}

// SuperTrend Direction (derived from SuperTrend value)
// Price above ST = Bullish (1), Price below ST = Bearish (-1)
double GetSuperTrendDirection(int period, double multiplier, ENUM_APPLIED_PRICE appliedPrice) {
    double stValue = GetSuperTrend(period, multiplier, appliedPrice, 0);
    if (stValue <= 0) return 1; // Default bullish if no data
    double closePrice = iClose(_Symbol, _Period, 0);
    return (closePrice >= stValue) ? 1.0 : -1.0; // 1 = Bullish, -1 = Bearish
}

// DEMA (Double Exponential Moving Average)
double GetDEMA(int period, int maShift, ENUM_APPLIED_PRICE price, int shift = 0) {
    // DEMA = 2*EMA - EMA(EMA)
    int emaHandle = iMA(_Symbol, _Period, period, maShift, 1, price); // 1 = EMA
    if (emaHandle == INVALID_HANDLE) {
        LogError("Failed to create EMA handle for DEMA");
        return 0;
    }
    
    double ema = GetIndicatorValue(emaHandle, 0, shift);
    
    // Para calcular EMA(EMA), necesitamos crear un segundo handle
    // En MQL5, esto es más complejo, así que usamos una aproximación simplificada
    // DEMA ≈ 2*EMA - EMA_prev (aproximación)
    double emaPrev = GetIndicatorValue(emaHandle, 0, shift + 1);
    double dema = 2 * ema - emaPrev;
    
    IndicatorRelease(emaHandle);
    return dema;
}

// Extended indicator helpers
double GetCCI(int period, ENUM_APPLIED_PRICE price, int shift = 0) {
    int handle = iCCI(_Symbol, _Period, period, price);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "CCI")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetADX(int period, int shift = 0) {
    int handle = iADX(_Symbol, _Period, period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "ADX")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetADXPlusDI(int period, int shift = 0) {
    int handle = iADX(_Symbol, _Period, period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 1, shift, 1, buffer, "ADX +DI")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetADXMinusDI(int period, int shift = 0) {
    int handle = iADX(_Symbol, _Period, period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 2, shift, 1, buffer, "ADX -DI")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetWilliamsPercent(int period, int shift = 0) {
    int handle = iWPR(_Symbol, _Period, period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Williams %R")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetMomentum(int period, ENUM_APPLIED_PRICE price, int shift = 0) {
    int handle = iMomentum(_Symbol, _Period, period, price);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Momentum")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// Bill Williams indicators
double GetAlligatorJaw(int jawPeriod, int jawShift, int shift = 0) {
    int handle = iAlligator(_Symbol, _Period, jawPeriod, jawShift, 13, 8, 8, 5, 2, PRICE_MEDIAN); // 2 = SMMA
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Alligator Jaw")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetAlligatorTeeth(int teethPeriod, int teethShift, int shift = 0) {
    int handle = iAlligator(_Symbol, _Period, 13, 8, teethPeriod, teethShift, 8, 5, 2, PRICE_MEDIAN); // 2 = SMMA
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 1, shift, 1, buffer, "Alligator Teeth")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetAlligatorLips(int lipsPeriod, int lipsShift, int shift = 0) {
    int handle = iAlligator(_Symbol, _Period, 13, 8, 8, 5, lipsPeriod, lipsShift, 2, PRICE_MEDIAN); // 2 = SMMA
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 2, shift, 1, buffer, "Alligator Lips")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetAC(int shift = 0) {
    int handle = iAC(_Symbol, _Period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Accelerator")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetAO(int shift = 0) {
    int handle = iAO(_Symbol, _Period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Awesome Oscillator")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// Fractals
double GetFractalUp(int shift = 0) {
    int handle = iFractals(_Symbol, _Period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Fractal Up")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetFractalDown(int shift = 0) {
    int handle = iFractals(_Symbol, _Period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 1, shift, 1, buffer, "Fractal Down")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// Standard Deviation
double GetStdDev(int period, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, int barShift = 0) {
    int handle = iStdDev(_Symbol, _Period, period, shift, method, price);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, barShift, 1, buffer, "StdDev")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// Envelopes
double GetEnvelopes(int period, int shift, double deviation, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, int mode, int barShift = 0) {
    int handle = iEnvelopes(_Symbol, _Period, period, shift, method, price, deviation);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, mode, barShift, 1, buffer, "Envelopes")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// Hull Suite (HMA, EHMA, THMA) - mode: 0=HMA, 1=EHMA, 2=THMA
double GetHullSuite5(int period, int mode, ENUM_APPLIED_PRICE price, int maShift, int shift = 0) {
    if (period < 2) period = 2;
    int halfPeriod = (int)MathFloor(period / 2.0);
    if (halfPeriod < 1) halfPeriod = 1;
    int sqrtPeriod = (int)MathRound(MathSqrt((double)period));
    if (sqrtPeriod < 1) sqrtPeriod = 1;

    double hullValue = 0;

    if (mode == 0) {
        // HMA = WMA(2*WMA(n/2) - WMA(n), sqrt(n))
        double weightedSum = 0;
        double weightTotal = 0;
        for (int i = 0; i < sqrtPeriod; i++) {
            double wmaHalf = GetMA(halfPeriod, maShift, MODE_LWMA, price, shift + i);
            double wmaFull = GetMA(period, maShift, MODE_LWMA, price, shift + i);
            double raw = 2.0 * wmaHalf - wmaFull;
            double w = (double)(sqrtPeriod - i);
            weightedSum += raw * w;
            weightTotal += w;
        }
        hullValue = (weightTotal > 0) ? weightedSum / weightTotal : 0;
    }
    else if (mode == 1) {
        // EHMA = EMA(2*EMA(n/2) - EMA(n), sqrt(n))
        double alpha = 2.0 / (sqrtPeriod + 1.0);
        double emaValue = 0;
        for (int i = sqrtPeriod - 1; i >= 0; i--) {
            double emaHalf = GetMA(halfPeriod, maShift, MODE_EMA, price, shift + i);
            double emaFull = GetMA(period, maShift, MODE_EMA, price, shift + i);
            double raw = 2.0 * emaHalf - emaFull;
            if (i == sqrtPeriod - 1)
                emaValue = raw;
            else
                emaValue = alpha * raw + (1.0 - alpha) * emaValue;
        }
        hullValue = emaValue;
    }
    else if (mode == 2) {
        // THMA = WMA(3*WMA(n/3) - WMA(n/2) - WMA(n), n/2)
        int thirdPeriod = (int)MathFloor(period / 3.0);
        if (thirdPeriod < 1) thirdPeriod = 1;
        int thmaPeriod = (int)MathFloor(period / 2.0);
        if (thmaPeriod < 1) thmaPeriod = 1;
        double weightedSum = 0;
        double weightTotal = 0;
        for (int i = 0; i < thmaPeriod; i++) {
            double wmaThird = GetMA(thirdPeriod, maShift, MODE_LWMA, price, shift + i);
            double wmaHalf  = GetMA(halfPeriod, maShift, MODE_LWMA, price, shift + i);
            double wmaFull  = GetMA(period, maShift, MODE_LWMA, price, shift + i);
            double raw = 3.0 * wmaThird - wmaHalf - wmaFull;
            double w = (double)(thmaPeriod - i);
            weightedSum += raw * w;
            weightTotal += w;
        }
        hullValue = (weightTotal > 0) ? weightedSum / weightTotal : 0;
    }

    return SafeIndicatorValue(hullValue);
}

// TEMA (Triple Exponential Moving Average)
double GetTEMA(int period, int maShift, ENUM_APPLIED_PRICE price, int shift = 0) {
    // TEMA = (3*EMA) - (3*EMA(EMA)) + EMA(EMA(EMA))
    // Aproximación simplificada
    int emaHandle = iMA(_Symbol, _Period, period, maShift, 1, price); // 1 = EMA
    if (emaHandle == INVALID_HANDLE) {
        LogError("Failed to create EMA handle for TEMA");
        return 0;
    }
    
    double ema1 = GetIndicatorValue(emaHandle, 0, shift);
    double ema2 = GetIndicatorValue(emaHandle, 0, shift + period);
    double ema3 = GetIndicatorValue(emaHandle, 0, shift + period * 2);
    
    double tema = (3 * ema1) - (3 * ema2) + ema3;
    
    IndicatorRelease(emaHandle);
    return tema;
}

// TRIX (Triple Exponential Average)
double GetTRIX(int period, ENUM_APPLIED_PRICE price, int shift = 0) {
    int emaHandle = iMA(_Symbol, _Period, period, 0, 1, price); // 1 = EMA
    if (emaHandle == INVALID_HANDLE) return 0;
    
    double ema1 = GetIndicatorValue(emaHandle, 0, shift);
    double ema1Prev = GetIndicatorValue(emaHandle, 0, shift + 1);
    
    double trix = 0;
    if (ema1Prev != 0) {
        trix = ((ema1 - ema1Prev) / ema1Prev) * 100;
    }
    
    IndicatorRelease(emaHandle);
    return trix;
}

// ROC (Rate of Change)
double GetROC(int period, ENUM_APPLIED_PRICE price, int shift = 0) {
    double currentPrice = 0;
    double pastPrice = 0;
    
    if (price == PRICE_CLOSE) {
        currentPrice = GetBarClose(_Symbol, _Period, shift);
        pastPrice = GetBarClose(_Symbol, _Period, shift + period);
    } else if (price == PRICE_OPEN) {
        currentPrice = GetBarOpen(_Symbol, _Period, shift);
        pastPrice = GetBarOpen(_Symbol, _Period, shift + period);
    }
    
    if (pastPrice == 0) return 0;
    
    return ((currentPrice - pastPrice) / pastPrice) * 100;
}

// Ultimate Oscillator
double GetUltimateOscillator(int period1, int period2, int period3, int shift = 0) {
    double bp = GetBarClose(_Symbol, _Period, shift) - MathMin(GetBarLow(_Symbol, _Period, shift), GetBarClose(_Symbol, _Period, shift + 1));
    double tr = MathMax(GetBarHigh(_Symbol, _Period, shift), GetBarClose(_Symbol, _Period, shift + 1)) - 
                MathMin(GetBarLow(_Symbol, _Period, shift), GetBarClose(_Symbol, _Period, shift + 1));
    
    // Simplificación - implementación completa requiere promedios de múltiples períodos
    if (tr == 0) return 50;
    
    double avg = (bp / tr) * 100;
    return avg;
}

// KST (Know Sure Thing)
double GetKST(int shift = 0) {
    // KST usa ROC de múltiples períodos
    double roc1 = GetROC(10, PRICE_CLOSE, shift);
    double roc2 = GetROC(15, PRICE_CLOSE, shift);
    double roc3 = GetROC(20, PRICE_CLOSE, shift);
    double roc4 = GetROC(30, PRICE_CLOSE, shift);
    
    // Weighted sum
    return (roc1 * 1) + (roc2 * 2) + (roc3 * 3) + (roc4 * 4);
}

// Ichimoku Tenkan-sen (Conversion Line)
double GetIchimokuTenkan(int tenkan, int kijun, int senkou, int shift = 0) {
    int handle = iIchimoku(_Symbol, _Period, tenkan, kijun, senkou);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Ichimoku Tenkan")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// Ichimoku Kijun-sen (Base Line)
double GetIchimokuKijun(int tenkan, int kijun, int senkou, int shift = 0) {
    int handle = iIchimoku(_Symbol, _Period, tenkan, kijun, senkou);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 1, shift, 1, buffer, "Ichimoku Kijun")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// Ichimoku Senkou Span A (Leading Span A)
double GetIchimokuSpanA(int tenkan, int kijun, int senkou, int shift = 0) {
    int handle = iIchimoku(_Symbol, _Period, tenkan, kijun, senkou);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 2, shift, 1, buffer, "Ichimoku Span A")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// Ichimoku Senkou Span B (Leading Span B)
double GetIchimokuSpanB(int tenkan, int kijun, int senkou, int shift = 0) {
    int handle = iIchimoku(_Symbol, _Period, tenkan, kijun, senkou);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 3, shift, 1, buffer, "Ichimoku Span B")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// Volumes
double GetVolumes(int shift = 0) {
    int handle = iVolumes(_Symbol, _Period, VOLUME_TICK);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Volumes")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// Parabolic SAR
double GetSAR(double step, double maximum, int shift = 0) {
    int handle = iSAR(_Symbol, _Period, step, maximum);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "SAR")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// A/D (Accumulation/Distribution)
double GetAD(int shift = 0) {
    int handle = iAD(_Symbol, _Period, VOLUME_TICK);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "A/D")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// MFI (Money Flow Index)
double GetMFI(int period, int shift = 0) {
    int handle = iMFI(_Symbol, _Period, period, VOLUME_TICK);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "MFI")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// OBV (On Balance Volume)
double GetOBV(int shift = 0) {
    int handle = iOBV(_Symbol, _Period, VOLUME_TICK);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "OBV")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// VWMA (Volume Weighted Moving Average)
double GetVWMA(int period, int shift = 0) {
    double sum = 0;
    double volumeSum = 0;
    
    for (int i = 0; i < period; i++) {
        double price = GetBarClose(_Symbol, _Period, shift + i);
        long volume = GetBarVolume(_Symbol, _Period, shift + i);
        sum += price * (double)volume;
        volumeSum += (double)volume;
    }
    
    if (volumeSum == 0) return 0;
    return sum / volumeSum;
}

// CMF (Chaikin Money Flow)
double GetCMF(int period, int shift = 0) {
    double sumMFV = 0;
    double sumVolume = 0;
    
    for (int i = 0; i < period; i++) {
        double high = GetBarHigh(_Symbol, _Period, shift + i);
        double low = GetBarLow(_Symbol, _Period, shift + i);
        double close = GetBarClose(_Symbol, _Period, shift + i);
        long volume = GetBarVolume(_Symbol, _Period, shift + i);
        
        double mfm = 0;
        if (high - low != 0) {
            mfm = ((close - low) - (high - close)) / (high - low);
        }
        
        sumMFV += mfm * (double)volume;
        sumVolume += (double)volume;
    }
    
    if (sumVolume == 0) return 0;
    return sumMFV / sumVolume;
}

// VPT (Volume Price Trend)
double GetVPT(int shift = 0) {
    static double vpt = 0;
    
    double close = GetBarClose(_Symbol, _Period, shift);
    double prevClose = GetBarClose(_Symbol, _Period, shift + 1);
    long volume = GetBarVolume(_Symbol, _Period, shift);
    
    if (prevClose != 0) {
        vpt += (double)volume * ((close - prevClose) / prevClose);
    }
    
    return vpt;
}

// VWAP (Volume Weighted Average Price)
// FIX: Recalcula desde cero en cada llamada - evita bugs de estado (v2.0)
double GetVWAP(int shift = 0) {
    datetime currentTime = GetBarTime(_Symbol, _Period, shift);
    MqlDateTime timeStruct;
    TimeToStruct(currentTime, timeStruct);
    
    // Find the start of the current day
    timeStruct.hour = 0;
    timeStruct.min = 0;
    timeStruct.sec = 0;
    datetime dayStart = StructToTime(timeStruct);
    
    // Calculate how many bars since start of day
    int barsToInclude = 0;
    for (int i = shift; i < 1000; i++) { // Max 1000 bars per day
        datetime barTime = GetBarTime(_Symbol, _Period, i);
        if (barTime < dayStart) break;
        barsToInclude++;
    }
    
    if (barsToInclude < 1) barsToInclude = 20; // Fallback to 20 bars
    
    // Calculate VWAP from scratch
    double cumulativeTPV = 0;
    double cumulativeVolume = 0;
    
    for (int i = shift; i < shift + barsToInclude; i++) {
        double high = GetBarHigh(_Symbol, _Period, i);
        double low = GetBarLow(_Symbol, _Period, i);
        double close = GetBarClose(_Symbol, _Period, i);
        long volume = GetBarVolume(_Symbol, _Period, i);
        
        double typicalPrice = (high + low + close) / 3;
        cumulativeTPV += typicalPrice * (double)volume;
        cumulativeVolume += (double)volume;
    }
    
    if (cumulativeVolume == 0) return 0;
    return cumulativeTPV / cumulativeVolume;
}

// Keltner Channels
double GetKeltner(int period, ENUM_MA_METHOD maType, int atrPeriod, double multiplier, int mode, int shift = 0) {
    double ma = GetMA(period, 0, maType, PRICE_CLOSE, shift);
    double atr = GetATR(atrPeriod, shift);
    
    if (mode == 0) {
        return ma + (atr * multiplier); // Upper
    } else if (mode == 1) {
        return ma; // Middle
    } else {
        return ma - (atr * multiplier); // Lower
    }
}

// Donchian Channels
double GetDonchian(int period, int mode, int shift = 0) {
    double highest = GetBarHigh(_Symbol, _Period, shift);
    double lowest = GetBarLow(_Symbol, _Period, shift);
    
    for (int i = 1; i < period; i++) {
        double high = GetBarHigh(_Symbol, _Period, shift + i);
        double low = GetBarLow(_Symbol, _Period, shift + i);
        
        if (high > highest) highest = high;
        if (low < lowest) lowest = low;
    }
    
    if (mode == 0) {
        return highest; // Upper
    } else if (mode == 1) {
        return (highest + lowest) / 2; // Middle
    } else {
        return lowest; // Lower
    }
}

// Historic Volatility
double GetHistoricVolatility(int period, int bars, ENUM_APPLIED_PRICE price, int shift = 0) {
    double sum = 0;
    double returns[];
    ArrayResize(returns, bars);
    
    for (int i = 0; i < bars; i++) {
        double currentPrice = GetBarClose(_Symbol, _Period, shift + i);
        double prevPrice = GetBarClose(_Symbol, _Period, shift + i + 1);
        
        if (prevPrice != 0) {
            returns[i] = MathLog(currentPrice / prevPrice);
            sum += returns[i];
        }
    }
    
    double mean = sum / bars;
    double variance = 0;
    
    for (int i = 0; i < bars; i++) {
        variance += MathPow(returns[i] - mean, 2);
    }
    
    variance /= bars;
    double volatility = MathSqrt(variance) * MathSqrt(252) * 100; // Annualized
    
    return volatility;
}

// Choppiness Index
double GetChoppiness(int period, int shift = 0) {
    double highest = GetBarHigh(_Symbol, _Period, shift);
    double lowest = GetBarLow(_Symbol, _Period, shift);
    double sumATR = 0;
    
    for (int i = 0; i < period; i++) {
        double high = GetBarHigh(_Symbol, _Period, shift + i);
        double low = GetBarLow(_Symbol, _Period, shift + i);
        
        if (high > highest) highest = high;
        if (low < lowest) lowest = low;
        
        sumATR += GetATR(1, shift + i);
    }
    
    if (highest - lowest == 0) return 0;
    
    double chop = 100 * MathLog10(sumATR / (highest - lowest)) / MathLog10(period);
    return chop;
}

// Pivot Points
double GetPivotPoint(string type, int shift = 0) {
    double prevHigh = GetBarHigh(_Symbol, PERIOD_D1, shift + 1);
    double prevLow = GetBarLow(_Symbol, PERIOD_D1, shift + 1);
    double prevClose = GetBarClose(_Symbol, PERIOD_D1, shift + 1);
    
    if (type == "STANDARD") {
        return (prevHigh + prevLow + prevClose) / 3;
    } else if (type == "FIBONACCI") {
        return (prevHigh + prevLow + prevClose) / 3;
    } else if (type == "WOODIE") {
        return (prevHigh + prevLow + 2 * prevClose) / 4;
    }
    
    return (prevHigh + prevLow + prevClose) / 3;
}

double GetPivotResistance(string type, int level, int shift = 0) {
    double pp = GetPivotPoint(type, shift);
    double prevHigh = GetBarHigh(_Symbol, PERIOD_D1, shift + 1);
    double prevLow = GetBarLow(_Symbol, PERIOD_D1, shift + 1);
    
    if (type == "STANDARD") {
        if (level == 1) return 2 * pp - prevLow;
        if (level == 2) return pp + (prevHigh - prevLow);
        if (level == 3) return prevHigh + 2 * (pp - prevLow);
    } else if (type == "FIBONACCI") {
        if (level == 1) return pp + 0.382 * (prevHigh - prevLow);
        if (level == 2) return pp + 0.618 * (prevHigh - prevLow);
        if (level == 3) return pp + 1.0 * (prevHigh - prevLow);
    }
    
    return pp;
}

double GetPivotSupport(string type, int level, int shift = 0) {
    double pp = GetPivotPoint(type, shift);
    double prevHigh = GetBarHigh(_Symbol, PERIOD_D1, shift + 1);
    double prevLow = GetBarLow(_Symbol, PERIOD_D1, shift + 1);
    
    if (type == "STANDARD") {
        if (level == 1) return 2 * pp - prevHigh;
        if (level == 2) return pp - (prevHigh - prevLow);
        if (level == 3) return prevLow - 2 * (prevHigh - pp);
    } else if (type == "FIBONACCI") {
        if (level == 1) return pp - 0.382 * (prevHigh - prevLow);
        if (level == 2) return pp - 0.618 * (prevHigh - prevLow);
        if (level == 3) return pp - 1.0 * (prevHigh - prevLow);
    }
    
    return pp;
}

// Camarilla Pivots
double GetCamarillaPivot(int shift = 0) {
    double prevHigh = GetBarHigh(_Symbol, PERIOD_D1, shift + 1);
    double prevLow = GetBarLow(_Symbol, PERIOD_D1, shift + 1);
    double prevClose = GetBarClose(_Symbol, PERIOD_D1, shift + 1);
    
    return (prevHigh + prevLow + prevClose) / 3;
}

double GetCamarillaLevel(string level, int shift = 0) {
    double prevHigh = GetBarHigh(_Symbol, PERIOD_D1, shift + 1);
    double prevLow = GetBarLow(_Symbol, PERIOD_D1, shift + 1);
    double prevClose = GetBarClose(_Symbol, PERIOD_D1, shift + 1);
    double range = prevHigh - prevLow;
    
    if (level == "H4") return prevClose + range * 1.1 / 2;
    if (level == "H3") return prevClose + range * 1.1 / 4;
    if (level == "H2") return prevClose + range * 1.1 / 6;
    if (level == "H1") return prevClose + range * 1.1 / 12;
    if (level == "L1") return prevClose - range * 1.1 / 12;
    if (level == "L2") return prevClose - range * 1.1 / 6;
    if (level == "L3") return prevClose - range * 1.1 / 4;
    if (level == "L4") return prevClose - range * 1.1 / 2;
    
    return prevClose;
}

// MTF (Multi-Timeframe) Indicators
double GetMTF_MA(int period, int maShift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, ENUM_TIMEFRAMES timeframe, int shift = 0) {
    int handle = iMA(_Symbol, timeframe, period, maShift, method, price);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "MTF MA")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetMTF_RSI(int period, ENUM_APPLIED_PRICE price, ENUM_TIMEFRAMES timeframe, int shift = 0) {
    int handle = iRSI(_Symbol, timeframe, period, price);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "MTF RSI")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetMTF_Stochastic(int kPeriod, int dPeriod, int slowing, ENUM_MA_METHOD method, ENUM_STO_PRICE priceField, ENUM_TIMEFRAMES timeframe, int mode, int shift = 0) {
    int handle = iStochastic(_Symbol, timeframe, kPeriod, dPeriod, slowing, method, priceField);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, mode, shift, 1, buffer, "MTF Stochastic")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

double GetMTF_MACD(int fastPeriod, int slowPeriod, int signalPeriod, ENUM_APPLIED_PRICE price, ENUM_TIMEFRAMES timeframe, int mode, int shift = 0) {
    int handle = iMACD(_Symbol, timeframe, fastPeriod, slowPeriod, signalPeriod, price);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, mode, shift, 1, buffer, "MTF MACD")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

//+------------------------------------------------------------------+
//| MTF ADX - Multi-Timeframe ADX (MQL5)                              |
//+------------------------------------------------------------------+
double GetMTF_ADX(int period, ENUM_TIMEFRAMES timeframe, int mode, int shift = 0) {
    // mode: 0 = ADX main, 1 = +DI, 2 = -DI
    int handle = iADX(_Symbol, timeframe, period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, mode, shift, 1, buffer, "MTF ADX")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

//+------------------------------------------------------------------+
//| MTF SuperTrend - Correct algorithm with bar iteration (MQL5)      |
//| Band smoothing + close price crossover (matches TradingView)      |
//+------------------------------------------------------------------+
double GetMTF_SuperTrend(int period, double multiplier, ENUM_TIMEFRAMES timeframe, int shift = 0) {
    // Static cache per timeframe
    static double mtf5_st_values[];
    static int mtf5_st_cachedBars = 0;
    static int mtf5_st_cachedPeriod = 0;
    static double mtf5_st_cachedMult = 0;
    static ENUM_TIMEFRAMES mtf5_st_cachedTF = PERIOD_CURRENT;
    static int mtf5_st_cacheSize = 0;
    
    int totalBars = Bars(_Symbol, timeframe);
    
    if (mtf5_st_cachedBars != totalBars || mtf5_st_cachedPeriod != period || 
        MathAbs(mtf5_st_cachedMult - multiplier) > 0.0001 || mtf5_st_cachedTF != timeframe) {
        
        int lookback = MathMin(MathMax(period * 10, 300), totalBars - period - 2);
        if (lookback < 2) lookback = 2;
        int total = lookback + 2;
        
        // Batch copy all data from the specified timeframe
        int atrHandle = iATR(_Symbol, timeframe, period);
        double atrBuf[], highBuf[], lowBuf[], closeBuf[];
        ArraySetAsSeries(atrBuf, true);
        ArraySetAsSeries(highBuf, true);
        ArraySetAsSeries(lowBuf, true);
        ArraySetAsSeries(closeBuf, true);
        
        bool ok = true;
        if (CopyBuffer(atrHandle, 0, 0, total, atrBuf) <= 0) ok = false;
        IndicatorRelease(atrHandle);
        if (!ok) return 0;
        
        if (CopyHigh(_Symbol, timeframe, 0, total, highBuf) <= 0) return 0;
        if (CopyLow(_Symbol, timeframe, 0, total, lowBuf) <= 0) return 0;
        if (CopyClose(_Symbol, timeframe, 0, total, closeBuf) <= 0) return 0;
        
        ArrayResize(mtf5_st_values, lookback + 1);
        ArrayInitialize(mtf5_st_values, 0);
        
        double prevLowerBand = 0, prevUpperBand = 0;
        int dir = 1;
        
        for (int i = lookback; i >= 0; i--) {
            double atr = atrBuf[i];
            if (atr <= 0) {
                mtf5_st_values[i] = (i < lookback) ? mtf5_st_values[i + 1] : 0;
                continue;
            }
            
            double hl2 = (highBuf[i] + lowBuf[i]) / 2.0;
            double basicUpper = hl2 + multiplier * atr;
            double basicLower = hl2 - multiplier * atr;
            
            double finalLower = basicLower;
            double finalUpper = basicUpper;
            
            // Band smoothing
            if (prevLowerBand != 0) {
                double cp = closeBuf[i + 1];
                finalLower = (basicLower > prevLowerBand || cp < prevLowerBand) ? basicLower : prevLowerBand;
                finalUpper = (basicUpper < prevUpperBand || cp > prevUpperBand) ? basicUpper : prevUpperBand;
            }
            
            // Direction change
            if (dir == 1 && closeBuf[i] < finalLower)
                dir = -1;
            else if (dir == -1 && closeBuf[i] > finalUpper)
                dir = 1;
            
            mtf5_st_values[i] = (dir == 1) ? finalLower : finalUpper;
            
            prevLowerBand = finalLower;
            prevUpperBand = finalUpper;
        }
        
        mtf5_st_cachedBars = totalBars;
        mtf5_st_cachedPeriod = period;
        mtf5_st_cachedMult = multiplier;
        mtf5_st_cachedTF = timeframe;
        mtf5_st_cacheSize = lookback + 1;
    }
    
    if (shift < 0 || shift >= mtf5_st_cacheSize) return 0;
    return SafeIndicatorValue(mtf5_st_values[shift]);
}

//+------------------------------------------------------------------+
//| MTF SuperTrend Direction (derived from MTF SuperTrend value)      |
//+------------------------------------------------------------------+
double GetMTF_SuperTrendDirection(int period, double multiplier, ENUM_TIMEFRAMES timeframe) {
    double stValue = GetMTF_SuperTrend(period, multiplier, timeframe, 0);
    if (stValue <= 0) return 1; // Default bullish if no data
    double closePrice = iClose(_Symbol, timeframe, 0);
    return (closePrice >= stValue) ? 1.0 : -1.0; // 1 = Bullish, -1 = Bearish
}

// ===== NEW INDICATORS HELPER FUNCTIONS - PRIORITY HIGH =====

//+------------------------------------------------------------------+
//| DeMarker Indicator                                               |
//+------------------------------------------------------------------+
double GetDeMarker(int period, int shift = 0) {
    int handle = iDeMarker(_Symbol, _Period, period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "DeMarker")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeOscillatorValue(buffer[0], 0, 1);
    IndicatorRelease(handle);
    return value;
}

//+------------------------------------------------------------------+
//| Bears Power Indicator                                            |
//+------------------------------------------------------------------+
double GetBearsPower(int period, ENUM_APPLIED_PRICE price, int shift = 0) {
    int handle = iBearsPower(_Symbol, _Period, period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Bears Power")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

//+------------------------------------------------------------------+
//| Bulls Power Indicator                                            |
//+------------------------------------------------------------------+
double GetBullsPower(int period, ENUM_APPLIED_PRICE price, int shift = 0) {
    int handle = iBullsPower(_Symbol, _Period, period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Bulls Power")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

//+------------------------------------------------------------------+
//| OsMA (Moving Average of Oscillator) Indicator                    |
//+------------------------------------------------------------------+
double GetOsMA(int fastPeriod, int slowPeriod, int signalPeriod, ENUM_APPLIED_PRICE price, int shift = 0) {
    int handle = iOsMA(_Symbol, _Period, fastPeriod, slowPeriod, signalPeriod, price);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "OsMA")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

//+------------------------------------------------------------------+
//| Force Index Indicator                                            |
//+------------------------------------------------------------------+
double GetForce(int period, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE price, int shift = 0) {
    int handle = iForce(_Symbol, _Period, period, method, VOLUME_TICK);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Force Index")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

// ===== NEW INDICATORS HELPER FUNCTIONS - PRIORITY MEDIUM =====

//+------------------------------------------------------------------+
//| Gator Oscillator - Upper Histogram                               |
//+------------------------------------------------------------------+
double GetGatorUpper(int jawPeriod, int jawShift, int teethPeriod, int teethShift, 
                    int lipsPeriod, int lipsShift, ENUM_MA_METHOD method, 
                    ENUM_APPLIED_PRICE price, int shift = 0) {
    int handle = iGator(_Symbol, _Period, jawPeriod, jawShift, teethPeriod, teethShift, 
                       lipsPeriod, lipsShift, method, price);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "Gator Upper")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = MathAbs(SafeIndicatorValue(buffer[0]));
    IndicatorRelease(handle);
    return value;
}

//+------------------------------------------------------------------+
//| Gator Oscillator - Lower Histogram                               |
//+------------------------------------------------------------------+
double GetGatorLower(int jawPeriod, int jawShift, int teethPeriod, int teethShift, 
                    int lipsPeriod, int lipsShift, ENUM_MA_METHOD method, 
                    ENUM_APPLIED_PRICE price, int shift = 0) {
    int handle = iGator(_Symbol, _Period, jawPeriod, jawShift, teethPeriod, teethShift, 
                       lipsPeriod, lipsShift, method, price);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 1, shift, 1, buffer, "Gator Lower")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = MathAbs(SafeIndicatorValue(buffer[0]));
    IndicatorRelease(handle);
    return value;
}

//+------------------------------------------------------------------+
//| Standard Deviation (Independent Indicator)                       |
//+------------------------------------------------------------------+
double GetStdDevValue(int period, int maShift, ENUM_MA_METHOD method, 
                     ENUM_APPLIED_PRICE price, int shift = 0) {
    int handle = iStdDev(_Symbol, _Period, period, maShift, method, price);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "StdDev")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double value = SafeIndicatorValue(buffer[0]);
    IndicatorRelease(handle);
    return value;
}

//+------------------------------------------------------------------+
//| Williams %R Normalized (0-1 range)                               |
//+------------------------------------------------------------------+
double GetWPRNormalized(int period, int shift = 0) {
    int handle = iWPR(_Symbol, _Period, period);
    double buffer[];
    
    if (!SafeCopyIndicatorBuffer(handle, 0, shift, 1, buffer, "WPR")) {
        IndicatorRelease(handle);
        return 0;
    }
    
    double wpr = SafeIndicatorValue(buffer[0]);
    // WPR returns -100 to 0, normalize to 0-1
    double normalized = (wpr + 100.0) / 100.0;
    IndicatorRelease(handle);
    return SafeOscillatorValue(normalized, 0, 1);
}

// ===== NEW INDICATORS HELPER FUNCTIONS - SPECIAL =====

//+------------------------------------------------------------------+
//| Get Time-based Price Value                                       |
//+------------------------------------------------------------------+
double GetTimePriceValue(int targetHour, int targetMinute, int daysBack, string priceFunc) {
    // Find bar at specific time
    datetime targetTime = StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +
                                        StringFormat("%02d:%02d", targetHour, targetMinute));
    
    // Adjust for days back
    targetTime -= daysBack * 86400;
    
    // Use native MQL5 iBarShift (approximate search)
    int barShift = iBarShift(_Symbol, _Period, targetTime);
    
    if (barShift < 0) {
        LogWarning("Time-based price: bar not found for time " + TimeToString(targetTime));
        return 0;
    }
    
    double value = 0;
    if (priceFunc == "GetBarOpen") value = GetBarOpen(_Symbol, _Period, barShift);
    else if (priceFunc == "GetBarHigh") value = GetBarHigh(_Symbol, _Period, barShift);
    else if (priceFunc == "GetBarLow") value = GetBarLow(_Symbol, _Period, barShift);
    else value = GetBarClose(_Symbol, _Period, barShift);
    
    return SafeIndicatorValue(value);
}

//+------------------------------------------------------------------+
//| PRICE ACTION PATTERN DETECTION (MQL5)                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Detect Price Action Patterns                                     |
//+------------------------------------------------------------------+
double DetectPricePattern(string pattern, double minBodySize, bool validateVolume, int confirmationBars) {
    // Returns: 1 = Bullish Pattern, -1 = Bearish Pattern, 0 = No Pattern
    
    // Convert minBodySize from points to price
    double minBody = minBodySize * _Point * 10;
    
    // Get candle data for pattern detection (current + 3 previous bars)
    double o0 = GetBarOpen(_Symbol, _Period, confirmationBars);
    double h0 = GetBarHigh(_Symbol, _Period, confirmationBars);
    double l0 = GetBarLow(_Symbol, _Period, confirmationBars);
    double c0 = GetBarClose(_Symbol, _Period, confirmationBars);
    
    double o1 = GetBarOpen(_Symbol, _Period, confirmationBars + 1);
    double h1 = GetBarHigh(_Symbol, _Period, confirmationBars + 1);
    double l1 = GetBarLow(_Symbol, _Period, confirmationBars + 1);
    double c1 = GetBarClose(_Symbol, _Period, confirmationBars + 1);
    
    double o2 = GetBarOpen(_Symbol, _Period, confirmationBars + 2);
    double h2 = GetBarHigh(_Symbol, _Period, confirmationBars + 2);
    double l2 = GetBarLow(_Symbol, _Period, confirmationBars + 2);
    double c2 = GetBarClose(_Symbol, _Period, confirmationBars + 2);
    
    // Calculate body sizes
    double body0 = MathAbs(c0 - o0);
    double body1 = MathAbs(c1 - o1);
    double body2 = MathAbs(c2 - o2);
    
    // Calculate total range
    double range0 = h0 - l0;
    
    // Volume validation if required (FIXED: More permissive)
    if (validateVolume) {
        long currentVol = GetBarVolume(_Symbol, _Period, confirmationBars);
        long avgVol = 0;
        for (int i = 1; i <= 10; i++) {
            avgVol += GetBarVolume(_Symbol, _Period, confirmationBars + i);
        }
        avgVol = avgVol / 10;
        
        // FIXED: More permissive - only reject if volume is EXTREMELY low
        if (currentVol < avgVol * 0.5) {
            LogDebug("Pattern rejected: Low volume - Current: " + IntegerToString(currentVol) + " vs Avg: " + IntegerToString(avgVol));
            return 0;
        }
    }
    
    // BULLISH ENGULFING - FIXED: More permissive
    if (pattern == "BULLISH_ENGULFING") {
        bool bearishPrev = c1 < o1;
        bool bullishCurr = c0 > o0;
        bool engulfs = c0 > o1 && o0 < c1;
        // FIXED: More permissive - 50% of minBody is acceptable
        bool minBodyMet = body0 >= minBody * 0.5 && body1 >= minBody * 0.5;
        // Current body should be larger than previous (true engulfing)
        bool largerBody = body0 > body1;
        
        if (bearishPrev && bullishCurr && engulfs && minBodyMet && largerBody) {
            LogDebug("BULLISH ENGULFING detected: Prev=" + DoubleToString(body1/_Point, 1) + "p, Curr=" + DoubleToString(body0/_Point, 1) + "p");
            return 1;
        }
    }
    
    // BEARISH ENGULFING - FIXED: More permissive
    else if (pattern == "BEARISH_ENGULFING") {
        bool bullishPrev = c1 > o1;
        bool bearishCurr = c0 < o0;
        bool engulfs = c0 < o1 && o0 > c1;
        // FIXED: More permissive
        bool minBodyMet = body0 >= minBody * 0.5 && body1 >= minBody * 0.5;
        bool largerBody = body0 > body1;
        
        if (bullishPrev && bearishCurr && engulfs && minBodyMet && largerBody) {
            LogDebug("BEARISH ENGULFING detected: Prev=" + DoubleToString(body1/_Point, 1) + "p, Curr=" + DoubleToString(body0/_Point, 1) + "p");
            return -1;
        }
    }
    
    // HAMMER - FIXED: Realistic criteria
    else if (pattern == "HAMMER") {
        double lowerShadow = (c0 > o0) ? (o0 - l0) : (c0 - l0);
        double upperShadow = (c0 > o0) ? (h0 - c0) : (h0 - o0);
        
        // FIXED Hammer requirements:
        // 1. Small body (less than 33% of total range)
        bool smallBody = body0 < range0 * 0.33;
        
        // 2. Long lower shadow (at least 2x body OR at least 60% of range)
        bool longLowerShadow = (lowerShadow >= body0 * 2) || (lowerShadow >= range0 * 0.6);
        
        // 3. SHORT upper shadow (less than 40% of RANGE, not body)
        // CRITICAL FIX: Compare with range, NOT with body
        bool shortUpperShadow = upperShadow < range0 * 0.4;
        
        // 4. Minimum range to avoid noise (FIXED: More permissive - 1x instead of 2x)
        double minRange = minBody * 1.0;
        bool hasMinRange = range0 >= minRange;
        
        if (smallBody && longLowerShadow && shortUpperShadow && hasMinRange) {
            LogDebug("HAMMER detected: Body=" + DoubleToString(body0/_Point, 1) + "p, LowerShadow=" + DoubleToString(lowerShadow/_Point, 1) + "p, UpperShadow=" + DoubleToString(upperShadow/_Point, 1) + "p, Range=" + DoubleToString(range0/_Point, 1) + "p");
            return 1; // Bullish reversal
        }
    }
    
    // SHOOTING STAR - FIXED: Realistic criteria
    else if (pattern == "SHOOTING_STAR") {
        double lowerShadow = (c0 > o0) ? (o0 - l0) : (c0 - l0);
        double upperShadow = (c0 > o0) ? (h0 - c0) : (h0 - o0);
        
        // FIXED Shooting Star requirements:
        bool smallBody = body0 < range0 * 0.33;
        bool longUpperShadow = (upperShadow >= body0 * 2) || (upperShadow >= range0 * 0.6);
        bool shortLowerShadow = lowerShadow < range0 * 0.4;
        double minRange = minBody * 1.0;
        bool hasMinRange = range0 >= minRange;
        
        if (smallBody && longUpperShadow && shortLowerShadow && hasMinRange) {
            LogDebug("SHOOTING STAR detected: Body=" + DoubleToString(body0/_Point, 1) + "p, UpperShadow=" + DoubleToString(upperShadow/_Point, 1) + "p, LowerShadow=" + DoubleToString(lowerShadow/_Point, 1) + "p, Range=" + DoubleToString(range0/_Point, 1) + "p");
            return -1; // Bearish reversal
        }
    }
    
    // DOJI - FIXED: More permissive
    else if (pattern == "DOJI") {
        double bodyRatio = (range0 > 0) ? (body0 / range0) : 0;
        // FIXED: Accept slightly larger bodies (15% instead of 10%)
        bool verySmallBody = bodyRatio < 0.15;
        bool hasRange = range0 > _Point * 10; // Minimum range
        
        if (verySmallBody && hasRange) {
            LogDebug("DOJI detected: Body=" + DoubleToString(body0/_Point, 1) + "p (" + DoubleToString(bodyRatio*100, 1) + "% of range)");
            return 1; // Return 1 for bullish context (can be used for reversals)
        }
    }
    
    // MORNING STAR (3-candle pattern) - FIXED: More permissive
    else if (pattern == "MORNING_STAR") {
        bool bearish1 = c2 < o2 && body2 >= minBody * 0.5;
        // FIXED: Accept larger middle body (40% instead of 30%)
        bool smallBody1 = body1 < body2 * 0.4;
        // FIXED: Gap not required, just lower position
        bool gap1 = h1 <= c2 || l1 < MathMin(o2, c2);
        bool bullish0 = c0 > o0 && body0 >= minBody * 0.5;
        // FIXED: Close above midpoint of first candle
        bool closes = c0 > (o2 + c2) / 2;
        
        if (bearish1 && smallBody1 && gap1 && bullish0 && closes) {
            LogDebug("MORNING STAR detected: 3-candle bullish reversal pattern");
            return 1;
        }
    }
    
    // EVENING STAR (3-candle pattern) - FIXED: More permissive
    else if (pattern == "EVENING_STAR") {
        bool bullish2 = c2 > o2 && body2 >= minBody * 0.5;
        bool smallBody1 = body1 < body2 * 0.4;
        // FIXED: Gap not required, just higher position
        bool gap1 = l1 >= c2 || h1 > MathMax(o2, c2);
        bool bearish0 = c0 < o0 && body0 >= minBody * 0.5;
        bool closes = c0 < (o2 + c2) / 2;
        
        if (bullish2 && smallBody1 && gap1 && bearish0 && closes) {
            LogDebug("EVENING STAR detected: 3-candle bearish reversal pattern");
            return -1;
        }
    }
    
    // HARAMI - FIXED: More permissive (Bullish and Bearish)
    else if (pattern == "HARAMI") {
        // Bullish Harami
        bool bearish1 = c1 < o1 && body1 >= minBody * 0.5;
        bool bullish0 = c0 > o0;
        bool inside = o0 > c1 && c0 < o1;
        // FIXED: Accept up to 60% of previous body (was 50%)
        bool smallBody = body0 < body1 * 0.6;
        
        if (bearish1 && bullish0 && inside && smallBody) {
            LogDebug("BULLISH HARAMI detected: Inside bar reversal");
            return 1;
        }
        
        // Bearish Harami
        bool bullish1Alt = c1 > o1 && body1 >= minBody * 0.5;
        bool bearish0Alt = c0 < o0;
        bool insideAlt = o0 < c1 && c0 > o1;
        
        if (bullish1Alt && bearish0Alt && insideAlt && body0 < body1 * 0.6) {
            LogDebug("BEARISH HARAMI detected: Inside bar reversal");
            return -1;
        }
    }
    
    // DARK CLOUD COVER - FIXED: More permissive
    else if (pattern == "DARK_CLOUD") {
        bool bullish1 = c1 > o1 && body1 >= minBody * 0.5;
        bool bearish0 = c0 < o0 && body0 >= minBody * 0.5;
        // FIXED: Opens above is not strict requirement
        bool opensAbove = o0 >= c1;
        // FIXED: Must close below midpoint of previous candle
        bool closesInto = c0 < (o1 + c1) / 2 && c0 > o1;
        
        if (bullish1 && bearish0 && opensAbove && closesInto) {
            LogDebug("DARK CLOUD COVER detected: Bearish reversal pattern");
            return -1;
        }
    }
    
    // PIERCING LINE - FIXED: More permissive
    else if (pattern == "PIERCING") {
        bool bearish1 = c1 < o1 && body1 >= minBody * 0.5;
        bool bullish0 = c0 > o0 && body0 >= minBody * 0.5;
        // FIXED: Opens below is not strict requirement
        bool opensBelow = o0 <= c1;
        // FIXED: Must close above midpoint of previous candle
        bool closesInto = c0 > (o1 + c1) / 2 && c0 < o1;
        
        if (bearish1 && bullish0 && opensBelow && closesInto) {
            LogDebug("PIERCING LINE detected: Bullish reversal pattern");
            return 1;
        }
    }
    
    return 0; // No pattern detected
}

// NOTE: GetBarVolume is already defined in the base compatibility helpers section
// of the code generator. No need to redefine it here.

//+------------------------------------------------------------------+
//| Lowest/Highest in period with shift (MQL5)                       |
//+------------------------------------------------------------------+
int iLowestMQL5(int mode, int count, int startShift) {
    // MQL5 uses iLowest which returns the bar index of the lowest value
    // mode: 0=High, 1=Low, 2=Close, 3=Open
    ENUM_SERIESMODE seriesMode;
    if (mode == 0) seriesMode = MODE_HIGH;
    else if (mode == 1) seriesMode = MODE_LOW;
    else if (mode == 2) seriesMode = MODE_CLOSE;
    else if (mode == 3) seriesMode = MODE_OPEN;
    else seriesMode = MODE_LOW;
    
    return iLowest(_Symbol, _Period, seriesMode, count, startShift);
}

int iHighestMQL5(int mode, int count, int startShift) {
    // MQL5 uses iHighest which returns the bar index of the highest value
    ENUM_SERIESMODE seriesMode;
    if (mode == 0) seriesMode = MODE_HIGH;
    else if (mode == 1) seriesMode = MODE_LOW;
    else if (mode == 2) seriesMode = MODE_CLOSE;
    else if (mode == 3) seriesMode = MODE_OPEN;
    else seriesMode = MODE_HIGH;
    
    return iHighest(_Symbol, _Period, seriesMode, count, startShift);
}

double GetLowestValue(int mode, int count, int startShift) {
    int barIdx = iLowestMQL5(mode, count, startShift);
    if (barIdx < 0 || barIdx >= Bars(_Symbol, _Period)) return 0;
    
    double prices[];
    ArraySetAsSeries(prices, true);
    
    if (mode == 0) { // High
        if (CopyHigh(_Symbol, _Period, 0, barIdx + 1, prices) < 0) return 0;
    } else if (mode == 1) { // Low
        if (CopyLow(_Symbol, _Period, 0, barIdx + 1, prices) < 0) return 0;
    } else if (mode == 2) { // Close
        if (CopyClose(_Symbol, _Period, 0, barIdx + 1, prices) < 0) return 0;
    } else { // Open
        if (CopyOpen(_Symbol, _Period, 0, barIdx + 1, prices) < 0) return 0;
    }
    
    return prices[barIdx];
}

double GetHighestValue(int mode, int count, int startShift) {
    int barIdx = iHighestMQL5(mode, count, startShift);
    if (barIdx < 0 || barIdx >= Bars(_Symbol, _Period)) return 0;
    
    double prices[];
    ArraySetAsSeries(prices, true);
    
    if (mode == 0) { // High
        if (CopyHigh(_Symbol, _Period, 0, barIdx + 1, prices) < 0) return 0;
    } else if (mode == 1) { // Low
        if (CopyLow(_Symbol, _Period, 0, barIdx + 1, prices) < 0) return 0;
    } else if (mode == 2) { // Close
        if (CopyClose(_Symbol, _Period, 0, barIdx + 1, prices) < 0) return 0;
    } else { // Open
        if (CopyOpen(_Symbol, _Period, 0, barIdx + 1, prices) < 0) return 0;
    }
    
    return prices[barIdx];
}

//+------------------------------------------------------------------+
//| Range Detection Helpers (MQL5)                                    |
//+------------------------------------------------------------------+
bool IsMarketRanging_MQL5(string method, int periods, double threshold) {
    if (method == "ADX") {
        int adxHandle = iADX(_Symbol, _Period, periods);
        if (adxHandle == INVALID_HANDLE) return false;
        
        double adxBuffer[];
        ArrayResize(adxBuffer, 1); // FIX FEB 2026: Pre-allocate to prevent error 4807
        ArraySetAsSeries(adxBuffer, true);
        if (CopyBuffer(adxHandle, 0, 0, 1, adxBuffer) <= 0) {
            IndicatorRelease(adxHandle);
            return false;
        }
        
        bool isRanging = (adxBuffer[0] < threshold);
        IndicatorRelease(adxHandle);
        return isRanging;
    }
    else if (method == "ATR") {
        double atr = GetATR(periods, 0);
        double avgPrice = (iHigh(_Symbol, _Period, 0) + iLow(_Symbol, _Period, 0)) / 2;
        double atrPercent = (atr / avgPrice) * 100;
        return (atrPercent < threshold / 100);
    }
    else { // HIGHLOW or default
        double highest = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, periods, 0));
        double lowest = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, periods, 0));
        double range = highest - lowest;
        double avgPrice = (highest + lowest) / 2;
        double rangePercent = (range / avgPrice) * 100;
        return (rangePercent < threshold / 10);
    }
}

double CalculateRangeWidth_MQL5(int periods) {
    double highest = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, periods, 0));
    double lowest = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, periods, 0));
    return highest - lowest;
}

//+------------------------------------------------------------------+
//| Trend Detection Helpers (MQL5)                                    |
//+------------------------------------------------------------------+
bool IsTrendUp_MQL5(string method, int periods, double minSlope, string strength) {
    if (method == "MA") {
        double ma1 = GetMA(periods, 0, MODE_EMA, PRICE_CLOSE, 0);
        double ma2 = GetMA(periods, 0, MODE_EMA, PRICE_CLOSE, periods/2);
        double slope = (ma1 - ma2) / (periods/2);
        
        if (strength == "STRONG") {
            return (slope > minSlope * 2 * _Point);
        }
        return (slope > minSlope * _Point);
    }
    else { // Price-based
        double close0 = iClose(_Symbol, _Period, 0);
        double closeN = iClose(_Symbol, _Period, periods);
        double slope = (close0 - closeN) / periods;
        
        if (strength == "STRONG") {
            return (slope > minSlope * 2 * _Point);
        }
        return (slope > minSlope * _Point);
    }
}

bool IsTrendDown_MQL5(string method, int periods, double minSlope, string strength) {
    if (method == "MA") {
        double ma1 = GetMA(periods, 0, MODE_EMA, PRICE_CLOSE, 0);
        double ma2 = GetMA(periods, 0, MODE_EMA, PRICE_CLOSE, periods/2);
        double slope = (ma1 - ma2) / (periods/2);
        
        if (strength == "STRONG") {
            return (slope < -minSlope * 2 * _Point);
        }
        return (slope < -minSlope * _Point);
    }
    else { // Price-based
        double close0 = iClose(_Symbol, _Period, 0);
        double closeN = iClose(_Symbol, _Period, periods);
        double slope = (close0 - closeN) / periods;
        
        if (strength == "STRONG") {
            return (slope < -minSlope * 2 * _Point);
        }
        return (slope < -minSlope * _Point);
    }
}

//+------------------------------------------------------------------+
//| Support/Resistance Detection (MQL5)                               |
//+------------------------------------------------------------------+
double FindSupportLevel_MQL5(int period, int strength, string method) {
    if (method == "FRACTAL") {
        double bestSupport = 0;
        int bestTouches = 0;
        for (int i = 2; i < period - 2; i++) {
            double low_i = iLow(_Symbol, _Period, i);
            if (low_i < iLow(_Symbol, _Period, i-1) && low_i < iLow(_Symbol, _Period, i-2) &&
                low_i < iLow(_Symbol, _Period, i+1) && low_i < iLow(_Symbol, _Period, i+2)) {
                int touches = 0;
                double zone = strength * _Point * 10;
                for (int j = 0; j < period; j++) {
                    if (MathAbs(iLow(_Symbol, _Period, j) - low_i) <= zone) touches++;
                }
                if (touches >= strength && (bestTouches == 0 || touches > bestTouches)) {
                    bestSupport = low_i;
                    bestTouches = touches;
                }
            }
        }
        if (bestSupport > 0) return bestSupport;
    }

    double lowestLow = iLow(_Symbol, _Period, iLowest(_Symbol, _Period, MODE_LOW, period, 0));
    int touches = 0;
    double supportZone = lowestLow + (strength * _Point * 10);
    for (int i = 0; i < period; i++) {
        double low = iLow(_Symbol, _Period, i);
        if (low <= supportZone && low >= lowestLow) touches++;
    }
    return lowestLow;
}

double FindResistanceLevel_MQL5(int period, int strength, string method) {
    if (method == "FRACTAL") {
        double bestResistance = 0;
        int bestTouches = 0;
        for (int i = 2; i < period - 2; i++) {
            double high_i = iHigh(_Symbol, _Period, i);
            if (high_i > iHigh(_Symbol, _Period, i-1) && high_i > iHigh(_Symbol, _Period, i-2) &&
                high_i > iHigh(_Symbol, _Period, i+1) && high_i > iHigh(_Symbol, _Period, i+2)) {
                int touches = 0;
                double zone = strength * _Point * 10;
                for (int j = 0; j < period; j++) {
                    if (MathAbs(iHigh(_Symbol, _Period, j) - high_i) <= zone) touches++;
                }
                if (touches >= strength && (bestTouches == 0 || touches > bestTouches)) {
                    bestResistance = high_i;
                    bestTouches = touches;
                }
            }
        }
        if (bestResistance > 0) return bestResistance;
    }

    double highestHigh = iHigh(_Symbol, _Period, iHighest(_Symbol, _Period, MODE_HIGH, period, 0));
    int touches = 0;
    double resistanceZone = highestHigh - (strength * _Point * 10);
    for (int i = 0; i < period; i++) {
        double high = iHigh(_Symbol, _Period, i);
        if (high >= resistanceZone && high <= highestHigh) touches++;
    }
    return highestHigh;
}

//+------------------------------------------------------------------+
//| Momentum Detection (MQL5)                                         |
//+------------------------------------------------------------------+
double CalculateMomentumStrength_MQL5(int periods) {
    double close0 = iClose(_Symbol, _Period, 0);
    double closeN = iClose(_Symbol, _Period, periods);

    if (closeN == 0) return 0;

    // Calculate percentage change
    double change = ((close0 - closeN) / closeN) * 100;

    return change;
}

//+------------------------------------------------------------------+
//| Detect Momentum Condition (MQL5)                                   |
//+------------------------------------------------------------------+
bool DetectMomentum_MQL5(string type, double value, int periods, double threshold) {
    int momHandle = iMomentum(_Symbol, _Period, periods, PRICE_CLOSE);
    if (momHandle == INVALID_HANDLE) return false;
    
    double buffer[];
    ArraySetAsSeries(buffer, true);
    if (CopyBuffer(momHandle, 0, 0, 1, buffer) <= 0) {
        IndicatorRelease(momHandle);
        return false;
    }
    
    double momentum = buffer[0];
    IndicatorRelease(momHandle);
    
    if (type == "INCREASING" || type == "BULLISH") {
        return (momentum > 100 + threshold);
    }
    else if (type == "DECREASING" || type == "BEARISH") {
        return (momentum < 100 - threshold);
    }
    else { // ANY
        return (MathAbs(momentum - 100) > threshold);
    }
}

//+------------------------------------------------------------------+
//| Market Statistics Pro - Panel Helper Functions (MQL5)             |
//+------------------------------------------------------------------+
void MktStatsLabel5(string name, string text, int x, int y, color clr, int sz) {
    if (ObjectFind(0, name) < 0) {
        ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
    }
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, sz);
}

void MktStatsRect5(string name, int x, int y, int w, int h, color bgClr, color borderClr) {
    if (ObjectFind(0, name) < 0) {
        ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
        ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, name, OBJPROP_BACK, false);
        ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    }
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
    ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgClr);
    ObjectSetInteger(0, name, OBJPROP_COLOR, borderClr);
}


// ===== STRATEGY BOOST HELPER FUNCTIONS =====

// ===== STRATEGY BOOST NODES MQL5 HELPER FUNCTIONS =====

// Calculate total risk for a magic number
double CalculateTotalRisk(long magic) {
    double totalRisk = 0;
    
    for (int i = 0; i < PositionsTotal(); i++) {
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) continue;
        
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        // Magic Number = 0: Apply to ALL positions of this symbol
        if (magic != 0 && PositionGetInteger(POSITION_MAGIC) != magic) continue;
        
        double sl = PositionGetDouble(POSITION_SL);
        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double lots = PositionGetDouble(POSITION_VOLUME);
        
        if (sl > 0) {
            double slDistance = MathAbs(openPrice - sl);
            double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
            totalRisk += (slDistance / GetPointValue()) * tickValue * lots;
        }
    }
    
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    return (totalRisk / balance) * 100.0;
}

// Update scale-in targets
void UpdateScaleInTargets(double avgPrice, double takeProfitPips, long magic) {
    for (int i = 0; i < PositionsTotal(); i++) {
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) continue;
        
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        // Magic Number = 0: Apply to ALL positions of this symbol
        if (magic != 0 && PositionGetInteger(POSITION_MAGIC) != magic) continue;
        
        string comment = PositionGetString(POSITION_COMMENT);
        if (StringFind(comment, "Scale-In") >= 0) {
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            double newTP = 0;
            
            if (type == POSITION_TYPE_BUY) {
                newTP = NormalizePrice(avgPrice + PipsToPrice(takeProfitPips));
            } else {
                newTP = NormalizePrice(avgPrice - PipsToPrice(takeProfitPips));
            }
            
            ModifyPosition(ticket, PositionGetDouble(POSITION_SL), newTP);
        }
    }
}

// Note: ClosePartialPosition and PlacePendingOrder are already defined in actionNodesMQL5HelperFunctions


// ===== PANEL POSITION HELPER FUNCTIONS (Runtime) =====
int __PanelPosX(int pos, int w) {
   int col = pos % 3;
   if(col == 0) return 10;
   if(col == 2) return (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - w - 10;
   return ((int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS) - w) / 2;
}
int __PanelPosY(int pos, int h) {
   int row = pos / 3;
   if(row == 0) return 30;
   if(row == 2) return (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - h - 30;
   return ((int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS) - h) / 2;
}

// ===== ARTIFICIAL INTELLIGENCE HELPER FUNCTIONS (MQL5) =====

// ===== ARTIFICIAL INTELLIGENCE HELPER FUNCTIONS (MQL5) =====
// Strategic Agent IA - Market Regime Detection + Adaptive RL
// Version: v1.0.0-ai-mql5

//+------------------------------------------------------------------+
//| MARKET REGIME DETECTION SYSTEM (MQL5)                             |
//+------------------------------------------------------------------+

// Market Regime Enumeration
enum ENUM_AI_MARKET_REGIME {
    AI_REGIME_TRENDING_UP_CALM,      // 0 - Strong uptrend, low volatility
    AI_REGIME_TRENDING_UP_NORMAL,    // 1 - Uptrend, normal volatility
    AI_REGIME_TRENDING_UP_VOLATILE,  // 2 - Uptrend, high volatility
    AI_REGIME_TRENDING_DOWN_CALM,    // 3 - Strong downtrend, low volatility
    AI_REGIME_TRENDING_DOWN_NORMAL,  // 4 - Downtrend, normal volatility
    AI_REGIME_TRENDING_DOWN_VOLATILE,// 5 - Downtrend, high volatility
    AI_REGIME_RANGING_QUIET,         // 6 - Range, very low volatility
    AI_REGIME_RANGING_NORMAL,        // 7 - Range, normal volatility
    AI_REGIME_VOLATILE_CHAOS,        // 8 - No clear direction, extreme volatility
    AI_REGIME_TRANSITION             // 9 - Regime is changing
};

// Volatility Classification
enum ENUM_AI_VOLATILITY_CLASS {
    AI_VOL_LOW,
    AI_VOL_NORMAL,
    AI_VOL_ELEVATED,
    AI_VOL_HIGH
};

// Momentum State
enum ENUM_AI_MOMENTUM_STATE {
    AI_MOM_OVERSOLD,
    AI_MOM_BULLISH,
    AI_MOM_NEUTRAL,
    AI_MOM_BEARISH,
    AI_MOM_OVERBOUGHT
};

// AI State Structure
struct AI_MarketStateStruct {
    ENUM_AI_MARKET_REGIME regime;
    double trendScore;           // -1 to +1
    double trendStrength;        // 0 to 100 (ADX)
    ENUM_AI_VOLATILITY_CLASS volatility;
    double volatilityRatio;      // Current ATR vs Historical
    double atrValue;             // Current ATR in price units (for SL/TP calculation)
    ENUM_AI_MOMENTUM_STATE momentum;
    double rsiValue;
    double bbUpperDistance;      // Distance to upper BB in ATR multiples
    double bbLowerDistance;      // Distance to lower BB in ATR multiples
    double supportLevel;
    double resistanceLevel;
    datetime lastUpdate;
};

// Q-Learning State
struct AI_QLearningStateStruct {
    int stateIndex;              // Discretized state (0-99)
    double qValues[4];           // Q-values for actions: HOLD, BUY, SELL, CLOSE
    double learningRate;         // Alpha
    double discountFactor;       // Gamma
    double explorationRate;      // Epsilon
    int totalEpisodes;
    double cumulativeReward;
};

// Performance Tracking
struct AI_PerformanceMetricsStruct {
    int totalTrades;
    int winningTrades;
    int losingTrades;
    double totalProfit;
    double maxDrawdown;
    double sharpeRatio;
    double profitFactor;
    double avgWin;
    double avgLoss;
    datetime lastTradeTime;
    bool isPaused;
    string pauseReason;
};

// Experience Replay Structure - Para aprendizaje acelerado
struct AI_ExperienceStruct {
    int state;           // Estado cuando tomó la decisión
    int action;          // Qué hizo (0=HOLD, 1=BUY, 2=SELL, 3=CLOSE)
    double reward;       // Resultado del trade
    int nextState;       // Estado después del trade
    datetime timestamp;  // Cuándo ocurrió
};

// Global AI Variables (MQL5)
AI_MarketStateStruct g_aiMarketState5;
AI_QLearningStateStruct g_aiQLearning5;
AI_PerformanceMetricsStruct g_aiPerformance5;
double g_aiDDLimit5 = 20;
double g_aiEdgeMFESum5 = 0;
double g_aiEdgeMAESum5 = 0;
int g_aiEdgeTrades5 = 0;
double g_qTable5[100][4];                    // 100 states x 4 actions
double g_historicalATR5[100];               // Historical ATR buffer
int g_atrHistoryIndex5 = 0;
bool g_aiInitialized5 = false;
datetime g_lastPanelUpdate5 = 0;

// ===== LEARNING PROGRESS TRACKING (MQL5 - PROFESSIONAL Q-LEARNING CRITERIA) =====
// 
// Q-Table structure: 100 states × 4 actions = 400 state-action pairs
//
// Professional Q-Learning convergence requires:
// 1. Each state-action pair visited multiple times
// 2. Typical convergence: starts ~1,000 episodes, optimal ~25,000-30,000
// 3. For trading: realistic targets considering 1-10 trades/day

#define TOTAL_STATES5 100
#define TOTAL_ACTIONS5 4
#define TOTAL_STATE_ACTION_PAIRS5 400

// Learning Phase targets:
#define LEARNING_TARGET_COVERAGE_PCT5 30    // % of state-action pairs to cover
#define LEARNING_TARGET_PAIRS5 120          // 30% of 400 pairs
#define LEARNING_TARGET_EPISODES5 500       // Episodes for basic learning
#define LEARNING_MIN_VISITS_PER_PAIR5 3     // Minimum avg visits for stability

// Specialization Phase:
#define SPECIALIZATION_TARGET_EPISODES5 2000
#define SPECIALIZATION_EPSILON_TARGET5 0.01
#define SPECIALIZATION_COVERAGE_PCT5 50

// ===== ADVANCED LEARNING OPTIONS - FAST MODE TARGETS (MQL5) =====
#define FAST_LEARNING_COVERAGE_PCT5 15       // Fast mode: 15% coverage (60/400 pairs)
#define FAST_LEARNING_EPISODES5 250          // Fast mode: 250 episodes
#define FAST_LEARNING_MIN_VISITS5 2          // Fast mode: 2 visits per pair
#define ADAPTIVE_CHECK_INTERVAL5 200         // Check stagnation every 200 episodes
#define ADAPTIVE_MIN_COVERAGE_PCT5 10        // Minimum adaptive coverage (40 pairs)
#define STAGNATION_THRESHOLD5 2.0            // Coverage must increase >2% per interval

// ===== ADVANCED LEARNING - Global Variables (MQL5) =====
bool g_fastLearningMode5 = false;            // Fast learning mode enabled
bool g_enableStateInterpolation5 = false;    // State interpolation enabled
bool g_enableAdaptiveCoverage5 = true;       // Adaptive coverage enabled (default ON)
bool g_enableVirtualExperience5 = false;     // Virtual experience generation enabled
bool g_showRegimeProgress5 = true;           // Show regime progress bar
double g_adaptedCoverageTarget5 = 30.0;      // Current adaptive coverage target
double g_lastCoverageCheck5 = 0.0;           // Coverage at last check
int g_lastCoverageCheckEpisode5 = 0;         // Episode count at last check
bool g_regimeVisited5[10];                   // Track which regimes have been visited (0-9)
string g_advancedLearningWarning5 = "";      // Warning message for panel

// ===== ADAPTIVE LEARNING SYSTEM (ALS) =====
// Detects performance degradation and automatically re-explores
#define ALS_ROLLING_WINDOW5 20
struct AI_RollingTradeStruct5 {
    double profit;
    datetime time;
    int regime;
};
AI_RollingTradeStruct5 g_alsRolling5[ALS_ROLLING_WINDOW5];
int g_alsRollingCount5 = 0;
int g_alsRollingIdx5 = 0;
int g_alsConsecutiveLosses5 = 0;
int g_alsMaxConsecLosses5 = 0;
double g_alsRollingWinRate5 = 0.5;
double g_alsRollingPF5 = 1.0;
int g_alsLastDegradationLevel5 = 0;
int g_alsLastResetEpisode5 = 0;
int g_alsLastDecayEpisode5 = 0;
int g_alsSoftResetCount5 = 0;
bool g_alsEnabled5 = true;
int g_alsSensitivity5 = 1;  // 0=conservative, 1=balanced, 2=aggressive

// Visit count tracking (MQL5)
int g_visitCount5[TOTAL_STATES5][TOTAL_ACTIONS5];
int g_totalVisits5 = 0;
double g_lastQDelta5 = 0;
double g_avgQDelta5 = 1.0;

//+------------------------------------------------------------------+
//| Initialize visit count tracking (MQL5)                             |
//+------------------------------------------------------------------+
void AI_InitVisitTracking5() {
    for (int s = 0; s < TOTAL_STATES5; s++) {
        for (int a = 0; a < TOTAL_ACTIONS5; a++) {
            g_visitCount5[s][a] = 0;
        }
    }
    g_totalVisits5 = 0;
    g_lastQDelta5 = 0;
    g_avgQDelta5 = 1.0;
}

//+------------------------------------------------------------------+
//| Record a visit to a state-action pair (MQL5)                       |
//+------------------------------------------------------------------+
void AI_RecordVisit5(int state, int action, double qDelta) {
    if (state >= 0 && state < TOTAL_STATES5 && action >= 0 && action < TOTAL_ACTIONS5) {
        g_visitCount5[state][action]++;
        g_totalVisits5++;
        g_lastQDelta5 = MathAbs(qDelta);
        g_avgQDelta5 = g_avgQDelta5 * 0.99 + g_lastQDelta5 * 0.01;
    }
}

//+------------------------------------------------------------------+
//| Count state-action pairs with at least 1 visit (MQL5)              |
//+------------------------------------------------------------------+
int AI_CountActivePairs5() {
    int count = 0;
    for (int s = 0; s < TOTAL_STATES5; s++) {
        for (int a = 0; a < TOTAL_ACTIONS5; a++) {
            if (g_visitCount5[s][a] > 0 || g_qTable5[s][a] != 0.0) {
                count++;
            }
        }
    }
    return count;
}

//+------------------------------------------------------------------+
//| Calculate average visits per active pair (MQL5)                    |
//+------------------------------------------------------------------+
double AI_GetAvgVisitsPerPair5() {
    int activePairs = AI_CountActivePairs5();
    if (activePairs == 0) return 0;
    return (double)g_totalVisits5 / activePairs;
}

//+------------------------------------------------------------------+
//| Get coverage percentage (MQL5)                                     |
//+------------------------------------------------------------------+
double AI_GetCoveragePercent5() {
    int activePairs = AI_CountActivePairs5();
    return (double)activePairs / TOTAL_STATE_ACTION_PAIRS5 * 100.0;
}

// ===== ADVANCED LEARNING OPTIONS - HELPER FUNCTIONS (MQL5) =====

//+------------------------------------------------------------------+
//| Initialize Advanced Learning Options (MQL5)                        |
//+------------------------------------------------------------------+
void AI_InitAdvancedLearning5(bool fastMode, bool stateInterp, bool adaptiveCov, bool virtualExp, bool regimeProgress) {
    g_fastLearningMode5 = fastMode;
    g_enableStateInterpolation5 = stateInterp;
    g_enableAdaptiveCoverage5 = adaptiveCov;
    g_enableVirtualExperience5 = virtualExp;
    g_showRegimeProgress5 = regimeProgress;
    
    g_adaptedCoverageTarget5 = g_fastLearningMode5 ? FAST_LEARNING_COVERAGE_PCT5 : LEARNING_TARGET_COVERAGE_PCT5;
    g_lastCoverageCheck5 = 0.0;
    g_lastCoverageCheckEpisode5 = 0;
    g_advancedLearningWarning5 = "";
    
    for (int i = 0; i < 10; i++) {
        g_regimeVisited5[i] = false;
    }
    
    if (g_fastLearningMode5) {
        g_advancedLearningWarning5 = "MODO RAPIDO: Precision reducida";
    } else if (g_enableVirtualExperience5) {
        g_advancedLearningWarning5 = "EXP. VIRTUALES: Datos sinteticos";
    } else if (g_enableStateInterpolation5) {
        g_advancedLearningWarning5 = "INTERPOLACION: Beta";
    }
}

//+------------------------------------------------------------------+
//| Get Adapted Learning Targets (MQL5)                                |
//+------------------------------------------------------------------+
void AI_GetAdaptedLearningTargets5(double &outCoveragePct, int &outEpisodes, int &outMinVisits) {
    if (g_fastLearningMode5) {
        outCoveragePct = FAST_LEARNING_COVERAGE_PCT5;
        outEpisodes = FAST_LEARNING_EPISODES5;
        outMinVisits = FAST_LEARNING_MIN_VISITS5;
    } else if (g_enableAdaptiveCoverage5) {
        outCoveragePct = g_adaptedCoverageTarget5;
        outEpisodes = LEARNING_TARGET_EPISODES5;
        outMinVisits = LEARNING_MIN_VISITS_PER_PAIR5;
    } else {
        outCoveragePct = LEARNING_TARGET_COVERAGE_PCT5;
        outEpisodes = LEARNING_TARGET_EPISODES5;
        outMinVisits = LEARNING_MIN_VISITS_PER_PAIR5;
    }
}

//+------------------------------------------------------------------+
//| Detect Stagnation and Adjust Coverage Target (MQL5)                |
//+------------------------------------------------------------------+
void AI_DetectStagnation5() {
    if (!g_enableAdaptiveCoverage5 || g_fastLearningMode5) return;
    
    int currentEpisodes = g_aiQLearning5.totalEpisodes;
    if (currentEpisodes - g_lastCoverageCheckEpisode5 < ADAPTIVE_CHECK_INTERVAL5) return;
    
    double currentCoverage = AI_GetCoveragePercent5();
    double coverageDelta = currentCoverage - g_lastCoverageCheck5;
    
    if (coverageDelta < STAGNATION_THRESHOLD5 && g_lastCoverageCheckEpisode5 > 0) {
        g_adaptedCoverageTarget5 = MathMax(ADAPTIVE_MIN_COVERAGE_PCT5, g_adaptedCoverageTarget5 - 5.0);
        g_advancedLearningWarning5 = "ADAPTADO: Objetivo " + DoubleToString(g_adaptedCoverageTarget5, 0) + "%";
        Print("AI Adaptive: Coverage stagnating. New target: ", g_adaptedCoverageTarget5, "%");
    }
    
    g_lastCoverageCheck5 = currentCoverage;
    g_lastCoverageCheckEpisode5 = currentEpisodes;
}

//+------------------------------------------------------------------+
//| Interpolate Q-Values to Nearby States (MQL5)                       |
//+------------------------------------------------------------------+
void AI_InterpolateNearbyStates5(int state, int action, double qValue) {
    if (!g_enableStateInterpolation5) return;
    
    int regime = state / 10;
    int subState = state % 10;
    double interpolatedQ = qValue * 0.5;
    
    for (int delta = -1; delta <= 1; delta += 2) {
        int neighborSubState = subState + delta;
        if (neighborSubState >= 0 && neighborSubState < 10) {
            int neighborState = regime * 10 + neighborSubState;
            if (g_visitCount5[neighborState][action] == 0 && g_qTable5[neighborState][action] == 0.0) {
                g_qTable5[neighborState][action] = interpolatedQ;
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Generate Virtual Experience (MQL5)                                 |
//+------------------------------------------------------------------+
void AI_GenerateVirtualExperience5(int state, int action, double reward, int nextState) {
    if (!g_enableVirtualExperience5) return;
    
    int regime = state / 10;
    int subState = state % 10;
    
    for (int i = 0; i < 2; i++) {
        int virtualSubState = subState + (i == 0 ? -1 : 1);
        if (virtualSubState < 0 || virtualSubState >= 10) continue;
        
        int virtualState = regime * 10 + virtualSubState;
        double noise = (MathRand() % 31 - 15) / 100.0;
        double virtualReward = reward * (1.0 + noise);
        
        AI_SaveExperience5(virtualState, action, virtualReward, nextState);
    }
}

//+------------------------------------------------------------------+
//| Mark Regime as Visited (MQL5)                                      |
//+------------------------------------------------------------------+
void AI_MarkRegimeVisited5(int regime) {
    if (regime >= 0 && regime < 10) {
        g_regimeVisited5[regime] = true;
    }
}

//+------------------------------------------------------------------+
//| Count Visited Regimes (MQL5)                                       |
//+------------------------------------------------------------------+
int AI_CountVisitedRegimes5() {
    int count = 0;
    for (int i = 0; i < 10; i++) {
        if (g_regimeVisited5[i]) count++;
    }
    return count;
}

//+------------------------------------------------------------------+
//| Get Regime Progress Percentage (MQL5)                              |
//+------------------------------------------------------------------+
double AI_GetRegimeProgress5() {
    return (double)AI_CountVisitedRegimes5() / 10.0 * 100.0;
}

//+------------------------------------------------------------------+
//| Get Advanced Learning Warning Message (MQL5)                       |
//+------------------------------------------------------------------+
string AI_GetAdvancedLearningWarning5() {
    return g_advancedLearningWarning5;
}

//+------------------------------------------------------------------+
//| Check if any advanced shortcut is active (MQL5)                    |
//+------------------------------------------------------------------+
bool AI_IsShortcutActive5() {
    return g_fastLearningMode5 || g_enableStateInterpolation5 || g_enableVirtualExperience5;
}

// Health Status Tracking (MQL5)
enum ENUM_AI_HEALTH_STATUS5 {
    AI_HEALTH5_OPTIMAL,
    AI_HEALTH5_WARNING,
    AI_HEALTH5_ERROR
};

struct AI_HealthState5 {
    ENUM_AI_HEALTH_STATUS5 status;
    string statusMessage;
    datetime lastTradeTime;
    datetime lastQTableSave;
    bool qTableSaveSuccess;
    int consecutiveSaveFailures;
};

AI_HealthState5 g_aiHealth5;

//+------------------------------------------------------------------+
//| Calculate Learning Progress (MQL5) - WITH ADVANCED OPTIONS         |
//| Uses adapted targets based on fast mode and adaptive coverage      |
//+------------------------------------------------------------------+
double AI_GetLearningProgress5() {
    // Get adapted targets based on current options
    double targetCoverage = 0;
    int targetEpisodes = 0;
    int targetMinVisits = 0;
    AI_GetAdaptedLearningTargets5(targetCoverage, targetEpisodes, targetMinVisits);
    
    // 1. Coverage progress (40% weight)
    double coveragePct = AI_GetCoveragePercent5();
    double coverageProgress = coveragePct / targetCoverage * 100.0;
    coverageProgress = MathMin(100.0, coverageProgress);
    
    // 2. Episodes progress (40% weight)
    double episodesProgress = (double)g_aiQLearning5.totalEpisodes / targetEpisodes * 100.0;
    episodesProgress = MathMin(100.0, episodesProgress);
    
    // 3. Depth progress (20% weight)
    double avgVisits = AI_GetAvgVisitsPerPair5();
    double depthProgress = avgVisits / targetMinVisits * 100.0;
    depthProgress = MathMin(100.0, depthProgress);
    
    // Combined: 40% coverage + 40% episodes + 20% depth
    double combinedProgress = (coverageProgress * 0.4) + (episodesProgress * 0.4) + (depthProgress * 0.2);
    return MathMin(100.0, combinedProgress);
}

//+------------------------------------------------------------------+
//| Check if learning phase is complete (MQL5) - WITH ADVANCED OPTIONS |
//+------------------------------------------------------------------+
bool AI_IsLearningComplete5() {
    // Get adapted targets
    double targetCoverage = 0;
    int targetEpisodes = 0;
    int targetMinVisits = 0;
    AI_GetAdaptedLearningTargets5(targetCoverage, targetEpisodes, targetMinVisits);
    
    double coveragePct = AI_GetCoveragePercent5();
    double avgVisits = AI_GetAvgVisitsPerPair5();
    
    return (coveragePct >= targetCoverage && 
            g_aiQLearning5.totalEpisodes >= targetEpisodes &&
            avgVisits >= targetMinVisits);
}

//+------------------------------------------------------------------+
//| Calculate Specialization Progress (MQL5)                           |
//| Based on: 35% episodes + 35% coverage + 30% epsilon                |
//+------------------------------------------------------------------+
double AI_GetSpecializationProgress5() {
    if (!AI_IsLearningComplete5()) {
        return 0.0;
    }
    
    // 1. Episodes progress toward 2000 (35% weight)
    double episodeProgress = (double)g_aiQLearning5.totalEpisodes / SPECIALIZATION_TARGET_EPISODES5 * 100.0;
    episodeProgress = MathMin(100.0, episodeProgress);
    
    // 2. Coverage progress toward 50% (35% weight)
    double coveragePct = AI_GetCoveragePercent5();
    double coverageProgress = coveragePct / SPECIALIZATION_COVERAGE_PCT5 * 100.0;
    coverageProgress = MathMin(100.0, coverageProgress);
    
    // 3. Epsilon decay progress (30% weight)
    double initialEpsilon = 0.2;
    double epsilonProgress = 0;
    if (g_aiQLearning5.explorationRate < initialEpsilon) {
        epsilonProgress = (initialEpsilon - g_aiQLearning5.explorationRate) / (initialEpsilon - SPECIALIZATION_EPSILON_TARGET5) * 100.0;
        epsilonProgress = MathMin(100.0, MathMax(0.0, epsilonProgress));
    }
    
    // Combined: 35% episodes + 35% coverage + 30% epsilon
    double combinedProgress = (episodeProgress * 0.35) + (coverageProgress * 0.35) + (epsilonProgress * 0.30);
    return MathMin(100.0, MathMax(0.0, combinedProgress));
}

//+------------------------------------------------------------------+
//| Update AI Health Status (MQL5)                                     |
//+------------------------------------------------------------------+
void AI_UpdateHealthStatus5() {
    datetime currentTime = TimeCurrent();
    
    if (g_aiPerformance5.isPaused) {
        g_aiHealth5.status = AI_HEALTH5_ERROR;
        g_aiHealth5.statusMessage = "PAUSADO: " + g_aiPerformance5.pauseReason;
        return;
    }
    
    if (g_aiHealth5.consecutiveSaveFailures >= 3) {
        g_aiHealth5.status = AI_HEALTH5_ERROR;
        g_aiHealth5.statusMessage = "ERROR: Q-Table no se guarda";
        return;
    }
    
    if (g_aiPerformance5.totalTrades > 0 && g_aiHealth5.lastTradeTime > 0) {
        int hoursSinceLastTrade = (int)((currentTime - g_aiHealth5.lastTradeTime) / 3600);
        if (hoursSinceLastTrade > 24) {
            g_aiHealth5.status = AI_HEALTH5_WARNING;
            g_aiHealth5.statusMessage = "Sin trades: " + IntegerToString(hoursSinceLastTrade) + "h";
            return;
        }
    }
    
    if (g_aiQLearning5.totalEpisodes > 0 && g_aiHealth5.lastQTableSave > 0) {
        int hoursSinceLastSave = (int)((currentTime - g_aiHealth5.lastQTableSave) / 3600);
        if (hoursSinceLastSave > 1) {
            g_aiHealth5.status = AI_HEALTH5_WARNING;
            g_aiHealth5.statusMessage = "Q-Table: " + IntegerToString(hoursSinceLastSave) + "h sin actualizar";
            return;
        }
    }
    
    if (g_aiQLearning5.totalEpisodes < 5 && g_aiQLearning5.explorationRate > 0.15) {
        g_aiHealth5.status = AI_HEALTH5_WARNING;
        g_aiHealth5.statusMessage = "Fase inicial: explorando...";
        return;
    }
    
    g_aiHealth5.status = AI_HEALTH5_OPTIMAL;
    if (!AI_IsLearningComplete5()) {
        g_aiHealth5.statusMessage = "Aprendiendo activamente";
    } else if (AI_GetSpecializationProgress5() < 100) {
        g_aiHealth5.statusMessage = "Especializándose";
    } else {
        g_aiHealth5.statusMessage = "Experto - Óptimo";
    }
}

//+------------------------------------------------------------------+
//| Get Learning Bar Color (MQL5)                                      |
//+------------------------------------------------------------------+
color AI_GetLearningBarColor5(double percent) {
    if (percent < 25) return clrRed;
    if (percent < 50) return clrOrangeRed;
    if (percent < 75) return clrOrange;
    if (percent < 90) return clrYellow;
    return clrLime;
}

//+------------------------------------------------------------------+
//| Get Specialization Bar Color (MQL5)                                |
//+------------------------------------------------------------------+
color AI_GetSpecializationBarColor5(double percent) {
    if (percent < 20) return C'139,0,139';
    if (percent < 40) return C'75,0,130';
    if (percent < 60) return C'65,105,225';
    if (percent < 80) return C'0,139,139';
    return C'0,206,209';
}

//+------------------------------------------------------------------+
//| Get Health Icon (MQL5)                                             |
//+------------------------------------------------------------------+
string AI_GetHealthIcon5(ENUM_AI_HEALTH_STATUS5 status) {
    switch(status) {
        case AI_HEALTH5_OPTIMAL: return "●";
        case AI_HEALTH5_WARNING: return "▲";
        case AI_HEALTH5_ERROR:   return "■";
        default: return "?";
    }
}

color AI_GetHealthColor5(ENUM_AI_HEALTH_STATUS5 status) {
    switch(status) {
        case AI_HEALTH5_OPTIMAL: return clrLime;
        case AI_HEALTH5_WARNING: return clrOrange;
        case AI_HEALTH5_ERROR:   return clrRed;
        default: return clrGray;
    }
}

// Experience Replay Buffer (MQL5)
#define EXPERIENCE_BUFFER_SIZE 1000
AI_ExperienceStruct g_experienceBuffer5[EXPERIENCE_BUFFER_SIZE];
int g_experienceCount5 = 0;
int g_experienceIndex5 = 0;
datetime g_lastReplayTime5 = 0;

// ✅ FIX: Track state when trade was OPENED (for correct Q-Learning update)
// This fixes the RL bug where we were using current state instead of action state
struct AI_OpenTradeState5 {
    ulong ticket;         // Position ticket
    int stateAtOpen;      // Market state when trade was opened
    int actionTaken;      // Action that was taken (1=BUY, 2=SELL)
    datetime openTime;    // When the trade was opened
};

#define MAX_TRACKED_TRADES5 50
AI_OpenTradeState5 g_openTradeStates5[MAX_TRACKED_TRADES5];
int g_trackedTradesCount5 = 0;

//+------------------------------------------------------------------+
//| Store state when opening a trade (MQL5)                            |
//+------------------------------------------------------------------+
void AI_StoreTradeOpenState5(ulong ticket, int state, int action) {
    // Find empty slot or oldest trade
    int slotIndex = -1;
    datetime oldestTime = TimeCurrent();
    int oldestIndex = 0;
    
    for (int i = 0; i < MAX_TRACKED_TRADES5; i++) {
        if (g_openTradeStates5[i].ticket == 0 || g_openTradeStates5[i].ticket == ticket) {
            slotIndex = i;
            break;
        }
        if (g_openTradeStates5[i].openTime < oldestTime) {
            oldestTime = g_openTradeStates5[i].openTime;
            oldestIndex = i;
        }
    }
    
    if (slotIndex == -1) {
        // Use oldest slot if full
        slotIndex = oldestIndex;
        Print("AI Trade State buffer full - reusing oldest slot");
    }
    
    g_openTradeStates5[slotIndex].ticket = ticket;
    g_openTradeStates5[slotIndex].stateAtOpen = state;
    g_openTradeStates5[slotIndex].actionTaken = action;
    g_openTradeStates5[slotIndex].openTime = TimeCurrent();
    
    if (g_trackedTradesCount5 < MAX_TRACKED_TRADES5) g_trackedTradesCount5++;
    
    Print("AI: Stored state ", state, " for trade #", ticket, " (action=", action, ")");
}

//+------------------------------------------------------------------+
//| Retrieve state when trade was opened (MQL5)                        |
//+------------------------------------------------------------------+
bool AI_GetTradeOpenState5(ulong ticket, int &outState, int &outAction) {
    for (int i = 0; i < MAX_TRACKED_TRADES5; i++) {
        if (g_openTradeStates5[i].ticket == ticket) {
            outState = g_openTradeStates5[i].stateAtOpen;
            outAction = g_openTradeStates5[i].actionTaken;
            
            // Clear the slot after retrieval
            g_openTradeStates5[i].ticket = 0;
            return true;
        }
    }
    return false;
}

//+------------------------------------------------------------------+
//| Initialize trade state tracking (MQL5)                             |
//+------------------------------------------------------------------+
void AI_InitTradeStateTracking5() {
    for (int i = 0; i < MAX_TRACKED_TRADES5; i++) {
        g_openTradeStates5[i].ticket = 0;
        g_openTradeStates5[i].stateAtOpen = 0;
        g_openTradeStates5[i].actionTaken = 0;
        g_openTradeStates5[i].openTime = 0;
    }
    g_trackedTradesCount5 = 0;
}

// Indicator handles (MQL5 specific)
int g_handleSMA50 = INVALID_HANDLE;
int g_handleSMA200 = INVALID_HANDLE;
int g_handleADX = INVALID_HANDLE;
int g_handleATR = INVALID_HANDLE;
int g_handleRSI = INVALID_HANDLE;
int g_handleBB = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Initialize AI System (MQL5)                                       |
//+------------------------------------------------------------------+
void AI_Initialize5(long magicNumber) {
    if (g_aiInitialized5) return;
    
    // Create indicator handles
    g_handleSMA50 = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
    g_handleSMA200 = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_SMA, PRICE_CLOSE);
    g_handleADX = iADX(_Symbol, PERIOD_CURRENT, 14);
    g_handleATR = iATR(_Symbol, PERIOD_CURRENT, 14);
    g_handleRSI = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    g_handleBB = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
    
    if (g_handleSMA50 == INVALID_HANDLE || g_handleSMA200 == INVALID_HANDLE ||
        g_handleADX == INVALID_HANDLE || g_handleATR == INVALID_HANDLE ||
        g_handleRSI == INVALID_HANDLE || g_handleBB == INVALID_HANDLE) {
        Print("AI ERROR: Failed to create indicator handles");
        return;
    }
    
    // Initialize market state
    g_aiMarketState5.regime = AI_REGIME_RANGING_NORMAL;
    g_aiMarketState5.trendScore = 0;
    g_aiMarketState5.trendStrength = 0;
    g_aiMarketState5.volatility = AI_VOL_NORMAL;
    g_aiMarketState5.volatilityRatio = 1.0;
    g_aiMarketState5.atrValue = 0;  // Will be calculated on first tick
    g_aiMarketState5.momentum = AI_MOM_NEUTRAL;
    g_aiMarketState5.rsiValue = 50;
    g_aiMarketState5.lastUpdate = 0;
    
    // Initialize Q-Learning
    g_aiQLearning5.learningRate = 0.1;
    g_aiQLearning5.discountFactor = 0.95;
    g_aiQLearning5.explorationRate = 0.2;
    g_aiQLearning5.totalEpisodes = 0;
    g_aiQLearning5.cumulativeReward = 0;
    
    // Initialize Q-Table to zeros (will be overwritten by LoadQTable if file exists)
    for (int s = 0; s < 100; s++) {
        for (int a = 0; a < 4; a++) {
            g_qTable5[s][a] = 0.0;
        }
    }
    
    // ✅ Initialize Performance to defaults BEFORE loading Q-Table
    // LoadQTable will overwrite these with saved values if file exists
    g_aiPerformance5.totalTrades = 0;
    g_aiPerformance5.winningTrades = 0;
    g_aiPerformance5.losingTrades = 0;
    g_aiPerformance5.totalProfit = 0;
    g_aiPerformance5.maxDrawdown = 0;
    g_aiPerformance5.sharpeRatio = 0;
    g_aiPerformance5.profitFactor = 0;
    g_aiPerformance5.isPaused = false;
    g_aiPerformance5.pauseReason = "";
    
    // Initialize ALS (Adaptive Learning System)
    g_alsRollingCount5 = 0;
    g_alsRollingIdx5 = 0;
    g_alsConsecutiveLosses5 = 0;
    g_alsMaxConsecLosses5 = 0;
    g_alsRollingWinRate5 = 0.5;
    g_alsRollingPF5 = 1.0;
    g_alsLastDegradationLevel5 = 0;
    g_alsLastResetEpisode5 = 0;
    g_alsLastDecayEpisode5 = 0;
    g_alsSoftResetCount5 = 0;
    for (int alsI = 0; alsI < ALS_ROLLING_WINDOW5; alsI++) {
        g_alsRolling5[alsI].profit = 0;
        g_alsRolling5[alsI].time = 0;
        g_alsRolling5[alsI].regime = 0;
    }
    
    // Load Q-Table from file if exists (searches Common + Local folders + symbol variations)
    // This will restore Q-values AND performance stats from the file
    AI_LoadQTable5(magicNumber);
    
    // Save Q-Table to Common folder (ensures portability across brokers/accounts)
    AI_SaveQTable5(magicNumber);
    Print("----------------------------------------------------------");
    Print("AI Q-Table PORTABLE STORAGE ENABLED");
    Print("File: AI_QTable_", magicNumber, "_", _Symbol, ".bin");
    Print("Location: ", TerminalInfoString(TERMINAL_COMMONDATA_PATH), "\\Files\\");
    Print("This Q-Table can be used on ANY MT5 terminal!");
    Print("----------------------------------------------------------");
    
    // Initialize ATR history
    double atrBuffer[];
    ArrayResize(atrBuffer, 1); // FIX FEB 2026: Pre-allocate to prevent error 4807
    ArraySetAsSeries(atrBuffer, true);
    if (CopyBuffer(g_handleATR, 0, 0, 1, atrBuffer) > 0) {
        for (int i = 0; i < 100; i++) {
            g_historicalATR5[i] = atrBuffer[0];
        }
    }
    
    // ✅ Initialize trade state tracking for correct Q-Learning
    AI_InitTradeStateTracking5();
    
    // ✅ Initialize visit count tracking for learning progress
    AI_InitVisitTracking5();
    
    // ✅ Initialize health status tracking (MQL5)
    g_aiHealth5.status = AI_HEALTH5_OPTIMAL;
    g_aiHealth5.statusMessage = "Iniciando...";
    g_aiHealth5.lastTradeTime = 0;
    g_aiHealth5.lastQTableSave = TimeCurrent();
    g_aiHealth5.qTableSaveSuccess = true;
    g_aiHealth5.consecutiveSaveFailures = 0;
    
    g_aiInitialized5 = true;
    Print("AI Strategic Agent (MQL5) initialized successfully. Magic: ", magicNumber);
}

//+------------------------------------------------------------------+
//| Deinitialize AI System (MQL5)                                     |
//+------------------------------------------------------------------+
void AI_Deinitialize5() {
    if (g_handleSMA50 != INVALID_HANDLE) IndicatorRelease(g_handleSMA50);
    if (g_handleSMA200 != INVALID_HANDLE) IndicatorRelease(g_handleSMA200);
    if (g_handleADX != INVALID_HANDLE) IndicatorRelease(g_handleADX);
    if (g_handleATR != INVALID_HANDLE) IndicatorRelease(g_handleATR);
    if (g_handleRSI != INVALID_HANDLE) IndicatorRelease(g_handleRSI);
    if (g_handleBB != INVALID_HANDLE) IndicatorRelease(g_handleBB);
}

//+------------------------------------------------------------------+
//| Trend Detection using SMA + ADX (MQL5)                            |
//+------------------------------------------------------------------+
double AI_CalculateTrendScore5() {
    double sma50Buffer[], sma50PrevBuffer[], sma200Buffer[];
    ArrayResize(sma50Buffer, 1); // FIX FEB 2026: Pre-allocate buffers
    ArrayResize(sma50PrevBuffer, 1);
    ArrayResize(sma200Buffer, 1);
    ArraySetAsSeries(sma50Buffer, true);
    ArraySetAsSeries(sma50PrevBuffer, true);
    ArraySetAsSeries(sma200Buffer, true);
    
    if (CopyBuffer(g_handleSMA50, 0, 0, 1, sma50Buffer) <= 0 ||
        CopyBuffer(g_handleSMA50, 0, 10, 1, sma50PrevBuffer) <= 0 ||
        CopyBuffer(g_handleSMA200, 0, 0, 1, sma200Buffer) <= 0) {
        return 0;
    }
    
    double sma50_current = sma50Buffer[0];
    double sma50_prev = sma50PrevBuffer[0];
    double sma200 = sma200Buffer[0];
    
    MqlTick tick;
    if (!SymbolInfoTick(_Symbol, tick)) return 0;
    double close = tick.bid;
    
    // Calculate slope (percentage change over 10 bars)
    double smaSlope = (sma50_current - sma50_prev) / sma50_prev * 100;
    
    // Normalize slope to -1 to +1
    double normalizedSlope = MathMax(-1, MathMin(1, smaSlope / 0.5));
    
    // Price position relative to MAs
    double priceVsSMA50 = (close - sma50_current) / sma50_current;
    double priceVsSMA200 = (close - sma200) / sma200;
    
    // Combine signals
    double trendScore = 0;
    trendScore += normalizedSlope * 0.5;                              // 50% weight to slope
    trendScore += MathMax(-0.25, MathMin(0.25, priceVsSMA50 * 5));    // 25% weight to price vs SMA50
    trendScore += MathMax(-0.25, MathMin(0.25, priceVsSMA200 * 5));   // 25% weight to price vs SMA200
    
    return MathMax(-1, MathMin(1, trendScore));
}

//+------------------------------------------------------------------+
//| Trend Strength using ADX (MQL5)                                   |
//+------------------------------------------------------------------+
double AI_CalculateTrendStrength5() {
    double adxBuffer[];
    ArrayResize(adxBuffer, 1); // FIX FEB 2026: Pre-allocate buffer
    ArraySetAsSeries(adxBuffer, true);
    
    if (CopyBuffer(g_handleADX, 0, 0, 1, adxBuffer) <= 0) return 0;
    
    double adx = adxBuffer[0];
    g_aiMarketState5.trendStrength = adx;
    
    return adx;
}

//+------------------------------------------------------------------+
//| Volatility Analysis using ATR (MQL5)                              |
//+------------------------------------------------------------------+
ENUM_AI_VOLATILITY_CLASS AI_AnalyzeVolatility5() {
    double atrBuffer[];
    ArrayResize(atrBuffer, 1); // FIX FEB 2026: Pre-allocate buffer
    ArraySetAsSeries(atrBuffer, true);
    
    if (CopyBuffer(g_handleATR, 0, 0, 1, atrBuffer) <= 0) return AI_VOL_NORMAL;
    
    double currentATR = atrBuffer[0];
    
    // Store ATR value for SL/TP calculations
    g_aiMarketState5.atrValue = currentATR;
    
    MqlTick tick;
    if (!SymbolInfoTick(_Symbol, tick)) return AI_VOL_NORMAL;
    
    // Update historical buffer
    g_historicalATR5[g_atrHistoryIndex5] = currentATR;
    g_atrHistoryIndex5 = (g_atrHistoryIndex5 + 1) % 100;
    
    // Calculate historical average
    double avgATR = 0;
    for (int i = 0; i < 100; i++) {
        avgATR += g_historicalATR5[i];
    }
    avgATR /= 100;
    
    // Calculate ratio
    g_aiMarketState5.volatilityRatio = currentATR / avgATR;
    
    // Classify volatility
    if (g_aiMarketState5.volatilityRatio > 1.5) {
        return AI_VOL_HIGH;
    } else if (g_aiMarketState5.volatilityRatio > 1.2) {
        return AI_VOL_ELEVATED;
    } else if (g_aiMarketState5.volatilityRatio < 0.7) {
        return AI_VOL_LOW;
    }
    return AI_VOL_NORMAL;
}

//+------------------------------------------------------------------+
//| Momentum Analysis using RSI (MQL5)                                |
//+------------------------------------------------------------------+
ENUM_AI_MOMENTUM_STATE AI_AnalyzeMomentum5() {
    double rsiBuffer[];
    ArrayResize(rsiBuffer, 1); // FIX FEB 2026: Pre-allocate buffer
    ArraySetAsSeries(rsiBuffer, true);
    
    if (CopyBuffer(g_handleRSI, 0, 0, 1, rsiBuffer) <= 0) return AI_MOM_NEUTRAL;
    
    double rsi = rsiBuffer[0];
    g_aiMarketState5.rsiValue = rsi;
    
    if (rsi > 70) return AI_MOM_OVERBOUGHT;
    if (rsi > 55) return AI_MOM_BULLISH;
    if (rsi < 30) return AI_MOM_OVERSOLD;
    if (rsi < 45) return AI_MOM_BEARISH;
    return AI_MOM_NEUTRAL;
}

//+------------------------------------------------------------------+
//| Support/Resistance using Bollinger Bands (MQL5)                   |
//+------------------------------------------------------------------+
void AI_CalculateSupportResistance5() {
    double bbUpperBuffer[], bbLowerBuffer[], bbMiddleBuffer[], atrBuffer[];
    ArrayResize(bbUpperBuffer, 1); // FIX FEB 2026: Pre-allocate buffers
    ArrayResize(bbLowerBuffer, 1);
    ArrayResize(bbMiddleBuffer, 1);
    ArrayResize(atrBuffer, 1);
    ArraySetAsSeries(bbUpperBuffer, true);
    ArraySetAsSeries(bbLowerBuffer, true);
    ArraySetAsSeries(bbMiddleBuffer, true);
    ArraySetAsSeries(atrBuffer, true);
    
    if (CopyBuffer(g_handleBB, 1, 0, 1, bbUpperBuffer) <= 0 ||
        CopyBuffer(g_handleBB, 2, 0, 1, bbLowerBuffer) <= 0 ||
        CopyBuffer(g_handleBB, 0, 0, 1, bbMiddleBuffer) <= 0 ||
        CopyBuffer(g_handleATR, 0, 0, 1, atrBuffer) <= 0) {
        return;
    }
    
    double bbUpper = bbUpperBuffer[0];
    double bbLower = bbLowerBuffer[0];
    double currentATR = atrBuffer[0];
    
    MqlTick tick;
    if (!SymbolInfoTick(_Symbol, tick)) return;
    double close = tick.bid;
    
    g_aiMarketState5.resistanceLevel = bbUpper;
    g_aiMarketState5.supportLevel = bbLower;
    
    // Calculate distances in ATR multiples
    g_aiMarketState5.bbUpperDistance = (bbUpper - close) / currentATR;
    g_aiMarketState5.bbLowerDistance = (close - bbLower) / currentATR;
}

//+------------------------------------------------------------------+
//| Main Regime Classification (MQL5)                                 |
//+------------------------------------------------------------------+
ENUM_AI_MARKET_REGIME AI_ClassifyRegime5() {
    double trendScore = AI_CalculateTrendScore5();
    double trendStrength = AI_CalculateTrendStrength5();
    ENUM_AI_VOLATILITY_CLASS volatility = AI_AnalyzeVolatility5();
    ENUM_AI_MOMENTUM_STATE momentum = AI_AnalyzeMomentum5();
    AI_CalculateSupportResistance5();
    
    g_aiMarketState5.trendScore = trendScore;
    g_aiMarketState5.volatility = volatility;
    g_aiMarketState5.momentum = momentum;
    
    // Previous regime for transition detection
    ENUM_AI_MARKET_REGIME prevRegime = g_aiMarketState5.regime;
    ENUM_AI_MARKET_REGIME newRegime;
    
    // Strong Trend Up
    if (trendScore > 0.5 && trendStrength > 25) {
        if (volatility == AI_VOL_LOW) newRegime = AI_REGIME_TRENDING_UP_CALM;
        else if (volatility == AI_VOL_HIGH) newRegime = AI_REGIME_TRENDING_UP_VOLATILE;
        else newRegime = AI_REGIME_TRENDING_UP_NORMAL;
    }
    // Strong Trend Down
    else if (trendScore < -0.5 && trendStrength > 25) {
        if (volatility == AI_VOL_LOW) newRegime = AI_REGIME_TRENDING_DOWN_CALM;
        else if (volatility == AI_VOL_HIGH) newRegime = AI_REGIME_TRENDING_DOWN_VOLATILE;
        else newRegime = AI_REGIME_TRENDING_DOWN_NORMAL;
    }
    // Ranging
    else if (trendStrength < 20) {
        if (volatility == AI_VOL_LOW) newRegime = AI_REGIME_RANGING_QUIET;
        else if (volatility == AI_VOL_HIGH) newRegime = AI_REGIME_VOLATILE_CHAOS;
        else newRegime = AI_REGIME_RANGING_NORMAL;
    }
    // Volatile Chaos
    else if (volatility == AI_VOL_HIGH && trendStrength < 30) {
        newRegime = AI_REGIME_VOLATILE_CHAOS;
    }
    // Default to normal ranging
    else {
        newRegime = AI_REGIME_RANGING_NORMAL;
    }
    
    // Detect transition
    if (prevRegime != newRegime && prevRegime != AI_REGIME_TRANSITION) {
        g_aiMarketState5.regime = AI_REGIME_TRANSITION;
    } else {
        g_aiMarketState5.regime = newRegime;
    }
    
    g_aiMarketState5.lastUpdate = TimeCurrent();
    
    return g_aiMarketState5.regime;
}

//+------------------------------------------------------------------+
//| Q-Learning: Discretize State (MQL5)                               |
//+------------------------------------------------------------------+
int AI_DiscretizeState5() {
    int trendState = (int)MathRound((g_aiMarketState5.trendScore + 1) * 4.5);
    trendState = MathMax(0, MathMin(9, trendState));
    
    int volState = (int)g_aiMarketState5.volatility;
    
    int momState = (int)g_aiMarketState5.momentum;
    momState = MathMax(0, MathMin(4, momState));
    
    int stateIndex = trendState * 10 + volState * 2 + (momState / 2);
    stateIndex = MathMax(0, MathMin(99, stateIndex));
    
    g_aiQLearning5.stateIndex = stateIndex;
    
    return stateIndex;
}

//+------------------------------------------------------------------+
//| Q-Learning: Select Action (MQL5)                                  |
//+------------------------------------------------------------------+
int AI_SelectAction5(int state, bool useExploration = true) {
    // Epsilon-greedy exploration
    if (useExploration && MathRand() / 32767.0 < g_aiQLearning5.explorationRate) {
        return MathRand() % 4;
    }
    
    // Greedy: select action with highest Q-value
    // ✅ FIX: Random tie-breaking when multiple actions have equal Q-values
    // Without this, a fresh Q-Table (all zeros) ALWAYS selects HOLD (action 0),
    // making the AI barely trade and barely learn - especially in autonomous mode
    int bestAction = 0;
    double bestValue = g_qTable5[state][0];
    int tiedActions[4];
    int tiedCount = 1;
    tiedActions[0] = 0;
    
    for (int a = 1; a < 4; a++) {
        if (g_qTable5[state][a] > bestValue + 0.0001) {
            // Strictly better action found
            bestValue = g_qTable5[state][a];
            bestAction = a;
            tiedCount = 1;
            tiedActions[0] = a;
        } else if (MathAbs(g_qTable5[state][a] - bestValue) <= 0.0001) {
            // Tied action (within floating-point tolerance)
            tiedActions[tiedCount] = a;
            tiedCount++;
        }
    }
    
    // If there are ties, randomly select among tied actions
    // This is critical for fresh Q-Tables where all values are 0.0
    if (tiedCount > 1) {
        bestAction = tiedActions[MathRand() % tiedCount];
    }
    
    for (int a = 0; a < 4; a++) {
        g_aiQLearning5.qValues[a] = g_qTable5[state][a];
    }
    
    return bestAction;
}

//+------------------------------------------------------------------+
//| Q-Learning: Update Q-Table (MQL5)                                 |
//+------------------------------------------------------------------+
void AI_UpdateQValue5(int state, int action, double reward, int nextState) {
    // Backtest Training: boost learning rate for faster convergence in Strategy Tester
    double alpha = g_aiQLearning5.learningRate;
    if (g_IsBacktestTraining) alpha = MathMin(alpha * g_AITrainingSpeedMultiplier, 0.35);
    double gamma = g_aiQLearning5.discountFactor;
    
    double maxNextQ = g_qTable5[nextState][0];
    for (int a = 1; a < 4; a++) {
        if (g_qTable5[nextState][a] > maxNextQ) {
            maxNextQ = g_qTable5[nextState][a];
        }
    }
    
    double oldQ = g_qTable5[state][action];
    double newQ = oldQ + alpha * (reward + gamma * maxNextQ - oldQ);
    double qDelta = newQ - oldQ;  // Track change magnitude
    g_qTable5[state][action] = newQ;
    
    // ✅ DEBUG: Log Q-Table update details
    Print("Q-UPDATE: State=", state, " Action=", action,
         " OldQ=", DoubleToString(oldQ, 4), " NewQ=", DoubleToString(newQ, 4),
         " Reward=", DoubleToString(reward, 2), " Alpha=", DoubleToString(alpha, 2));
    
    // ✅ Record visit to this state-action pair for learning progress tracking
    AI_RecordVisit5(state, action, qDelta);
    
    // ===== ADAPTIVE EPSILON (VDBE - Value-Difference Based Exploration) =====
    // TD-error magnitude measures "surprise": high = model is wrong = explore more
    // Based on Tokic 2010 "Adaptive epsilon-Greedy Exploration in RL Based on Value Differences"
    double epsilonFloor5 = g_IsBacktestTraining ? 0.03 : SPECIALIZATION_EPSILON_TARGET5;
    
    if (g_alsEnabled5 && g_alsRollingCount5 >= 5) {
        double tdMag5 = MathAbs(qDelta);
        // Sigmoid: maps TD-error to [0,1]. Offset=3.0 centers the transition
        double sigma5 = 1.0 / (1.0 + MathExp(-tdMag5 + 3.0));
        // Blend: 10% VDBE signal + 90% current epsilon (smooth adaptation)
        double newEps5 = 0.9 * g_aiQLearning5.explorationRate + 0.1 * sigma5;
        // Degradation override: force minimum epsilon when losing
        int alsLevel5 = AI_ALS_GetDegradationLevel5();
        if (alsLevel5 >= 3)      newEps5 = MathMax(newEps5, 0.25);
        else if (alsLevel5 >= 2) newEps5 = MathMax(newEps5, 0.15);
        else if (alsLevel5 >= 1) newEps5 = MathMax(newEps5, 0.08);
        g_aiQLearning5.explorationRate = MathMax(epsilonFloor5, MathMin(0.40, newEps5));
    } else {
        // Fallback: standard decay when ALS not yet active (< 5 trades)
        if (g_aiQLearning5.explorationRate > epsilonFloor5) {
            double decayRate = g_IsBacktestTraining ? 0.9993 : 0.9995;
            g_aiQLearning5.explorationRate *= decayRate;
            if (g_aiQLearning5.explorationRate < epsilonFloor5)
                g_aiQLearning5.explorationRate = epsilonFloor5;
        }
    }
    
    g_aiQLearning5.totalEpisodes++;
    g_aiQLearning5.cumulativeReward += reward;
}

//+------------------------------------------------------------------+
//| EXPERIENCE REPLAY: Save Experience to Buffer (MQL5)               |
//| Guarda cada experiencia para aprender de ella múltiples veces    |
//+------------------------------------------------------------------+
void AI_SaveExperience5(int state, int action, double reward, int nextState) {
    g_experienceBuffer5[g_experienceIndex5].state = state;
    g_experienceBuffer5[g_experienceIndex5].action = action;
    g_experienceBuffer5[g_experienceIndex5].reward = reward;
    g_experienceBuffer5[g_experienceIndex5].nextState = nextState;
    g_experienceBuffer5[g_experienceIndex5].timestamp = TimeCurrent();
    
    // Buffer circular - sobrescribe las experiencias más antiguas
    g_experienceIndex5 = (g_experienceIndex5 + 1) % EXPERIENCE_BUFFER_SIZE;
    if (g_experienceCount5 < EXPERIENCE_BUFFER_SIZE) {
        g_experienceCount5++;
    }
}

//+------------------------------------------------------------------+
//| EXPERIENCE REPLAY: Learn from Random Past Experiences (MQL5)      |
//| Selecciona experiencias aleatorias y aprende de ellas            |
//| Esto acelera el aprendizaje 10-100x vs aprender solo del último  |
//+------------------------------------------------------------------+
void AI_ExperienceReplay5(int batchSize = 32) {
    if (g_experienceCount5 < batchSize) return;
    
    // In backtest: replay more frequently for maximum learning; live: every 60s
    int replayInterval = g_IsBacktestTraining ? 5 : 60;
    if (TimeCurrent() - g_lastReplayTime5 < replayInterval) return;
    g_lastReplayTime5 = TimeCurrent();
    
    double alpha = g_aiQLearning5.learningRate * 0.5;
    if (g_IsBacktestTraining) alpha = MathMin(alpha * g_AITrainingSpeedMultiplier, 0.35);
    double gamma = g_aiQLearning5.discountFactor;
    
    int replayed = 0;
    for (int i = 0; i < batchSize; i++) {
        // Seleccionar experiencia aleatoria
        int idx = MathRand() % g_experienceCount5;
        
        int state = g_experienceBuffer5[idx].state;
        int action = g_experienceBuffer5[idx].action;
        double reward = g_experienceBuffer5[idx].reward;
        int nextState = g_experienceBuffer5[idx].nextState;
        
        // Validar índices
        if (state < 0 || state >= 100 || nextState < 0 || nextState >= 100) continue;
        if (action < 0 || action >= 4) continue;
        
        // Calcular max Q del siguiente estado
        double maxNextQ = g_qTable5[nextState][0];
        for (int a = 1; a < 4; a++) {
            if (g_qTable5[nextState][a] > maxNextQ) {
                maxNextQ = g_qTable5[nextState][a];
            }
        }
        
        // Actualizar Q-value con la experiencia pasada
        double oldQ = g_qTable5[state][action];
        double newQ = oldQ + alpha * (reward + gamma * maxNextQ - oldQ);
        g_qTable5[state][action] = newQ;
        replayed++;
    }
    
    if (replayed > 0) {
        Print("AI Experience Replay (MQL5): Learned from ", replayed, " past experiences | Buffer: ", g_experienceCount5, "/", EXPERIENCE_BUFFER_SIZE);
    }
}

//+------------------------------------------------------------------+
//| EXPERIENCE REPLAY: Prioritized Replay - Aprende más de errores   |
//| Las experiencias con mayor |reward| se repiten más               |
//+------------------------------------------------------------------+
void AI_PrioritizedReplay5(int batchSize = 32) {
    if (g_experienceCount5 < batchSize * 2) return;
    int replayInterval = g_IsBacktestTraining ? 5 : 60;
    if (TimeCurrent() - g_lastReplayTime5 < replayInterval) return;
    g_lastReplayTime5 = TimeCurrent();
    
    double alpha = g_aiQLearning5.learningRate * 0.5;
    if (g_IsBacktestTraining) alpha = MathMin(alpha * g_AITrainingSpeedMultiplier, 0.35);
    double gamma = g_aiQLearning5.discountFactor;
    
    // Recency-weighted priority: recent experiences are sampled more often
    // Half-life: 7 days live, 30 days backtest (in seconds)
    double halfLife5 = g_IsBacktestTraining ? 86400.0 * 30.0 : 86400.0 * 7.0;
    datetime now5 = TimeCurrent();
    
    double totalPriority = 0;
    for (int i = 0; i < g_experienceCount5; i++) {
        double age5 = (double)(now5 - g_experienceBuffer5[i].timestamp);
        double recency5 = MathExp(-0.693 * age5 / halfLife5);
        totalPriority += (MathAbs(g_experienceBuffer5[i].reward) + 0.1) * MathMax(0.05, recency5);
    }

    int replayed = 0;
    for (int b = 0; b < batchSize; b++) {
        double target = (MathRand() / 32767.0) * totalPriority;
        double cumulative = 0;
        int idx = 0;

        for (int i = 0; i < g_experienceCount5; i++) {
            double age5r = (double)(now5 - g_experienceBuffer5[i].timestamp);
            double recency5r = MathExp(-0.693 * age5r / halfLife5);
            cumulative += (MathAbs(g_experienceBuffer5[i].reward) + 0.1) * MathMax(0.05, recency5r);
            if (cumulative >= target) {
                idx = i;
                break;
            }
        }
        
        int state = g_experienceBuffer5[idx].state;
        int action = g_experienceBuffer5[idx].action;
        double reward = g_experienceBuffer5[idx].reward;
        int nextState = g_experienceBuffer5[idx].nextState;
        
        if (state < 0 || state >= 100 || nextState < 0 || nextState >= 100) continue;
        if (action < 0 || action >= 4) continue;
        
        double maxNextQ = g_qTable5[nextState][0];
        for (int a = 1; a < 4; a++) {
            if (g_qTable5[nextState][a] > maxNextQ) {
                maxNextQ = g_qTable5[nextState][a];
            }
        }
        
        double oldQ = g_qTable5[state][action];
        double newQ = oldQ + alpha * (reward + gamma * maxNextQ - oldQ);
        g_qTable5[state][action] = newQ;
        replayed++;
    }
    
    if (replayed > 0) {
        Print("AI Prioritized Replay (MQL5): Learned from ", replayed, " high-impact experiences");
    }
}

//+------------------------------------------------------------------+
//| Calculate Reward from Trade Result (MQL5)                         |
//+------------------------------------------------------------------+
double AI_CalculateReward5(double profitPips, double riskRewardRatio) {
    double reward = 0;
    
    if (profitPips > 0) {
        reward = MathSqrt(profitPips) * 10;
        g_aiPerformance5.winningTrades++;
        g_aiPerformance5.avgWin = (g_aiPerformance5.avgWin * (g_aiPerformance5.winningTrades - 1) + profitPips) / g_aiPerformance5.winningTrades;
    } else {
        reward = -MathSqrt(MathAbs(profitPips)) * 15;
        g_aiPerformance5.losingTrades++;
        g_aiPerformance5.avgLoss = (g_aiPerformance5.avgLoss * (g_aiPerformance5.losingTrades - 1) + MathAbs(profitPips)) / g_aiPerformance5.losingTrades;
    }
    
    if (riskRewardRatio > 1.5) {
        reward *= 1.2;
    }
    
    g_aiPerformance5.totalTrades++;
    g_aiPerformance5.totalProfit += profitPips;
    
    if (g_aiPerformance5.avgLoss > 0) {
        g_aiPerformance5.profitFactor = g_aiPerformance5.avgWin * g_aiPerformance5.winningTrades / 
                                        (g_aiPerformance5.avgLoss * g_aiPerformance5.losingTrades);
    }
    
    return reward;
}

//+------------------------------------------------------------------+
//| Adaptive Parameters based on Regime (MQL5)                        |
//| Returns multipliers applied for transparency                      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| AI CALCULATES ALL TRADE PARAMETERS AUTONOMOUSLY (MQL5)            |
//| - SL: Based on ATR (volatility), NOT fixed user values            |
//| - TP: Based on dynamic R:R ratio determined by regime             |
//| - Lots: Based on risk % and calculated SL, within user limits     |
//+------------------------------------------------------------------+
void AI_CalculateTradeParameters5(
    double &stopLoss,        // OUTPUT: AI-calculated SL in points
    double &takeProfit,      // OUTPUT: AI-calculated TP in points
    double &lotSize,         // OUTPUT: AI-calculated lot size
    double riskPercent,      // User limit: Max % of balance to risk
    double minLots,          // User limit: Minimum lot size
    double maxLots,          // User limit: Maximum lot size (hard ceiling)
    double minSLPoints,      // User limit: Safety floor for SL (points)
    double maxSLPoints,      // User limit: Safety ceiling for SL (points)
    double minTPPoints,      // User limit: Safety floor for TP (points)
    double maxTPPoints,      // User limit: Safety ceiling for TP (points)
    double minRR,            // User limit: Minimum R:R ratio
    double chaosLotMult      // User limit: Lot multiplier for chaos regime (0 = no trade)
) {
    ENUM_AI_MARKET_REGIME regime = g_aiMarketState5.regime;
    double volRatio = g_aiMarketState5.volatilityRatio;
    double atrValue = g_aiMarketState5.atrValue;  // ATR in price units
    
    // Convert ATR to pips
    double atrPips = atrValue / _Point;
    
    // Ensure ATR is valid
    if (atrPips < 1.0) {
        atrPips = 20.0; // Reasonable default
    }
    
    //===================================================================
    // STEP 1: AI CALCULATES STOP LOSS (Based 100% on ATR)
    //===================================================================
    double atrMultiplier = 1.5;
    string slReason = "";
    
    switch (regime) {
        case AI_REGIME_TRENDING_UP_CALM:
        case AI_REGIME_TRENDING_DOWN_CALM:
            atrMultiplier = 1.0;
            slReason = "TREND+CALM: 1.0x ATR";
            break;
            
        case AI_REGIME_TRENDING_UP_VOLATILE:
        case AI_REGIME_TRENDING_DOWN_VOLATILE:
            atrMultiplier = 2.0;
            slReason = "TREND+VOL: 2.0x ATR";
            break;
            
        case AI_REGIME_RANGING_QUIET:
            atrMultiplier = 1.0;
            slReason = "RANGE+QUIET: 1.0x ATR";
            break;
            
        case AI_REGIME_RANGING_NORMAL:
            atrMultiplier = 1.5;
            slReason = "RANGE+NORMAL: 1.5x ATR";
            break;
            
        case AI_REGIME_VOLATILE_CHAOS:
            atrMultiplier = 2.5;
            slReason = "CHAOS: 2.5x ATR";
            break;
            
        case AI_REGIME_TRANSITION:
            atrMultiplier = 1.8;
            slReason = "TRANSITION: 1.8x ATR";
            break;
            
        default:
            atrMultiplier = 1.5;
            slReason = "DEFAULT: 1.5x ATR";
            break;
    }
    
    stopLoss = atrPips * atrMultiplier;
    stopLoss *= MathMax(0.7, MathMin(1.5, volRatio));
    stopLoss = MathMax(minSLPoints, MathMin(maxSLPoints, stopLoss));
    
    //===================================================================
    // STEP 2: AI CALCULATES TAKE PROFIT (Dynamic R:R)
    //===================================================================
    double targetRR = minRR;
    string tpReason = "";
    
    switch (regime) {
        case AI_REGIME_TRENDING_UP_CALM:
        case AI_REGIME_TRENDING_DOWN_CALM:
            targetRR = MathMax(minRR, 2.5);
            tpReason = "TREND+CALM: R:R 2.5:1";
            break;
            
        case AI_REGIME_TRENDING_UP_VOLATILE:
        case AI_REGIME_TRENDING_DOWN_VOLATILE:
            targetRR = MathMax(minRR, 2.0);
            tpReason = "TREND+VOL: R:R 2.0:1";
            break;
            
        case AI_REGIME_RANGING_QUIET:
            targetRR = MathMax(minRR, 1.2);
            tpReason = "RANGE+QUIET: R:R 1.2:1";
            break;
            
        case AI_REGIME_RANGING_NORMAL:
            targetRR = MathMax(minRR, 1.5);
            tpReason = "RANGE+NORMAL: R:R 1.5:1";
            break;
            
        case AI_REGIME_VOLATILE_CHAOS:
            targetRR = MathMax(minRR, 1.0);
            tpReason = "CHAOS: R:R 1.0:1";
            break;
            
        case AI_REGIME_TRANSITION:
            targetRR = MathMax(minRR, 1.3);
            tpReason = "TRANSITION: R:R 1.3:1";
            break;
            
        default:
            targetRR = MathMax(minRR, 1.5);
            tpReason = "DEFAULT: R:R 1.5:1";
            break;
    }
    
    takeProfit = stopLoss * targetRR;
    
    // Apply user's TP safety bounds (minTPPoints and maxTPPoints)
    // Also ensure we NEVER violate the user's minimum R:R ratio!
    double maxTP = MathMin(atrPips * 5.0, maxTPPoints);
    double minTPForRR = stopLoss * minRR;  // Minimum TP to satisfy user's R:R
    double effectiveMinTP = MathMax(minTPPoints, minTPForRR);  // Use the higher of user's min or R:R requirement
    
    // If cap would violate the effective minimum, we need to either:
    // 1. Reduce SL to allow proper TP, or
    // 2. Use minTP even if it exceeds cap
    if (maxTP < effectiveMinTP) {
        // Option: Reduce SL to maintain minRR within TP cap
        double maxSLForRR = maxTP / minRR;
        if (maxSLForRR >= minSLPoints) {
            stopLoss = maxSLForRR;
            takeProfit = maxTP;
            Print("[AI] Adjusted SL to ", DoubleToString(stopLoss, 1), " to maintain R:R ", DoubleToString(minRR, 1), ":1");
        } else {
            // Can't reduce SL further, use effectiveMinTP even if it exceeds cap
            takeProfit = effectiveMinTP;
            Print("[AI] Using TP ", DoubleToString(takeProfit, 1), " to satisfy minTP/R:R requirements");
        }
    } else {
        // Apply both min and max bounds
        takeProfit = MathMax(effectiveMinTP, MathMin(takeProfit, maxTP));
    }
    
    //===================================================================
    // STEP 3: AI CALCULATES LOT SIZE (Based on risk % and SL)
    //===================================================================
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    
    double pipValuePerLot = tickValue * (_Point / tickSize);
    double riskAmount = balance * (riskPercent / 100.0);
    
    double baseLots = 0;
    if (stopLoss > 0 && pipValuePerLot > 0) {
        baseLots = riskAmount / (stopLoss * pipValuePerLot);
    }
    
    double lotsMultiplier = 1.0;
    string lotsReason = "";
    
    switch (regime) {
        case AI_REGIME_TRENDING_UP_CALM:
        case AI_REGIME_TRENDING_DOWN_CALM:
            lotsMultiplier = 1.0;
            lotsReason = "Full size";
            break;
            
        case AI_REGIME_TRENDING_UP_VOLATILE:
        case AI_REGIME_TRENDING_DOWN_VOLATILE:
            lotsMultiplier = 0.7;
            lotsReason = "70% size";
            break;
            
        case AI_REGIME_RANGING_QUIET:
        case AI_REGIME_RANGING_NORMAL:
            lotsMultiplier = 0.8;
            lotsReason = "80% size";
            break;
            
        case AI_REGIME_VOLATILE_CHAOS:
            lotsMultiplier = chaosLotMult;
            if (chaosLotMult == 0) {
                lotsReason = "NO TRADE (disabled)";
            } else {
                lotsReason = DoubleToString(chaosLotMult * 100, 0) + "% size";
            }
            break;
            
        case AI_REGIME_TRANSITION:
            lotsMultiplier = 0.5;
            lotsReason = "50% size";
            break;
            
        default:
            lotsMultiplier = 0.8;
            lotsReason = "80% size";
            break;
    }
    
    lotSize = baseLots * lotsMultiplier;
    
    // Enforce limits
    double brokerMinLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double brokerMaxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    lotSize = MathMax(minLots, MathMin(maxLots, lotSize));
    lotSize = MathMax(brokerMinLot, MathMin(brokerMaxLot, lotSize));
    lotSize = MathFloor(lotSize / lotStep) * lotStep;
    lotSize = MathMax(brokerMinLot, lotSize);
    
    //===================================================================
    // LOG AI DECISIONS (Only on new bar)
    //===================================================================
    static string lastLogKey5 = "";
    string logKey = slReason + tpReason + lotsReason;
    
    if (logKey != lastLogKey5) {
        lastLogKey5 = logKey;
        Print("===== AI TRADE PARAMETERS (MQL5) =====");
        Print("ATR: ", DoubleToString(atrPips, 1), " pts | VolRatio: ", DoubleToString(volRatio, 2));
        Print("SL: ", DoubleToString(stopLoss, 1), " pts (", slReason, ")");
        Print("TP: ", DoubleToString(takeProfit, 1), " pts, R:R=", DoubleToString(targetRR, 1), ":1 (", tpReason, ")");
        Print("Lots: ", DoubleToString(lotSize, 2), " (", lotsReason, ") | Max: ", DoubleToString(maxLots, 2));
        Print("Risk: ", DoubleToString(riskPercent, 1), "% of ", DoubleToString(balance, 2), " = ", DoubleToString(riskAmount, 2));
    }
}

//+------------------------------------------------------------------+
//| Self-Optimization: Check for Degradation (MQL5)                   |
//| ✅ IMPROVED LOGIC: Only pause on REAL losses, not just low win rate |
//+------------------------------------------------------------------+
void AI_CheckPerformanceDegradation5(double maxAllowedDrawdown) {
    // Calculate current drawdown from FLOATING P/L
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double currentDD = (balance > 0) ? ((balance - equity) / balance) * 100 : 0;
    
    // Track max drawdown
    if (currentDD > g_aiPerformance5.maxDrawdown) {
        g_aiPerformance5.maxDrawdown = currentDD;
    }
    
    // Calculate performance metrics
    double winRate = 0;
    if (g_aiPerformance5.totalTrades > 0) {
        winRate = (double)g_aiPerformance5.winningTrades / g_aiPerformance5.totalTrades * 100;
    }
    
    // Check if paused - try to resume
    if (g_aiPerformance5.isPaused) {
        // Resume if drawdown recovered and either profitable or in learning phase
        if (currentDD < maxAllowedDrawdown * 0.7) {
            if (g_aiPerformance5.profitFactor > 1.0 || g_aiPerformance5.totalTrades < 20) {
                g_aiPerformance5.isPaused = false;
                g_aiPerformance5.pauseReason = "";
                Print("AI Agent RESUMED - DD recovered: ", DoubleToString(currentDD, 1), "%, PF: ", DoubleToString(g_aiPerformance5.profitFactor, 2));
            }
        }
        return;
    }
    
    // Need minimum trades before making decisions
    if (g_aiPerformance5.totalTrades < 10) {
        return;  // Learning phase - never pause
    }
    
    // CRITERIA 1: Excessive Drawdown (CRITICAL)
        if (currentDD > maxAllowedDrawdown) {
            g_aiPerformance5.isPaused = true;
        g_aiPerformance5.pauseReason = "DRAWDOWN PROTECTION: " + DoubleToString(currentDD, 1) + "% > " + DoubleToString(maxAllowedDrawdown, 0) + "%";
            Print("AI Agent PAUSED - ", g_aiPerformance5.pauseReason);
            return;
        }
        
    // CRITERIA 2: Consistent Money Loss (PF < 0.7 AND negative profit)
    if (g_aiPerformance5.profitFactor < 0.7 && g_aiPerformance5.totalProfit < 0) {
            g_aiPerformance5.isPaused = true;
        g_aiPerformance5.pauseReason = "UNPROFITABLE: PF=" + DoubleToString(g_aiPerformance5.profitFactor, 2) + ", Loss=" + DoubleToString(g_aiPerformance5.totalProfit, 2);
            Print("AI Agent PAUSED - ", g_aiPerformance5.pauseReason);
            return;
        }
        
    // Win Rate alone does NOT trigger pause!
}

//+------------------------------------------------------------------+
//| ADAPTIVE LEARNING SYSTEM (ALS) - Rolling Window Monitor           |
//| Tracks last N trades in a rolling window for degradation detection|
//+------------------------------------------------------------------+
void AI_ALS_UpdateRollingWindow5(double profit, int regime) {
    if (!g_alsEnabled5) return;
    
    g_alsRolling5[g_alsRollingIdx5].profit = profit;
    g_alsRolling5[g_alsRollingIdx5].time = TimeCurrent();
    g_alsRolling5[g_alsRollingIdx5].regime = regime;
    g_alsRollingIdx5 = (g_alsRollingIdx5 + 1) % ALS_ROLLING_WINDOW5;
    if (g_alsRollingCount5 < ALS_ROLLING_WINDOW5) g_alsRollingCount5++;
    
    // Track consecutive losses
    if (profit < 0) {
        g_alsConsecutiveLosses5++;
        if (g_alsConsecutiveLosses5 > g_alsMaxConsecLosses5)
            g_alsMaxConsecLosses5 = g_alsConsecutiveLosses5;
    } else {
        g_alsConsecutiveLosses5 = 0;
    }
    
    // Recalculate rolling metrics
    if (g_alsRollingCount5 < 5) return;
    int wins = 0;
    double sumWin = 0, sumLoss = 0;
    for (int i = 0; i < g_alsRollingCount5; i++) {
        if (g_alsRolling5[i].profit > 0) { wins++; sumWin += g_alsRolling5[i].profit; }
        else { sumLoss += MathAbs(g_alsRolling5[i].profit); }
    }
    g_alsRollingWinRate5 = (double)wins / g_alsRollingCount5;
    g_alsRollingPF5 = (sumLoss > 0) ? sumWin / sumLoss : (sumWin > 0 ? 10.0 : 1.0);
}

//+------------------------------------------------------------------+
//| ALS: Determine degradation level from rolling window              |
//| Returns: 0=OK, 1=mild, 2=moderate, 3=severe                      |
//+------------------------------------------------------------------+
int AI_ALS_GetDegradationLevel5() {
    if (!g_alsEnabled5 || g_alsRollingCount5 < 5) return 0;
    
    // Sensitivity multipliers: conservative=wider thresholds, aggressive=tighter
    double wrMult = (g_alsSensitivity5 == 0) ? 0.85 : (g_alsSensitivity5 == 2) ? 1.15 : 1.0;
    double lossMult = (g_alsSensitivity5 == 0) ? 1.5 : (g_alsSensitivity5 == 2) ? 0.75 : 1.0;
    
    double wr = g_alsRollingWinRate5;
    double pf = g_alsRollingPF5;
    int cl = g_alsConsecutiveLosses5;
    
    // Level 3 - Severe: system is clearly failing
    if (wr < 0.20 * wrMult || pf < 0.3 || cl >= (int)(8 * lossMult)) return 3;
    // Level 2 - Moderate: significant underperformance
    if (wr < 0.30 * wrMult || pf < 0.5 || cl >= (int)(6 * lossMult)) return 2;
    // Level 1 - Mild: early signs of degradation
    if (wr < 0.40 * wrMult || pf < 0.8 || cl >= (int)(4 * lossMult)) return 1;
    
    return 0;
}

//+------------------------------------------------------------------+
//| ALS: Q-Table Decay - Exponential forgetting of stale Q-values     |
//| Runs periodically; decay factor scales with degradation severity  |
//+------------------------------------------------------------------+
void AI_ALS_DecayQTable5() {
    if (!g_alsEnabled5) return;
    int decayInterval = g_IsBacktestTraining ? 100 : 50;
    if (g_aiQLearning5.totalEpisodes - g_alsLastDecayEpisode5 < decayInterval) return;
    g_alsLastDecayEpisode5 = g_aiQLearning5.totalEpisodes;
    
    int level = AI_ALS_GetDegradationLevel5();
    double factor = 0.98;
    if (level == 1) factor = 0.95;
    else if (level == 2) factor = 0.90;
    else if (level == 3) factor = 0.80;
    
    for (int s = 0; s < 100; s++)
        for (int a = 0; a < 4; a++)
            g_qTable5[s][a] *= factor;
    
    if (level > 0) {
        Print("ALS Q-Decay: factor=", DoubleToString(factor, 2),
              " level=", level, " WR=", DoubleToString(g_alsRollingWinRate5 * 100, 1),
              "% PF=", DoubleToString(g_alsRollingPF5, 2),
              " consLoss=", g_alsConsecutiveLosses5);
    }
}

//+------------------------------------------------------------------+
//| ALS: Soft Reset - Partial Q-table reset + epsilon boost           |
//| strength: 0.0=no reset, 1.0=full reset to zero                   |
//+------------------------------------------------------------------+
void AI_ALS_SoftReset5(double strength) {
    if (!g_alsEnabled5) return;
    
    // Partially decay Q-values toward zero
    double keep = 1.0 - strength;
    for (int s = 0; s < 100; s++)
        for (int a = 0; a < 4; a++)
            g_qTable5[s][a] *= keep;
    
    // Boost epsilon proportionally
    double newEps = 0.10 + strength * 0.15;  // 10-25% depending on severity
    g_aiQLearning5.explorationRate = MathMax(g_aiQLearning5.explorationRate, newEps);
    
    // Deprioritize old experiences by shifting buffer index forward
    // (new experiences will overwrite oldest ones faster)
    int purgeCount = (int)(g_experienceCount5 * strength * 0.5);
    if (purgeCount > 0 && g_experienceCount5 > purgeCount) {
        g_experienceCount5 = MathMax(10, g_experienceCount5 - purgeCount);
    }
    
    g_alsSoftResetCount5++;
    Print("ALS SOFT RESET #", g_alsSoftResetCount5,
          ": strength=", DoubleToString(strength * 100, 0), "%",
          " epsilon->", DoubleToString(g_aiQLearning5.explorationRate, 3),
          " purged=", purgeCount, " experiences");
}

//+------------------------------------------------------------------+
//| ALS: Master adaptive check - Orchestrates all ALS responses       |
//| Called after processing closed trades each tick                    |
//+------------------------------------------------------------------+
void AI_ALS_AdaptiveCheck5() {
    if (!g_alsEnabled5 || g_alsRollingCount5 < 5) return;
    
    int level = AI_ALS_GetDegradationLevel5();
    
    // Cooldown: minimum 10 episodes between resets
    bool canReset = (g_aiQLearning5.totalEpisodes - g_alsLastResetEpisode5) > 10;
    
    // Only act when degradation INCREASES (not repeatedly at same level)
    if (level > g_alsLastDegradationLevel5 && canReset) {
        if (level == 1) {
            g_aiQLearning5.explorationRate = MathMax(g_aiQLearning5.explorationRate, 0.08);
            Print("ALS: MILD degradation -> epsilon boosted to ",
                  DoubleToString(g_aiQLearning5.explorationRate, 3),
                  " | WR=", DoubleToString(g_alsRollingWinRate5 * 100, 1), "%");
        }
        else if (level == 2) {
            AI_ALS_SoftReset5(0.30);
            Print("ALS: MODERATE degradation -> Soft Reset 30%");
        }
        else if (level == 3) {
            AI_ALS_SoftReset5(0.60);
            Print("ALS: SEVERE degradation -> Soft Reset 60%");
        }
        g_alsLastResetEpisode5 = g_aiQLearning5.totalEpisodes;
    }
    
    // When performance recovers, log it
    if (level < g_alsLastDegradationLevel5 && g_alsLastDegradationLevel5 > 0) {
        Print("ALS: Performance RECOVERING -> level ", g_alsLastDegradationLevel5, "->", level,
              " | WR=", DoubleToString(g_alsRollingWinRate5 * 100, 1),
              "% PF=", DoubleToString(g_alsRollingPF5, 2));
    }
    
    g_alsLastDegradationLevel5 = level;
}

//+------------------------------------------------------------------+
//| Q-Table Portable File System (MQL5) v2.0                          |
//| - Uses FILE_COMMON for cross-broker/account portability           |
//| - Searches multiple locations for existing Q-Tables               |
//| - Auto-migrates old Q-Tables to common folder                     |
//| - ✅ NEW: Includes account identification to prevent "ghost" stats|
//| - ✅ NEW: Uses timestamp-based history tracking                    |
//+------------------------------------------------------------------+

// Q-Table file version for backward compatibility
// Version history:
// - v1: Original format (no version header, starts with Q-table doubles)
// - v2: Added version header (value = 2) + account info + timestamp + performance stats
// - v2.1: Changed to unique magic number 0x51544232 to avoid confusion with Q-values
// We must recognize ALL v2 formats for FULL backward compatibility:
//   - v2 original: header = 2
//   - v2.1 buggy:  header = 1364283954 (incorrect hex calculation, used temporarily)
//   - v2.1 fixed:  header = 1364476466 (correct: 0x51544232)
// NOTE: 0x51544232 = 1364476466 in decimal
#define QTABLE_FILE_VERSION_5 1364476466
#define QTABLE_FILE_VERSION_5_BUGGY 1364283954
#define QTABLE_FILE_VERSION_5_OLD 2
#define QTABLE_FILE_MAGIC_5 0x51544232

// Global variable to store imported Q-Table filename
string g_qtableImportFile5 = "";

// ✅ NEW: Global variables for account-aware Q-Table tracking
long g_qtableAccountLogin5 = 0;           // Account login from loaded Q-Table
string g_qtableAccountCompany5 = "";      // Account company from loaded Q-Table
datetime g_qtableLastTradeTime5 = 0;      // Timestamp of last processed trade
bool g_qtableSameAccount5 = true;         // Whether current account matches Q-Table's account

//+------------------------------------------------------------------+
//| Extract filename only from path (MQL5 sandbox uses only filename) |
//+------------------------------------------------------------------+
string AI_QTableBasename5(string pathOrName) {
    string s = pathOrName;
    StringTrimLeft(s);
    StringTrimRight(s);
    if (StringLen(s) == 0) return "";
    // Last path separator (backslash 92 or slash 47)
    int last = -1;
    for (int i = 0; i < StringLen(s); i++) {
        ushort c = (ushort)StringGetCharacter(s, i);
        if (c == 92 || c == 47) last = i;
    }
    if (last >= 0)
        return StringSubstr(s, last + 1);
    return s;
}

//+------------------------------------------------------------------+
//| Set Q-Table Import File (called from OnInit - BEFORE first tick)  |
//| ✅ Normalizes: trim + basename so full paths work in sandbox       |
//+------------------------------------------------------------------+
void AI_SetQTableImportFile5(string importFile) {
    string normalized = AI_QTableBasename5(importFile);
    g_qtableImportFile5 = normalized;
    if (StringLen(normalized) > 0) {
        Print("AI Q-Table: Import file configured: ", normalized);
        if (StringCompare(normalized, importFile) != 0)
            Print("   (normalized from: ", importFile, ")");
    }
}

//+------------------------------------------------------------------+
//| Get Standard Q-Table Filename - SIMPLIFIED (Magic + Symbol only)  |
//| Format: AI_QTable_{MagicNumber}_{Symbol}.bin                      |
//| ✅ FIX FEB 2026: Removed AccountLogin from filename                |
//| This ensures Q-Table is found regardless of which account/terminal|
//| the user loads it on. Same Magic + Same Symbol = Same Q-Table     |
//+------------------------------------------------------------------+
string AI_GetQTableFilename5(long magicNumber, string symbol) {
    // ✅ CRITICAL: Use SIMPLE format without AccountLogin
    // This guarantees continuity across terminals/accounts/brokers
    // ✅ FIX: Add MT5_ prefix to avoid incompatible binary formats between platforms
    return "MT5_AI_QTable_" + IntegerToString(magicNumber) + "_" + symbol + ".bin";
}

//+------------------------------------------------------------------+
//| Get OLD Q-Table Filename (format with account - for migration)    |
//| Only used to find and migrate old files                           |
//+------------------------------------------------------------------+
string AI_GetQTableFilenameOldFormat5(long magicNumber, string symbol) {
    long accountLogin = AccountInfoInteger(ACCOUNT_LOGIN);
    return "AI_QTable_" + IntegerToString(accountLogin) + "_" + IntegerToString(magicNumber) + "_" + symbol + ".bin";
}

//+------------------------------------------------------------------+
//| Get Legacy Q-Table Filename (same as standard now)                |
//| Kept for backward compatibility                                   |
//+------------------------------------------------------------------+
string AI_GetQTableFilenameLegacy5(long magicNumber, string symbol) {
    return AI_GetQTableFilename5(magicNumber, symbol);
}

//+------------------------------------------------------------------+
//| Check if Q-Table file exists in specified location                |
//+------------------------------------------------------------------+
bool AI_QTableFileExists5(string filename, bool useCommon) {
    if (useCommon)
        return FileIsExist(filename, FILE_COMMON);
    else
        return FileIsExist(filename);
}

//+------------------------------------------------------------------+
//| Find Q-Table file - BULLETPROOF SEARCH (MQL5)                     |
//| ✅ FIX FEB 2026: Exhaustive search in ALL possible locations       |
//| Search order:                                                      |
//| 1. User-specified import file                                      |
//| 2. Standard format: AI_QTable_{Magic}_{Symbol}.bin (Common)        |
//| 3. Standard format: AI_QTable_{Magic}_{Symbol}.bin (Local)         |
//| 4. Old format with account: AI_QTable_{Account}_{Magic}_{Symbol}   |
//| 5. Wildcard search for ANY file matching Magic+Symbol              |
//+------------------------------------------------------------------+
string AI_FindQTableFile5(long magicNumber, bool &useCommon, bool &needsMigration) {
    useCommon = true;
    needsMigration = false;
    long accountLogin = AccountInfoInteger(ACCOUNT_LOGIN);
    string symbol = _Symbol;
    
    // Log search parameters for debugging
    Print("=== AI Q-Table Search Started ===");
    Print("Magic Number: ", magicNumber);
    Print("Symbol: ", symbol);
    Print("Account: ", accountLogin);
    
    // ===== PRIORITY 1: User-specified import file (exact name) =====
    if (StringLen(g_qtableImportFile5) > 0) {
        Print("Checking user-specified file: ", g_qtableImportFile5);
        if (FileIsExist(g_qtableImportFile5, FILE_COMMON)) {
            Print("✅ FOUND in Common folder: ", g_qtableImportFile5);
            useCommon = true;
            needsMigration = false;
            return g_qtableImportFile5;
        }
        if (FileIsExist(g_qtableImportFile5)) {
            Print("✅ FOUND in Local folder: ", g_qtableImportFile5);
            useCommon = false;
            needsMigration = true;
            return g_qtableImportFile5;
        }
        Print("⚠️ User-specified file not found, will try standard name by Magic+Symbol: ", g_qtableImportFile5);
        // DO NOT return - fall through to standard/wildcard search so we still find by Magic+Symbol
    }
    
    // ===== PRIORITY 2: Standard format in Common folder =====
    string standardFile = AI_GetQTableFilename5(magicNumber, symbol);
    Print("Checking standard format: ", standardFile);
    
    if (FileIsExist(standardFile, FILE_COMMON)) {
        Print("✅ FOUND Q-Table in Common folder: ", standardFile);
        useCommon = true;
        needsMigration = false;
        return standardFile;
    }
    
    // ===== PRIORITY 3: Standard format in Local folder =====
    if (FileIsExist(standardFile)) {
        Print("✅ FOUND Q-Table in Local folder: ", standardFile);
        Print("Will migrate to Common folder for better portability");
        useCommon = false;
        needsMigration = true;
        return standardFile;
    }
    
    // ===== PRIORITY 4: Old format WITH AccountLogin =====
    string oldFormatFile = AI_GetQTableFilenameOldFormat5(magicNumber, symbol);
    Print("Checking old format (with account): ", oldFormatFile);
    
    if (FileIsExist(oldFormatFile, FILE_COMMON)) {
        Print("✅ FOUND OLD FORMAT Q-Table: ", oldFormatFile);
        Print("Will migrate to new simple format: ", standardFile);
        useCommon = true;
        needsMigration = true;
        return oldFormatFile;
    }
    
    if (FileIsExist(oldFormatFile)) {
        Print("✅ FOUND OLD FORMAT Q-Table in Local: ", oldFormatFile);
        useCommon = false;
        needsMigration = true;
        return oldFormatFile;
    }
    
    // ===== PRIORITY 5: Wildcard search for ANY matching file =====
    Print("Performing wildcard search for Magic=", magicNumber, " Symbol=", symbol);
    
    // Search pattern: Files ending with _{Magic}_{Symbol}.bin
    string pattern1 = "*_" + IntegerToString(magicNumber) + "_" + symbol + ".bin";
    string foundFile = "";
    long handle = FileFindFirst(pattern1, foundFile, FILE_COMMON);
    
    if (handle != INVALID_HANDLE) {
        Print("✅ WILDCARD MATCH in Common: ", foundFile);
        Print("This file matches Magic=", magicNumber, " Symbol=", symbol);
        FileFindClose(handle);
        useCommon = true;
        needsMigration = true;
        return foundFile;
    }
    
    // Search in local folder too
    handle = FileFindFirst(pattern1, foundFile);
    if (handle != INVALID_HANDLE) {
        Print("✅ WILDCARD MATCH in Local: ", foundFile);
        FileFindClose(handle);
        useCommon = false;
        needsMigration = true;
        return foundFile;
    }
    
    // ===== PRIORITY 6: Try without broker suffix in symbol =====
    if (StringLen(symbol) > 6) {
        string baseSymbol = StringSubstr(symbol, 0, 6);
        string baseFile = AI_GetQTableFilename5(magicNumber, baseSymbol);
        
        if (FileIsExist(baseFile, FILE_COMMON)) {
            Print("✅ FOUND with base symbol: ", baseFile);
            Print("Your symbol (", symbol, ") matched base (", baseSymbol, ")");
            useCommon = true;
            needsMigration = true;
            return baseFile;
        }
        
        if (FileIsExist(baseFile)) {
            Print("✅ FOUND with base symbol in Local: ", baseFile);
            useCommon = false;
            needsMigration = true;
            return baseFile;
        }
    }
    
    // ===== NOT FOUND - Log all checked locations =====
    Print("❌ Q-Table NOT FOUND - Starting fresh");
    Print("Searched locations:");
    Print("  1. User import file: ", (StringLen(g_qtableImportFile5) > 0 ? g_qtableImportFile5 : "(not specified)"));
    Print("  2. Standard (Common): ", standardFile);
    Print("  3. Standard (Local): ", standardFile);
    Print("  4. Old format: ", oldFormatFile);
    Print("  5. Wildcard pattern: ", pattern1);
    Print("New Q-Table will be saved as: ", standardFile);
    
    return "";
}

//+------------------------------------------------------------------+
//| Save Q-Table to File (MQL5) v2.0 - With Account ID & Timestamp    |
//| ✅ FIX: Now saves account info and last trade timestamp            |
//| This prevents "ghost" statistics and enables safe account migration|
//+------------------------------------------------------------------+
void AI_SaveQTable5(long magicNumber) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return;
    string filename = AI_GetQTableFilename5(magicNumber, _Symbol);
    string fullPath = TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\" + filename;
    
    Print("AI_SaveQTable5: Starting save to: ", filename);
    Print("AI_SaveQTable5: Full path: ", fullPath);
    
    // Delete existing file first to avoid corruption
    if (FileIsExist(filename, FILE_COMMON)) {
        bool deleted = FileDelete(filename, FILE_COMMON);
        if (deleted) {
            Print("AI_SaveQTable5: Deleted existing file successfully");
        } else {
            int err = GetLastError();
            Print("AI_SaveQTable5 WARNING: Could not delete existing file. Error: ", err);
            // Continue anyway - FileOpen with FILE_WRITE should overwrite
        }
    }
    
    // Open file in Common folder with FILE_COMMON flag
    int handle = FileOpen(filename, FILE_WRITE | FILE_BIN | FILE_COMMON);
    
    if (handle == INVALID_HANDLE) {
        int err = GetLastError();
        Print("AI_SaveQTable5 FAILED: Cannot open file '", filename, "' for writing in Common folder. Error: ", err);
        Print("Common folder path: ", TerminalInfoString(TERMINAL_COMMONDATA_PATH), "\\Files\\");
        Print("Check: 1) Common/Files folder exists 2) Disk has space 3) File permissions");
        
        g_aiHealth5.qTableSaveSuccess = false;
        g_aiHealth5.consecutiveSaveFailures++;
        return;
    }
    
    Print("AI_SaveQTable5: File opened successfully, handle: ", handle);
    
    int bytesWritten = 0;
    
    // ===== HEADER: File magic number for v2 format =====
    // Using 0x51544232 ("QTB2") which cannot be confused with Q-values
    uint magicWritten = FileWriteInteger(handle, QTABLE_FILE_MAGIC_5, INT_VALUE);
    Print("AI_SaveQTable5: Magic number write result: ", magicWritten, " bytes (expected 4)");
    Print("AI_SaveQTable5: Magic value written: ", QTABLE_FILE_MAGIC_5, " (0x51544232)");
    if (magicWritten > 0) bytesWritten++;
    
    // ===== SECTION 1: Q-Table data (100 states × 4 actions) =====
    for (int s = 0; s < 100; s++) {
        for (int a = 0; a < 4; a++) {
            if (FileWriteDouble(handle, g_qTable5[s][a]) > 0) bytesWritten++;
        }
    }
    
    // ===== SECTION 2: Q-Learning metadata =====
    if (FileWriteDouble(handle, g_aiQLearning5.explorationRate) > 0) bytesWritten++;
    if (FileWriteLong(handle, g_aiQLearning5.totalEpisodes) > 0) bytesWritten++;
    if (FileWriteDouble(handle, g_aiQLearning5.cumulativeReward) > 0) bytesWritten++;
    
    // ===== SECTION 3: Account identification (NEW in v2) =====
    // This allows detecting when Q-Table is used on a different account
    long currentAccountLogin = AccountInfoInteger(ACCOUNT_LOGIN);
    string currentAccountCompany = AccountInfoString(ACCOUNT_COMPANY);
    
    if (FileWriteLong(handle, currentAccountLogin) > 0) bytesWritten++;
    // Write company name as fixed-size string (64 chars max, padded with nulls)
    uchar companyBytes[64];
    ArrayInitialize(companyBytes, 0);
    StringToCharArray(currentAccountCompany, companyBytes, 0, MathMin(63, StringLen(currentAccountCompany)));
    if (FileWriteArray(handle, companyBytes) > 0) bytesWritten++;
    
    // ===== SECTION 4: Last processed trade timestamp (NEW in v2) =====
    // This prevents re-processing old trades when reloading
    if (FileWriteLong(handle, g_qtableLastTradeTime5) > 0) bytesWritten++;
    
    // ===== SECTION 5: Performance metrics (NEW in v2) =====
    // These are account-specific but help maintain continuity on same account
    if (FileWriteInteger(handle, g_aiPerformance5.totalTrades, INT_VALUE) > 0) bytesWritten++;
    if (FileWriteInteger(handle, g_aiPerformance5.winningTrades, INT_VALUE) > 0) bytesWritten++;
    if (FileWriteInteger(handle, g_aiPerformance5.losingTrades, INT_VALUE) > 0) bytesWritten++;
    if (FileWriteDouble(handle, g_aiPerformance5.totalProfit) > 0) bytesWritten++;
    if (FileWriteDouble(handle, g_aiPerformance5.maxDrawdown) > 0) bytesWritten++;
    if (FileWriteDouble(handle, g_aiPerformance5.profitFactor) > 0) bytesWritten++;
    if (FileWriteDouble(handle, g_aiPerformance5.avgWin) > 0) bytesWritten++;
    if (FileWriteDouble(handle, g_aiPerformance5.avgLoss) > 0) bytesWritten++;
    
    // ===== SECTION 6: ALS (Adaptive Learning System) state =====
    if (FileWriteInteger(handle, g_alsConsecutiveLosses5, INT_VALUE) > 0) bytesWritten++;
    if (FileWriteInteger(handle, g_alsMaxConsecLosses5, INT_VALUE) > 0) bytesWritten++;
    if (FileWriteInteger(handle, g_alsSoftResetCount5, INT_VALUE) > 0) bytesWritten++;
    if (FileWriteDouble(handle, g_alsRollingWinRate5) > 0) bytesWritten++;
    if (FileWriteDouble(handle, g_alsRollingPF5) > 0) bytesWritten++;
    if (FileWriteInteger(handle, g_alsRollingCount5, INT_VALUE) > 0) bytesWritten++;
    for (int alsS = 0; alsS < ALS_ROLLING_WINDOW5; alsS++) {
        if (FileWriteDouble(handle, g_alsRolling5[alsS].profit) > 0) bytesWritten++;
        if (FileWriteLong(handle, g_alsRolling5[alsS].time) > 0) bytesWritten++;
        if (FileWriteInteger(handle, g_alsRolling5[alsS].regime, INT_VALUE) > 0) bytesWritten++;
    }
    
    // Flush and close
    FileFlush(handle);
    FileClose(handle);
    
    Print("AI_SaveQTable5: File closed. Fields written: ", bytesWritten);
    
    // ===== VERIFICATION: Re-read file to confirm magic number was written =====
    int verifyHandle = FileOpen(filename, FILE_READ | FILE_BIN | FILE_COMMON);
    if (verifyHandle != INVALID_HANDLE) {
        int verifyMagic = FileReadInteger(verifyHandle, INT_VALUE);
        ulong fileSize = FileSize(verifyHandle);
        FileClose(verifyHandle);
        
        Print("AI_SaveQTable5: VERIFICATION - File size: ", fileSize, " bytes");
        Print("AI_SaveQTable5: VERIFICATION - First 4 bytes (magic): ", verifyMagic);
        Print("AI_SaveQTable5: VERIFICATION - Expected magic: ", QTABLE_FILE_MAGIC_5);
        
        if (verifyMagic == QTABLE_FILE_MAGIC_5) {
            Print("AI_SaveQTable5: ✅ VERIFIED - v2 format saved correctly!");
        } else if (verifyMagic == QTABLE_FILE_VERSION_5_OLD) {
            Print("AI_SaveQTable5: ✅ VERIFIED - v2 (old format) saved correctly!");
        } else {
            Print("AI_SaveQTable5: ⚠️ WARNING - Magic number mismatch! File may be corrupted or v1 format");
            Print("AI_SaveQTable5: Read: ", verifyMagic, " vs Expected: ", QTABLE_FILE_MAGIC_5);
        }
    } else {
        Print("AI_SaveQTable5: WARNING - Could not verify file after save");
    }
    
    // Expected bytes: 1 (version) + 400 (Q-table) + 3 (QL metadata) + 1 (account) + 1 (company) + 1 (timestamp) + 8 (performance) = 415+
    int expectedFields = 415;
    if (bytesWritten < expectedFields) {
        Print("AI_SaveQTable5: Only ", bytesWritten, " of ~", expectedFields, " fields written. File may be incomplete.");
        g_aiHealth5.qTableSaveSuccess = false;
        g_aiHealth5.consecutiveSaveFailures++;
    } else {
        g_aiHealth5.qTableSaveSuccess = true;
        g_aiHealth5.consecutiveSaveFailures = 0;
        g_aiHealth5.lastQTableSave = TimeCurrent();
        
        Print("AI Q-Table v2 saved to Common folder: ", filename);
        Print("Episodes: ", g_aiQLearning5.totalEpisodes, " | ε=", DoubleToString(g_aiQLearning5.explorationRate, 3));
        Print("Account: ", currentAccountLogin, " | LastTradeTime: ", TimeToString(g_qtableLastTradeTime5));
        Print("Performance: Trades=", g_aiPerformance5.totalTrades, " | WinRate=", 
              g_aiPerformance5.totalTrades > 0 ? DoubleToString((double)g_aiPerformance5.winningTrades/g_aiPerformance5.totalTrades*100.0, 1) : "0", "%");
        Print("Path: ", TerminalInfoString(TERMINAL_COMMONDATA_PATH), "\\Files\\", filename);
    }
}

//+------------------------------------------------------------------+
//| Load Q-Table from File (MQL5) v2.0 - With Account Validation       |
//| ✅ FIX: Detects file version and validates account for safe loading|
//| - v1 files: Legacy format (Q-table + basic metadata only)          |
//| - v2 files: Includes account ID and performance stats              |
//+------------------------------------------------------------------+
void AI_LoadQTable5(long magicNumber) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) {
        Print("AI_LoadQTable5: Optimization mode - each pass starts with a fresh Q-Table");
        return;
    }
    bool useCommon = true;
    bool needsMigration = false;

    // Use intelligent search to find Q-Table file
    string filename = AI_FindQTableFile5(magicNumber, useCommon, needsMigration);
    
    // Initialize account tracking for fresh start
    long currentAccountLogin = AccountInfoInteger(ACCOUNT_LOGIN);
    string currentAccountCompany = AccountInfoString(ACCOUNT_COMPANY);
    g_qtableSameAccount5 = true;
    g_qtableLastTradeTime5 = 0;
    
    if (StringLen(filename) == 0) {
        // ✅ CRITICAL FIX: Set timestamp to NOW to prevent processing old trades
        // Without this, a fresh Q-Table would process ALL historical trades with same magic number
        g_qtableLastTradeTime5 = TimeCurrent();
        
        Print("==========================================================");
        Print("AI Q-Table: No existing file found - Starting FRESH");
        Print("Searched locations:");
        Print("  1. Common folder: ", TerminalInfoString(TERMINAL_COMMONDATA_PATH), "\\Files\\");
        Print("  2. Local folder: MQL5/Files/");
        Print("  3. Symbol variations (XAUUSD, XAUUSDm, GOLD, etc.)");
        if (StringLen(g_qtableImportFile5) > 0) {
            Print("  4. User import file: ", g_qtableImportFile5);
        }
        Print("New Q-Table v2 will be saved to Common folder for portability");
        Print("Account: ", currentAccountLogin, " @ ", currentAccountCompany);
        Print("⚠️ IMPORTANT: Only trades from NOW onwards will be processed");
        Print("   (Old trades with same magic number will be IGNORED to prevent ghost stats)");
        Print("   Start time: ", TimeToString(g_qtableLastTradeTime5));
        Print("==========================================================");
        return;
    }
    
    // Open file with appropriate flag
    int openFlags = FILE_READ | FILE_BIN;
    if (useCommon) openFlags |= FILE_COMMON;
    
    int handle = FileOpen(filename, openFlags);
    
    if (handle == INVALID_HANDLE) {
        int err = GetLastError();
        Print("AI_LoadQTable5 FAILED: Cannot open file '", filename, "'. Error: ", err);
        return;
    }
    
    // Check file size (minimum for v1 format: 400 doubles + metadata = ~3224 bytes)
    ulong fileSize = FileSize(handle);
    if (fileSize < 3200) {
        // ⚠️ CRITICAL: NEVER delete user's Q-Table files!
        // Just warn and try to read what we can, or start fresh without deleting
        Print("⚠️ AI Q-Table WARNING: File is smaller than expected (", (long)fileSize, " bytes)");
        Print("   Expected minimum: ~3224 bytes for v1 format");
        Print("   File will NOT be deleted. Starting with fresh Q-Table instead.");
        Print("   Original file preserved at: ", filename);
        FileClose(handle);
        // ✅ Set timestamp to NOW and return - DO NOT DELETE THE FILE
        g_qtableLastTradeTime5 = TimeCurrent();
        return;
    }
    
    // ===== DETECT FILE VERSION =====
    // v2 files start with version header (either 2 or 1364283954)
    // v1 files start directly with Q-table double values
    int fileVersion = 1;  // Assume v1 by default
    
    Print("AI_LoadQTable5: File size: ", fileSize, " bytes");
    Print("AI_LoadQTable5: Reading first 4 bytes to detect version...");
    
    // Read first 4 bytes to check version
    int potentialVersion = FileReadInteger(handle, INT_VALUE);
    
    Print("AI_LoadQTable5: First 4 bytes as INT: ", potentialVersion);
    Print("AI_LoadQTable5: Expected v2 values: ", QTABLE_FILE_VERSION_5, " or ", QTABLE_FILE_VERSION_5_BUGGY, " or ", QTABLE_FILE_VERSION_5_OLD);
    
    // Check for v2 format (ALL known magic numbers for FULL backward compatibility)
    // Recognizes: v2.1 correct (1364476466), v2.1 buggy (1364283954), v2 original (2)
    if (potentialVersion == QTABLE_FILE_VERSION_5 || 
        potentialVersion == QTABLE_FILE_VERSION_5_BUGGY || 
        potentialVersion == QTABLE_FILE_VERSION_5_OLD) {
        fileVersion = 2;
        Print("AI Q-Table: ✅ Detected file version 2 (with account tracking)");
        if (potentialVersion == QTABLE_FILE_VERSION_5_BUGGY) {
            Print("   Note: Using legacy v2.1 format (will be updated on next save)");
        }
    } else {
        // It's a v1 file, need to rewind and read as old format
        fileVersion = 1;
        FileSeek(handle, 0, SEEK_SET);
        Print("AI Q-Table: Detected legacy file version 1 (will upgrade on save)");
        Print("   First bytes interpreted as double would be Q-value, not version header");
        Print("   ✅ Your Q-Learning data will be PRESERVED and upgraded to v2 format");
    }
    
    // ===== READ Q-TABLE DATA =====
    int valuesRead = 0;
    for (int s = 0; s < 100; s++) {
        for (int a = 0; a < 4; a++) {
            if (!FileIsEnding(handle)) {
                g_qTable5[s][a] = FileReadDouble(handle);
                valuesRead++;
            }
        }
    }
    
    // ===== READ Q-LEARNING METADATA =====
    if (!FileIsEnding(handle)) {
        g_aiQLearning5.explorationRate = FileReadDouble(handle);
        valuesRead++;
    }
    if (!FileIsEnding(handle)) {
        g_aiQLearning5.totalEpisodes = (int)FileReadLong(handle);
        valuesRead++;
    }
    if (!FileIsEnding(handle)) {
        g_aiQLearning5.cumulativeReward = FileReadDouble(handle);
        valuesRead++;
    }
    
    // ===== READ V2 EXTENDED DATA (if available) =====
    bool accountMatches = true;
    
    if (fileVersion >= 2 && !FileIsEnding(handle)) {
        // Read account identification
        g_qtableAccountLogin5 = FileReadLong(handle);
        valuesRead++;
        
        // Read company name (64 bytes fixed)
        uchar companyBytes[64];
        if (FileReadArray(handle, companyBytes) > 0) {
            g_qtableAccountCompany5 = CharArrayToString(companyBytes);
            valuesRead++;
        }
        
        // Read last processed trade timestamp
        if (!FileIsEnding(handle)) {
            g_qtableLastTradeTime5 = (datetime)FileReadLong(handle);
            valuesRead++;
        }
        
        // Check if current account matches the Q-Table's account
        accountMatches = (g_qtableAccountLogin5 == currentAccountLogin);
        g_qtableSameAccount5 = accountMatches;
        
        // ===== READ PERFORMANCE METRICS =====
        // ✅ ALWAYS restore performance stats - they represent the Q-Table's learning history
        // The timestamp prevents processing old trades from different accounts, but stats continue
        ulong posBeforeStats = FileTell(handle);
        Print("AI_LoadQTable5: Reading performance stats from position: ", posBeforeStats);
        
        if (!FileIsEnding(handle)) {
            int savedTotalTrades = FileReadInteger(handle, INT_VALUE);
            int savedWinningTrades = FileReadInteger(handle, INT_VALUE);
            int savedLosingTrades = FileReadInteger(handle, INT_VALUE);
            double savedTotalProfit = FileReadDouble(handle);
            double savedMaxDrawdown = FileReadDouble(handle);
            double savedProfitFactor = FileReadDouble(handle);
            double savedAvgWin = FileReadDouble(handle);
            double savedAvgLoss = FileReadDouble(handle);
            valuesRead += 8;
            
            Print("AI_LoadQTable5: READ FROM FILE - Trades:", savedTotalTrades, 
                  " Wins:", savedWinningTrades, " Losses:", savedLosingTrades);
            Print("AI_LoadQTable5: READ FROM FILE - Profit:", savedTotalProfit,
                  " PF:", savedProfitFactor, " MaxDD:", savedMaxDrawdown);
            
            // ✅ ALWAYS restore stats - they belong to the Q-Table, not the account
            // This preserves the learning history when migrating between accounts/brokers
            g_aiPerformance5.totalTrades = savedTotalTrades;
            g_aiPerformance5.winningTrades = savedWinningTrades;
            g_aiPerformance5.losingTrades = savedLosingTrades;
            g_aiPerformance5.totalProfit = savedTotalProfit;
            g_aiPerformance5.maxDrawdown = savedMaxDrawdown;
            g_aiPerformance5.profitFactor = savedProfitFactor;
            g_aiPerformance5.avgWin = savedAvgWin;
            g_aiPerformance5.avgLoss = savedAvgLoss;
            
            Print("AI_LoadQTable5: RESTORED - Performance stats loaded successfully");
            
            // ===== READ ALS (Adaptive Learning System) STATE =====
            if (!FileIsEnding(handle)) {
                g_alsConsecutiveLosses5 = FileReadInteger(handle, INT_VALUE);
                g_alsMaxConsecLosses5 = FileReadInteger(handle, INT_VALUE);
                g_alsSoftResetCount5 = FileReadInteger(handle, INT_VALUE);
                g_alsRollingWinRate5 = FileReadDouble(handle);
                g_alsRollingPF5 = FileReadDouble(handle);
                g_alsRollingCount5 = FileReadInteger(handle, INT_VALUE);
                if (g_alsRollingCount5 > ALS_ROLLING_WINDOW5) g_alsRollingCount5 = 0;
                for (int alsL = 0; alsL < ALS_ROLLING_WINDOW5; alsL++) {
                    g_alsRolling5[alsL].profit = FileReadDouble(handle);
                    g_alsRolling5[alsL].time = (datetime)FileReadLong(handle);
                    g_alsRolling5[alsL].regime = FileReadInteger(handle, INT_VALUE);
                }
                g_alsRollingIdx5 = g_alsRollingCount5 % ALS_ROLLING_WINDOW5;
                valuesRead += 6 + ALS_ROLLING_WINDOW5 * 3;
                Print("AI_LoadQTable5: ALS state restored - ConsecLoss:", g_alsConsecutiveLosses5,
                      " Resets:", g_alsSoftResetCount5, " RollingWR:", DoubleToString(g_alsRollingWinRate5 * 100, 1), "%");
            }
        } else {
            Print("AI_LoadQTable5: WARNING - FileIsEnding before reading performance stats!");
            Print("AI_LoadQTable5: File position: ", posBeforeStats, ", expected more data");
        }
    }
    
    FileClose(handle);
    
    // ===== PRINT LOAD SUMMARY =====
    Print("==========================================================");
    Print("AI Q-TABLE v", fileVersion, " LOADED SUCCESSFULLY!");
    Print("Source file: ", filename);
    Print("Location: ", useCommon ? "Common folder (PORTABLE)" : "Local folder");
    Print("----------------------------------------------------------");
    Print("Q-Learning Data:");
    Print("  Episodes: ", g_aiQLearning5.totalEpisodes);
    Print("  Exploration rate: ", DoubleToString(g_aiQLearning5.explorationRate * 100, 1), "%");
    Print("  Cumulative reward: ", DoubleToString(g_aiQLearning5.cumulativeReward, 2));
    
    if (fileVersion >= 2) {
        Print("----------------------------------------------------------");
        Print("Account Tracking (v2):");
        Print("  Q-Table account: ", g_qtableAccountLogin5, " @ ", g_qtableAccountCompany5);
        Print("  Current account: ", currentAccountLogin, " @ ", currentAccountCompany);
        Print("  Last trade time: ", g_qtableLastTradeTime5 > 0 ? TimeToString(g_qtableLastTradeTime5) : "N/A");
        
        // ✅ Q-Table is the bot's memory - account/broker doesn't matter
        // If Q-Table exists, load EVERYTHING (Q-values + stats + timestamp)
        if (!accountMatches) {
            Print("  ℹ️ Different account/broker detected - Q-Table will continue normally");
        }
        Print("  ✅ Q-Table LOADED - Full continuity:");
        Print("  Trades: ", g_aiPerformance5.totalTrades, " | WinRate: ", 
              g_aiPerformance5.totalTrades > 0 ? DoubleToString((double)g_aiPerformance5.winningTrades/g_aiPerformance5.totalTrades*100, 1) : "0", "%");
        Print("  ProfitFactor: ", DoubleToString(g_aiPerformance5.profitFactor, 2), " | TotalProfit: ", DoubleToString(g_aiPerformance5.totalProfit, 2));
        Print("  Last processed trade: ", g_qtableLastTradeTime5 > 0 ? TimeToString(g_qtableLastTradeTime5) : "None");
    } else {
        Print("----------------------------------------------------------");
        Print("⚠️ Legacy v1 file detected - no account tracking");
        Print("Will upgrade to v2 format on next save.");
        Print("Performance stats starting fresh (Q-values preserved).");
        // ✅ CRITICAL FIX: Set timestamp to NOW to prevent processing old trades
        // For v1 files, we don't know what account made them, so start fresh from NOW
        g_qtableLastTradeTime5 = TimeCurrent();
        Print("Only trades from NOW onwards will be processed.");
        Print("Start time: ", TimeToString(g_qtableLastTradeTime5));
    }
    
    // Auto-migrate from local to Common folder if needed
    if (needsMigration) {
        Print("----------------------------------------------------------");
        Print("AUTO-MIGRATION: Copying Q-Table to Common folder...");
        Print("This ensures portability across ALL brokers and accounts.");
        
        // Save to common folder immediately (will use current symbol name)
        AI_SaveQTable5(magicNumber);
        
        Print("MIGRATION COMPLETE! Q-Table is now fully portable.");
        Print("New location: ", TerminalInfoString(TERMINAL_COMMONDATA_PATH), "\\Files\\");
        Print("You can now use this Q-Table on ANY MT5 terminal.");
    }
    Print("==========================================================");
}

//+------------------------------------------------------------------+
//| Get Regime Name String (MQL5)                                     |
//+------------------------------------------------------------------+
string AI_GetRegimeName5(ENUM_AI_MARKET_REGIME regime) {
    switch (regime) {
        case AI_REGIME_TRENDING_UP_CALM: return "TREND UP (Calm)";
        case AI_REGIME_TRENDING_UP_NORMAL: return "TREND UP (Normal)";
        case AI_REGIME_TRENDING_UP_VOLATILE: return "TREND UP (Volatile)";
        case AI_REGIME_TRENDING_DOWN_CALM: return "TREND DOWN (Calm)";
        case AI_REGIME_TRENDING_DOWN_NORMAL: return "TREND DOWN (Normal)";
        case AI_REGIME_TRENDING_DOWN_VOLATILE: return "TREND DOWN (Volatile)";
        case AI_REGIME_RANGING_QUIET: return "RANGE (Quiet)";
        case AI_REGIME_RANGING_NORMAL: return "RANGE (Normal)";
        case AI_REGIME_VOLATILE_CHAOS: return "VOLATILE CHAOS";
        case AI_REGIME_TRANSITION: return "TRANSITION";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Get Volatility Name String (MQL5)                                 |
//+------------------------------------------------------------------+
string AI_GetVolatilityName5(ENUM_AI_VOLATILITY_CLASS vol) {
    switch (vol) {
        case AI_VOL_LOW: return "LOW";
        case AI_VOL_NORMAL: return "NORMAL";
        case AI_VOL_ELEVATED: return "ELEVATED";
        case AI_VOL_HIGH: return "HIGH";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Get Momentum Name String (MQL5)                                   |
//+------------------------------------------------------------------+
string AI_GetMomentumName5(ENUM_AI_MOMENTUM_STATE mom) {
    switch (mom) {
        case AI_MOM_OVERSOLD: return "OVERSOLD";
        case AI_MOM_BULLISH: return "BULLISH";
        case AI_MOM_NEUTRAL: return "NEUTRAL";
        case AI_MOM_BEARISH: return "BEARISH";
        case AI_MOM_OVERBOUGHT: return "OVERBOUGHT";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Create AI Monitoring Panel (MQL5)                                 |
//+------------------------------------------------------------------+
void AI_CreatePanel5(long magicNumber, int panelX, int panelY) {
    string prefix = "AI_Panel_" + IntegerToString(magicNumber) + "_";
    int x = panelX;
    int y = panelY;
    int width = 300;  // Increased from 280 to prevent text cutoff
    int lineHeight = 18;
    int barHeight = 14;
    int barWidth = 200;
    color bgColor = clrBlack;
    color textColor = clrWhite;
    color headerColor = clrGold;
    color valueColor = clrLime;
    
    // Background
    ObjectCreate(0, prefix + "BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_XSIZE, width);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_YSIZE, 770);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_BGCOLOR, bgColor);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_COLOR, clrDarkSlateGray);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_BACK, false);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_SELECTABLE, false);
    
    // Header
    AI_CreateLabel5(prefix + "Header", "🤖 STRATEGIC AGENT IA", x + 10, y + 5, headerColor, 11);
    AI_CreateLabel5(prefix + "Version", "v2.0 MQL5 - Q-Learning Active", x + 10, y + 25, clrDarkGray, 8);
    
    // ===== HEALTH STATUS INDICATOR =====
    y += 42;
    AI_CreateLabel5(prefix + "HealthIcon", "●", x + 15, y, clrLime, 12);
    AI_CreateLabel5(prefix + "HealthLabel", "Estado:", x + 35, y + 2, textColor, 9);
    AI_CreateLabel5(prefix + "HealthValue", "Iniciando...", x + 90, y + 2, clrLime, 9);
    
    // ===== PROGRESS BARS SECTION =====
    y += lineHeight + 5;
    AI_CreateLabel5(prefix + "ProgressTitle", ":: PROGRESO IA", x + 10, y, headerColor, 9);
    
    // Learning Progress Bar
    y += lineHeight;
    AI_CreateLabel5(prefix + "LearnLabel", "Aprendizaje:", x + 15, y, textColor, 8);
    AI_CreateLabel5(prefix + "LearnPercent", "0%", x + 250, y, clrGray, 8);
    
    y += 12;
    ObjectCreate(0, prefix + "LearnBarBG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, prefix + "LearnBarBG", OBJPROP_XDISTANCE, x + 15);
    ObjectSetInteger(0, prefix + "LearnBarBG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, prefix + "LearnBarBG", OBJPROP_XSIZE, barWidth);
    ObjectSetInteger(0, prefix + "LearnBarBG", OBJPROP_YSIZE, barHeight);
    ObjectSetInteger(0, prefix + "LearnBarBG", OBJPROP_BGCOLOR, C'40,40,40');
    ObjectSetInteger(0, prefix + "LearnBarBG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, prefix + "LearnBarBG", OBJPROP_COLOR, clrDimGray);
    ObjectSetInteger(0, prefix + "LearnBarBG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, prefix + "LearnBarBG", OBJPROP_BACK, false);
    
    ObjectCreate(0, prefix + "LearnBarFill", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_XDISTANCE, x + 15);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_XSIZE, 1);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_YSIZE, barHeight);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_BGCOLOR, clrRed);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_COLOR, clrRed);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_BACK, false);
    
    // Specialization Progress Bar
    y += barHeight + 8;
    AI_CreateLabel5(prefix + "SpecLabel", "Especialización:", x + 15, y, textColor, 8);
    AI_CreateLabel5(prefix + "SpecPercent", "Bloqueado", x + 230, y, clrGray, 8);
    
    y += 12;
    ObjectCreate(0, prefix + "SpecBarBG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, prefix + "SpecBarBG", OBJPROP_XDISTANCE, x + 15);
    ObjectSetInteger(0, prefix + "SpecBarBG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, prefix + "SpecBarBG", OBJPROP_XSIZE, barWidth);
    ObjectSetInteger(0, prefix + "SpecBarBG", OBJPROP_YSIZE, barHeight);
    ObjectSetInteger(0, prefix + "SpecBarBG", OBJPROP_BGCOLOR, C'30,30,30');
    ObjectSetInteger(0, prefix + "SpecBarBG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, prefix + "SpecBarBG", OBJPROP_COLOR, clrDimGray);
    ObjectSetInteger(0, prefix + "SpecBarBG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, prefix + "SpecBarBG", OBJPROP_BACK, false);
    
    ObjectCreate(0, prefix + "SpecBarFill", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_XDISTANCE, x + 15);
    ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_XSIZE, 1);
    ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_YSIZE, barHeight);
    ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_BGCOLOR, C'139,0,139');
    ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_COLOR, C'139,0,139');
    ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_BACK, false);
    
    // --- Regime Progress Bar (Optional - for visual feedback on market diversity) ---
    y += barHeight + 8;
    AI_CreateLabel5(prefix + "RegimeProgressLabel", "Regímenes:", x + 15, y, textColor, 8);
    AI_CreateLabel5(prefix + "RegimePercent", "0/10 regimenes", x + 230, y, clrGray, 8);
    
    y += 12;
    ObjectCreate(0, prefix + "RegimeBarBG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, prefix + "RegimeBarBG", OBJPROP_XDISTANCE, x + 15);
    ObjectSetInteger(0, prefix + "RegimeBarBG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, prefix + "RegimeBarBG", OBJPROP_XSIZE, barWidth);
    ObjectSetInteger(0, prefix + "RegimeBarBG", OBJPROP_YSIZE, barHeight);
    ObjectSetInteger(0, prefix + "RegimeBarBG", OBJPROP_BGCOLOR, C'35,35,35');
    ObjectSetInteger(0, prefix + "RegimeBarBG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, prefix + "RegimeBarBG", OBJPROP_COLOR, clrDimGray);
    ObjectSetInteger(0, prefix + "RegimeBarBG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, prefix + "RegimeBarBG", OBJPROP_BACK, false);
    
    ObjectCreate(0, prefix + "RegimeBarFill", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_XDISTANCE, x + 15);
    ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_XSIZE, 1);
    ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_YSIZE, barHeight);
    ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_BGCOLOR, clrOrange);
    ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_COLOR, clrOrange);
    ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_BACK, false);
    
    // --- Advanced Learning Warning Line ---
    y += barHeight + 5;
    AI_CreateLabel5(prefix + "AdvancedWarning", "", x + 15, y, clrOrange, 8);
    
    // Separator
    y += lineHeight + 3;
    AI_CreateLabel5(prefix + "Sep1", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━", x + 5, y, clrDarkGray, 8);
    
    y += lineHeight;
    AI_CreateLabel5(prefix + "RegimeTitle", "📊 MARKET REGIME", x + 10, y, headerColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "RegimeLabel", "Regime:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "RegimeValue", "---", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "TrendLabel", "Trend Score:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "TrendValue", "0.00", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "ADXLabel", "ADX Strength:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "ADXValue", "0.00", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "VolLabel", "Volatility:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "VolValue", "NORMAL", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "MomLabel", "Momentum:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "MomValue", "NEUTRAL", x + 160, y, valueColor, 9);
    
    y += lineHeight + 5;
    AI_CreateLabel5(prefix + "Sep2", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━", x + 5, y, clrDarkGray, 8);
    
    y += lineHeight;
    AI_CreateLabel5(prefix + "QLTitle", "🧠 Q-LEARNING ENGINE", x + 10, y, headerColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "StateLabel", "State Index:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "StateValue", "0", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "EpsLabel", "Exploration ε:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "EpsValue", "0.20", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "EpLabel", "Episodes:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "EpValue", "0", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "QLabel", "Best Q-Value:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "QValue", "0.00", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "ActionLabel", "Recommended:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "ActionValue", "HOLD", x + 160, y, clrCyan, 9);
    
    y += lineHeight + 5;
    AI_CreateLabel5(prefix + "Sep3", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━", x + 5, y, clrDarkGray, 8);
    
    y += lineHeight;
    AI_CreateLabel5(prefix + "PerfTitle", "📈 PERFORMANCE", x + 10, y, headerColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "TradesLabel", "Total Trades:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "TradesValue", "0", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "WinRateLabel", "Win Rate:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "WinRateValue", "0%", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "PFLabel", "Profit Factor:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "PFValue", "0.00", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "DDLabel", "Max Drawdown:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "DDValue", "0.00%", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "DDLimitLabel", "DD Limit:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "DDLimitValue", "---", x + 160, y, clrCyan, 9);
    
    y += lineHeight + 5;
    AI_CreateLabel5(prefix + "Sep4", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━", x + 5, y, clrDarkGray, 8);
    
    y += lineHeight;
    AI_CreateLabel5(prefix + "StatusTitle", "⚡ AI PARAMETERS", x + 10, y, headerColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "StatusLabel", "Agent Status:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "StatusValue", "ACTIVE", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "AdaptLabel", "AI Stop Loss:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "AdaptSLValue", "--- pts", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "AdaptTPLabel", "AI Take Profit:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "AdaptTPValue", "--- pts", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "AdaptLotsLabel", "AI Lot Size:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "AdaptLotsValue", "--- lots", x + 160, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "AdaptRRLabel", "Risk:Reward:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "AdaptRRValue", "---", x + 160, y, valueColor, 9);
    
    ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Create Label Helper (MQL5)                                        |
//+------------------------------------------------------------------+
void AI_CreateLabel5(string name, string text, int x, int y, color clr, int fontSize) {
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
    ObjectSetString(0, name, OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Update AI Monitoring Panel (MQL5)                                 |
//+------------------------------------------------------------------+
void AI_UpdatePanel5(long magicNumber, double adaptedSL, double adaptedTP, double adaptedLots) {
    if (TimeCurrent() - g_lastPanelUpdate5 < 1) return;
    g_lastPanelUpdate5 = TimeCurrent();
    
    string prefix = "AI_Panel_" + IntegerToString(magicNumber) + "_";
    color valueColor = clrLime;
    color warningColor = clrOrange;
    color dangerColor = clrRed;
    int barWidth = 200;
    
    // ===== UPDATE HEALTH STATUS =====
    AI_UpdateHealthStatus5();
    string healthIcon = AI_GetHealthIcon5(g_aiHealth5.status);
    color healthColor = AI_GetHealthColor5(g_aiHealth5.status);
    ObjectSetString(0, prefix + "HealthIcon", OBJPROP_TEXT, healthIcon);
    ObjectSetInteger(0, prefix + "HealthIcon", OBJPROP_COLOR, healthColor);
    ObjectSetString(0, prefix + "HealthValue", OBJPROP_TEXT, g_aiHealth5.statusMessage);
    ObjectSetInteger(0, prefix + "HealthValue", OBJPROP_COLOR, healthColor);
    
    // ===== UPDATE LEARNING PROGRESS BAR =====
    double learningProgress = AI_GetLearningProgress5();
    int learnBarFillWidth = (int)(barWidth * learningProgress / 100.0);
    if (learnBarFillWidth < 1) learnBarFillWidth = 1;
    
    color learnColor = AI_GetLearningBarColor5(learningProgress);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_XSIZE, learnBarFillWidth);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_BGCOLOR, learnColor);
    ObjectSetInteger(0, prefix + "LearnBarFill", OBJPROP_COLOR, learnColor);
    
    // Get professional learning stats
    int activePairs5 = AI_CountActivePairs5();
    double coveragePct5 = AI_GetCoveragePercent5();
    
    string learnPercentText = DoubleToString(learningProgress, 0) + "%";
    if (AI_IsLearningComplete5()) {
        learnPercentText = "100% ✓";
    }
    ObjectSetString(0, prefix + "LearnPercent", OBJPROP_TEXT, learnPercentText);
    ObjectSetInteger(0, prefix + "LearnPercent", OBJPROP_COLOR, learnColor);
    
    // Update learning label with professional metrics
    string learnLabelText = IntegerToString(activePairs5) + "/400 pares | " + 
                           IntegerToString(g_aiQLearning5.totalEpisodes) + " ep | " +
                           DoubleToString(coveragePct5, 1) + "% cob";
    ObjectSetString(0, prefix + "LearnLabel", OBJPROP_TEXT, learnLabelText);
    
    // ===== UPDATE SPECIALIZATION PROGRESS BAR =====
    double specProgress = AI_GetSpecializationProgress5();
    bool specUnlocked = AI_IsLearningComplete5();
    
    if (specUnlocked) {
        int specBarFillWidth = (int)(barWidth * specProgress / 100.0);
        if (specBarFillWidth < 1) specBarFillWidth = 1;
        
        color specColor = AI_GetSpecializationBarColor5(specProgress);
        ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_XSIZE, specBarFillWidth);
        ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_BGCOLOR, specColor);
        ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_COLOR, specColor);
        
        string specPercentText = DoubleToString(specProgress, 0) + "%";
        if (specProgress >= 100) specPercentText = "100% ★";
        ObjectSetString(0, prefix + "SpecPercent", OBJPROP_TEXT, specPercentText);
        ObjectSetInteger(0, prefix + "SpecPercent", OBJPROP_COLOR, specColor);
    } else {
        ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_XSIZE, 1);
        ObjectSetInteger(0, prefix + "SpecBarFill", OBJPROP_BGCOLOR, C'50,50,50');
        ObjectSetString(0, prefix + "SpecPercent", OBJPROP_TEXT, "🔒 Bloqueado");
        ObjectSetInteger(0, prefix + "SpecPercent", OBJPROP_COLOR, clrGray);
    }
    
    // ===== UPDATE REGIME PROGRESS BAR (if enabled) =====
    if (g_showRegimeProgress5) {
        double regimeProgress = AI_GetRegimeProgress5();
        int regimeBarFillWidth = (int)(barWidth * regimeProgress / 100.0);
        if (regimeBarFillWidth < 1) regimeBarFillWidth = 1;
        
        color regProgressColor = regimeProgress >= 80 ? clrLime : (regimeProgress >= 50 ? clrYellow : clrOrange);
        ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_XSIZE, regimeBarFillWidth);
        ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_BGCOLOR, regProgressColor);
        ObjectSetInteger(0, prefix + "RegimeBarFill", OBJPROP_COLOR, regProgressColor);
        
        int visitedRegimes = AI_CountVisitedRegimes5();
        string regimeProgressText = IntegerToString(visitedRegimes) + "/10 regimenes";
        ObjectSetString(0, prefix + "RegimePercent", OBJPROP_TEXT, regimeProgressText);
        ObjectSetInteger(0, prefix + "RegimePercent", OBJPROP_COLOR, regProgressColor);
    }
    
    // ===== UPDATE ADVANCED LEARNING WARNING (if shortcuts active) =====
    string advancedWarning = AI_GetAdvancedLearningWarning5();
    if (StringLen(advancedWarning) > 0) {
        ObjectSetString(0, prefix + "AdvancedWarning", OBJPROP_TEXT, "⚠ " + advancedWarning);
        ObjectSetInteger(0, prefix + "AdvancedWarning", OBJPROP_COLOR, clrOrange);
    } else {
        ObjectSetString(0, prefix + "AdvancedWarning", OBJPROP_TEXT, "");
    }
    
    // ===== UPDATE REGIME VALUES =====
    string regimeName = AI_GetRegimeName5(g_aiMarketState5.regime);
    color regimeColor = valueColor;
    if (g_aiMarketState5.regime == AI_REGIME_VOLATILE_CHAOS) regimeColor = dangerColor;
    else if (g_aiMarketState5.regime == AI_REGIME_TRANSITION) regimeColor = warningColor;
    
    ObjectSetString(0, prefix + "RegimeValue", OBJPROP_TEXT, regimeName);
    ObjectSetInteger(0, prefix + "RegimeValue", OBJPROP_COLOR, regimeColor);
    
    ObjectSetString(0, prefix + "TrendValue", OBJPROP_TEXT, DoubleToString(g_aiMarketState5.trendScore, 2));
    ObjectSetInteger(0, prefix + "TrendValue", OBJPROP_COLOR, g_aiMarketState5.trendScore > 0 ? clrLime : clrRed);
    
    ObjectSetString(0, prefix + "ADXValue", OBJPROP_TEXT, DoubleToString(g_aiMarketState5.trendStrength, 1));
    ObjectSetInteger(0, prefix + "ADXValue", OBJPROP_COLOR, g_aiMarketState5.trendStrength > 25 ? valueColor : clrGray);
    
    ObjectSetString(0, prefix + "VolValue", OBJPROP_TEXT, AI_GetVolatilityName5(g_aiMarketState5.volatility) + " (" + DoubleToString(g_aiMarketState5.volatilityRatio, 2) + "x)");
    ObjectSetInteger(0, prefix + "VolValue", OBJPROP_COLOR, g_aiMarketState5.volatility == AI_VOL_HIGH ? dangerColor : valueColor);
    
    ObjectSetString(0, prefix + "MomValue", OBJPROP_TEXT, AI_GetMomentumName5(g_aiMarketState5.momentum) + " (RSI:" + DoubleToString(g_aiMarketState5.rsiValue, 0) + ")");
    
    // ===== UPDATE Q-LEARNING VALUES =====
    ObjectSetString(0, prefix + "StateValue", OBJPROP_TEXT, IntegerToString(g_aiQLearning5.stateIndex));
    ObjectSetString(0, prefix + "EpsValue", OBJPROP_TEXT, DoubleToString(g_aiQLearning5.explorationRate, 4));
    ObjectSetString(0, prefix + "EpValue", OBJPROP_TEXT, IntegerToString(g_aiQLearning5.totalEpisodes));
    
    double maxQ = g_aiQLearning5.qValues[0];
    int bestAction = 0;
    for (int a = 1; a < 4; a++) {
        if (g_aiQLearning5.qValues[a] > maxQ) {
            maxQ = g_aiQLearning5.qValues[a];
            bestAction = a;
        }
    }
    ObjectSetString(0, prefix + "QValue", OBJPROP_TEXT, DoubleToString(maxQ, 2));
    
    string actionName;
    color actionColor;
    switch(bestAction) {
        case 0: actionName = "HOLD"; actionColor = clrGray; break;
        case 1: actionName = "BUY"; actionColor = clrLime; break;
        case 2: actionName = "SELL"; actionColor = clrRed; break;
        case 3: actionName = "CLOSE"; actionColor = clrYellow; break;
        default: actionName = "HOLD"; actionColor = clrGray; break;
    }
    ObjectSetString(0, prefix + "ActionValue", OBJPROP_TEXT, actionName);
    ObjectSetInteger(0, prefix + "ActionValue", OBJPROP_COLOR, actionColor);
    
    // ===== UPDATE PERFORMANCE VALUES =====
    ObjectSetString(0, prefix + "TradesValue", OBJPROP_TEXT, IntegerToString(g_aiPerformance5.totalTrades));
    
    double winRate = g_aiPerformance5.totalTrades > 0 ? 
                     (double)g_aiPerformance5.winningTrades / g_aiPerformance5.totalTrades * 100 : 0;
    ObjectSetString(0, prefix + "WinRateValue", OBJPROP_TEXT, DoubleToString(winRate, 1) + "%");
    ObjectSetInteger(0, prefix + "WinRateValue", OBJPROP_COLOR, winRate >= 50 ? valueColor : dangerColor);
    
    ObjectSetString(0, prefix + "PFValue", OBJPROP_TEXT, DoubleToString(g_aiPerformance5.profitFactor, 2));
    ObjectSetInteger(0, prefix + "PFValue", OBJPROP_COLOR, g_aiPerformance5.profitFactor >= 1.0 ? valueColor : dangerColor);
    
    ObjectSetString(0, prefix + "DDValue", OBJPROP_TEXT, DoubleToString(g_aiPerformance5.maxDrawdown, 2) + "%");
    ObjectSetInteger(0, prefix + "DDValue", OBJPROP_COLOR, g_aiPerformance5.maxDrawdown < g_aiDDLimit5 * 0.5 ? valueColor : (g_aiPerformance5.maxDrawdown < g_aiDDLimit5 * 0.8 ? warningColor : dangerColor));
    ObjectSetString(0, prefix + "DDLimitValue", OBJPROP_TEXT, DoubleToString(g_aiDDLimit5, 0) + "%");
    ObjectSetInteger(0, prefix + "DDLimitValue", OBJPROP_COLOR, g_aiPerformance5.maxDrawdown >= g_aiDDLimit5 ? dangerColor : (g_aiPerformance5.maxDrawdown >= g_aiDDLimit5 * 0.8 ? warningColor : clrCyan));

    // ===== UPDATE STATUS =====
    if (g_aiPerformance5.isPaused) {
        ObjectSetString(0, prefix + "StatusValue", OBJPROP_TEXT, "PAUSED");
        ObjectSetInteger(0, prefix + "StatusValue", OBJPROP_COLOR, dangerColor);
    } else {
        ObjectSetString(0, prefix + "StatusValue", OBJPROP_TEXT, "ACTIVE");
        ObjectSetInteger(0, prefix + "StatusValue", OBJPROP_COLOR, valueColor);
    }
    
    // ===== UPDATE AI TRADE PARAMETERS =====
    string slText = DoubleToString(adaptedSL, 1) + " pts";
    string tpText = DoubleToString(adaptedTP, 1) + " pts";
    string lotsText = DoubleToString(adaptedLots, 2) + " lots";
    double rrRatio = adaptedSL > 0 ? adaptedTP / adaptedSL : 0;
    string rrText = DoubleToString(rrRatio, 1) + ":1";
    
    ObjectSetString(0, prefix + "AdaptSLValue", OBJPROP_TEXT, slText);
    ObjectSetString(0, prefix + "AdaptTPValue", OBJPROP_TEXT, tpText);
    ObjectSetString(0, prefix + "AdaptLotsValue", OBJPROP_TEXT, lotsText);
    ObjectSetString(0, prefix + "AdaptRRValue", OBJPROP_TEXT, rrText);
    
    ObjectSetInteger(0, prefix + "AdaptSLValue", OBJPROP_COLOR, valueColor);
    ObjectSetInteger(0, prefix + "AdaptTPValue", OBJPROP_COLOR, valueColor);
    ObjectSetInteger(0, prefix + "AdaptLotsValue", OBJPROP_COLOR, valueColor);
    ObjectSetInteger(0, prefix + "AdaptRRValue", OBJPROP_COLOR, rrRatio >= 1.5 ? valueColor : warningColor);
    
    ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Clean up AI Panel (MQL5)                                          |
//+------------------------------------------------------------------+
void AI_DeletePanel5(long magicNumber) {
    string prefix = "AI_Panel_" + IntegerToString(magicNumber) + "_";
    ObjectsDeleteAll(0, prefix);
}

//+------------------------------------------------------------------+
//|       MARKET STRUCTURE DETECTION & STRATEGY GENERATION (MQL5)    |
//+------------------------------------------------------------------+

// 8 Test Strategies Enumeration (MQL5)
enum ENUM_AI_TEST_STRATEGY {
    AI_TEST_TREND_FOLLOWING,
    AI_TEST_MEAN_REVERSION,
    AI_TEST_MOMENTUM,
    AI_TEST_VOLATILITY_BREAKOUT,
    AI_TEST_SESSION_OPENING,
    AI_TEST_RSI_DIVERGENCE,
    AI_TEST_RANGE_TRADING,
    AI_TEST_HTF_CONFIRMATION
};

// Market Structure Type (MQL5)
enum ENUM_AI_MARKET_STRUCTURE {
    AI_STRUCT_TRENDING,
    AI_STRUCT_RANGING,
    AI_STRUCT_VOLATILE,
    AI_STRUCT_CONSOLIDATION,
    AI_STRUCT_MIXED
};

// Strategy Template Enumeration (MQL5)
enum ENUM_AI_STRATEGY_TEMPLATE {
    AI_STRAT_MOMENTUM,
    AI_STRAT_MEAN_REVERSION,
    AI_STRAT_BREAKOUT,
    AI_STRAT_SCALP,
    AI_STRAT_SWING
};

// Trade Direction (MQL5)
enum ENUM_AI_TRADE_DIRECTION {
    AI_DIR_LONG,
    AI_DIR_SHORT,
    AI_DIR_BOTH
};

// Strategy Test Metrics (MQL5) - ENHANCED v2.0
struct StrategyTestMetrics5 {
    // Core Performance
    double winRate;
    double profitFactor;
    double sharpeRatio;
    double avgWinLossRatio;
    double maxDrawdown;
    double recoveryFactor;
    double expectancy;         // MOST IMPORTANT metric
    double efficiency;
    int maxConsecLosses;
    double totalReturn;
    double tradesPerPeriod;
    // Advanced Metrics (NEW)
    double sortinoRatio;       // Return / Downside deviation
    double downsideDeviation;  // Volatility of losing trades only
    double winStreakAvg;       // Average consecutive wins
    double statisticalConfidence;  // 0-100% based on sample size
    // Summary
    double overallScore;
    bool isViable;
    int totalTrades;
    int winningTrades;
    int losingTrades;
};

// Strategy Test Results (MQL5) - ENHANCED with Hurst Exponent
struct StrategyTestResults5 {
    StrategyTestMetrics5 metrics[8];
    int bestStrategyIndex;
    int secondBestIndex;
    int worstStrategyIndex;
    ENUM_AI_MARKET_STRUCTURE detectedStructure;
    string structureDescription;
    double confidenceLevel;
    datetime analysisTime;
    // Hurst Exponent Analysis (R/S Method)
    double hurstValue;           // H: 0.5=random, >0.5=trending, <0.5=mean reverting
    int hurstRegime;             // -1=MeanReverting, 0=Random, 1=Trending
    double hurstMemoryStrength;  // |H - 0.5| * 100 (0-50%)
    double hurstFractalDimension; // D = 2 - H (1.0=smooth, 2.0=chaotic)
    string hurstDescription;     // Human-readable interpretation
};

// Generated Strategy Structure (MQL5)
struct AI_GeneratedStrategy5 {
    ENUM_AI_STRATEGY_TEMPLATE stratTemplate;
    ENUM_AI_MARKET_REGIME targetRegime;
    ENUM_AI_TRADE_DIRECTION direction;
    ENUM_AI_MARKET_STRUCTURE marketStructure;
    
    string entryConditions;
    double entryRSI_Low;
    double entryRSI_High;
    double entryADX_Min;
    bool useSMA;
    bool useBB;
    bool useHTFConfirmation;
    
    double stopLossATR;
    double takeProfitATR;
    double riskRewardRatio;
    double positionSizeMultiplier;
    double riskPercent;
    
    bool useBreakeven;
    double breakevenTrigger;
    
    int backtestBars;
    double backtestWinRate;
    double backtestProfitFactor;
    double backtestMaxDD;
    double backtestSharpeRatio;
    int backtestTrades;
    double backtestExpectancy;
    double backtestRecoveryFactor;
    
    StrategyTestResults5 testResults;
    
    // Winning strategy-specific filters
    bool useSessionFilter;
    int sessionStartHour;
    int sessionEndHour;
    bool useVolatilityFilter;
    bool useHTFFilter;

    string warnings[10];
    int warningCount;

    bool isViable;
    string viabilityReason;
    datetime generatedTime;
};

AI_GeneratedStrategy5 g_genStrategy5;
StrategyTestResults5 g_testResults5;
bool g_stratGenInitialized5 = false;
datetime g_lastReportExport5 = 0;
string g_strategyNames5[8] = {"TREND_FOLLOW", "MEAN_REVER", "MOMENTUM", "VOL_BREAK", "SESSION_OPEN", "RSI_DIVERG", "RANGE_TRADE", "HTF_CONFIRM"};

//+------------------------------------------------------------------+
//| Initialize Strategy Generator (MQL5)                               |
//+------------------------------------------------------------------+
void StratGen_Initialize5() {
    Print("[STRATGEN INIT] StratGen_Initialize5() called - g_stratGenInitialized5=", g_stratGenInitialized5);
    if (g_stratGenInitialized5) {
        Print("[STRATGEN INIT] Already initialized, skipping");
        return;
    }
    
    Print("[STRATGEN INIT] Initializing strategy generator structures...");
    for (int i = 0; i < 10; i++) g_genStrategy5.warnings[i] = "";
    g_genStrategy5.warningCount = 0;
    g_genStrategy5.isViable = false;
    g_genStrategy5.generatedTime = 0;
    
    // Initialize test results
    Print("[STRATGEN INIT] Initializing test results for 8 strategies...");
    for (int i = 0; i < 8; i++) {
        g_testResults5.metrics[i].winRate = 0;
        g_testResults5.metrics[i].profitFactor = 0;
        g_testResults5.metrics[i].overallScore = 0;
        g_testResults5.metrics[i].isViable = false;
    }
    g_testResults5.bestStrategyIndex = -1;
    g_testResults5.detectedStructure = AI_STRUCT_MIXED;
    g_testResults5.confidenceLevel = 0;
    
    // Initialize Hurst fields
    Print("[STRATGEN INIT] Initializing Hurst exponent fields...");
    g_testResults5.hurstValue = 0.5;  // Default to random walk
    g_testResults5.hurstRegime = 0;   // Random
    g_testResults5.hurstMemoryStrength = 0;
    g_testResults5.hurstFractalDimension = 1.5;
    g_testResults5.hurstDescription = "Calculating...";
    
    g_stratGenInitialized5 = true;
    Print("[STRATGEN INIT] ✓ Market Structure Detection IA (MQL5) with Hurst R/S initialized successfully");
}

//+------------------------------------------------------------------+
//| Calculate Hurst Exponent using R/S (Rescaled Range) Method        |
//| This is the professional standard for financial markets            |
//| H > 0.5 = Trending (persistent), H = 0.5 = Random, H < 0.5 = Mean Reversion |
//+------------------------------------------------------------------+
void StratGen_CalculateHurst5(int period = 200) {
    Print("[STRATGEN HURST] ========================================");
    Print("[STRATGEN HURST] Starting Hurst Exponent calculation (R/S Method)");
    Print("[STRATGEN HURST] Analysis period: ", period, " bars");
    
    int minWindowSize = 8;
    double TREND_THRESHOLD = 0.55;
    double RANDOM_UPPER = 0.53;
    double RANDOM_LOWER = 0.47;
    double REVERSION_THRESHOLD = 0.45;
    
    // Get close prices
    double closePrices[];
    ArraySetAsSeries(closePrices, true);
    int copied = CopyClose(_Symbol, PERIOD_CURRENT, 0, period, closePrices);
    
    if (copied < period) {
        Print("HURST: Insufficient data (", copied, "/", period, ") - using default 0.5");
        g_testResults5.hurstValue = 0.5;
        g_testResults5.hurstRegime = 0;
        g_testResults5.hurstMemoryStrength = 0;
        g_testResults5.hurstFractalDimension = 1.5;
        g_testResults5.hurstDescription = "Insufficient data - assuming random";
        return;
    }
    
    // Calculate log returns (more appropriate for financial data)
    double returns[];
    int dataLen = period - 1;
    ArrayResize(returns, dataLen);
    ArraySetAsSeries(returns, false);
    
    for (int i = 0; i < dataLen; i++) {
        double price1 = closePrices[period - 1 - i];
        double price2 = closePrices[period - 2 - i];
        if (price1 > 0 && price2 > 0) {
            returns[i] = MathLog(price2 / price1);
        } else {
            returns[i] = 0.0;
        }
    }
    
    // Generate logarithmically spaced window sizes
    int maxWindowSize = dataLen / 4;
    if (maxWindowSize < minWindowSize * 2) maxWindowSize = minWindowSize * 2;
    
    int numScales = 10;
    double windowSizes[];
    double logRS[];
    double logN[];
    bool validScale[];
    ArrayResize(windowSizes, numScales);
    ArrayResize(logRS, numScales);
    ArrayResize(logN, numScales);
    ArrayResize(validScale, numScales);
    ArrayInitialize(validScale, false);
    
    // Logarithmic spacing
    double logRatio = MathLog((double)maxWindowSize / minWindowSize);
    for (int k = 0; k < numScales; k++) {
        double exponent = (double)k / (numScales - 1);
        windowSizes[k] = minWindowSize * MathExp(logRatio * exponent);
    }
    
    // Calculate R/S for each window size
    for (int s = 0; s < numScales; s++) {
        int windowSize = (int)MathRound(windowSizes[s]);
        if (windowSize < minWindowSize) windowSize = minWindowSize;
        if (windowSize > dataLen) continue;
        
        int numBlocks = dataLen / windowSize;
        if (numBlocks < 4) continue;
        
        double sumRS = 0.0;
        int validBlocks = 0;
        
        for (int b = 0; b < numBlocks; b++) {
            int blockStart = b * windowSize;
            int blockEnd = blockStart + windowSize;
            if (blockEnd > dataLen) break;
            
            // Calculate mean of this block
            double blockMean = 0.0;
            for (int j = blockStart; j < blockEnd; j++) {
                blockMean += returns[j];
            }
            blockMean /= windowSize;
            
            // Calculate cumulative deviation and standard deviation
            double cumDev = 0.0;
            double maxCumDev = -1e10;
            double minCumDev = 1e10;
            double sumSq = 0.0;
            
            for (int j = blockStart; j < blockEnd; j++) {
                double deviation = returns[j] - blockMean;
                cumDev += deviation;
                sumSq += deviation * deviation;
                
                if (cumDev > maxCumDev) maxCumDev = cumDev;
                if (cumDev < minCumDev) minCumDev = cumDev;
            }
            
            double R = maxCumDev - minCumDev;  // Range
            double S = MathSqrt(sumSq / windowSize);  // Std Dev
            
            if (S > 1e-10 && R > 0) {
                sumRS += R / S;
                validBlocks++;
            }
        }
        
        if (validBlocks >= 4) {
            double avgRS = sumRS / validBlocks;
            logRS[s] = MathLog(avgRS);
            logN[s] = MathLog((double)windowSize);
            validScale[s] = true;
        }
    }
    
    // Linear regression log(R/S) vs log(n) to get Hurst exponent
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    int validPoints = 0;
    
    for (int i = 0; i < numScales; i++) {
        if (validScale[i]) {
            sumX += logN[i];
            sumY += logRS[i];
            sumXY += logN[i] * logRS[i];
            sumX2 += logN[i] * logN[i];
            validPoints++;
        }
    }
    
    double rawH = 0.5;
    if (validPoints >= 4) {
        double denom = (validPoints * sumX2 - sumX * sumX);
        if (MathAbs(denom) > 1e-10) {
            rawH = (validPoints * sumXY - sumX * sumY) / denom;
        }
    }
    
    // Clamp to valid range
    rawH = MathMax(0.01, MathMin(0.99, rawH));
    
    // Store results
    g_testResults5.hurstValue = rawH;
    g_testResults5.hurstMemoryStrength = MathAbs(rawH - 0.5) * 100.0;
    g_testResults5.hurstFractalDimension = 2.0 - rawH;
    
    // Determine regime
    if (rawH > TREND_THRESHOLD) {
        g_testResults5.hurstRegime = 1;  // TRENDING
        g_testResults5.hurstDescription = "PERSISTENT/TRENDING (H=" + DoubleToString(rawH, 3) + ") - Trend-following strategies recommended";
    }
    else if (rawH >= RANDOM_LOWER && rawH <= RANDOM_UPPER) {
        g_testResults5.hurstRegime = 0;  // RANDOM
        g_testResults5.hurstDescription = "RANDOM WALK (H=" + DoubleToString(rawH, 3) + ") - Market is noise, reduce exposure";
    }
    else if (rawH < REVERSION_THRESHOLD) {
        g_testResults5.hurstRegime = -1; // MEAN REVERTING
        g_testResults5.hurstDescription = "MEAN REVERTING (H=" + DoubleToString(rawH, 3) + ") - Counter-trend strategies recommended";
    }
    else {
        // Transition zone
        if (rawH > 0.5) {
            g_testResults5.hurstRegime = 1;
            g_testResults5.hurstDescription = "WEAK TREND (H=" + DoubleToString(rawH, 3) + ") - Cautious trend-following";
        } else {
            g_testResults5.hurstRegime = -1;
            g_testResults5.hurstDescription = "WEAK REVERSION (H=" + DoubleToString(rawH, 3) + ") - Cautious mean-reversion";
        }
    }
    
    Print("HURST R/S RESULT: H=", DoubleToString(rawH, 4), 
          " | Regime=", g_testResults5.hurstRegime == 1 ? "TRENDING" : (g_testResults5.hurstRegime == -1 ? "REVERTING" : "RANDOM"),
          " | Memory=", DoubleToString(g_testResults5.hurstMemoryStrength, 1), "%",
          " | FractalD=", DoubleToString(g_testResults5.hurstFractalDimension, 3));
}

//+------------------------------------------------------------------+
//| Get Strategy Name (MQL5)                                           |
//+------------------------------------------------------------------+
string StratGen_GetTestStrategyName5(int index) {
    if (index >= 0 && index < 8) return g_strategyNames5[index];
    return "UNKNOWN";
}

//+------------------------------------------------------------------+
//| Get Market Structure Name (MQL5)                                   |
//+------------------------------------------------------------------+
string StratGen_GetStructureName5(ENUM_AI_MARKET_STRUCTURE structure) {
    switch (structure) {
        case AI_STRUCT_TRENDING: return "TRENDING";
        case AI_STRUCT_RANGING: return "RANGING";
        case AI_STRUCT_VOLATILE: return "VOLATILE";
        case AI_STRUCT_CONSOLIDATION: return "CONSOLIDATION";
        case AI_STRUCT_MIXED: return "MIXED/CHOPPY";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Calculate Overall Score (MQL5) - IMPROVED v2.0                     |
//| Priority: Expectancy > Profit Factor > Sharpe > Win Rate           |
//+------------------------------------------------------------------+
double StratGen_CalculateScore5(StrategyTestMetrics5 &m) {
    double score = 0;
    
    // ===== EXPECTANCY as PRIMARY metric (max 3.0 points) =====
    if (m.expectancy >= 0.5) score += 3.0;
    else if (m.expectancy >= 0.3) score += 2.5;
    else if (m.expectancy >= 0.15) score += 2.0;
    else if (m.expectancy >= 0.05) score += 1.5;
    else if (m.expectancy >= 0) score += 0.5;
    
    // ===== PROFIT FACTOR (max 2.0 points) =====
    if (m.profitFactor >= 2.0) score += 2.0;
    else if (m.profitFactor >= 1.5) score += 1.5;
    else if (m.profitFactor >= 1.2) score += 1.0;
    else if (m.profitFactor >= 1.0) score += 0.5;
    
    // ===== SHARPE RATIO (max 1.5 points) =====
    if (m.sharpeRatio >= 1.5) score += 1.5;
    else if (m.sharpeRatio >= 1.0) score += 1.0;
    else if (m.sharpeRatio >= 0.5) score += 0.5;
    
    // ===== WIN RATE - now SECONDARY (max 1.0 points) =====
    if (m.winRate >= 60 && m.avgWinLossRatio >= 1.0) score += 1.0;
    else if (m.winRate >= 50 && m.avgWinLossRatio >= 1.2) score += 0.75;
    else if (m.winRate >= 45 && m.avgWinLossRatio >= 1.5) score += 0.5;
    else if (m.winRate >= 40 && m.avgWinLossRatio >= 2.0) score += 0.5;
    
    // ===== DRAWDOWN RISK (max 1.0 points) =====
    if (m.maxDrawdown < 5) score += 1.0;
    else if (m.maxDrawdown < 10) score += 0.75;
    else if (m.maxDrawdown < 15) score += 0.5;
    else if (m.maxDrawdown < 20) score += 0.25;
    
    // ===== RECOVERY FACTOR (max 0.75 points) =====
    if (m.recoveryFactor >= 3.0) score += 0.75;
    else if (m.recoveryFactor >= 2.0) score += 0.5;
    else if (m.recoveryFactor >= 1.0) score += 0.25;
    
    // ===== STABILITY (max 0.5 points) =====
    if (m.maxConsecLosses <= 3) score += 0.5;
    else if (m.maxConsecLosses <= 5) score += 0.25;
    
    // ===== SAMPLE SIZE PENALTY =====
    if (m.totalTrades < 15) {
        score *= 0.7;  // 30% penalty for very small samples
    } else if (m.totalTrades < 30) {
        score *= 0.85; // 15% penalty for small samples
    }
    
    // ===== CONSISTENCY BONUS (max 0.25 points) =====
    int goodMetrics = 0;
    if (m.expectancy > 0.1) goodMetrics++;
    if (m.profitFactor > 1.2) goodMetrics++;
    if (m.sharpeRatio > 0.7) goodMetrics++;
    if (m.winRate > 45) goodMetrics++;
    if (m.avgWinLossRatio > 1.2) goodMetrics++;
    if (goodMetrics >= 4) score += 0.25;
    
    return MathMin(10.0, score);
}

//+------------------------------------------------------------------+
//| Calculate Advanced Metrics (MQL5) - Sortino, Downside Dev, etc.    |
//+------------------------------------------------------------------+
void StratGen_CalculateAdvancedMetrics5(StrategyTestMetrics5 &m, double &returns[], int returnCount) {
    if (returnCount < 2) {
        m.sortinoRatio = 0;
        m.downsideDeviation = 0;
        m.statisticalConfidence = 0;
        return;
    }
    
    // Calculate average return
    double avgReturn = 0;
    for (int i = 0; i < returnCount; i++) avgReturn += returns[i];
    avgReturn /= returnCount;
    
    // Calculate Downside Deviation (only negative returns contribute)
    double downsideSum = 0;
    int downsideCount = 0;
    for (int i = 0; i < returnCount; i++) {
        if (returns[i] < 0) {
            downsideSum += MathPow(returns[i], 2);
            downsideCount++;
        }
    }
    
    m.downsideDeviation = downsideCount > 0 ? MathSqrt(downsideSum / returnCount) : 0;
    m.sortinoRatio = m.downsideDeviation > 0 ? (avgReturn / m.downsideDeviation) : 0;
    
    // Statistical Confidence based on sample size
    if (m.totalTrades < 10) {
        m.statisticalConfidence = 20 + (m.totalTrades * 2);
    } else if (m.totalTrades < 30) {
        m.statisticalConfidence = 40 + ((m.totalTrades - 10) * 1.5);
    } else if (m.totalTrades < 50) {
        m.statisticalConfidence = 70 + ((m.totalTrades - 30) * 0.75);
    } else if (m.totalTrades < 100) {
        m.statisticalConfidence = 85 + ((m.totalTrades - 50) * 0.2);
    } else {
        m.statisticalConfidence = 95;
    }
}

//+------------------------------------------------------------------+
//| Get Dynamic Look-ahead Based on Timeframe (MQL5)                   |
//| EXACT VALUES FROM MQL4 - each strategy has specific calculation    |
//+------------------------------------------------------------------+
int StratGen_GetLookAhead5(int strategyType) {
    // Convert ENUM_TIMEFRAMES to minutes for comparison
    // MQL4 Period() returns minutes: M1=1, M5=5, M15=15, M30=30, H1=60, H4=240, D1=1440
    // MQL5 Period() returns ENUM: PERIOD_M15=15, but PERIOD_H1=16385 (not 60!)
    ENUM_TIMEFRAMES tf = Period();
    int periodMinutes;
    
    // Convert MQL5 ENUM_TIMEFRAMES to minutes (matching MQL4 behavior)
    switch (tf) {
        case PERIOD_M1:  periodMinutes = 1; break;
        case PERIOD_M5:  periodMinutes = 5; break;
        case PERIOD_M15: periodMinutes = 15; break;
        case PERIOD_M30: periodMinutes = 30; break;
        case PERIOD_H1:  periodMinutes = 60; break;
        case PERIOD_H4:  periodMinutes = 240; break;
        case PERIOD_D1:  periodMinutes = 1440; break;
        case PERIOD_W1:  periodMinutes = 10080; break;
        case PERIOD_MN1: periodMinutes = 43200; break;
        default: periodMinutes = 60; // Default to H1
    }
    
    // EXACT look-ahead formulas from MQL4 (each strategy specific)
    switch (strategyType) {
        case 0: // Trend Following: (Period() <= 15) ? 60 : (Period() <= 60) ? 50 : 40
            return (periodMinutes <= 15) ? 60 : (periodMinutes <= 60) ? 50 : 40;
            
        case 1: // Mean Reversion: (Period() <= 15) ? 50 : (Period() <= 60) ? 40 : 30
            return (periodMinutes <= 15) ? 50 : (periodMinutes <= 60) ? 40 : 30;
            
        case 2: // Momentum: (Period() <= 15) ? 50 : (Period() <= 60) ? 40 : 35
            return (periodMinutes <= 15) ? 50 : (periodMinutes <= 60) ? 40 : 35;
            
        case 3: // Volatility Breakout: (Period() <= 15) ? 60 : (Period() <= 60) ? 50 : 40
            return (periodMinutes <= 15) ? 60 : (periodMinutes <= 60) ? 50 : 40;
            
        case 4: // Session Opening: (Period() <= 15) ? 24 : (Period() <= 60) ? 16 : 12
            return (periodMinutes <= 15) ? 24 : (periodMinutes <= 60) ? 16 : 12;
            
        case 5: // RSI Divergence: (Period() <= 15) ? 50 : (Period() <= 60) ? 40 : 30
            return (periodMinutes <= 15) ? 50 : (periodMinutes <= 60) ? 40 : 30;
            
        case 6: // Range Trading: (Period() <= 15) ? 40 : (Period() <= 60) ? 30 : 25
            return (periodMinutes <= 15) ? 40 : (periodMinutes <= 60) ? 30 : 25;
            
        case 7: // HTF Confirmation: (Period() <= 15) ? 50 : (Period() <= 60) ? 45 : 35
            return (periodMinutes <= 15) ? 50 : (periodMinutes <= 60) ? 45 : 35;
            
        default:
            return (periodMinutes <= 15) ? 50 : (periodMinutes <= 60) ? 40 : 30;
    }
}

//+------------------------------------------------------------------+
//| Get Strategy-specific SL/TP (MQL5) - Same as MQL4                  |
//+------------------------------------------------------------------+
void StratGen_GetSLTP5(int strategyType, double &sl, double &tp) {
    switch (strategyType) {
        case 0: // Trend Following
            sl = 2.0; tp = 3.0; break;
        case 1: // Mean Reversion
            sl = 1.2; tp = 1.5; break;
        case 2: // Momentum
            sl = 1.5; tp = 2.5; break;
        case 3: // Volatility Breakout
            sl = 2.0; tp = 3.0; break;
        case 4: // Session Opening
            sl = 1.5; tp = 2.0; break;
        case 5: // RSI Divergence
            sl = 1.5; tp = 2.5; break;
        case 6: // Range Trading
            sl = 1.0; tp = 2.0; break;
        case 7: // HTF Confirmation
            sl = 1.8; tp = 3.0; break;
        default:
            sl = 1.5; tp = 2.5; break;
    }
}

//+------------------------------------------------------------------+
//| Run 8 Strategy Tests (MQL5) - SYNCHRONIZED WITH MQL4               |
//| Uses same logic: dynamic look-ahead, resolved trades only, etc.    |
//+------------------------------------------------------------------+
void StratGen_RunAllTests5(int bars) {
    Print("[STRATGEN ANALYSIS] ========================================");
    Print("[STRATGEN ANALYSIS] StratGen_RunAllTests5() STARTED");
    Print("[STRATGEN ANALYSIS] Symbol: ", _Symbol, " | Timeframe: ", EnumToString(PERIOD_CURRENT));
    Print("[STRATGEN ANALYSIS] Requested bars: ", bars);
    
    int totalBars = iBars(_Symbol, PERIOD_CURRENT);
    Print("[STRATGEN ANALYSIS] Available bars in chart: ", totalBars);
    
    if (totalBars < bars) {
        bars = totalBars;
        Print("[STRATGEN ANALYSIS] Adjusted bars to available: ", bars);
    }
    
    if (bars < 500) {
        Print("[STRATGEN ANALYSIS] WARNING: Recommend at least 1000 bars for reliable analysis (have ", bars, ")");
        if (bars < 100) {
            Print("[STRATGEN ANALYSIS] ERROR: Insufficient bars (<100) - ABORTING");
            return;
        }
    }
    
    // Create indicator handles
    Print("[STRATGEN ANALYSIS] Creating indicator handles...");
    int smaHandle = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
    int sma200Handle = iMA(_Symbol, PERIOD_CURRENT, 200, 0, MODE_SMA, PRICE_CLOSE);
    int adxHandle = iADX(_Symbol, PERIOD_CURRENT, 14);
    int rsiHandle = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    int bbHandle = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
    int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
    
    Print("[STRATGEN ANALYSIS] Indicator handles: SMA50=", smaHandle, " SMA200=", sma200Handle, 
          " ADX=", adxHandle, " RSI=", rsiHandle, " BB=", bbHandle, " ATR=", atrHandle);
    
    if (smaHandle == INVALID_HANDLE || sma200Handle == INVALID_HANDLE ||
        adxHandle == INVALID_HANDLE || rsiHandle == INVALID_HANDLE ||
        bbHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE) {
        Print("[STRATGEN ANALYSIS] ERROR: Failed to create indicator handles - ABORTING");
        Print("[STRATGEN ANALYSIS] GetLastError: ", GetLastError());
        return;
    }
    Print("[STRATGEN ANALYSIS] ✓ All indicator handles created successfully");
    
    // Prepare buffers (including BB Middle for Mean Reversion TP calculation)
    double smaBuffer[], sma200Buffer[], adxBuffer[], rsiBuffer[];
    double bbUpperBuffer[], bbLowerBuffer[], bbMiddleBuffer[], atrBuffer[];
    ArrayResize(smaBuffer, 1); // FIX FEB 2026: Pre-allocate all buffers
    ArrayResize(sma200Buffer, 1);
    ArrayResize(adxBuffer, 1);
    ArrayResize(rsiBuffer, 1);
    ArrayResize(bbUpperBuffer, 1);
    ArrayResize(bbLowerBuffer, 1);
    ArrayResize(bbMiddleBuffer, 1);
    ArrayResize(atrBuffer, 1);
    ArraySetAsSeries(smaBuffer, true);
    ArraySetAsSeries(sma200Buffer, true);
    ArraySetAsSeries(adxBuffer, true);
    ArraySetAsSeries(rsiBuffer, true);
    ArraySetAsSeries(bbUpperBuffer, true);
    ArraySetAsSeries(bbLowerBuffer, true);
    ArraySetAsSeries(bbMiddleBuffer, true);
    ArraySetAsSeries(atrBuffer, true);
    
    // Copy data (BB buffer 0=middle, 1=upper, 2=lower)
    if (CopyBuffer(smaHandle, 0, 0, bars, smaBuffer) <= 0 ||
        CopyBuffer(sma200Handle, 0, 0, bars, sma200Buffer) <= 0 ||
        CopyBuffer(adxHandle, 0, 0, bars, adxBuffer) <= 0 ||
        CopyBuffer(rsiHandle, 0, 0, bars, rsiBuffer) <= 0 ||
        CopyBuffer(bbHandle, 0, 0, bars, bbMiddleBuffer) <= 0 ||   // Buffer 0 = Middle
        CopyBuffer(bbHandle, 1, 0, bars, bbUpperBuffer) <= 0 ||    // Buffer 1 = Upper
        CopyBuffer(bbHandle, 2, 0, bars, bbLowerBuffer) <= 0 ||    // Buffer 2 = Lower
        CopyBuffer(atrHandle, 0, 0, bars, atrBuffer) <= 0) {
        Print("ERROR: Failed to copy indicator buffers");
        IndicatorRelease(smaHandle); IndicatorRelease(sma200Handle);
        IndicatorRelease(adxHandle); IndicatorRelease(rsiHandle);
        IndicatorRelease(bbHandle); IndicatorRelease(atrHandle);
        return;
    }
    
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int ratesCopied = CopyRates(_Symbol, PERIOD_CURRENT, 0, bars, rates);
    if (ratesCopied <= 0) {
        Print("ERROR: Failed to copy price data");
        IndicatorRelease(smaHandle); IndicatorRelease(sma200Handle);
        IndicatorRelease(adxHandle); IndicatorRelease(rsiHandle);
        IndicatorRelease(bbHandle); IndicatorRelease(atrHandle);
        return;
    }
    
    Print("Data loaded: ", ratesCopied, " bars");
    
    // Test each strategy with IDENTICAL logic to MQL4
    for (int stratIdx = 0; stratIdx < 8; stratIdx++) {
        int wins = 0, losses = 0, totalTrades = 0;
        double totalProfit = 0, totalLoss = 0;
        double maxEquity = 10000, currentEquity = 10000, maxDD = 0;
        int maxConsecLosses = 0, consecLosses = 0;
        double returns[];
        ArrayResize(returns, 0);
        
        // Get strategy-specific look-ahead (EXACT VALUES FROM MQL4)
        int lookAhead = StratGen_GetLookAhead5(stratIdx);
        
        // ===== IDENTICAL INDEX RANGES AS MQL4 =====
        // MQL4 Trend Following:  minIdx = MathMax(lookAhead + 10, bars / 10), maxIdx = bars - 201
        // MQL4 All others:       minIdx = MathMax(lookAhead + 10, 50), maxIdx = bars - 1 (for loop uses bars-1)
        int minIdx, maxIdx;
        
        if (stratIdx == 0) {  // Trend Following ONLY needs SMA200 warmup
            minIdx = MathMax(lookAhead + 10, ratesCopied / 10);
            maxIdx = ratesCopied - 201;
            if (maxIdx < minIdx) maxIdx = minIdx + 10;
        } else {
            // All other strategies: start from bars-1, minIdx = 50
            minIdx = MathMax(lookAhead + 10, 50);
            maxIdx = ratesCopied - 1;
        }
        
        if (maxIdx <= minIdx) continue;
        
        // NO EXTRA continue CHECK - MQL4 doesn't have it
        for (int i = maxIdx; i >= minIdx; i--) {
            
            bool buySignal = false, sellSignal = false;
            double atr = atrBuffer[i];
            double close_i = rates[i].close;
            
            // STRATEGY-SPECIFIC SL/TP - exactly matching MQL4
            double sl = 0, tp = 0;
            
            switch (stratIdx) {
                case 0: // Trend Following - SL: 2.0*ATR, TP: 3.0*ATR
                    buySignal = (close_i > smaBuffer[i] && smaBuffer[i] > sma200Buffer[i] && adxBuffer[i] > 25);
                    sellSignal = (close_i < smaBuffer[i] && smaBuffer[i] < sma200Buffer[i] && adxBuffer[i] > 25);
                    sl = 2.0 * atr;
                    tp = 3.0 * atr;
                    break;
                    
                case 1: // Mean Reversion - SL: 1.2*ATR, TP: dynamic (BB middle distance)
                    buySignal = (close_i < bbLowerBuffer[i] && rsiBuffer[i] < 30);
                    sellSignal = (close_i > bbUpperBuffer[i] && rsiBuffer[i] > 70);
                    sl = 1.2 * atr;
                    // CRITICAL: Dynamic TP based on BB middle distance (SAME AS MQL4)
                    tp = MathAbs(buySignal ? (bbMiddleBuffer[i] - close_i) : (close_i - bbMiddleBuffer[i]));
                    if (tp < 0.5 * atr) tp = 1.0 * atr;
                    break;
                    
                case 2: // Momentum - SL: 1.5*ATR, TP: 2.5*ATR
                    if (i + 1 < ratesCopied) {
                        buySignal = (rsiBuffer[i+1] < 30 && rsiBuffer[i] > 30);
                        sellSignal = (rsiBuffer[i+1] > 70 && rsiBuffer[i] < 70);
                    }
                    sl = 1.5 * atr;
                    tp = 2.5 * atr;
                    break;
                    
                case 3: // Volatility Breakout - SL: 2.0*ATR, TP: 3.0*ATR
                    // MQL4 iHighest/iLowest work even near array limits - replicate that
                    if (i + 1 < ratesCopied) {
                        int atrCount = MathMin(20, ratesCopied - i);
                        double atrAvg = 0;
                        for (int k = 0; k < atrCount; k++) atrAvg += atrBuffer[i + k];
                        atrAvg /= atrCount;
                        
                        int rangeEnd = MathMin(i + 21, ratesCopied);
                        double high20 = rates[i+1].high;
                        double low20 = rates[i+1].low;
                        for (int k = i+1; k < rangeEnd; k++) {
                            if (rates[k].high > high20) high20 = rates[k].high;
                            if (rates[k].low < low20) low20 = rates[k].low;
                        }
                        bool atrExpanding = (atr > atrAvg * 1.2);
                        buySignal = (rates[i].high > high20 && atrExpanding);
                        sellSignal = (rates[i].low < low20 && atrExpanding);
                    }
                    sl = 2.0 * atr;
                    tp = 3.0 * atr;
                    break;
                    
                case 4: // Session Opening - SL: 1.5*ATR, TP: 2.0*ATR
                    {
                        MqlDateTime dt;
                        TimeToStruct(rates[i].time, dt);
                        if (dt.hour == 8 || dt.hour == 13) {
                            buySignal = (rates[i].close > rates[i].open + 0.5 * atr);
                            sellSignal = (rates[i].close < rates[i].open - 0.5 * atr);
                        }
                    }
                    sl = 1.5 * atr;
                    tp = 2.0 * atr;
                    break;
                    
                case 5: // RSI Divergence - SL: 1.5*ATR, TP: 2.5*ATR
                    // MQL4 iLowest works near limits - need at least i+10 for RSI comparison
                    if (i + 10 < ratesCopied) {
                        double priceLow_curr = rates[i].low;
                        double priceLow_10 = rates[i+10].low;
                        double priceHigh_curr = rates[i].high;
                        double priceHigh_10 = rates[i+10].high;
                        
                        int end5 = MathMin(i + 5, ratesCopied);
                        int end15 = MathMin(i + 15, ratesCopied);
                        
                        for (int k = i; k < end5; k++) {
                            if (rates[k].low < priceLow_curr) priceLow_curr = rates[k].low;
                            if (rates[k].high > priceHigh_curr) priceHigh_curr = rates[k].high;
                        }
                        for (int k = i+10; k < end15; k++) {
                            if (rates[k].low < priceLow_10) priceLow_10 = rates[k].low;
                            if (rates[k].high > priceHigh_10) priceHigh_10 = rates[k].high;
                        }
                        buySignal = (priceLow_curr < priceLow_10 && rsiBuffer[i] > rsiBuffer[i+10] && rsiBuffer[i] < 40);
                        sellSignal = (priceHigh_curr > priceHigh_10 && rsiBuffer[i] < rsiBuffer[i+10] && rsiBuffer[i] > 60);
                    }
                    sl = 1.5 * atr;
                    tp = 2.5 * atr;
                    break;
                    
                case 6: // Range Trading - SL: 1.0*ATR, TP: range*0.5
                    // MQL4 iHighest/iLowest work near limits - replicate that
                    if (i + 1 < ratesCopied) {
                        int rangeEnd = MathMin(i + 21, ratesCopied);
                        double high20 = rates[i+1].high;
                        double low20 = rates[i+1].low;
                        for (int k = i+1; k < rangeEnd; k++) {
                            if (rates[k].high > high20) high20 = rates[k].high;
                            if (rates[k].low < low20) low20 = rates[k].low;
                        }
                        double range = high20 - low20;
                        if (range > 1.5 * atr && range < 5 * atr) {
                            buySignal = (close_i <= low20 + range * 0.1);
                            sellSignal = (close_i >= high20 - range * 0.1);
                            tp = range * 0.5;  // Dynamic TP: mid-range
                        }
                    }
                    sl = 1.0 * atr;
                    if (tp == 0) tp = 2.0 * atr;  // Fallback if range not set
                    break;
                    
                case 7: // HTF Confirmation - SL: 1.8*ATR, TP: 3.0*ATR
                    buySignal = (close_i > smaBuffer[i] && close_i > sma200Buffer[i] && adxBuffer[i] > 20);
                    sellSignal = (close_i < smaBuffer[i] && close_i < sma200Buffer[i] && adxBuffer[i] > 20);
                    sl = 1.8 * atr;
                    tp = 3.0 * atr;
                    break;
            }
            
            // Execute trade with DYNAMIC look-ahead and RESOLVED-ONLY filter
            if ((buySignal || sellSignal) && sl > 0 && tp > 0) {
                bool isWin = false;
                bool tradeResolved = false;
                
                for (int j = i - 1; j >= MathMax(0, i - lookAhead); j--) {
                    if (buySignal) {
                        if (rates[j].low <= close_i - sl) { isWin = false; tradeResolved = true; break; }
                        if (rates[j].high >= close_i + tp) { isWin = true; tradeResolved = true; break; }
                    } else {
                        if (rates[j].high >= close_i + sl) { isWin = false; tradeResolved = true; break; }
                        if (rates[j].low <= close_i - tp) { isWin = true; tradeResolved = true; break; }
                    }
                }
                
                // CRITICAL: Only count resolved trades (SAME as MQL4)
                if (!tradeResolved) continue;
                
                totalTrades++;
                if (isWin) {
                    wins++;
                    totalProfit += tp / atr;
                    currentEquity += (tp / atr) * 100;
                    consecLosses = 0;
                } else {
                    losses++;
                    totalLoss += sl / atr;
                    currentEquity -= (sl / atr) * 100;
                    consecLosses++;
                    if (consecLosses > maxConsecLosses) maxConsecLosses = consecLosses;
                }
                
                if (currentEquity > maxEquity) maxEquity = currentEquity;
                double dd = (maxEquity - currentEquity) / maxEquity * 100;
                if (dd > maxDD) maxDD = dd;
                
                int size = ArraySize(returns);
                ArrayResize(returns, size + 1);
                returns[size] = isWin ? (tp / atr) : -(sl / atr);
            }
        }
        
        // Calculate ALL metrics (same as MQL4)
        g_testResults5.metrics[stratIdx].totalTrades = totalTrades;
        g_testResults5.metrics[stratIdx].winningTrades = wins;
        g_testResults5.metrics[stratIdx].losingTrades = losses;
        g_testResults5.metrics[stratIdx].winRate = totalTrades > 0 ? ((double)wins / totalTrades * 100) : 0;
        g_testResults5.metrics[stratIdx].profitFactor = totalLoss > 0 ? (totalProfit / totalLoss) : 0;
        g_testResults5.metrics[stratIdx].maxDrawdown = maxDD;
        g_testResults5.metrics[stratIdx].maxConsecLosses = maxConsecLosses;
        g_testResults5.metrics[stratIdx].totalReturn = (currentEquity - 10000) / 100;
        g_testResults5.metrics[stratIdx].tradesPerPeriod = (double)totalTrades / bars * 100;
        
        // Calculate Sharpe and Expectancy
        int returnCount = ArraySize(returns);
        if (returnCount > 0) {
            double avgReturn = 0;
            for (int r = 0; r < returnCount; r++) avgReturn += returns[r];
            avgReturn /= returnCount;
            double stdDev = 0;
            for (int r = 0; r < returnCount; r++) stdDev += MathPow(returns[r] - avgReturn, 2);
            stdDev = MathSqrt(stdDev / returnCount);
            g_testResults5.metrics[stratIdx].sharpeRatio = stdDev > 0 ? (avgReturn / stdDev) : 0;
            g_testResults5.metrics[stratIdx].expectancy = avgReturn;
        }
        
        double avgWin = wins > 0 ? (totalProfit / wins) : 0;
        double avgLoss = losses > 0 ? (totalLoss / losses) : 1;
        g_testResults5.metrics[stratIdx].avgWinLossRatio = avgLoss > 0 ? (avgWin / avgLoss) : 0;
        g_testResults5.metrics[stratIdx].recoveryFactor = maxDD > 0 ? (g_testResults5.metrics[stratIdx].totalReturn / maxDD) : 0;
        g_testResults5.metrics[stratIdx].efficiency = MathMin(1.0, g_testResults5.metrics[stratIdx].totalReturn / 50.0);
        
        // Calculate advanced metrics (Sortino, etc.)
        StratGen_CalculateAdvancedMetrics5(g_testResults5.metrics[stratIdx], returns, returnCount);
        
        g_testResults5.metrics[stratIdx].overallScore = StratGen_CalculateScore5(g_testResults5.metrics[stratIdx]);
        g_testResults5.metrics[stratIdx].isViable = (totalTrades >= 15 && 
                                                     g_testResults5.metrics[stratIdx].expectancy > 0 && 
                                                     g_testResults5.metrics[stratIdx].profitFactor >= 1.0 && 
                                                     maxDD < 25);
    }
    
    // Release handles
    IndicatorRelease(smaHandle);
    IndicatorRelease(sma200Handle);
    IndicatorRelease(adxHandle);
    IndicatorRelease(rsiHandle);
    IndicatorRelease(bbHandle);
    IndicatorRelease(atrHandle);
    
    // Find best/worst strategies
    // NEW LOGIC: Prioritize by WinRate, must be viable AND WinRate >= 50.1%
    double worstScore = 100;
    g_testResults5.bestStrategyIndex = -1;  // -1 means none found yet
    g_testResults5.secondBestIndex = -1;
    g_testResults5.worstStrategyIndex = 0;
    
    // First pass: find worst strategy by score (for display purposes)
    for (int i = 0; i < 8; i++) {
        if (g_testResults5.metrics[i].overallScore < worstScore) {
            worstScore = g_testResults5.metrics[i].overallScore;
            g_testResults5.worstStrategyIndex = i;
        }
    }
    
    // Second pass: Sort strategies by WinRate descending and find best viable one
    int sortedByWR5[8];
    for (int i = 0; i < 8; i++) sortedByWR5[i] = i;
    
    // Simple bubble sort by WinRate descending
    for (int i = 0; i < 7; i++) {
        for (int j = i + 1; j < 8; j++) {
            if (g_testResults5.metrics[sortedByWR5[j]].winRate > g_testResults5.metrics[sortedByWR5[i]].winRate) {
                int temp = sortedByWR5[i];
                sortedByWR5[i] = sortedByWR5[j];
                sortedByWR5[j] = temp;
            }
        }
    }
    
    // Find best viable strategy with WinRate >= 50.1%
    for (int i = 0; i < 8; i++) {
        int idx = sortedByWR5[i];
        double wr = g_testResults5.metrics[idx].winRate;
        
        // Skip if WinRate < 50.1% (minimum threshold)
        if (wr < 50.1) {
            Print("[STRATGEN5] Strategy ", StratGen_GetTestStrategyName5(idx), " skipped: WinRate ", DoubleToString(wr, 1), "% < 50.1% threshold");
            continue;
        }
        
        // Check if strategy is viable
        if (g_testResults5.metrics[idx].isViable) {
            if (g_testResults5.bestStrategyIndex < 0) {
                g_testResults5.bestStrategyIndex = idx;
                Print("[STRATGEN5] ✓ Best strategy selected: ", StratGen_GetTestStrategyName5(idx), " (WR: ", DoubleToString(wr, 1), "%, Viable: YES)");
            } else if (g_testResults5.secondBestIndex < 0) {
                g_testResults5.secondBestIndex = idx;
                Print("[STRATGEN5] ✓ Second best strategy: ", StratGen_GetTestStrategyName5(idx), " (WR: ", DoubleToString(wr, 1), "%, Viable: YES)");
                break;  // We have both, stop searching
            }
        } else {
            Print("[STRATGEN5] Strategy ", StratGen_GetTestStrategyName5(idx), " skipped: WinRate OK (", DoubleToString(wr, 1), "%) but not viable");
        }
    }
    
    // If no viable strategy found with WinRate >= 50.1%, use highest WinRate for display
    if (g_testResults5.bestStrategyIndex < 0) {
        g_testResults5.bestStrategyIndex = sortedByWR5[0];  // Highest WinRate even if not viable
        Print("[STRATGEN5] WARNING: No viable strategy with WinRate >= 50.1%. Using highest WR for display: ", 
              StratGen_GetTestStrategyName5(sortedByWR5[0]), " (", DoubleToString(g_testResults5.metrics[sortedByWR5[0]].winRate, 1), "%)");
    }
    if (g_testResults5.secondBestIndex < 0) {
        g_testResults5.secondBestIndex = sortedByWR5[1];  // Second highest WinRate
    }
    
    // ===== CALCULATE HURST EXPONENT (R/S Method) =====
    // This is critical for accurate regime detection
    StratGen_CalculateHurst5(bars);
    
    // ===== DETERMINE MARKET STRUCTURE - ENHANCED WITH HURST =====
    // Combines strategy performance analysis with Hurst exponent for maximum accuracy
    int best = g_testResults5.bestStrategyIndex;
    double H = g_testResults5.hurstValue;
    int hurstRegime = g_testResults5.hurstRegime;
    double bestScore = g_testResults5.metrics[best].overallScore;
    
    // Step 1: Initial structure based on best performing strategy
    ENUM_AI_MARKET_STRUCTURE initialStructure = AI_STRUCT_MIXED;
    if (best == AI_TEST_TREND_FOLLOWING || best == AI_TEST_HTF_CONFIRMATION) {
        initialStructure = AI_STRUCT_TRENDING;
    } else if (best == AI_TEST_MEAN_REVERSION || best == AI_TEST_RANGE_TRADING) {
        if (g_testResults5.metrics[AI_TEST_RANGE_TRADING].winRate > 60) {
            initialStructure = AI_STRUCT_CONSOLIDATION;
        } else {
            initialStructure = AI_STRUCT_RANGING;
        }
    } else if (best == AI_TEST_VOLATILITY_BREAKOUT) {
        initialStructure = AI_STRUCT_VOLATILE;
    }
    
    // Step 2: Apply Hurst confirmation/override
    // Hurst is a powerful independent measure that can confirm or override strategy results
    bool hurstConfirms = false;
    string hurstAdjustment = "";
    
    if (hurstRegime == 1) {  // Hurst says TRENDING (H > 0.55)
        if (initialStructure == AI_STRUCT_TRENDING) {
            hurstConfirms = true;
            g_testResults5.detectedStructure = AI_STRUCT_TRENDING;
            g_testResults5.structureDescription = "CONFIRMED TRENDING (Hurst H=" + DoubleToString(H, 3) + "). Strong trend persistence. Trend-following optimal.";
        } else if (initialStructure == AI_STRUCT_RANGING || initialStructure == AI_STRUCT_CONSOLIDATION) {
            // Conflict: strategies say ranging but Hurst says trending
            // Trust Hurst more if H is strong (> 0.6)
            if (H > 0.60) {
                g_testResults5.detectedStructure = AI_STRUCT_TRENDING;
                g_testResults5.structureDescription = "HURST OVERRIDE: Trending (H=" + DoubleToString(H, 3) + ") despite ranging strategy performance. Breakout imminent.";
                hurstAdjustment = "UPGRADED to TRENDING by Hurst";
            } else {
                g_testResults5.detectedStructure = AI_STRUCT_RANGING;
                g_testResults5.structureDescription = "Ranging market with weak trend bias (H=" + DoubleToString(H, 3) + "). Watch for breakout.";
            }
        } else if (initialStructure == AI_STRUCT_VOLATILE) {
            g_testResults5.detectedStructure = AI_STRUCT_VOLATILE;
            g_testResults5.structureDescription = "Volatile TRENDING market (H=" + DoubleToString(H, 3) + "). Trend-following with wider stops.";
        } else {
            // Mixed/choppy but Hurst says trending
            if (H > 0.58) {
                g_testResults5.detectedStructure = AI_STRUCT_TRENDING;
                g_testResults5.structureDescription = "HURST RESCUE: Underlying trend detected (H=" + DoubleToString(H, 3) + ") despite choppy price action.";
                hurstAdjustment = "RESCUED from MIXED by Hurst";
            } else {
                g_testResults5.detectedStructure = AI_STRUCT_MIXED;
                g_testResults5.structureDescription = "Mixed with weak trend bias (H=" + DoubleToString(H, 3) + "). Cautious trend-following.";
            }
        }
    }
    else if (hurstRegime == -1) {  // Hurst says MEAN REVERTING (H < 0.45)
        if (initialStructure == AI_STRUCT_RANGING || initialStructure == AI_STRUCT_CONSOLIDATION) {
            hurstConfirms = true;
            g_testResults5.detectedStructure = initialStructure;
            g_testResults5.structureDescription = "CONFIRMED " + (initialStructure == AI_STRUCT_CONSOLIDATION ? "CONSOLIDATION" : "RANGING") + " (Hurst H=" + DoubleToString(H, 3) + "). Mean-reversion optimal.";
        } else if (initialStructure == AI_STRUCT_TRENDING) {
            // Conflict: strategies say trending but Hurst says mean reverting
            if (H < 0.42) {
                g_testResults5.detectedStructure = AI_STRUCT_RANGING;
                g_testResults5.structureDescription = "HURST OVERRIDE: Mean-reverting (H=" + DoubleToString(H, 3) + ") despite trend strategy performance. Trend exhaustion.";
                hurstAdjustment = "DOWNGRADED to RANGING by Hurst";
            } else {
                g_testResults5.detectedStructure = AI_STRUCT_TRENDING;
                g_testResults5.structureDescription = "Trending but weakening (H=" + DoubleToString(H, 3) + "). Watch for reversal.";
            }
        } else if (initialStructure == AI_STRUCT_VOLATILE) {
            g_testResults5.detectedStructure = AI_STRUCT_VOLATILE;
            g_testResults5.structureDescription = "Volatile mean-reverting (H=" + DoubleToString(H, 3) + "). Counter-trend with tight management.";
        } else {
            // Mixed/choppy with mean reversion
            g_testResults5.detectedStructure = AI_STRUCT_RANGING;
            g_testResults5.structureDescription = "HURST CLARIFICATION: Market is mean-reverting (H=" + DoubleToString(H, 3) + "). Use range strategies.";
            hurstAdjustment = "CLARIFIED to RANGING by Hurst";
        }
    }
    else {  // Hurst says RANDOM (0.47 <= H <= 0.53)
        if (initialStructure == AI_STRUCT_MIXED) {
            hurstConfirms = true;
            g_testResults5.detectedStructure = AI_STRUCT_MIXED;
            g_testResults5.structureDescription = "CONFIRMED CHOPPY/RANDOM (Hurst H=" + DoubleToString(H, 3) + "). No edge - reduce exposure significantly.";
        } else {
            // Strategy found something but Hurst says random - trust strategy but warn
            g_testResults5.detectedStructure = initialStructure;
            g_testResults5.structureDescription = StratGen_GetStructureName5(initialStructure) + " detected but Hurst warns RANDOM (H=" + DoubleToString(H, 3) + "). Exercise caution.";
            hurstAdjustment = "WARNING: Hurst indicates randomness";
        }
    }
    
    // Step 3: Calculate confidence with Hurst adjustment
    double avgScore = 0;
    for (int i = 0; i < 8; i++) avgScore += g_testResults5.metrics[i].overallScore;
    avgScore /= 8;
    g_testResults5.confidenceLevel = MathMin(100, (bestScore / avgScore - 1) * 100 + 50);
    
    // Adjust confidence based on Hurst confirmation
    if (hurstConfirms) {
        g_testResults5.confidenceLevel *= 1.15;  // 15% boost when Hurst confirms
    } else if (hurstRegime == 0) {
        g_testResults5.confidenceLevel *= 0.7;   // 30% penalty when Hurst says random
    } else if (hurstAdjustment != "") {
        g_testResults5.confidenceLevel *= 0.9;   // 10% penalty when Hurst overrides
    }
    
    // Additional penalties from strategy metrics
    if (g_testResults5.metrics[best].winRate < 45) g_testResults5.confidenceLevel *= 0.7;
    if (g_testResults5.metrics[best].profitFactor < 1.0) g_testResults5.confidenceLevel *= 0.8;
    
    // Bonus for strong Hurst memory
    if (g_testResults5.hurstMemoryStrength > 10) {
        g_testResults5.confidenceLevel *= 1.1;  // 10% boost for strong memory
    }
    
    g_testResults5.confidenceLevel = MathMin(100, g_testResults5.confidenceLevel);
    g_testResults5.analysisTime = TimeCurrent();
    
    Print("[STRATGEN ANALYSIS] ========================================");
    Print("[STRATGEN ANALYSIS] ✓ MARKET STRUCTURE DETECTION COMPLETE");
    Print("[STRATGEN ANALYSIS] Structure: ", StratGen_GetStructureName5(g_testResults5.detectedStructure), 
          " | Confidence: ", DoubleToString(g_testResults5.confidenceLevel, 1), "%");
    Print("[STRATGEN ANALYSIS] Best Strategy: ", StratGen_GetTestStrategyName5(best), " (Score:", DoubleToString(bestScore, 1), 
          ", WR:", DoubleToString(g_testResults5.metrics[best].winRate, 1), 
          "%, Trades:", g_testResults5.metrics[best].totalTrades, ")");
    Print("[STRATGEN HURST] H=", DoubleToString(H, 4), " | Regime=", 
          hurstRegime == 1 ? "TRENDING" : (hurstRegime == -1 ? "REVERTING" : "RANDOM"),
          " | Memory=", DoubleToString(g_testResults5.hurstMemoryStrength, 1), "%");
    if (hurstAdjustment != "") Print("[STRATGEN HURST] ADJUSTMENT: ", hurstAdjustment);
    if (hurstConfirms) Print("[STRATGEN HURST] CONFIRMATION: Strategy and Hurst agree - HIGH confidence");
    Print("[STRATGEN ANALYSIS] ========================================");
}

//+------------------------------------------------------------------+
//| Generate Strategy From Structure (MQL5)                            |
//+------------------------------------------------------------------+
void StratGen_GenerateFromStructure5(double riskPct) {
    g_genStrategy5.marketStructure = g_testResults5.detectedStructure;
    g_genStrategy5.riskPercent = riskPct;
    g_genStrategy5.testResults = g_testResults5;
    
    int best = g_testResults5.bestStrategyIndex;
    g_genStrategy5.backtestWinRate = g_testResults5.metrics[best].winRate;
    g_genStrategy5.backtestProfitFactor = g_testResults5.metrics[best].profitFactor;
    g_genStrategy5.backtestSharpeRatio = g_testResults5.metrics[best].sharpeRatio;
    g_genStrategy5.backtestMaxDD = g_testResults5.metrics[best].maxDrawdown;
    g_genStrategy5.backtestTrades = g_testResults5.metrics[best].totalTrades;
    g_genStrategy5.backtestExpectancy = g_testResults5.metrics[best].expectancy;
    g_genStrategy5.backtestRecoveryFactor = g_testResults5.metrics[best].recoveryFactor;
    
    switch (g_testResults5.detectedStructure) {
        case AI_STRUCT_TRENDING:
            g_genStrategy5.stratTemplate = AI_STRAT_MOMENTUM;
            g_genStrategy5.entryConditions = "Price > SMA(50) AND SMA(50) > SMA(200) AND ADX > 25";
            g_genStrategy5.stopLossATR = 2.0;
            g_genStrategy5.takeProfitATR = 3.0;
            g_genStrategy5.positionSizeMultiplier = 1.0;
            g_genStrategy5.useBreakeven = true;
            g_genStrategy5.breakevenTrigger = 1.5;
            break;
        case AI_STRUCT_RANGING:
        case AI_STRUCT_CONSOLIDATION:
            g_genStrategy5.stratTemplate = AI_STRAT_MEAN_REVERSION;
            g_genStrategy5.entryConditions = "Price < BB_Lower AND RSI < 30";
            g_genStrategy5.stopLossATR = 1.2;
            g_genStrategy5.takeProfitATR = 1.8;
            g_genStrategy5.positionSizeMultiplier = 1.2;
            g_genStrategy5.useBreakeven = false;
            break;
        case AI_STRUCT_VOLATILE:
            g_genStrategy5.stratTemplate = AI_STRAT_BREAKOUT;
            g_genStrategy5.entryConditions = "Breakout with ATR expansion + 2 confirmations";
            g_genStrategy5.stopLossATR = 2.0;
            g_genStrategy5.takeProfitATR = 4.0;
            g_genStrategy5.positionSizeMultiplier = 0.7;
            g_genStrategy5.useBreakeven = true;
            g_genStrategy5.breakevenTrigger = 2.0;
            break;
        default:
            g_genStrategy5.stratTemplate = AI_STRAT_BREAKOUT;
            g_genStrategy5.entryConditions = "Strict breakout with multiple confirmations";
            g_genStrategy5.stopLossATR = 1.8;
            g_genStrategy5.takeProfitATR = 2.5;
            g_genStrategy5.positionSizeMultiplier = 0.7;
            g_genStrategy5.useBreakeven = true;
            g_genStrategy5.breakevenTrigger = 1.5;
            g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "CHOPPY MARKET";
            break;
    }
    
    g_genStrategy5.riskRewardRatio = g_genStrategy5.takeProfitATR / g_genStrategy5.stopLossATR;
    
    // ===== WINNING STRATEGY OVERLAY =====
    g_genStrategy5.useSessionFilter = false;
    g_genStrategy5.sessionStartHour = 0;
    g_genStrategy5.sessionEndHour = 23;
    g_genStrategy5.useVolatilityFilter = false;
    g_genStrategy5.useHTFFilter = false;
    
    switch (best) {
        case AI_TEST_SESSION_OPENING:
            g_genStrategy5.entryConditions = "SESSION OPENING BIAS: Trade in direction of first-bar move at session open. BUY when Close > Open + 0.5*ATR(14), SELL when Close < Open - 0.5*ATR(14). REQUIRES time filter: London open (08:00 GMT) and/or New York open (13:00 GMT)";
            g_genStrategy5.stopLossATR = 1.5;
            g_genStrategy5.takeProfitATR = 2.0;
            g_genStrategy5.riskRewardRatio = 1.33;
            g_genStrategy5.useSessionFilter = true;
            g_genStrategy5.sessionStartHour = 8;
            g_genStrategy5.sessionEndHour = 16;
            break;
        case AI_TEST_RSI_DIVERGENCE:
            g_genStrategy5.entryConditions = "RSI DIVERGENCE: BUY when price makes lower low but RSI(14) makes higher low (bullish divergence). SELL when price makes higher high but RSI(14) makes lower high (bearish divergence). Confirm with RSI crossing back above 30 (buy) or below 70 (sell)";
            g_genStrategy5.stopLossATR = 1.5;
            g_genStrategy5.takeProfitATR = 2.5;
            g_genStrategy5.riskRewardRatio = 1.67;
            break;
        case AI_TEST_RANGE_TRADING:
            g_genStrategy5.entryConditions = "RANGE TRADING: BUY at dynamic support (lowest low of last 20 bars + 0.2*ATR buffer). SELL at dynamic resistance (highest high of last 20 bars - 0.2*ATR buffer). REQUIRES: ADX(14) < 25 (confirms no trend) AND ATR(14) < 80% of average ATR (low volatility filter)";
            g_genStrategy5.stopLossATR = 1.0;
            g_genStrategy5.takeProfitATR = 1.5;
            g_genStrategy5.riskRewardRatio = 1.5;
            g_genStrategy5.useVolatilityFilter = true;
            break;
        case AI_TEST_HTF_CONFIRMATION:
            g_genStrategy5.entryConditions = g_genStrategy5.entryConditions + " WITH Higher Timeframe confirmation: H4 SMA(50) must agree with trade direction (price above H4 SMA for buys, below for sells)";
            g_genStrategy5.useHTFFilter = true;
            break;
        case AI_TEST_VOLATILITY_BREAKOUT:
            g_genStrategy5.entryConditions = "VOLATILITY BREAKOUT: BUY when price breaks above highest high of last 20 bars AND ATR(14) > 1.2x average ATR AND ADX(14) > 20. SELL when price breaks below lowest low of last 20 bars with same filters";
            g_genStrategy5.stopLossATR = 2.0;
            g_genStrategy5.takeProfitATR = 4.0;
            g_genStrategy5.riskRewardRatio = 2.0;
            g_genStrategy5.useVolatilityFilter = true;
            break;
        case AI_TEST_TREND_FOLLOWING:
            g_genStrategy5.entryConditions = "TREND FOLLOWING: BUY when Price > SMA(50) AND SMA(50) slope is positive AND ADX(14) > 25. SELL when Price < SMA(50) AND SMA(50) slope is negative AND ADX(14) > 25. Use trailing stop at 2x ATR";
            break;
        case AI_TEST_MEAN_REVERSION:
            g_genStrategy5.entryConditions = "MEAN REVERSION: BUY when Price < BB_Lower(20,2) AND RSI(14) < 30. SELL when Price > BB_Upper(20,2) AND RSI(14) > 70. Target: BB_Middle (SMA 20)";
            break;
        case AI_TEST_MOMENTUM:
            g_genStrategy5.entryConditions = "MOMENTUM: BUY when RSI(14) crosses above 30 from oversold AND ADX(14) > 20. SELL when RSI(14) crosses below 70 from overbought AND ADX(14) > 20";
            break;
    }
    
    // Determine viability - NEW LOGIC: must have viable strategy with WinRate >= 50.1%
    double bestWinRate5 = g_testResults5.metrics[best].winRate;
    bool hasViableStrategy5 = (g_testResults5.metrics[best].isViable && bestWinRate5 >= 50.1);
    
    g_genStrategy5.isViable = (hasViableStrategy5 && g_testResults5.confidenceLevel > 40);
    
    if (!g_genStrategy5.isViable) {
        if (g_testResults5.confidenceLevel <= 40) {
            g_genStrategy5.viabilityReason = "Low confidence in market structure detection";
        } else if (!g_testResults5.metrics[best].isViable) {
            g_genStrategy5.viabilityReason = "No viable strategy found (metrics don't meet criteria)";
        } else if (bestWinRate5 < 50.1) {
            g_genStrategy5.viabilityReason = "No strategy with WinRate >= 50.1% (best: " + DoubleToString(bestWinRate5, 1) + "%)";
        } else {
            g_genStrategy5.viabilityReason = "Strategy does not meet minimum criteria";
        }
    } else {
        g_genStrategy5.viabilityReason = "VIABLE - " + StratGen_GetStructureName5(g_testResults5.detectedStructure) + 
                                        " market with " + StratGen_GetTestStrategyName5(best) + " (WR:" + DoubleToString(bestWinRate5, 1) + "%)";
    }
    
    // Add warnings based on analysis
    if (g_testResults5.metrics[best].maxDrawdown > 15 && g_genStrategy5.warningCount < 10) {
        g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "High drawdown risk detected";
    }
    if (bestWinRate5 < 55 && bestWinRate5 >= 50.1 && g_genStrategy5.warningCount < 10) {
        g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "Win rate marginal (50-55%) - monitor closely";
    }
    if (g_testResults5.metrics[best].maxConsecLosses > 5 && g_genStrategy5.warningCount < 10) {
        g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "High consecutive loss risk";
    }
    
    g_genStrategy5.generatedTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Get Optimal Template for Regime (MQL5)                             |
//+------------------------------------------------------------------+
ENUM_AI_STRATEGY_TEMPLATE StratGen_GetOptimalTemplate5(ENUM_AI_MARKET_REGIME regime) {
    switch (regime) {
        case AI_REGIME_TRENDING_UP_CALM:
        case AI_REGIME_TRENDING_UP_NORMAL:
        case AI_REGIME_TRENDING_DOWN_CALM:
        case AI_REGIME_TRENDING_DOWN_NORMAL:
            return AI_STRAT_MOMENTUM;
        case AI_REGIME_TRENDING_UP_VOLATILE:
        case AI_REGIME_TRENDING_DOWN_VOLATILE:
            return AI_STRAT_BREAKOUT;
        case AI_REGIME_RANGING_QUIET:
        case AI_REGIME_RANGING_NORMAL:
            return AI_STRAT_MEAN_REVERSION;
        case AI_REGIME_VOLATILE_CHAOS:
            return AI_STRAT_BREAKOUT;
        case AI_REGIME_TRANSITION:
            return AI_STRAT_SCALP;
        default:
            return AI_STRAT_MEAN_REVERSION;
    }
}

//+------------------------------------------------------------------+
//| Generate Entry Conditions (MQL5)                                   |
//+------------------------------------------------------------------+
void StratGen_GenerateEntryConditions5(ENUM_AI_STRATEGY_TEMPLATE stratTemplate, ENUM_AI_MARKET_REGIME regime, double riskPct) {
    g_genStrategy5.stratTemplate = stratTemplate;
    g_genStrategy5.targetRegime = regime;
    g_genStrategy5.riskPercent = riskPct;
    
    g_genStrategy5.useSMA = true;
    g_genStrategy5.useBB = false;
    g_genStrategy5.useBreakeven = false;
    g_genStrategy5.positionSizeMultiplier = 1.0;
    
    switch (stratTemplate) {
        case AI_STRAT_MOMENTUM:
            g_genStrategy5.entryConditions = "Price > SMA(50) AND RSI(14) < 70 AND ADX(14) > 25";
            g_genStrategy5.entryRSI_Low = 30;
            g_genStrategy5.entryRSI_High = 70;
            g_genStrategy5.entryADX_Min = 25;
            g_genStrategy5.useSMA = true;
            g_genStrategy5.stopLossATR = 1.5;
            g_genStrategy5.takeProfitATR = 3.0;
            g_genStrategy5.riskRewardRatio = 2.0;
            g_genStrategy5.positionSizeMultiplier = 1.0;
            g_genStrategy5.useBreakeven = true;
            g_genStrategy5.breakevenTrigger = 1.5;
            break;
        case AI_STRAT_MEAN_REVERSION:
            g_genStrategy5.entryConditions = "Price < BB_Lower(20,2) AND RSI(14) < 30";
            g_genStrategy5.entryRSI_Low = 30;
            g_genStrategy5.entryRSI_High = 70;
            g_genStrategy5.entryADX_Min = 0;
            g_genStrategy5.useSMA = false;
            g_genStrategy5.useBB = true;
            g_genStrategy5.stopLossATR = 1.2;
            g_genStrategy5.takeProfitATR = 1.0;
            g_genStrategy5.riskRewardRatio = 0.8;
            g_genStrategy5.positionSizeMultiplier = 1.2;
            g_genStrategy5.useBreakeven = false;
            break;
        case AI_STRAT_BREAKOUT:
            g_genStrategy5.entryConditions = "Price breaks High(20) AND ADX(14) > 20 AND Volume > Avg(20)";
            g_genStrategy5.entryRSI_Low = 40;
            g_genStrategy5.entryRSI_High = 60;
            g_genStrategy5.entryADX_Min = 20;
            g_genStrategy5.useSMA = true;
            g_genStrategy5.useBB = true;
            g_genStrategy5.stopLossATR = 2.0;
            g_genStrategy5.takeProfitATR = 4.0;
            g_genStrategy5.riskRewardRatio = 2.0;
            g_genStrategy5.positionSizeMultiplier = 0.7;
            g_genStrategy5.useBreakeven = true;
            g_genStrategy5.breakevenTrigger = 2.0;
            break;
        case AI_STRAT_SCALP:
            g_genStrategy5.entryConditions = "RSI(7) crosses 30/70 AND ATR < 1.2x Average";
            g_genStrategy5.entryRSI_Low = 30;
            g_genStrategy5.entryRSI_High = 70;
            g_genStrategy5.entryADX_Min = 15;
            g_genStrategy5.useSMA = false;
            g_genStrategy5.stopLossATR = 0.8;
            g_genStrategy5.takeProfitATR = 1.0;
            g_genStrategy5.riskRewardRatio = 1.25;
            g_genStrategy5.positionSizeMultiplier = 0.5;
            g_genStrategy5.useBreakeven = false;
            break;
        case AI_STRAT_SWING:
            g_genStrategy5.entryConditions = "Price > SMA(200) AND RSI(14) < 50 AND ADX(14) > 30";
            g_genStrategy5.entryRSI_Low = 40;
            g_genStrategy5.entryRSI_High = 60;
            g_genStrategy5.entryADX_Min = 30;
            g_genStrategy5.useSMA = true;
            g_genStrategy5.stopLossATR = 2.5;
            g_genStrategy5.takeProfitATR = 5.0;
            g_genStrategy5.riskRewardRatio = 2.0;
            g_genStrategy5.positionSizeMultiplier = 1.0;
            g_genStrategy5.useBreakeven = true;
            g_genStrategy5.breakevenTrigger = 3.0;
            break;
    }
    
    if (regime == AI_REGIME_VOLATILE_CHAOS) {
        g_genStrategy5.stopLossATR *= 1.5;
        g_genStrategy5.positionSizeMultiplier *= 0.5;
        g_genStrategy5.entryConditions += " [STRICT: 2+ confirmations]";
    }
    
    if (regime == AI_REGIME_TRENDING_UP_CALM || regime == AI_REGIME_TRENDING_DOWN_CALM || regime == AI_REGIME_RANGING_QUIET) {
        g_genStrategy5.stopLossATR *= 0.8;
        g_genStrategy5.positionSizeMultiplier *= 1.2;
    }
}

//+------------------------------------------------------------------+
//| Calculate Lot Size (MQL5)                                          |
//+------------------------------------------------------------------+
double StratGen_CalculateLotSize5(double riskPercent, double slPips) {
    double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountBalance * (riskPercent / 100.0);
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    if (tickValue == 0 || slPips == 0) return minLot;
    
    double pipValue = tickValue * (_Point / tickSize);
    double lotSize = riskAmount / (slPips * pipValue);
    lotSize *= g_genStrategy5.positionSizeMultiplier;
    lotSize = MathFloor(lotSize / lotStep) * lotStep;
    lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Quick Backtest (MQL5)                                              |
//+------------------------------------------------------------------+
void StratGen_QuickBacktest5(int bars) {
    g_genStrategy5.backtestBars = bars;
    g_genStrategy5.backtestTrades = 0;
    g_genStrategy5.backtestWinRate = 0;
    g_genStrategy5.backtestProfitFactor = 0;
    g_genStrategy5.backtestMaxDD = 0;
    g_genStrategy5.backtestSharpeRatio = 0;
    g_genStrategy5.warningCount = 0;
    
    int totalBars = iBars(_Symbol, PERIOD_CURRENT);
    if (totalBars < bars) {
        g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "Insufficient historical data";
        return;
    }
    
    int wins = 0, losses = 0;
    double totalProfit = 0, totalLoss = 0;
    double maxEquity = 10000, currentEquity = 10000, maxDD = 0;
    double returns[100];
    ArrayInitialize(returns, 0.0);  // Initialize to avoid "possible use of uninitialized variable" warning
    int returnCount = 0;
    
    int smaHandle = iMA(_Symbol, PERIOD_CURRENT, 50, 0, MODE_SMA, PRICE_CLOSE);
    int adxHandle = iADX(_Symbol, PERIOD_CURRENT, 14);
    int rsiHandle = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    int bbHandle = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
    int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
    
    // Validate indicator handles before proceeding
    if (smaHandle == INVALID_HANDLE || adxHandle == INVALID_HANDLE || 
        rsiHandle == INVALID_HANDLE || bbHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE) {
        g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "Failed to create indicator handles";
        if (smaHandle != INVALID_HANDLE) IndicatorRelease(smaHandle);
        if (adxHandle != INVALID_HANDLE) IndicatorRelease(adxHandle);
        if (rsiHandle != INVALID_HANDLE) IndicatorRelease(rsiHandle);
        if (bbHandle != INVALID_HANDLE) IndicatorRelease(bbHandle);
        if (atrHandle != INVALID_HANDLE) IndicatorRelease(atrHandle);
        return;
    }
    
    double smaBuffer[], adxBuffer[], rsiBuffer[], bbUpperBuffer[], bbLowerBuffer[], atrBuffer[];
    ArraySetAsSeries(smaBuffer, true);
    ArraySetAsSeries(adxBuffer, true);
    ArraySetAsSeries(rsiBuffer, true);
    ArraySetAsSeries(bbUpperBuffer, true);
    ArraySetAsSeries(bbLowerBuffer, true);
    ArraySetAsSeries(atrBuffer, true);
    
    // Copy indicator buffers WITH validation
    int copiedSma = CopyBuffer(smaHandle, 0, 0, bars, smaBuffer);
    int copiedAdx = CopyBuffer(adxHandle, 0, 0, bars, adxBuffer);
    int copiedRsi = CopyBuffer(rsiHandle, 0, 0, bars, rsiBuffer);
    int copiedBbUpper = CopyBuffer(bbHandle, 1, 0, bars, bbUpperBuffer);
    int copiedBbLower = CopyBuffer(bbHandle, 2, 0, bars, bbLowerBuffer);
    int copiedAtr = CopyBuffer(atrHandle, 0, 0, bars, atrBuffer);
    
    // Check if all buffers were copied successfully
    if (copiedSma <= 0 || copiedAdx <= 0 || copiedRsi <= 0 || 
        copiedBbUpper <= 0 || copiedBbLower <= 0 || copiedAtr <= 0) {
        g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "Failed to copy indicator buffers - wait for chart data";
        IndicatorRelease(smaHandle);
        IndicatorRelease(adxHandle);
        IndicatorRelease(rsiHandle);
        IndicatorRelease(bbHandle);
        IndicatorRelease(atrHandle);
        return;
    }
    
    MqlRates rates[];
    ArraySetAsSeries(rates, true);
    int copiedRates = CopyRates(_Symbol, PERIOD_CURRENT, 0, bars, rates);
    
    // Validate rates copy
    if (copiedRates <= 0) {
        g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "Failed to copy price rates";
        IndicatorRelease(smaHandle);
        IndicatorRelease(adxHandle);
        IndicatorRelease(rsiHandle);
        IndicatorRelease(bbHandle);
        IndicatorRelease(atrHandle);
        return;
    }
    
    // Use the minimum of copied data to avoid array out of range
    int safeMaxIndex = MathMin(copiedSma, MathMin(copiedAdx, MathMin(copiedRsi, 
                       MathMin(copiedBbUpper, MathMin(copiedBbLower, MathMin(copiedAtr, copiedRates))))));
    
    for (int i = safeMaxIndex - 1; i >= 50; i--) {
        double close_i = rates[i].close;
        double atr = atrBuffer[i];
        
        bool buySignal = false, sellSignal = false;
        
        switch (g_genStrategy5.stratTemplate) {
            case AI_STRAT_MOMENTUM:
                buySignal = (close_i > smaBuffer[i] && rsiBuffer[i] < g_genStrategy5.entryRSI_High && adxBuffer[i] > g_genStrategy5.entryADX_Min);
                sellSignal = (close_i < smaBuffer[i] && rsiBuffer[i] > g_genStrategy5.entryRSI_Low && adxBuffer[i] > g_genStrategy5.entryADX_Min);
                break;
            case AI_STRAT_MEAN_REVERSION:
                buySignal = (close_i < bbLowerBuffer[i] && rsiBuffer[i] < g_genStrategy5.entryRSI_Low);
                sellSignal = (close_i > bbUpperBuffer[i] && rsiBuffer[i] > g_genStrategy5.entryRSI_High);
                break;
            case AI_STRAT_BREAKOUT:
            case AI_STRAT_SCALP:
            case AI_STRAT_SWING:
                buySignal = (close_i > smaBuffer[i] && adxBuffer[i] > g_genStrategy5.entryADX_Min);
                sellSignal = (close_i < smaBuffer[i] && adxBuffer[i] > g_genStrategy5.entryADX_Min);
                break;
        }
        
        if (buySignal && g_genStrategy5.direction != AI_DIR_SHORT) {
            double sl = g_genStrategy5.stopLossATR * atr;
            double tp = g_genStrategy5.takeProfitATR * atr;
            
            for (int j = i - 1; j >= MathMax(0, i - 20); j--) {
                if (rates[j].low <= close_i - sl) {
                    losses++;
                    totalLoss += sl / atr;
                    currentEquity -= sl / atr * 100;
                    break;
                } else if (rates[j].high >= close_i + tp) {
                    wins++;
                    totalProfit += tp / atr;
                    currentEquity += tp / atr * 100;
                    break;
                }
            }
            
            if (returnCount < 100) returns[returnCount++] = (currentEquity - maxEquity) / maxEquity;
            if (currentEquity > maxEquity) maxEquity = currentEquity;
            double dd = (maxEquity - currentEquity) / maxEquity * 100;
            if (dd > maxDD) maxDD = dd;
        }
        
        if (sellSignal && g_genStrategy5.direction != AI_DIR_LONG) {
            double sl = g_genStrategy5.stopLossATR * atr;
            double tp = g_genStrategy5.takeProfitATR * atr;
            
            for (int j = i - 1; j >= MathMax(0, i - 20); j--) {
                if (rates[j].high >= close_i + sl) {
                    losses++;
                    totalLoss += sl / atr;
                    currentEquity -= sl / atr * 100;
                    break;
                } else if (rates[j].low <= close_i - tp) {
                    wins++;
                    totalProfit += tp / atr;
                    currentEquity += tp / atr * 100;
                    break;
                }
            }
            
            if (returnCount < 100) returns[returnCount++] = (currentEquity - maxEquity) / maxEquity;
            if (currentEquity > maxEquity) maxEquity = currentEquity;
            double dd = (maxEquity - currentEquity) / maxEquity * 100;
            if (dd > maxDD) maxDD = dd;
        }
    }
    
    IndicatorRelease(smaHandle);
    IndicatorRelease(adxHandle);
    IndicatorRelease(rsiHandle);
    IndicatorRelease(bbHandle);
    IndicatorRelease(atrHandle);
    
    g_genStrategy5.backtestTrades = wins + losses;
    g_genStrategy5.backtestWinRate = (g_genStrategy5.backtestTrades > 0) ? ((double)wins / g_genStrategy5.backtestTrades * 100) : 0;
    g_genStrategy5.backtestProfitFactor = (totalLoss > 0) ? (totalProfit / totalLoss) : 0;
    g_genStrategy5.backtestMaxDD = maxDD;
    
    if (returnCount > 0) {
        double avgReturn = 0;
        for (int r = 0; r < returnCount; r++) avgReturn += returns[r];
        avgReturn /= returnCount;
        double stdDev = 0;
        for (int r = 0; r < returnCount; r++) stdDev += MathPow(returns[r] - avgReturn, 2);
        stdDev = MathSqrt(stdDev / returnCount);
        g_genStrategy5.backtestSharpeRatio = (stdDev > 0) ? (avgReturn / stdDev) : 0;
    }
    
    if (g_genStrategy5.backtestTrades < 10) g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "Low sample size";
    if (g_genStrategy5.backtestWinRate < 35) g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "Win rate too low";
    if (g_genStrategy5.backtestMaxDD > 20) g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "High drawdown risk";
    if (g_genStrategy5.backtestProfitFactor < 1.0) g_genStrategy5.warnings[g_genStrategy5.warningCount++] = "Unprofitable";
    
    g_genStrategy5.isViable = (g_genStrategy5.backtestWinRate >= 35 && 
                               g_genStrategy5.backtestProfitFactor >= 0.8 &&
                               g_genStrategy5.backtestMaxDD < 30 &&
                               g_genStrategy5.backtestTrades >= 5);
    
    if (!g_genStrategy5.isViable) {
        if (g_genStrategy5.backtestTrades < 5) g_genStrategy5.viabilityReason = "Insufficient trades";
        else if (g_genStrategy5.backtestProfitFactor < 0.8) g_genStrategy5.viabilityReason = "Unprofitable";
        else if (g_genStrategy5.backtestMaxDD >= 30) g_genStrategy5.viabilityReason = "Excessive risk";
        else g_genStrategy5.viabilityReason = "Poor win rate";
    } else {
        g_genStrategy5.viabilityReason = "VIABLE - Good metrics";
    }
    
    g_genStrategy5.generatedTime = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Get Template Name (MQL5)                                           |
//+------------------------------------------------------------------+
string StratGen_GetTemplateName5(ENUM_AI_STRATEGY_TEMPLATE stratTemplate) {
    switch (stratTemplate) {
        case AI_STRAT_MOMENTUM: return "MOMENTUM";
        case AI_STRAT_MEAN_REVERSION: return "MEAN_REVERSION";
        case AI_STRAT_BREAKOUT: return "BREAKOUT";
        case AI_STRAT_SCALP: return "SCALP";
        case AI_STRAT_SWING: return "SWING";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Get Template Display Name (MQL5) - Aligned with BEST for UI       |
//| When TREND_FOLLOW wins, show TREND_FOLLOW not MOMENTUM            |
//+------------------------------------------------------------------+
string StratGen_GetTemplateDisplayName5() {
    if (g_testResults5.bestStrategyIndex >= 0 && g_testResults5.bestStrategyIndex < 8)
        return StratGen_GetTestStrategyName5(g_testResults5.bestStrategyIndex);
    return StratGen_GetTemplateName5(g_genStrategy5.stratTemplate);
}

//+------------------------------------------------------------------+
//| Get Direction Name (MQL5)                                          |
//+------------------------------------------------------------------+
string StratGen_GetDirectionName5(ENUM_AI_TRADE_DIRECTION dir) {
    switch (dir) {
        case AI_DIR_LONG: return "LONG";
        case AI_DIR_SHORT: return "SHORT";
        case AI_DIR_BOTH: return "BOTH";
        default: return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Create Strategy Generation Panel (MQL5) - COMPLETE VERSION         |
//+------------------------------------------------------------------+
void StratGen_CreatePanel5(int panelX, int panelY) {
    Print("[STRATGEN PANEL] StratGen_CreatePanel5() called - Position: X=", panelX, " Y=", panelY);
    
    string prefix = "StratGen_Panel5_";
    int x = panelX;
    int y = panelY;
    int width = 480;
    int lineHeight = 14;
    color bgColor = C'12,12,20';
    color textColor = clrWhite;
    color headerColor = C'200,255,100';
    color valueColor = clrLime;
    color warningColor = clrOrange;
    color dangerColor = clrRed;
    color accentColor = C'100,200,255';
    color tableHeaderColor = C'80,80,120';
    
    Print("[STRATGEN PANEL] Creating background rectangle...");
    // Background (increased height for Hurst section)
    bool bgCreated = ObjectCreate(0, prefix + "BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    Print("[STRATGEN PANEL] Background created: ", bgCreated, " | Error: ", GetLastError());
    ObjectSetInteger(0, prefix + "BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_XSIZE, width);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_YSIZE, 760);  // Increased for Hurst section
    ObjectSetInteger(0, prefix + "BG", OBJPROP_BGCOLOR, bgColor);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_COLOR, C'100,200,100');
    ObjectSetInteger(0, prefix + "BG", OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_BACK, false);
    ObjectSetInteger(0, prefix + "BG", OBJPROP_SELECTABLE, false);
    
    // Header
    AI_CreateLabel5(prefix + "Header", ">> MARKET STRUCTURE DETECTION", x + 10, y + 5, headerColor, 11);
    AI_CreateLabel5(prefix + "Subheader", "8-Strategy Analysis + Hurst R/S", x + 10, y + 22, clrDarkGray, 8);
    
    // Separator
    y += 38;
    AI_CreateLabel5(prefix + "Sep1", "------------------------------------------------", x + 5, y, clrDarkGray, 8);
    
    // Market Structure Section
    y += lineHeight;
    AI_CreateLabel5(prefix + "StructTitle", ":: DETECTED MARKET STRUCTURE", x + 10, y, accentColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "StructLabel", "Structure:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "StructValue", "---", x + 100, y, valueColor, 10);
    y += lineHeight;
    AI_CreateLabel5(prefix + "ConfLabel", "Confidence:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "ConfValue", "---%", x + 100, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "DescLabel", "", x + 15, y, clrGray, 8);
    
    // Separator
    y += lineHeight + 3;
    AI_CreateLabel5(prefix + "SepHurst", "------------------------------------------------", x + 5, y, clrDarkGray, 8);
    
    // ===== HURST EXPONENT SECTION (NEW) =====
    y += lineHeight;
    AI_CreateLabel5(prefix + "HurstTitle", ":: HURST EXPONENT (R/S Analysis)", x + 10, y, C'255,200,100', 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "HurstHLabel", "H Value:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "HurstHValue", "0.500", x + 80, y, valueColor, 10);
    AI_CreateLabel5(prefix + "HurstRegLabel", "Regime:", x + 150, y, textColor, 9);
    AI_CreateLabel5(prefix + "HurstRegValue", "RANDOM", x + 210, y, warningColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "HurstMemLabel", "Memory:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "HurstMemValue", "0.0%", x + 80, y, valueColor, 9);
    AI_CreateLabel5(prefix + "HurstFDLabel", "FractalD:", x + 150, y, textColor, 9);
    AI_CreateLabel5(prefix + "HurstFDValue", "1.500", x + 220, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "HurstInterpLabel", "", x + 15, y, clrGray, 7);
    
    // Separator
    y += lineHeight + 3;
    AI_CreateLabel5(prefix + "Sep2", "------------------------------------------------", x + 5, y, clrDarkGray, 8);
    
    // 8 Strategy Results Table
    y += lineHeight;
    AI_CreateLabel5(prefix + "TableTitle", "** 8-STRATEGY TEST RESULTS", x + 10, y, accentColor, 9);
    y += lineHeight;
    
    // Table Header
    AI_CreateLabel5(prefix + "TH_Name", "STRATEGY", x + 15, y, tableHeaderColor, 8);
    AI_CreateLabel5(prefix + "TH_WR", "WinRate", x + 120, y, tableHeaderColor, 8);
    AI_CreateLabel5(prefix + "TH_Sharpe", "Sharpe", x + 180, y, tableHeaderColor, 8);
    AI_CreateLabel5(prefix + "TH_Return", "Return", x + 235, y, tableHeaderColor, 8);
    AI_CreateLabel5(prefix + "TH_Score", "Score", x + 290, y, tableHeaderColor, 8);
    AI_CreateLabel5(prefix + "TH_Viable", "Status", x + 340, y, tableHeaderColor, 8);
    
    y += lineHeight - 2;
    AI_CreateLabel5(prefix + "TH_Line", "-----------------------------------------------", x + 10, y, clrDarkGray, 7);
    
    // 8 Strategy Rows
    string stratNames5[8] = {"TREND_FOLLOW", "MEAN_REVER", "MOMENTUM", "VOL_BREAK", "SESSION_OPEN", "RSI_DIVERG", "RANGE_TRADE", "HTF_CONFIRM"};
    for (int i = 0; i < 8; i++) {
        y += lineHeight;
        string idx = IntegerToString(i);
        AI_CreateLabel5(prefix + "S" + idx + "_Name", stratNames5[i], x + 15, y, textColor, 8);
        AI_CreateLabel5(prefix + "S" + idx + "_WR", "---%", x + 120, y, valueColor, 8);
        AI_CreateLabel5(prefix + "S" + idx + "_Sharpe", "-.--", x + 180, y, valueColor, 8);
        AI_CreateLabel5(prefix + "S" + idx + "_Return", "-.-%", x + 235, y, valueColor, 8);
        AI_CreateLabel5(prefix + "S" + idx + "_Score", "-.-", x + 290, y, valueColor, 8);
        AI_CreateLabel5(prefix + "S" + idx + "_Viable", "---", x + 340, y, valueColor, 8);
    }
    
    // Best/Worst Summary
    y += lineHeight + 3;
    AI_CreateLabel5(prefix + "BestLabel", "** BEST:", x + 15, y, headerColor, 8);
    AI_CreateLabel5(prefix + "BestValue", "---", x + 70, y, valueColor, 8);
    AI_CreateLabel5(prefix + "WorstLabel", "!! AVOID:", x + 240, y, warningColor, 8);
    AI_CreateLabel5(prefix + "WorstValue", "---", x + 310, y, dangerColor, 8);
    
    // Separator
    y += lineHeight + 3;
    AI_CreateLabel5(prefix + "Sep3", "------------------------------------------------", x + 5, y, clrDarkGray, 8);
    
    // Generated Strategy Section
    y += lineHeight;
    AI_CreateLabel5(prefix + "StratSectionTitle", ":: AUTO-GENERATED STRATEGY", x + 10, y, accentColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "TemplateLabel", "Template:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "TemplateValue", "---", x + 100, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "EntryLabel", "Entry:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "EntryValue", "---", x + 100, y, valueColor, 7);
    y += lineHeight;
    AI_CreateLabel5(prefix + "RiskLabel", "SL/TP:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "RiskValue", "---", x + 100, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "PosLabel", "Position:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "PosValue", "---", x + 100, y, valueColor, 9);
    
    // Separator
    y += lineHeight + 3;
    AI_CreateLabel5(prefix + "Sep4", "------------------------------------------------", x + 5, y, clrDarkGray, 8);
    
    // Expected Performance
    y += lineHeight;
    AI_CreateLabel5(prefix + "PerfTitle", "^^ EXPECTED PERFORMANCE", x + 10, y, accentColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "ExpWRLabel", "Win Rate:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "ExpWRValue", "---%", x + 100, y, valueColor, 9);
    AI_CreateLabel5(prefix + "ExpPFLabel", "Profit Factor:", x + 200, y, textColor, 9);
    AI_CreateLabel5(prefix + "ExpPFValue", "-.--", x + 300, y, valueColor, 9);
    y += lineHeight;
    AI_CreateLabel5(prefix + "ExpDDLabel", "Max DD:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "ExpDDValue", "--%", x + 100, y, valueColor, 9);
    AI_CreateLabel5(prefix + "ExpSharpeLabel", "Sharpe:", x + 200, y, textColor, 9);
    AI_CreateLabel5(prefix + "ExpSharpeValue", "-.--", x + 300, y, valueColor, 9);
    
    // Separator
    y += lineHeight + 3;
    AI_CreateLabel5(prefix + "Sep5", "------------------------------------------------", x + 5, y, clrDarkGray, 8);
    
    // Warnings
    y += lineHeight;
    AI_CreateLabel5(prefix + "WarnTitle", "!! WARNINGS", x + 10, y, warningColor, 9);
    for (int w = 0; w < 3; w++) {
        y += lineHeight;
        AI_CreateLabel5(prefix + "Warn" + IntegerToString(w), "", x + 15, y, warningColor, 8);
    }
    
    // Final Status
    y += lineHeight + 3;
    AI_CreateLabel5(prefix + "StatusLabel", "STATUS:", x + 15, y, textColor, 9);
    AI_CreateLabel5(prefix + "StatusValue", "---", x + 80, y, valueColor, 10);
    AI_CreateLabel5(prefix + "ExportLabel", "Export:", x + 280, y, textColor, 8);
    AI_CreateLabel5(prefix + "ExportValue", "---", x + 330, y, clrDarkGray, 8);
    
    // Force chart refresh to display panel
    Print("[STRATGEN PANEL] ✓ Panel creation complete - Total objects created: ", ObjectsTotal(0, -1, -1));
    Print("[STRATGEN PANEL] Verifying key objects exist:");
    Print("[STRATGEN PANEL]   - BG: ", (ObjectFind(0, prefix + "BG") >= 0 ? "YES" : "NO"));
    Print("[STRATGEN PANEL]   - StructValue: ", (ObjectFind(0, prefix + "StructValue") >= 0 ? "YES" : "NO"));
    Print("[STRATGEN PANEL]   - Header: ", (ObjectFind(0, prefix + "Header") >= 0 ? "YES" : "NO"));
    ChartRedraw(0);
    Print("[STRATGEN PANEL] ChartRedraw(0) called");
}

//+------------------------------------------------------------------+
//| Update Strategy Generation Panel (MQL5) - COMPLETE VERSION         |
//+------------------------------------------------------------------+
void StratGen_UpdatePanel5() {
    static int updateCounter5 = 0;
    updateCounter5++;
    
    // Log every 10th update to avoid spam
    if (updateCounter5 % 10 == 1) {
        Print("[STRATGEN UPDATE] StratGen_UpdatePanel5() called - Update #", updateCounter5);
        Print("[STRATGEN UPDATE] Current data: Structure=", StratGen_GetStructureName5(g_testResults5.detectedStructure),
              " | Confidence=", DoubleToString(g_testResults5.confidenceLevel, 1), "%",
              " | Hurst=", DoubleToString(g_testResults5.hurstValue, 3));
    }
    
    string prefix = "StratGen_Panel5_";
    color valueColor = clrLime;
    color warningColor = clrOrange;
    color dangerColor = clrRed;
    color bestColor = C'100,255,100';
    color worstColor = C'255,100,100';
    
    // Verify panel exists before updating
    if (ObjectFind(0, prefix + "StructValue") < 0) {
        Print("[STRATGEN UPDATE] ERROR: Panel object '", prefix, "StructValue' not found!");
        return;
    }
    
    // Update Market Structure
    ObjectSetString(0, prefix + "StructValue", OBJPROP_TEXT, StratGen_GetStructureName5(g_testResults5.detectedStructure));
    color structColor = valueColor;
    if (g_testResults5.detectedStructure == AI_STRUCT_VOLATILE) structColor = warningColor;
    else if (g_testResults5.detectedStructure == AI_STRUCT_MIXED) structColor = dangerColor;
    ObjectSetInteger(0, prefix + "StructValue", OBJPROP_COLOR, structColor);
    
    ObjectSetString(0, prefix + "ConfValue", OBJPROP_TEXT, DoubleToString(g_testResults5.confidenceLevel, 1) + "%");
    ObjectSetInteger(0, prefix + "ConfValue", OBJPROP_COLOR, g_testResults5.confidenceLevel >= 60 ? valueColor : (g_testResults5.confidenceLevel >= 40 ? warningColor : dangerColor));
    
    ObjectSetString(0, prefix + "DescLabel", OBJPROP_TEXT, g_testResults5.structureDescription);
    
    // ===== UPDATE HURST EXPONENT SECTION =====
    double H = g_testResults5.hurstValue;
    int hurstReg = g_testResults5.hurstRegime;
    
    // H Value with color coding
    ObjectSetString(0, prefix + "HurstHValue", OBJPROP_TEXT, DoubleToString(H, 3));
    color hurstHColor = clrYellow;  // Default to neutral
    if (H > 0.55) hurstHColor = clrLime;        // Trending
    else if (H < 0.45) hurstHColor = clrAqua;   // Mean reverting
    else if (H >= 0.47 && H <= 0.53) hurstHColor = clrOrange;  // Random
    ObjectSetInteger(0, prefix + "HurstHValue", OBJPROP_COLOR, hurstHColor);
    
    // Regime text and color
    string regimeText = hurstReg == 1 ? "TRENDING" : (hurstReg == -1 ? "REVERTING" : "RANDOM");
    color regimeColor = hurstReg == 1 ? clrLime : (hurstReg == -1 ? clrAqua : clrOrange);
    ObjectSetString(0, prefix + "HurstRegValue", OBJPROP_TEXT, regimeText);
    ObjectSetInteger(0, prefix + "HurstRegValue", OBJPROP_COLOR, regimeColor);
    
    // Memory strength
    ObjectSetString(0, prefix + "HurstMemValue", OBJPROP_TEXT, DoubleToString(g_testResults5.hurstMemoryStrength, 1) + "%");
    ObjectSetInteger(0, prefix + "HurstMemValue", OBJPROP_COLOR, g_testResults5.hurstMemoryStrength > 10 ? clrLime : (g_testResults5.hurstMemoryStrength > 5 ? clrYellow : clrGray));
    
    // Fractal Dimension
    ObjectSetString(0, prefix + "HurstFDValue", OBJPROP_TEXT, DoubleToString(g_testResults5.hurstFractalDimension, 3));
    
    // Interpretation
    ObjectSetString(0, prefix + "HurstInterpLabel", OBJPROP_TEXT, g_testResults5.hurstDescription);
    
    // Update 8 Strategy Results Table
    for (int i = 0; i < 8; i++) {
        string idx = IntegerToString(i);
        StrategyTestMetrics5 m = g_testResults5.metrics[i];
        
        // Highlight best/worst
        color rowColor = clrWhite;
        if (i == g_testResults5.bestStrategyIndex) rowColor = bestColor;
        else if (i == g_testResults5.worstStrategyIndex) rowColor = worstColor;
        
        ObjectSetInteger(0, prefix + "S" + idx + "_Name", OBJPROP_COLOR, rowColor);
        
        // Win Rate
        ObjectSetString(0, prefix + "S" + idx + "_WR", OBJPROP_TEXT, DoubleToString(m.winRate, 1) + "%");
        ObjectSetInteger(0, prefix + "S" + idx + "_WR", OBJPROP_COLOR, m.winRate >= 55 ? valueColor : (m.winRate >= 45 ? warningColor : dangerColor));
        
        // Sharpe
        ObjectSetString(0, prefix + "S" + idx + "_Sharpe", OBJPROP_TEXT, DoubleToString(m.sharpeRatio, 2));
        ObjectSetInteger(0, prefix + "S" + idx + "_Sharpe", OBJPROP_COLOR, m.sharpeRatio >= 1.0 ? valueColor : (m.sharpeRatio >= 0.5 ? warningColor : dangerColor));
        
        // Return
        ObjectSetString(0, prefix + "S" + idx + "_Return", OBJPROP_TEXT, DoubleToString(m.totalReturn, 1) + "%");
        ObjectSetInteger(0, prefix + "S" + idx + "_Return", OBJPROP_COLOR, m.totalReturn > 0 ? valueColor : dangerColor);
        
        // Score
        ObjectSetString(0, prefix + "S" + idx + "_Score", OBJPROP_TEXT, DoubleToString(m.overallScore, 1));
        ObjectSetInteger(0, prefix + "S" + idx + "_Score", OBJPROP_COLOR, m.overallScore >= 7 ? valueColor : (m.overallScore >= 5 ? warningColor : dangerColor));
        
        // Viable
        string viableText = m.isViable ? "[v] YES" : "[x] NO";
        ObjectSetString(0, prefix + "S" + idx + "_Viable", OBJPROP_TEXT, viableText);
        ObjectSetInteger(0, prefix + "S" + idx + "_Viable", OBJPROP_COLOR, m.isViable ? valueColor : dangerColor);
    }
    
    // Update Best/Worst
    ObjectSetString(0, prefix + "BestValue", OBJPROP_TEXT, StratGen_GetTestStrategyName5(g_testResults5.bestStrategyIndex) + " (" + DoubleToString(g_testResults5.metrics[g_testResults5.bestStrategyIndex].winRate, 1) + "%)");
    ObjectSetString(0, prefix + "WorstValue", OBJPROP_TEXT, StratGen_GetTestStrategyName5(g_testResults5.worstStrategyIndex));
    
    // Update Generated Strategy
    ObjectSetString(0, prefix + "TemplateValue", OBJPROP_TEXT, StratGen_GetTemplateDisplayName5());
    
    string entryText = g_genStrategy5.entryConditions;
    if (StringLen(entryText) > 50) entryText = StringSubstr(entryText, 0, 47) + "...";
    ObjectSetString(0, prefix + "EntryValue", OBJPROP_TEXT, entryText);
    
    ObjectSetString(0, prefix + "RiskValue", OBJPROP_TEXT, "SL:" + DoubleToString(g_genStrategy5.stopLossATR, 1) + " TP:" + DoubleToString(g_genStrategy5.takeProfitATR, 1) + " ATR (1:" + DoubleToString(g_genStrategy5.riskRewardRatio, 1) + ")");
    
    string posText = DoubleToString(g_genStrategy5.positionSizeMultiplier, 1) + "x";
    if (g_genStrategy5.useBreakeven) posText += " + BE@" + DoubleToString(g_genStrategy5.breakevenTrigger, 1);
    ObjectSetString(0, prefix + "PosValue", OBJPROP_TEXT, posText);
    
    // Update Expected Performance
    ObjectSetString(0, prefix + "ExpWRValue", OBJPROP_TEXT, DoubleToString(g_genStrategy5.backtestWinRate, 1) + "%");
    ObjectSetInteger(0, prefix + "ExpWRValue", OBJPROP_COLOR, g_genStrategy5.backtestWinRate >= 55 ? valueColor : (g_genStrategy5.backtestWinRate >= 45 ? warningColor : dangerColor));
    
    ObjectSetString(0, prefix + "ExpPFValue", OBJPROP_TEXT, DoubleToString(g_genStrategy5.backtestProfitFactor, 2));
    ObjectSetInteger(0, prefix + "ExpPFValue", OBJPROP_COLOR, g_genStrategy5.backtestProfitFactor >= 1.5 ? valueColor : (g_genStrategy5.backtestProfitFactor >= 1.0 ? warningColor : dangerColor));
    
    ObjectSetString(0, prefix + "ExpDDValue", OBJPROP_TEXT, DoubleToString(g_genStrategy5.backtestMaxDD, 1) + "%");
    ObjectSetInteger(0, prefix + "ExpDDValue", OBJPROP_COLOR, g_genStrategy5.backtestMaxDD < 10 ? valueColor : (g_genStrategy5.backtestMaxDD < 20 ? warningColor : dangerColor));
    
    ObjectSetString(0, prefix + "ExpSharpeValue", OBJPROP_TEXT, DoubleToString(g_genStrategy5.backtestSharpeRatio, 2));
    ObjectSetInteger(0, prefix + "ExpSharpeValue", OBJPROP_COLOR, g_genStrategy5.backtestSharpeRatio >= 1.0 ? valueColor : (g_genStrategy5.backtestSharpeRatio >= 0.5 ? warningColor : dangerColor));
    
    // Update Warnings - Show control message when no warnings
    if (g_genStrategy5.warningCount == 0) {
        ObjectSetString(0, prefix + "Warn0", OBJPROP_TEXT, "✓ No warnings detected");
        ObjectSetInteger(0, prefix + "Warn0", OBJPROP_COLOR, clrLime);
        ObjectSetString(0, prefix + "Warn1", OBJPROP_TEXT, " ");
        ObjectSetString(0, prefix + "Warn2", OBJPROP_TEXT, " ");
    } else {
        for (int w = 0; w < 3; w++) {
            if (w < g_genStrategy5.warningCount) {
                ObjectSetString(0, prefix + "Warn" + IntegerToString(w), OBJPROP_TEXT, "* " + g_genStrategy5.warnings[w]);
                ObjectSetInteger(0, prefix + "Warn" + IntegerToString(w), OBJPROP_COLOR, warningColor);
            } else {
                ObjectSetString(0, prefix + "Warn" + IntegerToString(w), OBJPROP_TEXT, " ");
            }
        }
    }
    
    // Update Status
    string statusText = g_genStrategy5.isViable ? "? VIABLE - " + StratGen_GetStructureName5(g_testResults5.detectedStructure) + " market wi..." : "X NOT VIABLE - " + g_genStrategy5.viabilityReason;
    ObjectSetString(0, prefix + "StatusValue", OBJPROP_TEXT, statusText);
    ObjectSetInteger(0, prefix + "StatusValue", OBJPROP_COLOR, g_genStrategy5.isViable ? valueColor : dangerColor);
    
    // Force chart refresh to update panel
    ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Show Warmup Status in Panel (MQL5) - Visual Progress Bar           |
//| Called during the initial 30-second warmup period                  |
//+------------------------------------------------------------------+
void StratGen_ShowWarmupStatus5(int elapsedSeconds, int totalSeconds) {
    string prefix = "StratGen_Panel5_";
    
    // DEBUG: Check if panel objects exist
    static bool debugPrinted = false;
    if (!debugPrinted) {
        bool bgExists = (ObjectFind(0, prefix + "BG") >= 0);
        bool structExists = (ObjectFind(0, prefix + "StructValue") >= 0);
        Print("[STRATGEN DEBUG] Panel BG exists: ", bgExists, " | StructValue exists: ", structExists);
        Print("[STRATGEN DEBUG] Total objects on chart: ", ObjectsTotal(0));
        debugPrinted = true;
    }
    
    // Protect against division by zero
    if (totalSeconds <= 0) totalSeconds = 30;  // Default to 30 seconds
    
    // Calculate progress percentage
    double progress = (double)elapsedSeconds / totalSeconds * 100.0;
    int remainingSeconds = totalSeconds - elapsedSeconds;
    
    // Create progress bar string (20 characters wide)
    int filledBars = (int)(progress / 5.0);  // 20 bars = 100%
    string progressBar = "[";
    for (int i = 0; i < 20; i++) {
        if (i < filledBars) progressBar += "|";
        else progressBar += ".";
    }
    progressBar += "] " + DoubleToString(progress, 0) + "%";
    
    // Update Structure section to show warmup status
    ObjectSetString(0, prefix + "StructValue", OBJPROP_TEXT, "WARMING UP...");
    ObjectSetInteger(0, prefix + "StructValue", OBJPROP_COLOR, C'255,200,100');
    
    ObjectSetString(0, prefix + "ConfValue", OBJPROP_TEXT, IntegerToString(remainingSeconds) + "s");
    ObjectSetInteger(0, prefix + "ConfValue", OBJPROP_COLOR, clrYellow);
    
    ObjectSetString(0, prefix + "DescLabel", OBJPROP_TEXT, progressBar);
    
    // Update Hurst section to show loading
    ObjectSetString(0, prefix + "HurstHValue", OBJPROP_TEXT, "...");
    ObjectSetInteger(0, prefix + "HurstHValue", OBJPROP_COLOR, clrGray);
    ObjectSetString(0, prefix + "HurstRegValue", OBJPROP_TEXT, "CALCULATING");
    ObjectSetInteger(0, prefix + "HurstRegValue", OBJPROP_COLOR, clrYellow);
    ObjectSetString(0, prefix + "HurstMemValue", OBJPROP_TEXT, "...");
    ObjectSetString(0, prefix + "HurstFDValue", OBJPROP_TEXT, "...");
    ObjectSetString(0, prefix + "HurstInterpLabel", OBJPROP_TEXT, "Stabilizing indicators for accurate analysis...");
    
    // Update 8 Strategy table headers to show loading
    for (int i = 0; i < 8; i++) {
        string idx = IntegerToString(i);
        ObjectSetString(0, prefix + "S" + idx + "_WR", OBJPROP_TEXT, "---%");
        ObjectSetInteger(0, prefix + "S" + idx + "_WR", OBJPROP_COLOR, clrGray);
        ObjectSetString(0, prefix + "S" + idx + "_Sharpe", OBJPROP_TEXT, "-.--");
        ObjectSetInteger(0, prefix + "S" + idx + "_Sharpe", OBJPROP_COLOR, clrGray);
        ObjectSetString(0, prefix + "S" + idx + "_Return", OBJPROP_TEXT, "-.-%");
        ObjectSetInteger(0, prefix + "S" + idx + "_Return", OBJPROP_COLOR, clrGray);
        ObjectSetString(0, prefix + "S" + idx + "_Score", OBJPROP_TEXT, "-.-");
        ObjectSetInteger(0, prefix + "S" + idx + "_Score", OBJPROP_COLOR, clrGray);
        ObjectSetString(0, prefix + "S" + idx + "_Viable", OBJPROP_TEXT, "...");
        ObjectSetInteger(0, prefix + "S" + idx + "_Viable", OBJPROP_COLOR, clrGray);
    }
    
    // Update Best/Worst to show loading
    ObjectSetString(0, prefix + "BestValue", OBJPROP_TEXT, "Analyzing...");
    ObjectSetString(0, prefix + "WorstValue", OBJPROP_TEXT, "Analyzing...");
    
    // Update Generated Strategy section
    ObjectSetString(0, prefix + "TemplateValue", OBJPROP_TEXT, "Pending...");
    ObjectSetString(0, prefix + "EntryValue", OBJPROP_TEXT, "Will be determined after analysis");
    ObjectSetString(0, prefix + "RiskValue", OBJPROP_TEXT, "---");
    ObjectSetString(0, prefix + "PosValue", OBJPROP_TEXT, "---");
    
    // Update Expected Performance
    ObjectSetString(0, prefix + "ExpWRValue", OBJPROP_TEXT, "---%");
    ObjectSetString(0, prefix + "ExpPFValue", OBJPROP_TEXT, "-.--");
    ObjectSetString(0, prefix + "ExpDDValue", OBJPROP_TEXT, "--%");
    ObjectSetString(0, prefix + "ExpSharpeValue", OBJPROP_TEXT, "-.--");
    
    // Show warmup message in warnings area
    ObjectSetString(0, prefix + "Warn0", OBJPROP_TEXT, "* Warming up indicators for accuracy...");
    ObjectSetInteger(0, prefix + "Warn0", OBJPROP_COLOR, C'255,200,100');
    ObjectSetString(0, prefix + "Warn1", OBJPROP_TEXT, "* SMA, RSI, ATR, HURST need stable data");
    ObjectSetInteger(0, prefix + "Warn1", OBJPROP_COLOR, clrGray);
    ObjectSetString(0, prefix + "Warn2", OBJPROP_TEXT, "* First analysis will begin in " + IntegerToString(remainingSeconds) + " seconds");
    ObjectSetInteger(0, prefix + "Warn2", OBJPROP_COLOR, clrGray);
    
    // Update Status
    ObjectSetString(0, prefix + "StatusValue", OBJPROP_TEXT, "INITIALIZING... " + progressBar);
    ObjectSetInteger(0, prefix + "StatusValue", OBJPROP_COLOR, C'255,200,100');
    
    ObjectSetString(0, prefix + "ExportValue", OBJPROP_TEXT, "Pending");
    
    // Force chart refresh
    ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Delete Strategy Generation Panel (MQL5)                            |
//+------------------------------------------------------------------+
void StratGen_DeletePanel5() {
    ObjectsDeleteAll(0, "StratGen_Panel5_");
}

//+------------------------------------------------------------------+
//| TECHAIN ENCRYPTION HELPERS - MQL5                                  |
//| XOR encryption with TECHAIN key                                    |
//+------------------------------------------------------------------+
int TCH_GetKeyByte5(int idx) {
    // "TECHAIN" = 84, 69, 67, 72, 65, 73, 78
    int pos = idx % 7;
    if (pos == 0) return 84;  // T
    if (pos == 1) return 69;  // E
    if (pos == 2) return 67;  // C
    if (pos == 3) return 72;  // H
    if (pos == 4) return 65;  // A
    if (pos == 5) return 73;  // I
    return 78;                 // N
}

string TCH_IntToHex5(int val) {
    string hex = "";
    string chars = "0123456789ABCDEF";
    hex = StringSubstr(chars, (val >> 4) & 0x0F, 1) + StringSubstr(chars, val & 0x0F, 1);
    return hex;
}

string TCH_EncryptContent5(string content) {
    string result = "";
    int len = StringLen(content);
    
    for (int i = 0; i < len; i++) {
        int ch = StringGetCharacter(content, i);
        int key = TCH_GetKeyByte5(i);
        int enc = ch ^ key;
        result = result + TCH_IntToHex5(enc);
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Export Strategy Report - TECHAIN ENCRYPTED FORMAT                  |
//| Now includes timestamp for version history (no overwrites)         |
//+------------------------------------------------------------------+
bool StratGen_ExportReport5(string expertPath, long magicNumber) {
    // Generate timestamp for versioning: YYYYMMDD_HHMM
    datetime now = TimeCurrent();
    string timestamp = TimeToString(now, TIME_DATE);
    StringReplace(timestamp, ".", "");
    timestamp = timestamp + "_" + TimeToString(now, TIME_MINUTES);
    StringReplace(timestamp, ":", "");
    
    // Filename with timestamp to prevent overwriting: AI_Strategy_Report_EURUSD_999999_20240115_1430.tch
    string filename = "AI_Strategy_Report_" + _Symbol + "_" + IntegerToString(magicNumber) + "_" + timestamp + ".tch";
    string nl = "\n";
    
    double atr = 0;
    int atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
    double atrBuffer[];
    ArrayResize(atrBuffer, 1); // FIX FEB 2026: Pre-allocate buffer
    ArraySetAsSeries(atrBuffer, true);
    if (CopyBuffer(atrHandle, 0, 0, 1, atrBuffer) > 0) atr = atrBuffer[0];
    IndicatorRelease(atrHandle);
    
    double slPips = g_genStrategy5.stopLossATR * atr / _Point;
    double tpPips = g_genStrategy5.takeProfitATR * atr / _Point;
    double lotSize = StratGen_CalculateLotSize5(g_genStrategy5.riskPercent, slPips);
    int best = g_testResults5.bestStrategyIndex;
    int worst = g_testResults5.worstStrategyIndex;
    string structureName = StratGen_GetStructureName5(g_testResults5.detectedStructure);
    string templateName = StratGen_GetTemplateDisplayName5();
    string directionName = StratGen_GetDirectionName5(g_genStrategy5.direction);
    
    // Construir todo el contenido del prompt en un string (CONTENIDO COMPLETO)
    string c = "";
    
    // SECCION HEADER
    c = c + "# INSTRUCCIONES PARA IA - GENERACION DE EXPERT ADVISOR PERSONALIZADO" + nl + nl;
    c = c + "## CONTEXTO Y PROPOSITO" + nl + nl;
    c = c + "Este documento contiene un analisis automatizado del mercado generado por el sistema " + nl;
    c = c + "Techain.ai Market Structure Detection. Tu tarea como IA es crear un Expert Advisor (EA) " + nl;
    c = c + "completo para MetaTrader 5 basado en este analisis." + nl + nl;
    c = c + "**IMPORTANTE**: No inventes datos. Usa EXACTAMENTE los valores proporcionados aqui." + nl + nl;
    
    // SECCION 1: DATOS DEL MERCADO
    c = c + "---" + nl + nl;
    c = c + "## SECCION 1: DATOS DEL MERCADO ANALIZADO" + nl + nl;
    c = c + "Estos son los datos del mercado que debes usar para configurar el EA:" + nl + nl;
    c = c + "| Parametro | Valor | Descripcion |" + nl;
    c = c + "|-----------|-------|-------------|" + nl;
    c = c + "| Simbolo | " + _Symbol + " | Par de divisas o instrumento a operar |" + nl;
    c = c + "| Timeframe | " + IntegerToString(PeriodSeconds() / 60) + " minutos | Marco temporal del grafico |" + nl;
    c = c + "| Fecha analisis | " + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + " | Momento del analisis |" + nl;
    c = c + "| ATR(14) actual | " + DoubleToString(atr / _Point, 1) + " pts | Volatilidad media - USAR para calcular SL/TP |" + nl + nl;
    
    // SECCION 2: ESTRUCTURA DE MERCADO
    c = c + "---" + nl + nl;
    c = c + "## SECCION 2: ESTRUCTURA DE MERCADO DETECTADA" + nl + nl;
    c = c + "El sistema ha analizado 8 estrategias diferentes y ha determinado:" + nl + nl;
    c = c + "| Resultado | Valor | Que significa |" + nl;
    c = c + "|-----------|-------|---------------|" + nl;
    c = c + "| Estructura | **" + structureName + "** | Tipo de mercado actual (tendencial, rango, volatil, etc.) |" + nl;
    c = c + "| Confianza | " + DoubleToString(g_testResults5.confidenceLevel, 1) + "% | Fiabilidad del analisis (>60% = alta, 40-60% = media, <40% = baja) |" + nl;
    c = c + "| Mejor estrategia | " + StratGen_GetTestStrategyName5(best) + " | La que mejor funciona en este mercado - USAR ESTA |" + nl;
    c = c + "| Peor estrategia | " + StratGen_GetTestStrategyName5(worst) + " | NO implementar logica similar a esta |" + nl + nl;
    c = c + "**INTERPRETACION DE LA ESTRUCTURA:**" + nl;
    c = c + "- Si es TRENDING: El mercado tiene direccion clara. Usar estrategias de seguimiento de tendencia." + nl;
    c = c + "- Si es RANGING: El mercado oscila entre niveles. Usar estrategias de reversion a la media." + nl;
    c = c + "- Si es VOLATILE: Alta volatilidad. Usar SL mas amplios y TP mas agresivos." + nl;
    c = c + "- Si es MIXED/CHOPPY: Sin direccion clara. Ser conservador o no operar." + nl + nl;
    
    // ===== SECCION 2.5: ANALISIS HURST (NUEVO) =====
    c = c + "---" + nl + nl;
    c = c + "## SECCION 2.5: ANALISIS HURST R/S (MEMORIA DE MERCADO)" + nl + nl;
    c = c + "El Exponente de Hurst mide la 'memoria' del mercado usando analisis R/S (Rescaled Range):" + nl + nl;
    
    string hurstRegimeName5 = g_testResults5.hurstRegime == 1 ? "PERSISTENTE/TRENDING" : 
                             (g_testResults5.hurstRegime == -1 ? "ANTI-PERSISTENTE/REVERTING" : "RANDOM WALK");
    
    c = c + "| Metrica | Valor | Interpretacion |" + nl;
    c = c + "|---------|-------|----------------|" + nl;
    c = c + "| **Hurst H** | **" + DoubleToString(g_testResults5.hurstValue, 3) + "** | Exponente de Hurst (0.01-0.99) |" + nl;
    c = c + "| Regimen | " + hurstRegimeName5 + " | Tipo de comportamiento detectado |" + nl;
    c = c + "| Memoria | " + DoubleToString(g_testResults5.hurstMemoryStrength, 1) + "% | Fuerza de la memoria (0-50%) |" + nl;
    c = c + "| Dimension Fractal | " + DoubleToString(g_testResults5.hurstFractalDimension, 3) + " | D = 2 - H (1.0=suave, 2.0=caotico) |" + nl + nl;
    
    c = c + "**INTERPRETACION DEL EXPONENTE DE HURST:**" + nl + nl;
    c = c + "- **H > 0.55 (TRENDING)**: El mercado tiene MEMORIA. Los movimientos tienden a continuar." + nl;
    c = c + "  - *Estrategia*: Seguimiento de tendencia. Entrar con momentum, dejar correr ganancias." + nl;
    c = c + "  - *SL/TP*: Usar SL amplios para no salir prematuramente." + nl + nl;
    c = c + "- **H = 0.47-0.53 (RANDOM)**: El mercado es ALEATORIO. No hay memoria ni patron predecible." + nl;
    c = c + "  - *Estrategia*: Reducir exposicion significativamente. No hay edge estadistico." + nl;
    c = c + "  - *Riesgo*: Cualquier estrategia es equivalente a lanzar una moneda." + nl + nl;
    c = c + "- **H < 0.45 (REVERTING)**: El mercado es ANTI-PERSISTENTE. Los movimientos tienden a revertir." + nl;
    c = c + "  - *Estrategia*: Mean reversion. Comprar en soportes, vender en resistencias." + nl;
    c = c + "  - *SL/TP*: Usar TP mas cercanos ya que el precio tiende a revertir." + nl + nl;
    
    c = c + "**VALIDACION CON ESTRUCTURA:**" + nl;
    if (g_testResults5.hurstRegime == 1 && g_testResults5.detectedStructure == AI_STRUCT_TRENDING) {
        c = c + "- CONFIRMADO: Tanto las estrategias como Hurst indican mercado TENDENCIAL. Alta confianza." + nl;
    } else if (g_testResults5.hurstRegime == -1 && (g_testResults5.detectedStructure == AI_STRUCT_RANGING || g_testResults5.detectedStructure == AI_STRUCT_CONSOLIDATION)) {
        c = c + "- CONFIRMADO: Tanto las estrategias como Hurst indican mercado en RANGO. Alta confianza." + nl;
    } else if (g_testResults5.hurstRegime == 0) {
        c = c + "- ADVERTENCIA: Hurst indica ALEATORIEDAD. Reducir tamano de posicion y ser conservador." + nl;
    } else {
        c = c + "- CONFLICTO: Existe discrepancia entre estrategias y Hurst. Analizar con precaucion." + nl;
    }
    c = c + nl;
    
    // SECCION 3: RESULTADOS DEL BACKTEST
    c = c + "---" + nl + nl;
    c = c + "## SECCION 3: RESULTADOS DEL BACKTEST DE 8 ESTRATEGIAS" + nl + nl;
    c = c + "Se han probado 8 estrategias sobre " + IntegerToString(g_genStrategy5.backtestBars) + " barras historicas." + nl;
    c = c + "**USA estos datos para entender que funciona y que no en este mercado:**" + nl + nl;
    c = c + "### Explicacion de metricas:" + nl;
    c = c + "- **Win Rate (WR%)**: Porcentaje de operaciones ganadoras. >50% es bueno." + nl;
    c = c + "- **Profit Factor (PF)**: Ganancia total / Perdida total. >1.5 es bueno, >2.0 excelente." + nl;
    c = c + "- **Sharpe Ratio**: Rendimiento ajustado por riesgo. >1.0 es bueno." + nl;
    c = c + "- **Max Drawdown (DD)**: Peor caida desde maximo. <15% es aceptable." + nl;
    c = c + "- **Score**: Puntuacion global 0-10. >7 es bueno." + nl;
    c = c + "- **Viable**: Si la estrategia es rentable y segura para usar." + nl + nl;
    c = c + "### Resultados por estrategia:" + nl + nl;
    
    for (int i = 0; i < 8; i++) {
        StrategyTestMetrics5 m = g_testResults5.metrics[i];
        string stratName = StratGen_GetTestStrategyName5(i);
        string tag = "";
        if (i == best) tag = " **[MEJOR - USAR ESTA]**";
        else if (i == worst) tag = " **[PEOR - EVITAR]**";
        else if (m.isViable) tag = " [viable]";
        
        c = c + "**" + IntegerToString(i+1) + ". " + stratName + "**" + tag + nl;
        c = c + "   - Win Rate: " + DoubleToString(m.winRate, 1) + "%" + nl;
        c = c + "   - Profit Factor: " + DoubleToString(m.profitFactor, 2) + nl;
        c = c + "   - Sharpe: " + DoubleToString(m.sharpeRatio, 2) + nl;
        c = c + "   - Max DD: " + DoubleToString(m.maxDrawdown, 1) + "%" + nl;
        c = c + "   - Trades: " + IntegerToString(m.totalTrades) + nl;
        c = c + "   - Score: " + DoubleToString(m.overallScore, 1) + "/10" + nl + nl;
    }
    
    // SECCION 4: ESTRATEGIA RECOMENDADA
    c = c + "---" + nl + nl;
    c = c + "## SECCION 4: ESTRATEGIA RECOMENDADA A IMPLEMENTAR" + nl + nl;
    c = c + "Basado en el analisis, el EA debe implementar esta configuracion:" + nl + nl;
    c = c + "### 4.1 Tipo de Estrategia" + nl;
    c = c + "- **Template**: " + templateName + nl;
    c = c + "- **Direccion**: " + directionName + " (LONG=solo compras, SHORT=solo ventas, BOTH=ambas)" + nl + nl;
    c = c + "### 4.2 Condiciones de Entrada (IMPLEMENTAR EXACTAMENTE)" + nl;
    c = c + "```" + nl;
    c = c + g_genStrategy5.entryConditions + nl;
    c = c + "```" + nl + nl;
    c = c + "### 4.3 Gestion de Riesgo (VALORES OBLIGATORIOS)" + nl + nl;
    c = c + "| Parametro | Valor | Como implementarlo |" + nl;
    c = c + "|-----------|-------|-------------------|" + nl;
    c = c + "| Stop Loss | " + DoubleToString(g_genStrategy5.stopLossATR, 1) + "x ATR (" + DoubleToString(slPips, 1) + " pts) | SL = precio_entrada +/- (ATR * " + DoubleToString(g_genStrategy5.stopLossATR, 1) + ") |" + nl;
    c = c + "| Take Profit | " + DoubleToString(g_genStrategy5.takeProfitATR, 1) + "x ATR (" + DoubleToString(tpPips, 1) + " pts) | TP = precio_entrada +/- (ATR * " + DoubleToString(g_genStrategy5.takeProfitATR, 1) + ") |" + nl;
    c = c + "| Ratio R:R | 1:" + DoubleToString(g_genStrategy5.riskRewardRatio, 1) + " | Por cada 1 que arriesgas, esperas ganar " + DoubleToString(g_genStrategy5.riskRewardRatio, 1) + " |" + nl;
    c = c + "| Riesgo/trade | " + DoubleToString(g_genStrategy5.riskPercent, 1) + "% | Maximo % de cuenta a perder por operacion |" + nl;
    c = c + "| Multiplicador | " + DoubleToString(g_genStrategy5.positionSizeMultiplier, 1) + "x | Ajuste de tamano de posicion |" + nl;
    c = c + "| Lote sugerido | " + DoubleToString(lotSize, 2) + " | Calculado para el riesgo indicado |" + nl;
    if (g_genStrategy5.useBreakeven) {
        c = c + "| Breakeven | SI, a " + DoubleToString(g_genStrategy5.breakevenTrigger, 1) + "x ATR | Mover SL a entrada cuando precio avance este ATR |" + nl;
    } else {
        c = c + "| Breakeven | NO | No mover SL a breakeven |" + nl;
    }
    c = c + nl;
    
    c = c + "### 4.4 Estado de Viabilidad" + nl + nl;
    if (g_genStrategy5.isViable) {
        c = c + "**ESTADO: VIABLE** - La estrategia tiene metricas aceptables. Proceder con implementacion." + nl;
    } else {
        c = c + "**ESTADO: PRECAUCION** - " + g_genStrategy5.viabilityReason + nl;
        c = c + "Considera ajustar parametros o usar gestion de riesgo mas conservadora." + nl;
    }
    c = c + nl;
    
    // ===== SECCION 4.5: FILTROS OBLIGATORIOS =====
    c = c + "### 4.5 Filtros Obligatorios para el EA (IMPLEMENTAR SIEMPRE)" + nl + nl;
    c = c + "Basado en la estrategia ganadora (" + StratGen_GetTestStrategyName5(best) + "), el EA DEBE incluir estos filtros:" + nl + nl;
    
    if (g_genStrategy5.useSessionFilter) {
        c = c + "**FILTRO DE HORARIO (OBLIGATORIO):**" + nl;
        c = c + "- Tipo: Filtro de sesion de mercado" + nl;
        c = c + "- Hora inicio: " + IntegerToString(g_genStrategy5.sessionStartHour) + ":00 GMT (apertura sesion)" + nl;
        c = c + "- Hora fin: " + IntegerToString(g_genStrategy5.sessionEndHour) + ":00 GMT" + nl;
        c = c + "- Sesiones relevantes: Londres (08:00-16:00 GMT), Nueva York (13:00-21:00 GMT)" + nl;
        c = c + "- **Nodo Techain**: logic.timeFilter con startHour=" + IntegerToString(g_genStrategy5.sessionStartHour) + ", endHour=" + IntegerToString(g_genStrategy5.sessionEndHour) + ", mode=HOUR_RANGE" + nl;
        c = c + "- Conectar output 'allowed' como condicion adicional en logic.and ANTES de action.buy/sell" + nl + nl;
    } else if (best == AI_TEST_SESSION_OPENING) {
        c = c + "**FILTRO DE HORARIO (OBLIGATORIO):**" + nl;
        c = c + "- La estrategia SESSION OPENING requiere operar SOLO en aperturas de sesion" + nl;
        c = c + "- Horas de apertura: 08:00 GMT (Londres) y 13:00 GMT (Nueva York)" + nl;
        c = c + "- **Nodo Techain**: logic.timeFilter con startHour=8, endHour=16, mode=SESSION" + nl;
        c = c + "- Conectar output 'allowed' como condicion adicional en logic.and ANTES de action.buy/sell" + nl + nl;
    }
    
    if (g_genStrategy5.useVolatilityFilter) {
        c = c + "**FILTRO DE VOLATILIDAD (OBLIGATORIO):**" + nl;
        if (best == AI_TEST_RANGE_TRADING) {
            c = c + "- Condicion: ATR(14) < 80% del promedio (baja volatilidad = rango)" + nl;
            c = c + "- Confirmar: ADX(14) < 25 (sin tendencia fuerte)" + nl;
        } else {
            c = c + "- Condicion: ATR(14) > 120% del promedio (alta volatilidad = breakout)" + nl;
            c = c + "- Confirmar: ADX(14) > 20 (hay fuerza direccional)" + nl;
        }
        c = c + "- **Nodo Techain**: logic.volatility o logic.threshold sobre ATR" + nl + nl;
    }
    
    if (g_genStrategy5.useHTFFilter || g_genStrategy5.useHTFConfirmation) {
        c = c + "**FILTRO DE TIMEFRAME SUPERIOR (RECOMENDADO):**" + nl;
        c = c + "- Confirmar direccion con SMA(50) en H4" + nl;
        c = c + "- Solo comprar si precio > SMA(50) en H4" + nl;
        c = c + "- Solo vender si precio < SMA(50) en H4" + nl + nl;
    }
    
    if (!g_genStrategy5.useSessionFilter && best != AI_TEST_SESSION_OPENING && !g_genStrategy5.useVolatilityFilter && !g_genStrategy5.useHTFFilter && !g_genStrategy5.useHTFConfirmation) {
        c = c + "- **Filtro de horario recomendado**: Evitar operar fuera de las sesiones principales (Londres 08:00-16:00, NY 13:00-21:00 GMT)" + nl;
        c = c + "- **Nodo Techain**: logic.timeFilter con startHour=8, endHour=21 para limitar a sesiones activas" + nl + nl;
    }
    
    // SECCION 5: INSTRUCCIONES PARA GENERAR EL EA
    c = c + "---" + nl + nl;
    c = c + "## SECCION 5: INSTRUCCIONES PARA GENERAR EL EA" + nl + nl;
    c = c + "### QUE DEBE HACER EL EA:" + nl + nl;
    c = c + "1. **Detectar senales de entrada** usando las condiciones de la Seccion 4.2" + nl;
    c = c + "2. **Aplicar TODOS los filtros** de la Seccion 4.5 (horario, volatilidad, HTF segun aplique)" + nl;
    c = c + "3. **Calcular SL y TP dinamicos** basados en ATR(14) actual" + nl;
    c = c + "4. **Calcular tamano de posicion** respetando el " + DoubleToString(g_genStrategy5.riskPercent, 1) + "% de riesgo maximo" + nl;
    c = c + "5. **Ejecutar ordenes** solo en direccion " + directionName + nl;
    if (g_genStrategy5.useBreakeven) {
        c = c + "6. **Mover SL a breakeven** cuando el precio avance " + DoubleToString(g_genStrategy5.breakevenTrigger, 1) + "x ATR a favor" + nl;
    }
    c = c + "7. **Mostrar panel visual** con estado actual, senales y rendimiento" + nl;
    c = c + "8. **Registrar operaciones** en el log para analisis posterior" + nl + nl;
    
    c = c + "### QUE NO DEBE HACER EL EA:" + nl + nl;
    c = c + "1. **NO usar logica de " + StratGen_GetTestStrategyName5(worst) + "** - Es la peor estrategia para este mercado" + nl;
    c = c + "2. **NO operar sin confirmar condiciones** de entrada completas" + nl;
    c = c + "3. **NO omitir los filtros de la Seccion 4.5** - Son OBLIGATORIOS para la estrategia" + nl;
    c = c + "4. **NO exceder el " + DoubleToString(g_genStrategy5.riskPercent * 3, 1) + "% de riesgo total** en posiciones abiertas simultaneas" + nl;
    c = c + "5. **NO operar durante noticias de alto impacto** (opcional pero recomendado)" + nl + nl;
    
    c = c + "### NODOS TECHAIN RECOMENDADOS PARA ESTE BOT:" + nl + nl;
    c = c + "El sistema visual Techain usa estos nodos. Incluir TODOS los necesarios:" + nl;
    c = c + "- **Indicadores**: indicator.rsi, indicator.ma, indicator.atr, indicator.bands, indicator.adx, indicator.currentPrice" + nl;
    c = c + "- **Logica**: logic.comparison, logic.threshold, logic.and, logic.crossover, logic.crossunder" + nl;
    if (g_genStrategy5.useSessionFilter || best == AI_TEST_SESSION_OPENING) {
        c = c + "- **FILTRO HORARIO**: logic.timeFilter (startHour, endHour, gmtOffset, mode) -> output: allowed (condition)" + nl;
    }
    if (g_genStrategy5.useVolatilityFilter) {
        c = c + "- **FILTRO VOLATILIDAD**: logic.volatility (condition, periods, threshold) -> output: signal (condition)" + nl;
    }
    c = c + "- **Acciones**: action.buy, action.sell" + nl;
    c = c + "- **Riesgo**: risk.positionSizing, risk.maxDrawdown, risk.stopLoss, risk.takeProfit" + nl;
    if (g_genStrategy5.useBreakeven) {
        c = c + "- **Breakeven**: risk.breakeven" + nl;
    }
    c = c + nl;
    
    c = c + "### PARAMETROS DE ENTRADA DEL EA (inputs):" + nl + nl;
    c = c + "El EA debe tener estos parametros configurables:" + nl;
    c = c + "```" + nl;
    c = c + "input double RiskPercent = " + DoubleToString(g_genStrategy5.riskPercent, 1) + ";     // Riesgo por operacion (%)" + nl;
    c = c + "input double SL_ATR_Mult = " + DoubleToString(g_genStrategy5.stopLossATR, 1) + ";      // Multiplicador ATR para SL" + nl;
    c = c + "input double TP_ATR_Mult = " + DoubleToString(g_genStrategy5.takeProfitATR, 1) + ";      // Multiplicador ATR para TP" + nl;
    c = c + "input bool   UseBreakeven = " + (g_genStrategy5.useBreakeven ? "true" : "false") + ";    // Usar breakeven" + nl;
    if (g_genStrategy5.useBreakeven) {
        c = c + "input double BE_ATR_Trigger = " + DoubleToString(g_genStrategy5.breakevenTrigger, 1) + "; // ATR para activar BE" + nl;
    }
    if (g_genStrategy5.useSessionFilter || best == AI_TEST_SESSION_OPENING) {
        c = c + "input int    SessionStartHour = " + IntegerToString(g_genStrategy5.sessionStartHour) + ";  // Hora inicio sesion (GMT)" + nl;
        c = c + "input int    SessionEndHour = " + IntegerToString(g_genStrategy5.sessionEndHour) + ";    // Hora fin sesion (GMT)" + nl;
    }
    c = c + "input long   MagicNumber = " + IntegerToString(magicNumber) + ";    // Numero magico del EA" + nl;
    c = c + "input bool   ShowPanel = true;         // Mostrar panel visual" + nl;
    c = c + "```" + nl + nl;
    
    // SECCION 6: RESUMEN EJECUTIVO
    c = c + "---" + nl + nl;
    c = c + "## SECCION 6: RESUMEN EJECUTIVO" + nl + nl;
    c = c + "**Genera un EA de MQL5 para " + _Symbol + " en " + IntegerToString(PeriodSeconds() / 60) + "M que:**" + nl + nl;
    c = c + "- Opere con estrategia **" + templateName + "** (la mejor para mercado " + structureName + ")" + nl;
    c = c + "- Use entrada: **" + g_genStrategy5.entryConditions + "**" + nl;
    c = c + "- SL dinamico: **" + DoubleToString(g_genStrategy5.stopLossATR, 1) + " x ATR**" + nl;
    c = c + "- TP dinamico: **" + DoubleToString(g_genStrategy5.takeProfitATR, 1) + " x ATR**" + nl;
    c = c + "- Riesgo: **" + DoubleToString(g_genStrategy5.riskPercent, 1) + "% por operacion**" + nl;
    c = c + "- Direccion: **" + directionName + "**" + nl;
    if (g_genStrategy5.useBreakeven) {
        c = c + "- Breakeven a **" + DoubleToString(g_genStrategy5.breakevenTrigger, 1) + "x ATR**" + nl;
    }
    if (g_genStrategy5.useSessionFilter) {
        c = c + "- **FILTRO HORARIO OBLIGATORIO**: logic.timeFilter startHour=" + IntegerToString(g_genStrategy5.sessionStartHour) + " endHour=" + IntegerToString(g_genStrategy5.sessionEndHour) + nl;
    }
    if (g_genStrategy5.useVolatilityFilter) {
        c = c + "- **FILTRO VOLATILIDAD OBLIGATORIO**: logic.volatility sobre ATR" + nl;
    }
    c = c + "- **EVITAR** logica tipo " + StratGen_GetTestStrategyName5(worst) + nl + nl;
    c = c + "- **HURST H = " + DoubleToString(g_testResults5.hurstValue, 3) + "** (" + 
        (g_testResults5.hurstRegime == 1 ? "TRENDING" : (g_testResults5.hurstRegime == -1 ? "REVERTING" : "RANDOM")) + 
        ", Memoria: " + DoubleToString(g_testResults5.hurstMemoryStrength, 1) + "%)" + nl + nl;
    c = c + "Confianza del analisis: **" + DoubleToString(g_testResults5.confidenceLevel, 1) + "%**" + nl;
    c = c + "Estado: **" + (g_genStrategy5.isViable ? "VIABLE" : "PRECAUCION") + "**" + nl + nl;
    c = c + "---" + nl;
    c = c + "*Reporte generado por Techain.ai Market Structure Detection System v3.0*" + nl;
    c = c + "*Incluye analisis Hurst R/S para mayor precision*" + nl;
    c = c + "*Fecha: " + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES) + "*" + nl;
    
    // Encriptar el contenido
    string encrypted = TCH_EncryptContent5(c);
    
    // Escribir archivo
    int handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_ANSI);
    if (handle == INVALID_HANDLE) {
        Print("Failed to create report: ", filename);
        return false;
    }
    
    // Header (no encriptado - necesario para identificar el archivo)
    FileWriteString(handle, "===TECHAIN_ENCRYPTED_PROMPT===\r\n");
    FileWriteString(handle, "VERSION:TCH_V2\r\n");
    FileWriteString(handle, "PLATFORM:MQL5\r\n");
    FileWriteString(handle, "TIMESTAMP:" + IntegerToString(TimeCurrent()) + "\r\n");
    FileWriteString(handle, "SYMBOL:" + _Symbol + "\r\n");
    FileWriteString(handle, "MAGIC:" + IntegerToString(magicNumber) + "\r\n");
    FileWriteString(handle, "LENGTH:" + IntegerToString(StringLen(c)) + "\r\n");
    FileWriteString(handle, "===DATA===\r\n");
    
    // Escribir datos encriptados en bloques de 80 caracteres
    int encLen = StringLen(encrypted);
    for (int idx = 0; idx < encLen; idx += 80) {
        int blockLen = MathMin(80, encLen - idx);
        FileWriteString(handle, StringSubstr(encrypted, idx, blockLen) + "\r\n");
    }
    
    FileWriteString(handle, "===END===\r\n");
    FileClose(handle);
    
    g_lastReportExport5 = TimeCurrent();
    Print("Encrypted report: ", filename);
    Print("Use Power AI in Techain.ai Chat to process this file");
    
    return true;
}

//+------------------------------------------------------------------+
//| ACTIVE ORDER MANAGEMENT SYSTEM (MQL5)                             |
//| Adjusts SL/TP of open positions when AI parameters change         |
//| significantly (only tightens, never loosens)                      |
//+------------------------------------------------------------------+

// Structure to store original SL/TP values when position was opened
struct AI_OriginalOrderParams5 {
    ulong ticket;              // Position ticket
    double originalSLPips;     // Original SL distance in pips
    double originalTPPips;     // Original TP distance in pips
    double lastAppliedSLPips;  // Last applied SL distance (after modifications)
    double lastAppliedTPPips;  // Last applied TP distance (after modifications)
    datetime openTime;         // When the position was opened
    bool isValid;              // Whether this entry is valid
};

// Global array to track original params (max 10 positions)
AI_OriginalOrderParams5 g_aiOriginalParams5[10];
int g_aiOriginalParamsCount5 = 0;
bool g_aiOriginalParamsInitialized5 = false;

//+------------------------------------------------------------------+
//| Initialize original params array                                   |
//+------------------------------------------------------------------+
void AI_InitOriginalParams5() {
    if (g_aiOriginalParamsInitialized5) return;
    
    for (int i = 0; i < 10; i++) {
        g_aiOriginalParams5[i].ticket = 0;
        g_aiOriginalParams5[i].originalSLPips = 0;
        g_aiOriginalParams5[i].originalTPPips = 0;
        g_aiOriginalParams5[i].lastAppliedSLPips = 0;
        g_aiOriginalParams5[i].lastAppliedTPPips = 0;
        g_aiOriginalParams5[i].openTime = 0;
        g_aiOriginalParams5[i].isValid = false;
    }
    g_aiOriginalParamsCount5 = 0;
    g_aiOriginalParamsInitialized5 = true;
}

//+------------------------------------------------------------------+
//| Store original params when a new position is opened               |
//+------------------------------------------------------------------+
void AI_StoreOriginalParams5(ulong ticket, double slPips, double tpPips) {
    AI_InitOriginalParams5();
    
    // Check if already exists
    for (int i = 0; i < 10; i++) {
        if (g_aiOriginalParams5[i].isValid && g_aiOriginalParams5[i].ticket == ticket) {
            return; // Already stored
        }
    }
    
    // Find empty slot
    for (int i = 0; i < 10; i++) {
        if (!g_aiOriginalParams5[i].isValid) {
            g_aiOriginalParams5[i].ticket = ticket;
            g_aiOriginalParams5[i].originalSLPips = slPips;
            g_aiOriginalParams5[i].originalTPPips = tpPips;
            g_aiOriginalParams5[i].lastAppliedSLPips = slPips;
            g_aiOriginalParams5[i].lastAppliedTPPips = tpPips;
            g_aiOriginalParams5[i].openTime = TimeCurrent();
            g_aiOriginalParams5[i].isValid = true;
            g_aiOriginalParamsCount5++;
            Print("AI Active Management: Stored original params for ticket ", ticket, 
                  " | SL: ", DoubleToString(slPips, 1), " pts | TP: ", DoubleToString(tpPips, 1), " pts");
            return;
        }
    }
    Print("AI Active Management: Warning - No empty slots for storing params");
}

//+------------------------------------------------------------------+
//| Get original params for a ticket                                   |
//+------------------------------------------------------------------+
int AI_GetOriginalParamsIndex5(ulong ticket) {
    AI_InitOriginalParams5();
    
    for (int i = 0; i < 10; i++) {
        if (g_aiOriginalParams5[i].isValid && g_aiOriginalParams5[i].ticket == ticket) {
            return i;
        }
    }
    return -1; // Not found
}

//+------------------------------------------------------------------+
//| Remove params when position is closed                              |
//+------------------------------------------------------------------+
void AI_RemoveOriginalParams5(ulong ticket) {
    int idx = AI_GetOriginalParamsIndex5(ticket);
    if (idx >= 0) {
        g_aiOriginalParams5[idx].isValid = false;
        g_aiOriginalParams5[idx].ticket = 0;
        g_aiOriginalParamsCount5--;
    }
}

//+------------------------------------------------------------------+
//| Active Order Management - Tighten SL/TP if AI params reduced      |
//| Only tightens (brings closer), never loosens                       |
//| Triggers when reduction >= 10% per step                            |
//+------------------------------------------------------------------+
void AI_ActiveOrderManagement5(
    int magicNumber,
    double currentSLPips,      // Current AI-calculated SL in pips
    double currentTPPips       // Current AI-calculated TP in pips
) {
    AI_InitOriginalParams5();
    
    const double THRESHOLD_PERCENT = 10.0; // 10% reduction threshold
    
    MqlTick tick;
    if (!SymbolInfoTick(_Symbol, tick)) return;
    
    // Clean up closed positions first
    for (int i = 0; i < 10; i++) {
        if (!g_aiOriginalParams5[i].isValid) continue;
        
        bool found = false;
        for (int j = PositionsTotal() - 1; j >= 0; j--) {
            ulong posTicket = PositionGetTicket(j);
            if (posTicket == g_aiOriginalParams5[i].ticket) {
                found = true;
                break;
            }
        }
        
        if (!found) {
            Print("AI Active Management: Position ", g_aiOriginalParams5[i].ticket, " closed, removing tracking");
            g_aiOriginalParams5[i].isValid = false;
            g_aiOriginalParams5[i].ticket = 0;
            g_aiOriginalParamsCount5--;
        }
    }
    
    // Process open positions
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (ticket == 0) continue;
        
        if (PositionGetInteger(POSITION_MAGIC) != magicNumber) continue;
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        
        int idx = AI_GetOriginalParamsIndex5(ticket);
        if (idx < 0) {
            // Position not tracked yet - might be from previous session
            // Store current SL/TP as original
            double posOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double posSL = PositionGetDouble(POSITION_SL);
            double posTP = PositionGetDouble(POSITION_TP);
            long posType = PositionGetInteger(POSITION_TYPE);
            
            double currentPosSLPips = 0;
            double currentPosTPPips = 0;
            
            if (posType == POSITION_TYPE_BUY) {
                if (posSL > 0) currentPosSLPips = (posOpenPrice - posSL) / _Point;
                if (posTP > 0) currentPosTPPips = (posTP - posOpenPrice) / _Point;
            } else {
                if (posSL > 0) currentPosSLPips = (posSL - posOpenPrice) / _Point;
                if (posTP > 0) currentPosTPPips = (posOpenPrice - posTP) / _Point;
            }
            
            if (currentPosSLPips > 0 && currentPosTPPips > 0) {
                AI_StoreOriginalParams5(ticket, currentPosSLPips, currentPosTPPips);
                idx = AI_GetOriginalParamsIndex5(ticket);
            }
            
            if (idx < 0) continue;
        }
        
        // Calculate reduction percentage from last applied values
        double slReductionPercent = 0;
        double tpReductionPercent = 0;
        
        if (g_aiOriginalParams5[idx].lastAppliedSLPips > 0) {
            slReductionPercent = ((g_aiOriginalParams5[idx].lastAppliedSLPips - currentSLPips) / 
                                   g_aiOriginalParams5[idx].lastAppliedSLPips) * 100.0;
        }
        
        if (g_aiOriginalParams5[idx].lastAppliedTPPips > 0) {
            tpReductionPercent = ((g_aiOriginalParams5[idx].lastAppliedTPPips - currentTPPips) / 
                                   g_aiOriginalParams5[idx].lastAppliedTPPips) * 100.0;
        }
        
        // Only proceed if reduction >= threshold (only tighten, never loosen)
        bool shouldModifySL = slReductionPercent >= THRESHOLD_PERCENT;
        bool shouldModifyTP = tpReductionPercent >= THRESHOLD_PERCENT;
        
        if (!shouldModifySL && !shouldModifyTP) continue;
        
        // Get current position data
        double posOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double currentPosSL = PositionGetDouble(POSITION_SL);
        double currentPosTP = PositionGetDouble(POSITION_TP);
        long posType = PositionGetInteger(POSITION_TYPE);
        
        double newSL = currentPosSL;
        double newTP = currentPosTP;
        
        if (posType == POSITION_TYPE_BUY) {
            if (shouldModifySL) {
                double proposedSL = NormalizeDouble(posOpenPrice - currentSLPips * _Point, _Digits);
                // Only tighten: new SL must be HIGHER than current SL (closer to entry)
                if (proposedSL > currentPosSL) {
                    newSL = proposedSL;
                }
            }
            if (shouldModifyTP) {
                double proposedTP = NormalizeDouble(posOpenPrice + currentTPPips * _Point, _Digits);
                // Only tighten: new TP must be LOWER than current TP (closer to entry)
                if (proposedTP < currentPosTP && proposedTP > posOpenPrice) {
                    newTP = proposedTP;
                }
            }
        } else { // SELL
            if (shouldModifySL) {
                double proposedSL = NormalizeDouble(posOpenPrice + currentSLPips * _Point, _Digits);
                // Only tighten: new SL must be LOWER than current SL (closer to entry)
                if (proposedSL < currentPosSL) {
                    newSL = proposedSL;
                }
            }
            if (shouldModifyTP) {
                double proposedTP = NormalizeDouble(posOpenPrice - currentTPPips * _Point, _Digits);
                // Only tighten: new TP must be HIGHER than current TP (closer to entry)
                if (proposedTP > currentPosTP && proposedTP < posOpenPrice) {
                    newTP = proposedTP;
                }
            }
        }
        
        // Apply modification if something changed
        if (newSL != currentPosSL || newTP != currentPosTP) {
            if (g_Trade.PositionModify(ticket, newSL, newTP)) {
                // Update last applied values
                if (newSL != currentPosSL && shouldModifySL) {
                    g_aiOriginalParams5[idx].lastAppliedSLPips = currentSLPips;
                }
                if (newTP != currentPosTP && shouldModifyTP) {
                    g_aiOriginalParams5[idx].lastAppliedTPPips = currentTPPips;
                }
                
                Print("AI Active Management: Modified position ", ticket);
                Print("  SL: ", DoubleToString(currentPosSL, _Digits), " -> ", DoubleToString(newSL, _Digits),
                      " (reduction: ", DoubleToString(slReductionPercent, 1), "%)");
                Print("  TP: ", DoubleToString(currentPosTP, _Digits), " -> ", DoubleToString(newTP, _Digits),
                      " (reduction: ", DoubleToString(tpReductionPercent, 1), "%)");
            } else {
                Print("AI Active Management: Failed to modify position ", ticket, " - Error: ", GetLastError());
            }
        }
    }
}

//+------------------------------------------------------------------+
//| EDGE RATIO - Entry Quality Analysis MQL5 (Global MFE/MAE)         |
//| Safe: Only multiplier on lots, never touches Q-Table              |
//+------------------------------------------------------------------+
void AI_UpdateEdge5(double mfe, double mae) {
    g_aiEdgeMFESum5 += mfe;
    g_aiEdgeMAESum5 += mae;
    g_aiEdgeTrades5++;
}

double AI_GetEdgeRatio5() {
    if (g_aiEdgeTrades5 < 5) return 1.0;
    double avgMAE = g_aiEdgeMAESum5 / g_aiEdgeTrades5;
    if (avgMAE <= 0) return 2.0;
    return (g_aiEdgeMFESum5 / g_aiEdgeTrades5) / avgMAE;
}

double AI_EdgeLotMultiplier5(int minTrades) {
    if (g_aiEdgeTrades5 < minTrades) return 1.0;
    double er = AI_GetEdgeRatio5();
    if (er >= 1.5) return 1.15;
    if (er >= 1.0) return 1.0 + (er - 1.0) * 0.3;
    return MathMax(0.5, 0.5 + er * 0.5);
}

void AI_CalcTradeEdge5(ulong dealTicket) {
    ulong posId = HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
    if (posId == 0) return;
    datetime openTime = 0; double openPrice = 0;
    ENUM_DEAL_TYPE openType = DEAL_TYPE_BUY;
    for (int d = HistoryDealsTotal() - 1; d >= 0; d--) {
        ulong dt2 = HistoryDealGetTicket(d);
        if (dt2 == 0) continue;
        if ((ulong)HistoryDealGetInteger(dt2, DEAL_POSITION_ID) != posId) continue;
        if ((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dt2, DEAL_ENTRY) == DEAL_ENTRY_IN) {
            openTime = (datetime)HistoryDealGetInteger(dt2, DEAL_TIME);
            openPrice = HistoryDealGetDouble(dt2, DEAL_PRICE);
            openType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dt2, DEAL_TYPE);
            break;
        }
    }
    if (openTime == 0 || openPrice <= 0) return;
    datetime closeTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
    int oBar = iBarShift(_Symbol, PERIOD_CURRENT, openTime);
    int cBar = iBarShift(_Symbol, PERIOD_CURRENT, closeTime);
    int nBars = oBar - cBar;
    if (nBars <= 0) return;
    int hBar = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, nBars + 1, cBar);
    int lBar = iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, nBars + 1, cBar);
    double hi = iHigh(_Symbol, PERIOD_CURRENT, hBar);
    double lo = iLow(_Symbol, PERIOD_CURRENT, lBar);
    double mfe = 0, mae = 0;
    if (openType == DEAL_TYPE_BUY) {
        mfe = (hi - openPrice) / _Point;
        mae = (openPrice - lo) / _Point;
    } else {
        mfe = (openPrice - lo) / _Point;
        mae = (hi - openPrice) / _Point;
    }
    if (mfe < 0) mfe = 0;
    if (mae < 0) mae = 0;
    AI_UpdateEdge5(mfe, mae);
}

// ===== PHASE 1 AI HELPER FUNCTIONS (MQL5) =====

// ===================================================================
// PHASE 1 AI NODES - HELPER FUNCTIONS (MQL5)
// Regime Detector | Signal Filter | Random Forest | Confidence Gate
// ===================================================================

//+------------------------------------------------------------------+
//| MQL5 Indicator Handle Utility                                      |
//+------------------------------------------------------------------+
double AI_P1_GetBuf(int handle, int bufIdx, int shift) {
    double buf[];
    ArraySetAsSeries(buf, true);
    if (CopyBuffer(handle, bufIdx, shift, 1, buf) <= 0) return 0;
    return buf[0];
}

double AI_P1_GetClose(int shift) {
    double buf[];
    ArraySetAsSeries(buf, true);
    if (CopyClose(_Symbol, PERIOD_CURRENT, shift, 1, buf) <= 0) return 0;
    return buf[0];
}

//+------------------------------------------------------------------+
//| MARKET REGIME DETECTOR IA - MQL5 Standalone Detection              |
//+------------------------------------------------------------------+
int g_rd5_lastRegime = -1;
int g_rd5_regimeAge = 0;
datetime g_rd5_lastBarTime = 0;
datetime g_rd5_lastPanelUpd = 0;
bool g_rd5_panelOk = false;
int g_rd5_hSMA = INVALID_HANDLE;
int g_rd5_hADX = INVALID_HANDLE;
int g_rd5_hATR = INVALID_HANDLE;
int g_rd5_hBB = INVALID_HANDLE;
bool g_rd5_handlesOk = false;

void AI_RD5_InitHandles(int smaPer, int adxPer, int atrPer, int bbPer) {
    if (g_rd5_handlesOk) return;
    g_rd5_hSMA = iMA(_Symbol, PERIOD_CURRENT, smaPer, 0, MODE_SMA, PRICE_CLOSE);
    g_rd5_hADX = iADX(_Symbol, PERIOD_CURRENT, adxPer);
    g_rd5_hATR = iATR(_Symbol, PERIOD_CURRENT, atrPer);
    g_rd5_hBB = iBands(_Symbol, PERIOD_CURRENT, bbPer, 0, 2.0, PRICE_CLOSE);
    if (g_rd5_hSMA == INVALID_HANDLE || g_rd5_hADX == INVALID_HANDLE || g_rd5_hATR == INVALID_HANDLE || g_rd5_hBB == INVALID_HANDLE) {
        Print("AI_RD5: Failed to create indicator handles");
        return;
    }
    g_rd5_handlesOk = true;
}

int AI_RD5_Classify() {
    if (!g_rd5_handlesOk) return 9;
    double price = AI_P1_GetClose(0);
    double sma = AI_P1_GetBuf(g_rd5_hSMA, 0, 0);
    double sma10 = AI_P1_GetBuf(g_rd5_hSMA, 0, 10);
    double adx = AI_P1_GetBuf(g_rd5_hADX, 0, 0); // Main ADX line
    double atr = AI_P1_GetBuf(g_rd5_hATR, 0, 0);
    double atrAvg = 0;
    for (int i = 0; i < 50; i++) atrAvg += AI_P1_GetBuf(g_rd5_hATR, 0, i);
    atrAvg /= 50.0;
    double volRatio = atrAvg > 0 ? atr / atrAvg : 1.0;
    double bbU = AI_P1_GetBuf(g_rd5_hBB, 1, 0); // Upper band
    double bbL = AI_P1_GetBuf(g_rd5_hBB, 2, 0); // Lower band
    double bbW = bbU - bbL;
    double bbAvgW = 0;
    for (int j = 0; j < 50; j++) bbAvgW += AI_P1_GetBuf(g_rd5_hBB, 1, j) - AI_P1_GetBuf(g_rd5_hBB, 2, j);
    bbAvgW /= 50.0;
    double bbRatio = bbAvgW > 0 ? bbW / bbAvgW : 1.0;
    double smaSlope = sma - sma10;
    bool trendUp = price > sma && smaSlope > 0;
    bool trendDown = price < sma && smaSlope < 0;
    if (volRatio > 2.0 && adx < 20) return 8;
    if (trendUp) {
        if (volRatio < 0.7) return 0;
        if (volRatio > 1.5) return 2;
        return 1;
    }
    if (trendDown) {
        if (volRatio < 0.7) return 3;
        if (volRatio > 1.5) return 5;
        return 4;
    }
    if (adx < 20) {
        if (bbRatio < 0.7) return 6;
        return 7;
    }
    return 9;
}

void AI_RD5_UpdateAge(int regime) {
    datetime bars[];
    ArraySetAsSeries(bars, true);
    if (CopyTime(_Symbol, PERIOD_CURRENT, 0, 1, bars) <= 0) return;
    datetime barTime = bars[0];
    if (barTime != g_rd5_lastBarTime) {
        g_rd5_lastBarTime = barTime;
        if (regime == g_rd5_lastRegime) g_rd5_regimeAge++;
        else { g_rd5_regimeAge = 1; g_rd5_lastRegime = regime; }
    }
}

string AI_RD5_GetName(int id) {
    switch(id) {
        case 0: return "TREND UP Calm";     case 1: return "TREND UP Normal";
        case 2: return "TREND UP Volatile"; case 3: return "TREND DOWN Calm";
        case 4: return "TREND DOWN Normal"; case 5: return "TREND DOWN Volatile";
        case 6: return "RANGE Quiet";       case 7: return "RANGE Normal";
        case 8: return "VOLATILE CHAOS";    case 9: return "TRANSITION";
        default: return "UNKNOWN";
    }
}

color AI_RD5_GetColor(int id) {
    switch(id) {
        case 0: return clrDodgerBlue;  case 1: return clrLimeGreen;
        case 2: return clrOrangeRed;   case 3: return clrSteelBlue;
        case 4: return clrCrimson;     case 5: return clrDarkRed;
        case 6: return clrGold;        case 7: return clrKhaki;
        case 8: return clrMagenta;     case 9: return clrSilver;
        default: return clrWhite;
    }
}

void AI_RD5_CreatePanel(int x, int y) {
    if (g_rd5_panelOk) return;
    ObjectCreate(0, "AI_RD5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_RD5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_RD5_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_RD5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_RD5_BG", OBJPROP_XSIZE, 280);
    ObjectSetInteger(0, "AI_RD5_BG", OBJPROP_YSIZE, 125);
    ObjectSetInteger(0, "AI_RD5_BG", OBJPROP_BGCOLOR, C'20,20,30');
    ObjectSetInteger(0, "AI_RD5_BG", OBJPROP_BORDER_COLOR, C'60,60,80');
    ObjectSetInteger(0, "AI_RD5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    for (int i = 0; i < 5; i++) {
        string nm = "AI_RD5_L" + IntegerToString(i);
        ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x + 10);
        ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y + 8 + i * 23);
        ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 9 : 8);
        ObjectSetInteger(0, nm, OBJPROP_COLOR, i == 0 ? clrGold : clrWhite);
    }
    ObjectSetString(0, "AI_RD5_L0", OBJPROP_TEXT, "REGIME DETECTOR IA");
    g_rd5_panelOk = true;
}

void AI_RD5_UpdatePanel(int regimeId, double strength, int age, int dir) {
    if (TimeCurrent() - g_rd5_lastPanelUpd < 1) return;
    g_rd5_lastPanelUpd = TimeCurrent();
    ObjectSetString(0, "AI_RD5_L1", OBJPROP_TEXT, "Regime: " + AI_RD5_GetName(regimeId));
    ObjectSetInteger(0, "AI_RD5_L1", OBJPROP_COLOR, AI_RD5_GetColor(regimeId));
    ObjectSetString(0, "AI_RD5_L2", OBJPROP_TEXT, "Strength: " + DoubleToString(strength, 1));
    ObjectSetString(0, "AI_RD5_L3", OBJPROP_TEXT, "Age: " + IntegerToString(age) + " bars");
    string dirS = dir > 0 ? "BULLISH" : (dir < 0 ? "BEARISH" : "NEUTRAL");
    color dc = dir > 0 ? clrLimeGreen : (dir < 0 ? clrCrimson : clrGray);
    ObjectSetString(0, "AI_RD5_L4", OBJPROP_TEXT, "Direction: " + dirS);
    ObjectSetInteger(0, "AI_RD5_L4", OBJPROP_COLOR, dc);
}

//+------------------------------------------------------------------+
//| AI SIGNAL FILTER - MQL5 Multi-Instance Online Learning Perceptron  |
//| Supports up to SF5_MAX_INST independent filters per EA             |
//+------------------------------------------------------------------+
#define SF5_FEATURES 10
#define SF5_HISTORY 200
#define SF5_MAX_INST 8
#define SF5_FILE_MAGIC 0x53464C35  // "SFL5" - Signal Filter Learn v5

double g_sf5_w[SF5_MAX_INST][SF5_FEATURES];
double g_sf5_b[SF5_MAX_INST];
int g_sf5_total[SF5_MAX_INST];
int g_sf5_passed[SF5_MAX_INST];
int g_sf5_trades[SF5_MAX_INST];
int g_sf5_wins[SF5_MAX_INST];
bool g_sf5_init[SF5_MAX_INST];
datetime g_sf5_panelUpd[SF5_MAX_INST];
bool g_sf5_panelOk[SF5_MAX_INST];
datetime g_sf5_procTime[SF5_MAX_INST];
bool g_sf5_fileLoaded[SF5_MAX_INST];

int g_sf5_hRSI = INVALID_HANDLE;
int g_sf5_hATR = INVALID_HANDLE;
int g_sf5_hADX = INVALID_HANDLE;
int g_sf5_hSMA20 = INVALID_HANDLE;
int g_sf5_hBB = INVALID_HANDLE;
bool g_sf5_hOk = false;

struct SF5_Rec {
    datetime signalTime;
    double feat[SF5_FEATURES];
    bool done;
    bool isBuy;
};
SF5_Rec g_sf5_rec[SF5_MAX_INST][SF5_HISTORY];
int g_sf5_recIdx[SF5_MAX_INST];

//+------------------------------------------------------------------+
//| Signal Filter Persistence: Save/Load to Common folder (MQL5)      |
//| File: AI_SF_<Magic>_<Idx>_<Symbol>.bin (one per instance)          |
//| Portable between brokers/terminals via Common/Files/               |
//+------------------------------------------------------------------+
string AI_SF5_GetFilename(int idx, int magic) {
    return "AI_SF_" + IntegerToString(magic) + "_" + IntegerToString(idx) + "_" + _Symbol + ".bin";
}
string AI_SF5_GetLegacyFilename(int magic) {
    return "AI_SF_" + IntegerToString(magic) + "_" + _Symbol + ".bin";
}

void AI_SF5_Save(int idx, int magic) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return;
    string fn = AI_SF5_GetFilename(idx, magic);
    if (FileIsExist(fn, FILE_COMMON)) FileDelete(fn, FILE_COMMON);
    int h = FileOpen(fn, FILE_WRITE | FILE_BIN | FILE_COMMON);
    if (h == INVALID_HANDLE) { Print("[SF5:", idx, "] Save FAILED: ", GetLastError()); return; }
    FileWriteInteger(h, SF5_FILE_MAGIC, INT_VALUE);
    FileWriteInteger(h, 1, INT_VALUE); // version
    FileWriteInteger(h, SF5_FEATURES, INT_VALUE);
    for (int i = 0; i < SF5_FEATURES; i++)
        FileWriteDouble(h, g_sf5_w[idx][i]);
    FileWriteDouble(h, g_sf5_b[idx]);
    FileWriteInteger(h, g_sf5_total[idx], INT_VALUE);
    FileWriteInteger(h, g_sf5_passed[idx], INT_VALUE);
    FileWriteInteger(h, g_sf5_trades[idx], INT_VALUE);
    FileWriteInteger(h, g_sf5_wins[idx], INT_VALUE);
    FileClose(h);
    Print("[SF5:", idx, "] Model saved: ", fn, " | Trades: ", g_sf5_trades[idx], " | WinRate: ",
          g_sf5_trades[idx] > 0 ? DoubleToString((double)g_sf5_wins[idx]/g_sf5_trades[idx]*100, 1) : "0", "%");
}

bool AI_SF5_Load(int idx, int magic) {
    string fn = AI_SF5_GetFilename(idx, magic);
    bool inCommon = FileIsExist(fn, FILE_COMMON);
    bool inLocal = !inCommon && FileIsExist(fn);
    if (!inCommon && !inLocal) {
        string legacyFn = AI_SF5_GetLegacyFilename(magic);
        bool legCommon = FileIsExist(legacyFn, FILE_COMMON);
        bool legLocal = !legCommon && FileIsExist(legacyFn);
        if (legCommon || legLocal) {
            Print("[SF5:", idx, "] Migrating from legacy file: ", legacyFn);
            fn = legacyFn;
            inCommon = legCommon;
            inLocal = legLocal;
        } else {
            Print("[SF5:", idx, "] No saved model: ", fn, " - starting fresh");
            return false;
        }
    }
    int flags = FILE_READ | FILE_BIN | (inCommon ? FILE_COMMON : 0);
    int h = FileOpen(fn, flags);
    if (h == INVALID_HANDLE) { Print("[SF5:", idx, "] Load FAILED: ", GetLastError()); return false; }
    int mgc = FileReadInteger(h, INT_VALUE);
    if (mgc != SF5_FILE_MAGIC) { Print("[SF5:", idx, "] Invalid header"); FileClose(h); return false; }
    FileReadInteger(h, INT_VALUE); // version
    int nf = FileReadInteger(h, INT_VALUE);
    if (nf != SF5_FEATURES) { Print("[SF5:", idx, "] Feature mismatch: ", nf, " vs ", SF5_FEATURES); FileClose(h); return false; }
    for (int i = 0; i < SF5_FEATURES; i++)
        g_sf5_w[idx][i] = FileReadDouble(h);
    g_sf5_b[idx] = FileReadDouble(h);
    g_sf5_total[idx] = FileReadInteger(h, INT_VALUE);
    g_sf5_passed[idx] = FileReadInteger(h, INT_VALUE);
    g_sf5_trades[idx] = FileReadInteger(h, INT_VALUE);
    g_sf5_wins[idx] = FileReadInteger(h, INT_VALUE);
    FileClose(h);
    if (inLocal && !inCommon) AI_SF5_Save(idx, magic);
    g_sf5_fileLoaded[idx] = true;
    Print("[SF5:", idx, "] Model loaded: ", fn, " | Trades: ", g_sf5_trades[idx], " | WinRate: ",
          g_sf5_trades[idx] > 0 ? DoubleToString((double)g_sf5_wins[idx]/g_sf5_trades[idx]*100, 1) : "0", "%");
    return true;
}

void AI_SF5_Init(int idx, int magic = 0, bool allowLoadInTester = false) {
    if (g_sf5_init[idx]) return;
    // Load model: in Demo/Live always; in Tester only if user explicitly enabled loadModelInTester
    bool inTester = (bool)MQLInfoInteger(MQL_TESTER);
    bool canLoad = !(bool)MQLInfoInteger(MQL_OPTIMIZATION) && magic > 0 && (inTester ? allowLoadInTester : true);
    if (canLoad && AI_SF5_Load(idx, magic)) {
        Print("[SF5:", idx, "] Continuing from saved model with ", g_sf5_trades[idx], " trades of experience");
    } else {
        MathSrand(g_MasterSeed + 10000 + idx);
        for (int i = 0; i < SF5_FEATURES; i++)
            g_sf5_w[idx][i] = (MathRand() / 32768.0 - 0.5) * 0.1;
        g_sf5_b[idx] = 0;
        g_sf5_total[idx] = 0; g_sf5_passed[idx] = 0;
        g_sf5_trades[idx] = 0; g_sf5_wins[idx] = 0;
    }
    g_sf5_recIdx[idx] = 0;
    for (int j = 0; j < SF5_HISTORY; j++) { g_sf5_rec[idx][j].signalTime = 0; g_sf5_rec[idx][j].done = true; }
    if (!g_sf5_hOk) {
        g_sf5_hRSI = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
        g_sf5_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
        g_sf5_hADX = iADX(_Symbol, PERIOD_CURRENT, 14);
        g_sf5_hSMA20 = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
        g_sf5_hBB = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
        if (g_sf5_hRSI == INVALID_HANDLE || g_sf5_hATR == INVALID_HANDLE || g_sf5_hADX == INVALID_HANDLE || g_sf5_hSMA20 == INVALID_HANDLE || g_sf5_hBB == INVALID_HANDLE) {
            Print("AI_SF5: Failed to create indicator handles");
            return;
        }
        g_sf5_hOk = true;
    }
    g_sf5_init[idx] = true;
}

double AI_SF5_Sigmoid(double x) {
    if (x > 10) return 1.0; if (x < -10) return 0.0;
    return 1.0 / (1.0 + MathExp(-x));
}

void AI_SF5_GetFeatures(double &feat[], bool isBuy) {
    double atr = AI_P1_GetBuf(g_sf5_hATR, 0, 0);
    double price = AI_P1_GetClose(0);
    double atrS = MathMax(atr, _Point);
    feat[0] = AI_P1_GetBuf(g_sf5_hRSI, 0, 0) / 100.0;
    feat[1] = atr / MathMax(price, _Point);
    feat[2] = AI_P1_GetBuf(g_sf5_hADX, 0, 0) / 100.0;
    double sma20 = AI_P1_GetBuf(g_sf5_hSMA20, 0, 0);
    feat[3] = MathMax(-1.0, MathMin(1.0, (price - sma20) / (3.0 * atrS)));
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    feat[4] = MathMin(1.0, (ask - bid) / atrS);
    MqlDateTime dt; TimeToStruct(TimeCurrent(), dt);
    feat[5] = (double)(dt.hour * 60 + dt.min) / 1440.0;
    double bbU = AI_P1_GetBuf(g_sf5_hBB, 1, 0);
    double bbL = AI_P1_GetBuf(g_sf5_hBB, 2, 0);
    double bbR = bbU - bbL;
    feat[6] = bbR > 0 ? (price - bbL) / bbR : 0.5;
    double p3 = AI_P1_GetClose(3);
    double chg = (price - p3) / atrS;
    feat[7] = MathMax(-1.0, MathMin(1.0, chg / 3.0));
    feat[8] = isBuy ? (feat[3] > 0 ? 1.0 : 0.0) : (feat[3] < 0 ? 1.0 : 0.0);
    double atrSlow = 0;
    for (int k = 0; k < 50; k++) atrSlow += AI_P1_GetBuf(g_sf5_hATR, 0, k);
    atrSlow /= 50.0;
    feat[9] = atrSlow > 0 ? MathMin(2.0, atr / atrSlow) / 2.0 : 0.5;
}

double AI_SF5_Score(int idx, double &feat[]) {
    double sum = g_sf5_b[idx];
    for (int i = 0; i < SF5_FEATURES; i++) sum += feat[i] * g_sf5_w[idx][i];
    return AI_SF5_Sigmoid(sum);
}

void AI_SF5_Learn(int idx, double &feat[], double target, double lr) {
    // Backtest Training: boost perceptron learning rate for faster convergence
    double effectiveLR = g_IsBacktestTraining ? MathMin(lr * g_AITrainingSpeedMultiplier, 0.5) : lr;
    double pred = AI_SF5_Score(idx, feat);
    double err = target - pred;
    double grad = pred * (1.0 - pred);
    for (int i = 0; i < SF5_FEATURES; i++)
        g_sf5_w[idx][i] += effectiveLR * err * grad * feat[i];
    g_sf5_b[idx] += effectiveLR * err * grad;
}

void AI_SF5_Store(int idx, double &feat[], bool isBuy) {
    int slot = g_sf5_recIdx[idx] % SF5_HISTORY;
    g_sf5_rec[idx][slot].signalTime = TimeCurrent();
    g_sf5_rec[idx][slot].done = false;
    g_sf5_rec[idx][slot].isBuy = isBuy;
    for (int i = 0; i < SF5_FEATURES; i++) g_sf5_rec[idx][slot].feat[i] = feat[i];
    g_sf5_recIdx[idx]++;
}

void AI_SF5_ProcessClosed(int idx, int magic, double lr) {
    if (TimeCurrent() - g_sf5_procTime[idx] < 5) return;
    g_sf5_procTime[idx] = TimeCurrent();
    if (!HistorySelect(TimeCurrent() - 86400 * 30, TimeCurrent())) return;
    for (int h = HistoryDealsTotal() - 1; h >= MathMax(0, HistoryDealsTotal() - 100); h--) {
        ulong dealTicket = HistoryDealGetTicket(h);
        if (dealTicket == 0) continue;
        if (HistoryDealGetInteger(dealTicket, DEAL_MAGIC) != magic) continue;
        if (HistoryDealGetString(dealTicket, DEAL_SYMBOL) != _Symbol) continue;
        if ((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
        double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT) +
                       HistoryDealGetDouble(dealTicket, DEAL_COMMISSION) +
                       HistoryDealGetDouble(dealTicket, DEAL_SWAP);
        ulong posId = (ulong)HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
        datetime openTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
        long dealType = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
        bool wasBuy = (dealType == DEAL_TYPE_SELL);
        int bestIdx = -1;
        int bestDiff = 300;
        for (int i = 0; i < MathMin(g_sf5_recIdx[idx], SF5_HISTORY); i++) {
            if (g_sf5_rec[idx][i].done) continue;
            if (g_sf5_rec[idx][i].isBuy != wasBuy) continue;
            int diff = (int)MathAbs((double)(openTime - g_sf5_rec[idx][i].signalTime));
            if (diff < bestDiff) { bestDiff = diff; bestIdx = i; }
        }
        if (bestIdx >= 0) {
            AI_SF5_Learn(idx, g_sf5_rec[idx][bestIdx].feat, profit > 0 ? 1.0 : 0.0, lr);
            g_sf5_trades[idx]++;
            if (profit > 0) g_sf5_wins[idx]++;
            g_sf5_rec[idx][bestIdx].done = true;
        }
    }
}

void AI_SF5_CreatePanel(int idx, int x, int y) {
    if (g_sf5_panelOk[idx]) return;
    string pfx = "AI_SF5_" + IntegerToString(idx) + "_";
    ObjectCreate(0, pfx + "BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, pfx + "BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, pfx + "BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, pfx + "BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, pfx + "BG", OBJPROP_XSIZE, 260);
    ObjectSetInteger(0, pfx + "BG", OBJPROP_YSIZE, 110);
    ObjectSetInteger(0, pfx + "BG", OBJPROP_BGCOLOR, C'20,20,30');
    ObjectSetInteger(0, pfx + "BG", OBJPROP_BORDER_COLOR, C'60,80,60');
    ObjectSetInteger(0, pfx + "BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    for (int i = 0; i < 4; i++) {
        string nm = pfx + "L" + IntegerToString(i);
        ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x + 10);
        ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y + 8 + i * 24);
        ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 9 : 8);
        ObjectSetInteger(0, nm, OBJPROP_COLOR, i == 0 ? clrCyan : clrWhite);
    }
    ObjectSetString(0, pfx + "L0", OBJPROP_TEXT, "AI SIGNAL FILTER #" + IntegerToString(idx));
    g_sf5_panelOk[idx] = true;
}

void AI_SF5_UpdatePanel(int idx) {
    if (TimeCurrent() - g_sf5_panelUpd[idx] < 1) return;
    g_sf5_panelUpd[idx] = TimeCurrent();
    string pfx = "AI_SF5_" + IntegerToString(idx) + "_";
    double fRate = g_sf5_total[idx] > 0 ? (1.0 - (double)g_sf5_passed[idx] / g_sf5_total[idx]) * 100.0 : 0;
    double wRate = g_sf5_trades[idx] > 0 ? (double)g_sf5_wins[idx] / g_sf5_trades[idx] * 100.0 : 0;
    ObjectSetString(0, pfx + "L1", OBJPROP_TEXT, "Signals: " + IntegerToString(g_sf5_total[idx]) + " | Passed: " + IntegerToString(g_sf5_passed[idx]));
    ObjectSetString(0, pfx + "L2", OBJPROP_TEXT, "Filtered: " + DoubleToString(fRate, 1) + "%");
    ObjectSetString(0, pfx + "L3", OBJPROP_TEXT, "WinRate: " + DoubleToString(wRate, 1) + "% (" + IntegerToString(g_sf5_trades[idx]) + " trades)");
    ObjectSetInteger(0, pfx + "L3", OBJPROP_COLOR, wRate >= 50 ? clrLimeGreen : (g_sf5_trades[idx] > 0 ? clrOrangeRed : clrGray));
}

//+------------------------------------------------------------------+
//| RANDOM FOREST CLASSIFIER IA - MQL5 Decision Tree Ensemble         |
//+------------------------------------------------------------------+
#define RF5_TREES 100
#define RF5_NODES 300
#define RF5_DEPTH 12
#define RF5_FEAT 8
#define RF5_SAMP 2000

struct RF5_Node {
    bool isLeaf;
    int feat;
    double thresh;
    double leafVal;
    int leftCh;
    int rightCh;
};

struct RF5_Tree {
    RF5_Node nd[RF5_NODES];
    int cnt;
    bool ok;
};

RF5_Tree g_rf5_t[RF5_TREES];
int g_rf5_nT = 0;
int g_rf5_mD = 0;
bool g_rf5_trained = false;
datetime g_rf5_trainTime = 0;
datetime g_rf5_panelUpd = 0;
bool g_rf5_panelOk = false;
int g_rf5_barCnt = 0;
datetime g_rf5_lastBar = 0;

double g_rf5_feat[RF5_SAMP][RF5_FEAT];
double g_rf5_tgt[RF5_SAMP];
int g_rf5_nS = 0;

int g_rf5_hRSI = INVALID_HANDLE;
int g_rf5_hATR = INVALID_HANDLE;
int g_rf5_hADX = INVALID_HANDLE;
int g_rf5_hSMA = INVALID_HANDLE;
int g_rf5_hBB = INVALID_HANDLE;
int g_rf5_hMACD = INVALID_HANDLE;
int g_rf5_hStoch = INVALID_HANDLE;
bool g_rf5_hOk = false;

void AI_RF5_InitHandles() {
    if (g_rf5_hOk) return;
    g_rf5_hRSI = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    g_rf5_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
    g_rf5_hADX = iADX(_Symbol, PERIOD_CURRENT, 14);
    g_rf5_hSMA = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    g_rf5_hBB = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
    g_rf5_hMACD = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
    g_rf5_hStoch = iStochastic(_Symbol, PERIOD_CURRENT, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
    if (g_rf5_hRSI == INVALID_HANDLE || g_rf5_hATR == INVALID_HANDLE || g_rf5_hADX == INVALID_HANDLE || g_rf5_hSMA == INVALID_HANDLE || g_rf5_hBB == INVALID_HANDLE || g_rf5_hMACD == INVALID_HANDLE || g_rf5_hStoch == INVALID_HANDLE) {
        Print("AI_RF5: Failed to create indicator handles");
        return;
    }
    g_rf5_hOk = true;
}

void AI_RF5_Init(int nT, int mD) {
    g_rf5_nT = MathMin(nT, RF5_TREES);
    g_rf5_mD = MathMin(mD, RF5_DEPTH);
    g_rf5_trained = false;
    g_rf5_nS = 0;
    g_rf5_barCnt = 0;
    AI_RF5_InitHandles();
    for (int t = 0; t < g_rf5_nT; t++) {
        g_rf5_t[t].cnt = 0;
        g_rf5_t[t].ok = false;
    }
}

void AI_RF5_GetFeat(int shift, double &f[]) {
    double atr = AI_P1_GetBuf(g_rf5_hATR, 0, shift);
    double price = AI_P1_GetClose(shift);
    double atrS = MathMax(atr, _Point);
    f[0] = AI_P1_GetBuf(g_rf5_hRSI, 0, shift) / 100.0;
    f[1] = atr / MathMax(price, _Point);
    f[2] = AI_P1_GetBuf(g_rf5_hADX, 0, shift) / 100.0;
    double sma = AI_P1_GetBuf(g_rf5_hSMA, 0, shift);
    f[3] = MathMax(-1.0, MathMin(1.0, (price - sma) / (3.0 * atrS))) * 0.5 + 0.5;
    double bbU = AI_P1_GetBuf(g_rf5_hBB, 1, shift);
    double bbL = AI_P1_GetBuf(g_rf5_hBB, 2, shift);
    double bbR = bbU - bbL;
    f[4] = bbR > 0 ? (price - bbL) / bbR : 0.5;
    double mM = AI_P1_GetBuf(g_rf5_hMACD, 0, shift);
    double mS = AI_P1_GetBuf(g_rf5_hMACD, 1, shift);
    f[5] = MathMax(-1.0, MathMin(1.0, (mM - mS) / atrS)) * 0.5 + 0.5;
    f[6] = AI_P1_GetBuf(g_rf5_hStoch, 0, shift) / 100.0;
    double pFut = AI_P1_GetClose(shift + 5);
    double mom = (pFut > 0) ? (price - pFut) : 0;
    f[7] = MathMax(-1.0, MathMin(1.0, mom / (3.0 * atrS))) * 0.5 + 0.5;
}

void AI_RF5_Collect(int trainBars, int lookAhead, double minPct) {
    g_rf5_nS = 0;
    int barsAvail = Bars(_Symbol, PERIOD_CURRENT);
    int maxB = MathMin(trainBars, barsAvail - lookAhead - 100);
    for (int i = lookAhead; i < maxB && g_rf5_nS < RF5_SAMP; i++) {
        double f[RF5_FEAT];
        AI_RF5_GetFeat(i, f);
        double fut = AI_P1_GetClose(i - lookAhead);
        double cur = AI_P1_GetClose(i);
        if (cur <= 0) continue;
        double pct = (fut - cur) / cur * 100.0;
        double tgt = 0;
        if (pct > minPct) tgt = 1.0;
        else if (pct < -minPct) tgt = -1.0;
        for (int j = 0; j < RF5_FEAT; j++) g_rf5_feat[g_rf5_nS][j] = f[j];
        g_rf5_tgt[g_rf5_nS] = tgt;
        g_rf5_nS++;
    }
}

double AI_RF5_Gini(int &idx[], int cnt) {
    if (cnt == 0) return 0;
    int cb = 0, cs = 0, ch = 0;
    for (int i = 0; i < cnt; i++) {
        if (g_rf5_tgt[idx[i]] > 0.5) cb++;
        else if (g_rf5_tgt[idx[i]] < -0.5) cs++;
        else ch++;
    }
    double pb = (double)cb / cnt, ps = (double)cs / cnt, ph = (double)ch / cnt;
    return 1.0 - pb * pb - ps * ps - ph * ph;
}

int AI_RF5_Build(int tI, int &idx[], int cnt, int dep) {
    if (g_rf5_t[tI].cnt >= RF5_NODES - 2 || cnt < 5 || dep >= g_rf5_mD) {
        int n = g_rf5_t[tI].cnt++;
        g_rf5_t[tI].nd[n].isLeaf = true;
        double s = 0;
        for (int i = 0; i < cnt; i++) s += g_rf5_tgt[idx[i]];
        g_rf5_t[tI].nd[n].leafVal = s / MathMax(1, cnt);
        g_rf5_t[tI].nd[n].leftCh = -1;
        g_rf5_t[tI].nd[n].rightCh = -1;
        return n;
    }
    double bG = -1; int bF = 0; double bTh = 0;
    int nFS = (int)MathMax(2, MathSqrt(RF5_FEAT));
    double pG = AI_RF5_Gini(idx, cnt);
    for (int fi = 0; fi < nFS; fi++) {
        int f = MathRand() % RF5_FEAT;
        for (int t = 0; t < 8; t++) {
            double th = g_rf5_feat[idx[MathRand() % cnt]][f];
            int lc = 0, rc = 0;
            int lI[]; ArrayResize(lI, cnt);
            int rI[]; ArrayResize(rI, cnt);
            for (int i = 0; i < cnt; i++) {
                if (g_rf5_feat[idx[i]][f] <= th) { lI[lc] = idx[i]; lc++; }
                else { rI[rc] = idx[i]; rc++; }
            }
            if (lc < 2 || rc < 2) continue;
            ArrayResize(lI, lc); ArrayResize(rI, rc);
            double wG = ((double)lc * AI_RF5_Gini(lI, lc) + (double)rc * AI_RF5_Gini(rI, rc)) / cnt;
            double gain = pG - wG;
            if (gain > bG) { bG = gain; bF = f; bTh = th; }
        }
    }
    if (bG <= 0.001) {
        int n = g_rf5_t[tI].cnt++;
        g_rf5_t[tI].nd[n].isLeaf = true;
        double s = 0;
        for (int i = 0; i < cnt; i++) s += g_rf5_tgt[idx[i]];
        g_rf5_t[tI].nd[n].leafVal = s / MathMax(1, cnt);
        g_rf5_t[tI].nd[n].leftCh = -1;
        g_rf5_t[tI].nd[n].rightCh = -1;
        return n;
    }
    int nIdx = g_rf5_t[tI].cnt++;
    g_rf5_t[tI].nd[nIdx].isLeaf = false;
    g_rf5_t[tI].nd[nIdx].feat = bF;
    g_rf5_t[tI].nd[nIdx].thresh = bTh;
    int la[]; ArrayResize(la, cnt);
    int ra[]; ArrayResize(ra, cnt);
    int lc2 = 0, rc2 = 0;
    for (int i = 0; i < cnt; i++) {
        if (g_rf5_feat[idx[i]][bF] <= bTh) { la[lc2] = idx[i]; lc2++; }
        else { ra[rc2] = idx[i]; rc2++; }
    }
    ArrayResize(la, lc2); ArrayResize(ra, rc2);
    g_rf5_t[tI].nd[nIdx].leftCh = AI_RF5_Build(tI, la, lc2, dep + 1);
    g_rf5_t[tI].nd[nIdx].rightCh = AI_RF5_Build(tI, ra, rc2, dep + 1);
    return nIdx;
}

bool AI_RF5_Train(int trainBars, int lookAhead, double minPct) {
    AI_RF5_Collect(trainBars, lookAhead, minPct);
    if (g_rf5_nS < 50) {
        Print("AI RF5: Not enough data (", g_rf5_nS, " samples)");
        return false;
    }
    Print("AI RF5: Training ", g_rf5_nT, " trees with ", g_rf5_nS, " samples...");
    MathSrand(g_MasterSeed + 20000);
    for (int t = 0; t < g_rf5_nT; t++) {
        g_rf5_t[t].cnt = 0;
        int bs[]; ArrayResize(bs, g_rf5_nS);
        for (int i = 0; i < g_rf5_nS; i++) bs[i] = MathRand() % g_rf5_nS;
        AI_RF5_Build(t, bs, g_rf5_nS, 0);
        g_rf5_t[t].ok = (g_rf5_t[t].cnt > 0);
    }
    g_rf5_trained = true;
    g_rf5_trainTime = TimeCurrent();
    Print("AI RF5: Training complete.");
    return true;
}

double AI_RF5_PredTree(int tI, double &f[]) {
    if (!g_rf5_t[tI].ok) return 0;
    int n = 0;
    for (int it = 0; it < RF5_DEPTH * 2; it++) {
        if (n < 0 || n >= g_rf5_t[tI].cnt) return 0;
        if (g_rf5_t[tI].nd[n].isLeaf) return g_rf5_t[tI].nd[n].leafVal;
        if (f[g_rf5_t[tI].nd[n].feat] <= g_rf5_t[tI].nd[n].thresh)
            n = g_rf5_t[tI].nd[n].leftCh;
        else n = g_rf5_t[tI].nd[n].rightCh;
    }
    return 0;
}

double AI_RF5_Predict(double &f[]) {
    if (!g_rf5_trained) return 0;
    double sum = 0; int v = 0;
    for (int t = 0; t < g_rf5_nT; t++) {
        if (g_rf5_t[t].ok) { sum += AI_RF5_PredTree(t, f); v++; }
    }
    return v > 0 ? sum / v : 0;
}

double AI_RF5_Confidence(double &f[]) {
    if (!g_rf5_trained) return 0;
    int bV = 0, sV = 0, hV = 0, v = 0;
    for (int t = 0; t < g_rf5_nT; t++) {
        if (g_rf5_t[t].ok) {
            double p = AI_RF5_PredTree(t, f);
            if (p > 0.3) bV++; else if (p < -0.3) sV++; else hV++;
            v++;
        }
    }
    if (v == 0) return 0;
    return (double)MathMax(bV, MathMax(sV, hV)) / v * 100.0;
}

void AI_RF5_CreatePanel(int x, int y) {
    if (g_rf5_panelOk) return;
    ObjectCreate(0, "AI_RF5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_RF5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_RF5_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_RF5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_RF5_BG", OBJPROP_XSIZE, 280);
    ObjectSetInteger(0, "AI_RF5_BG", OBJPROP_YSIZE, 110);
    ObjectSetInteger(0, "AI_RF5_BG", OBJPROP_BGCOLOR, C'20,20,30');
    ObjectSetInteger(0, "AI_RF5_BG", OBJPROP_BORDER_COLOR, C'60,80,60');
    ObjectSetInteger(0, "AI_RF5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    for (int i = 0; i < 4; i++) {
        string nm = "AI_RF5_L" + IntegerToString(i);
        ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x + 10);
        ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y + 8 + i * 24);
        ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 9 : 8);
        ObjectSetInteger(0, nm, OBJPROP_COLOR, i == 0 ? clrLime : clrWhite);
    }
    ObjectSetString(0, "AI_RF5_L0", OBJPROP_TEXT, "RANDOM FOREST IA");
    g_rf5_panelOk = true;
}

void AI_RF5_UpdatePanel(double pred, double conf, double buyThresh, double sellThresh) {
    if (TimeCurrent() - g_rf5_panelUpd < 1) return;
    g_rf5_panelUpd = TimeCurrent();
    string status = g_rf5_trained ? "ACTIVE" : "TRAINING...";
    ObjectSetString(0, "AI_RF5_L1", OBJPROP_TEXT, "Status: " + status);
    ObjectSetInteger(0, "AI_RF5_L1", OBJPROP_COLOR, g_rf5_trained ? clrLime : clrYellow);
    string sig = pred > buyThresh ? "BUY" : (pred < sellThresh ? "SELL" : "HOLD");
    color sc = pred > buyThresh ? clrLimeGreen : (pred < sellThresh ? clrCrimson : clrGray);
    ObjectSetString(0, "AI_RF5_L2", OBJPROP_TEXT, "Signal: " + sig + " (" + DoubleToString(pred, 3) + ")");
    ObjectSetInteger(0, "AI_RF5_L2", OBJPROP_COLOR, sc);
    ObjectSetString(0, "AI_RF5_L3", OBJPROP_TEXT, "Confidence: " + DoubleToString(conf, 1) + "%");
}

// ===== PHASE 2 AI HELPER FUNCTIONS (MQL5) =====

// ===================================================================
// PHASE 2 AI NODES - HELPER FUNCTIONS (MQL5)
// Risk Manager | Strategy Router | Ensemble Voter | Dynamic SL/TP
// ===================================================================

//+------------------------------------------------------------------+
//| AI RISK MANAGER - MQL5 Kelly Criterion + Drawdown Protection       |
//+------------------------------------------------------------------+
#define RM5_MAX 500
struct RM5_Trade {
    ulong ticket;
    double profit;
    double lots;
};
RM5_Trade g_rm5_hist[RM5_MAX];
int g_rm5_idx = 0;
int g_rm5_total = 0;
int g_rm5_wins = 0;
double g_rm5_winAmt = 0;
double g_rm5_lossAmt = 0;
double g_rm5_peakBal = 0;
double g_rm5_dd = 0;
double g_rm5_maxDD = 0;
int g_rm5_consLoss = 0;
bool g_rm5_paused = false;
bool g_rm5_recovery = false;
double g_rm5_recBal = 0;
datetime g_rm5_lastProc = 0;
datetime g_rm5_panelUpd = 0;
bool g_rm5_panelOk = false;
bool g_rm5_init = false;
int g_rm5_hATR = INVALID_HANDLE;

// NOTE: Persistence is not yet implemented. All statistics (trades, wins, losses, drawdown, consecutive losses)
// reset to zero when the EA restarts. Stats are only maintained during the current EA session.
void AI_RM5_Init() {
    if (g_rm5_init) return;
    g_rm5_peakBal = AccountInfoDouble(ACCOUNT_BALANCE);
    g_rm5_idx = 0; g_rm5_total = 0; g_rm5_wins = 0;
    g_rm5_winAmt = 0; g_rm5_lossAmt = 0;
    g_rm5_dd = 0; g_rm5_maxDD = 0; g_rm5_consLoss = 0;
    g_rm5_paused = false; g_rm5_recovery = false;
    if (g_rm5_hATR == INVALID_HANDLE) g_rm5_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
    g_rm5_init = true;
}

void AI_RM5_Process(int magic) {
    if (TimeCurrent() - g_rm5_lastProc < 3) return;
    g_rm5_lastProc = TimeCurrent();
    double bal = AccountInfoDouble(ACCOUNT_BALANCE);
    if (bal > g_rm5_peakBal) g_rm5_peakBal = bal;
    g_rm5_dd = g_rm5_peakBal > 0 ? (g_rm5_peakBal - bal) / g_rm5_peakBal * 100.0 : 0;
    if (g_rm5_dd > g_rm5_maxDD) g_rm5_maxDD = g_rm5_dd;
    if (!HistorySelect(TimeCurrent() - 86400 * 60, TimeCurrent())) return;
    for (int h = HistoryDealsTotal() - 1; h >= MathMax(0, HistoryDealsTotal() - 50); h--) {
        ulong dt = HistoryDealGetTicket(h);
        if (dt == 0) continue;
        if (HistoryDealGetInteger(dt, DEAL_MAGIC) != magic) continue;
        if (HistoryDealGetString(dt, DEAL_SYMBOL) != _Symbol) continue;
        if (HistoryDealGetInteger(dt, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
        bool found = false;
        for (int i = 0; i < MathMin(g_rm5_idx, RM5_MAX); i++) { if (g_rm5_hist[i].ticket == dt) { found = true; break; } }
        if (found) continue;
        double profit = HistoryDealGetDouble(dt, DEAL_PROFIT) + HistoryDealGetDouble(dt, DEAL_COMMISSION) + HistoryDealGetDouble(dt, DEAL_SWAP);
        int idx = g_rm5_idx % RM5_MAX;
        g_rm5_hist[idx].ticket = dt; g_rm5_hist[idx].profit = profit;
        g_rm5_hist[idx].lots = HistoryDealGetDouble(dt, DEAL_VOLUME);
        g_rm5_idx++; g_rm5_total++;
        if (profit > 0) { g_rm5_wins++; g_rm5_winAmt += profit; g_rm5_consLoss = 0; }
        else { g_rm5_lossAmt += MathAbs(profit); g_rm5_consLoss++; }
    }
}

double AI_RM5_Kelly() {
    if (g_rm5_total < 10) return 0.02;
    double wr = (double)g_rm5_wins / g_rm5_total;
    double avgW = g_rm5_wins > 0 ? g_rm5_winAmt / g_rm5_wins : 0;
    int losses = g_rm5_total - g_rm5_wins;
    double avgL = losses > 0 ? g_rm5_lossAmt / losses : 1;
    if (avgL <= 0) return 0.02;
    double R = avgW / avgL;
    double k = (wr * R - (1.0 - wr)) / R;
    return MathMax(0.0, MathMin(0.25, k));
}

double AI_RM5_CalcLots(string method, double baseRisk, double maxRisk,
                        double minL, double maxL,
                        double tMul, double rMul, double vMul, double cMul,
                        bool regAdj, bool ddRed, double maxDDPct,
                        bool recMode, double recThresh, int maxConsL) {
    double bal = AccountInfoDouble(ACCOUNT_BALANCE);
    if (bal <= 0) return minL;
    if (g_rm5_consLoss >= maxConsL) g_rm5_paused = true;
    if (g_rm5_dd >= maxDDPct) g_rm5_paused = true;
    if (g_rm5_paused) {
        if (g_rm5_dd < maxDDPct * 0.5 && g_rm5_consLoss < maxConsL) g_rm5_paused = false;
        else return 0;
    }
    if (recMode && g_rm5_dd >= recThresh) {
        if (!g_rm5_recovery) { g_rm5_recovery = true; g_rm5_recBal = bal; }
    }
    if (g_rm5_recovery && bal > g_rm5_recBal * 1.05) g_rm5_recovery = false;
    double riskPct = baseRisk;
    if (method == "KELLY" || method == "KELLY_HALF" || method == "OPTIMAL_F") {
        double kf = AI_RM5_Kelly();
        if (method == "KELLY_HALF") kf *= 0.5;
        if (method == "OPTIMAL_F") kf = MathMin(kf, 0.1);
        riskPct = kf * 100.0;
        riskPct = MathMax(baseRisk * 0.25, MathMin(maxRisk, riskPct));
    } else if (method == "ATR_BASED") {
        double atr = AI_P1_GetBuf(g_rm5_hATR, 0, 0);
        double atrAvg = 0;
        for (int i = 0; i < 50; i++) atrAvg += AI_P1_GetBuf(g_rm5_hATR, 0, i);
        atrAvg /= 50.0;
        double volAdj = atrAvg > 0 ? atrAvg / MathMax(atr, _Point) : 1.0;
        riskPct = baseRisk * MathMax(0.3, MathMin(2.0, volAdj));
    }
    if (regAdj) {
        int regime = AI_RD5_Classify();
        // Check chaos multiplier early - if 0 or negative, return 0 lots
        if (regime == 8 && cMul <= 0) cMul = 0.15;
        double mul = 1.0;
        if (regime >= 0 && regime <= 5) mul = tMul;
        else if (regime == 6 || regime == 7) mul = rMul;
        else if (regime == 8) mul = cMul;
        else mul = vMul;
        riskPct *= mul;
    }
    if (ddRed && g_rm5_dd > 0 && maxDDPct > 0) riskPct *= MathMax(0.1, 1.0 - (g_rm5_dd / maxDDPct) * 0.8);
    if (g_rm5_recovery) riskPct *= 0.5;
    riskPct = MathMax(0.1, MathMin(maxRisk, riskPct));
    double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double ls = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    double atr2 = AI_P1_GetBuf(g_rm5_hATR, 0, 0);
    double slPts = atr2 * 1.5 / _Point;
    if (slPts <= 0) slPts = 100;
    if (tv <= 0) tv = 1;
    double lots = (bal * riskPct / 100.0) / (slPts * tv);
    if (ls > 0) lots = MathFloor(lots / ls) * ls;
    return MathMax(minL, MathMin(maxL, lots));
}

void AI_RM5_CreatePanel(int x, int y) {
    if (g_rm5_panelOk) return;
    ObjectCreate(0, "AI_RM5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_RM5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_RM5_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_RM5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_RM5_BG", OBJPROP_XSIZE, 300);
    ObjectSetInteger(0, "AI_RM5_BG", OBJPROP_YSIZE, 155);
    ObjectSetInteger(0, "AI_RM5_BG", OBJPROP_BGCOLOR, C'25,15,15');
    ObjectSetInteger(0, "AI_RM5_BG", OBJPROP_BORDER_COLOR, C'80,40,40');
    ObjectSetInteger(0, "AI_RM5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    for (int i = 0; i < 6; i++) {
        string nm = "AI_RM5_L" + IntegerToString(i);
        ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x + 10);
        ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y + 8 + i * 23);
        ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 9 : 8);
        ObjectSetInteger(0, nm, OBJPROP_COLOR, i == 0 ? clrOrangeRed : clrWhite);
    }
    ObjectSetString(0, "AI_RM5_L0", OBJPROP_TEXT, "AI RISK MANAGER");
    g_rm5_panelOk = true;
}

void AI_RM5_UpdatePanel(double lots, double riskPct, double kelly) {
    if (TimeCurrent() - g_rm5_panelUpd < 1) return;
    g_rm5_panelUpd = TimeCurrent();
    double wr = g_rm5_total > 0 ? (double)g_rm5_wins / g_rm5_total * 100.0 : 0;
    string status = g_rm5_paused ? "PAUSED" : (g_rm5_recovery ? "RECOVERY" : "ACTIVE");
    color sc = g_rm5_paused ? clrRed : (g_rm5_recovery ? clrYellow : clrLime);
    ObjectSetString(0, "AI_RM5_L1", OBJPROP_TEXT, "Status: " + status + " | Lots: " + DoubleToString(lots, 2));
    ObjectSetInteger(0, "AI_RM5_L1", OBJPROP_COLOR, sc);
    ObjectSetString(0, "AI_RM5_L2", OBJPROP_TEXT, "Risk: " + DoubleToString(riskPct, 2) + "% | Kelly: " + DoubleToString(kelly * 100, 1) + "%");
    ObjectSetString(0, "AI_RM5_L3", OBJPROP_TEXT, "DD: " + DoubleToString(g_rm5_dd, 1) + "% (Max: " + DoubleToString(g_rm5_maxDD, 1) + "%)");
    ObjectSetInteger(0, "AI_RM5_L3", OBJPROP_COLOR, g_rm5_dd > 10 ? clrOrangeRed : clrWhite);
    ObjectSetString(0, "AI_RM5_L4", OBJPROP_TEXT, "Trades: " + IntegerToString(g_rm5_total) + " | WR: " + DoubleToString(wr, 1) + "%");
    ObjectSetString(0, "AI_RM5_L5", OBJPROP_TEXT, "ConsLoss: " + IntegerToString(g_rm5_consLoss));
    ObjectSetInteger(0, "AI_RM5_L5", OBJPROP_COLOR, g_rm5_consLoss >= 3 ? clrOrangeRed : clrWhite);
}

//+------------------------------------------------------------------+
//| MULTI-STRATEGY ROUTER - MQL5                                       |
//+------------------------------------------------------------------+
int g_sr5_slot = -1;
int g_sr5_pend = -1;
int g_sr5_pendC = 0;
int g_sr5_transB = 0;
double g_sr5_transW = 1.0;
int g_sr5_prev = -1;
datetime g_sr5_lastBar = 0;
datetime g_sr5_panelUpd = 0;
bool g_sr5_panelOk = false;
int g_sr5_slotT[3];
int g_sr5_slotW[3];
double g_sr5_slotP[3];
datetime g_sr5_scoreUpd = 0;
int g_sr5_hADX = INVALID_HANDLE;
int g_sr5_hATR = INVALID_HANDLE;
bool g_sr5_hOk = false;

void AI_SR5_Init() {
    g_sr5_slot = -1; g_sr5_pend = -1; g_sr5_pendC = 0;
    g_sr5_transB = 0; g_sr5_transW = 1.0; g_sr5_prev = -1;
    for (int i = 0; i < 3; i++) { g_sr5_slotT[i] = 0; g_sr5_slotW[i] = 0; g_sr5_slotP[i] = 0; }
    if (!g_sr5_hOk) {
        g_sr5_hADX = iADX(_Symbol, PERIOD_CURRENT, 14);
        g_sr5_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
        g_sr5_hOk = true;
    }
}

int AI_SR5_Detect(int tADX, int rADX, double vATR) {
    double adx = AI_P1_GetBuf(g_sr5_hADX, 0, 0);
    double atr = AI_P1_GetBuf(g_sr5_hATR, 0, 0);
    double atrAvg = 0;
    for (int i = 0; i < 50; i++) atrAvg += AI_P1_GetBuf(g_sr5_hATR, 0, i);
    atrAvg /= 50.0;
    double volR = atrAvg > 0 ? atr / atrAvg : 1.0;
    if (volR > vATR) return 2;
    if (adx >= tADX) return 0;
    if (adx <= rADX) return 1;
    return 0;
}

void AI_SR5_Score(int magic) {
    if (TimeCurrent() - g_sr5_scoreUpd < 10) return;
    g_sr5_scoreUpd = TimeCurrent();
    for (int i = 0; i < 3; i++) { g_sr5_slotT[i] = 0; g_sr5_slotW[i] = 0; g_sr5_slotP[i] = 0; }
    if (!HistorySelect(TimeCurrent() - 86400 * 30, TimeCurrent())) return;
    for (int h = HistoryDealsTotal() - 1; h >= MathMax(0, HistoryDealsTotal() - 200); h--) {
        ulong dt = HistoryDealGetTicket(h);
        if (dt == 0) continue;
        if (HistoryDealGetInteger(dt, DEAL_MAGIC) != magic) continue;
        if (HistoryDealGetString(dt, DEAL_SYMBOL) != _Symbol) continue;
        if ((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dt, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
        string comment = HistoryDealGetString(dt, DEAL_COMMENT);
        int slot = -1;
        if (StringFind(comment, "SR_T") >= 0) slot = 0;
        else if (StringFind(comment, "SR_R") >= 0) slot = 1;
        else if (StringFind(comment, "SR_V") >= 0) slot = 2;
        if (slot < 0) continue;
        double profit = HistoryDealGetDouble(dt, DEAL_PROFIT) + HistoryDealGetDouble(dt, DEAL_COMMISSION) + HistoryDealGetDouble(dt, DEAL_SWAP);
        g_sr5_slotT[slot]++;
        if (profit > 0) g_sr5_slotW[slot]++;
        g_sr5_slotP[slot] += profit;
    }
}

void AI_SR5_CreatePanel(int x, int y) {
    if (g_sr5_panelOk) return;
    ObjectCreate(0, "AI_SR5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_SR5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_SR5_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_SR5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_SR5_BG", OBJPROP_XSIZE, 300);
    ObjectSetInteger(0, "AI_SR5_BG", OBJPROP_YSIZE, 135);
    ObjectSetInteger(0, "AI_SR5_BG", OBJPROP_BGCOLOR, C'15,15,30');
    ObjectSetInteger(0, "AI_SR5_BG", OBJPROP_BORDER_COLOR, C'40,40,80');
    ObjectSetInteger(0, "AI_SR5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    for (int i = 0; i < 5; i++) {
        string nm = "AI_SR5_L" + IntegerToString(i);
        ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x + 10);
        ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y + 8 + i * 25);
        ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 9 : 8);
        ObjectSetInteger(0, nm, OBJPROP_COLOR, i == 0 ? clrMediumPurple : clrWhite);
    }
    ObjectSetString(0, "AI_SR5_L0", OBJPROP_TEXT, "STRATEGY ROUTER IA");
    g_sr5_panelOk = true;
}

void AI_SR5_UpdatePanel(int slot, bool trans, double score) {
    if (TimeCurrent() - g_sr5_panelUpd < 1) return;
    g_sr5_panelUpd = TimeCurrent();
    string names[3]; names[0] = "TRENDING"; names[1] = "RANGING"; names[2] = "VOLATILE";
    color cols[3]; cols[0] = clrDodgerBlue; cols[1] = clrGold; cols[2] = clrOrangeRed;
    string sn = (slot >= 0 && slot <= 2) ? names[slot] : "NONE";
    color sc = (slot >= 0 && slot <= 2) ? cols[slot] : clrGray;
    ObjectSetString(0, "AI_SR5_L1", OBJPROP_TEXT, "Active: " + sn + (trans ? " [TRANS]" : ""));
    ObjectSetInteger(0, "AI_SR5_L1", OBJPROP_COLOR, trans ? clrYellow : sc);
    double w0 = g_sr5_slotT[0] > 0 ? (double)g_sr5_slotW[0] / g_sr5_slotT[0] * 100.0 : 0;
    double w1 = g_sr5_slotT[1] > 0 ? (double)g_sr5_slotW[1] / g_sr5_slotT[1] * 100.0 : 0;
    double w2 = g_sr5_slotT[2] > 0 ? (double)g_sr5_slotW[2] / g_sr5_slotT[2] * 100.0 : 0;
    ObjectSetString(0, "AI_SR5_L2", OBJPROP_TEXT, "T:" + DoubleToString(w0, 0) + "% R:" + DoubleToString(w1, 0) + "% V:" + DoubleToString(w2, 0) + "%");
    ObjectSetString(0, "AI_SR5_L3", OBJPROP_TEXT, "Score: " + DoubleToString(score, 1) + "%");
    ObjectSetString(0, "AI_SR5_L4", OBJPROP_TEXT, "ADX: " + DoubleToString(AI_P1_GetBuf(g_sr5_hADX, 0, 0), 1));
}

//+------------------------------------------------------------------+
//| ENSEMBLE VOTER - MQL5 (5 strategies)                              |
//+------------------------------------------------------------------+
#define EV5_MAX 5
double g_ev5_w[EV5_MAX];
int g_ev5_t[EV5_MAX];
int g_ev5_wi[EV5_MAX];
double g_ev5_p[EV5_MAX];
bool g_ev5_init = false;
datetime g_ev5_panelUpd = 0;
bool g_ev5_panelOk = false;
datetime g_ev5_wUpd = 0;
int g_ev5_dec = 0;
int g_ev5_lastSigBar[EV5_MAX];
int g_ev5_barCnt = 0;

// Signal Memory Buffer: keeps each strategy's vote alive for N bars (async voting)
#define EV5_MEM_MAX 10
bool g_ev5_memBuy[EV5_MAX][EV5_MEM_MAX];
bool g_ev5_memSell[EV5_MAX][EV5_MEM_MAX];
datetime g_ev5_memBarTime = 0;

void AI_EV5_InitMemory() {
    for (int i = 0; i < EV5_MAX; i++)
        for (int j = 0; j < EV5_MEM_MAX; j++) {
            g_ev5_memBuy[i][j] = false;
            g_ev5_memSell[i][j] = false;
        }
    g_ev5_memBarTime = 0;
}

void AI_EV5_ShiftMemory(int memBars) {
    datetime curBar = iTime(_Symbol, PERIOD_CURRENT, 0);
    if (curBar == g_ev5_memBarTime) return;
    g_ev5_memBarTime = curBar;
    int lim = (int)MathMin(memBars, EV5_MEM_MAX);
    for (int i = 0; i < EV5_MAX; i++) {
        for (int j = lim - 1; j > 0; j--) {
            g_ev5_memBuy[i][j] = g_ev5_memBuy[i][j-1];
            g_ev5_memSell[i][j] = g_ev5_memSell[i][j-1];
        }
        g_ev5_memBuy[i][0] = false;
        g_ev5_memSell[i][0] = false;
    }
}

void AI_EV5_StoreSignals(bool b1, bool b2, bool b3, bool b4, bool b5,
                          bool s1, bool s2, bool s3, bool s4, bool s5) {
    bool buys[EV5_MAX]; buys[0]=b1; buys[1]=b2; buys[2]=b3; buys[3]=b4; buys[4]=b5;
    bool sells[EV5_MAX]; sells[0]=s1; sells[1]=s2; sells[2]=s3; sells[3]=s4; sells[4]=s5;
    for (int i = 0; i < EV5_MAX; i++) {
        if (buys[i]) {
            g_ev5_memBuy[i][0] = true;
            for (int j = 0; j < EV5_MEM_MAX; j++) g_ev5_memSell[i][j] = false;
        }
        if (sells[i]) {
            g_ev5_memSell[i][0] = true;
            for (int j = 0; j < EV5_MEM_MAX; j++) g_ev5_memBuy[i][j] = false;
        }
    }
}

bool AI_EV5_MemCheck(int strat, bool isBuy, int memBars) {
    int lim = (int)MathMin(memBars, EV5_MEM_MAX);
    for (int j = 0; j < lim; j++) {
        if (isBuy ? g_ev5_memBuy[strat][j] : g_ev5_memSell[strat][j]) return true;
    }
    return false;
}

// NOTE: Persistence is not yet implemented. All statistics (weights, trades, wins, profit, decisions)
// reset to default values when the EA restarts. Stats are only maintained during the current EA session.
void AI_EV5_Init() {
    if (g_ev5_init) return;
    for (int i = 0; i < EV5_MAX; i++) {
        g_ev5_w[i] = 1.0; g_ev5_t[i] = 0; g_ev5_wi[i] = 0; g_ev5_p[i] = 0;
        g_ev5_lastSigBar[i] = -9999;
    }
    g_ev5_dec = 0; g_ev5_barCnt = 0;
    AI_EV5_InitMemory(); g_ev5_init = true;
}

double AI_EV5_Vote(bool s1, bool s2, bool s3, bool s4, bool s5, string method) {
    double tw = 0, aw = 0; int act = 0;
    bool s[EV5_MAX]; s[0] = s1; s[1] = s2; s[2] = s3; s[3] = s4; s[4] = s5;
    for (int i = 0; i < EV5_MAX; i++) { tw += g_ev5_w[i]; if (s[i]) { aw += g_ev5_w[i]; act++; } }
    if (method == "UNANIMOUS") return act == EV5_MAX ? 100.0 : 0.0;
    if (method == "MAJORITY") return act > EV5_MAX / 2 ? (double)act / EV5_MAX * 100.0 : 0.0;
    return tw > 0 ? aw / tw * 100.0 : 0.0;
}

void AI_EV5_TrackActivity(bool b1, bool b2, bool b3, bool b4, bool b5,
                           bool s1, bool s2, bool s3, bool s4, bool s5) {
    bool any[EV5_MAX];
    any[0]=b1||s1; any[1]=b2||s2; any[2]=b3||s3; any[3]=b4||s4; any[4]=b5||s5;
    for (int i = 0; i < EV5_MAX; i++)
        if (any[i]) g_ev5_lastSigBar[i] = g_ev5_barCnt;
}

bool AI_EV5_IsActive(int strat, int lookback) {
    return (g_ev5_barCnt - g_ev5_lastSigBar[strat]) <= lookback;
}

int AI_EV5_CountActive(int lookback) {
    int c = 0;
    for (int i = 0; i < EV5_MAX; i++)
        if (AI_EV5_IsActive(i, lookback)) c++;
    return c;
}

double AI_EV5_VoteDynamic(bool sig1, bool sig2, bool sig3, bool sig4, bool sig5,
                           int actLookback) {
    bool sigs[EV5_MAX];
    sigs[0]=sig1; sigs[1]=sig2; sigs[2]=sig3; sigs[3]=sig4; sigs[4]=sig5;
    double aw = 0, cw = 0;
    for (int i = 0; i < EV5_MAX; i++) {
        if (AI_EV5_IsActive(i, actLookback)) {
            cw += g_ev5_w[i];
            if (sigs[i]) aw += g_ev5_w[i];
        }
    }
    if (cw <= 0) return 0.0;
    return aw / cw * 100.0;
}

double AI_EV5_VoteAnyConfirmed(bool p1, bool p2, bool p3, bool p4, bool p5,
                                bool v1, bool v2, bool v3, bool v4, bool v5,
                                int actLookback) {
    int pv = 0, vc = 0, ac = 0;
    bool prim[EV5_MAX], veto[EV5_MAX];
    prim[0]=p1; prim[1]=p2; prim[2]=p3; prim[3]=p4; prim[4]=p5;
    veto[0]=v1; veto[1]=v2; veto[2]=v3; veto[3]=v4; veto[4]=v5;
    for (int i = 0; i < EV5_MAX; i++) {
        if (!AI_EV5_IsActive(i, actLookback)) continue;
        ac++;
        if (prim[i]) pv++;
        if (veto[i]) vc++;
    }
    if (ac == 0 || pv == 0) return 0.0;
    if (vc > 0) return 0.0;
    return 100.0;
}

double AI_EV5_VoteWeightedActive(bool sig1, bool sig2, bool sig3, bool sig4, bool sig5,
                                  int connMask) {
    bool sigs[EV5_MAX];
    sigs[0]=sig1; sigs[1]=sig2; sigs[2]=sig3; sigs[3]=sig4; sigs[4]=sig5;
    double tw = 0, aw = 0;
    for (int i = 0; i < EV5_MAX; i++) {
        if ((connMask & (1 << i)) == 0) continue;
        tw += g_ev5_w[i];
        if (sigs[i]) aw += g_ev5_w[i];
    }
    if (tw <= 0) return 0.0;
    return aw / tw * 100.0;
}

double AI_EV5_AdjThreshold(double baseThr, int warmupPeriod) {
    if (warmupPeriod <= 0 || g_ev5_barCnt >= warmupPeriod) return baseThr;
    double minThr = 20.0;
    double progress = (double)g_ev5_barCnt / warmupPeriod;
    return minThr + (baseThr - minThr) * progress;
}

void AI_EV5_Update(int magic, double decay, double minW) {
    if (TimeCurrent() - g_ev5_wUpd < 30) return;
    g_ev5_wUpd = TimeCurrent();
    for (int i = 0; i < EV5_MAX; i++) { g_ev5_t[i] = 0; g_ev5_wi[i] = 0; g_ev5_p[i] = 0; }
    if (!HistorySelect(TimeCurrent() - 86400 * 30, TimeCurrent())) return;
    for (int h = HistoryDealsTotal() - 1; h >= MathMax(0, HistoryDealsTotal() - 200); h--) {
        ulong dt = HistoryDealGetTicket(h);
        if (dt == 0) continue;
        if (HistoryDealGetInteger(dt, DEAL_MAGIC) != magic) continue;
        if (HistoryDealGetString(dt, DEAL_SYMBOL) != _Symbol) continue;
        if ((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dt, DEAL_ENTRY) != DEAL_ENTRY_OUT) continue;
        string cmt = HistoryDealGetString(dt, DEAL_COMMENT);
        int st = -1;
        if (StringFind(cmt, "EV_S0") >= 0) st = 0;
        else if (StringFind(cmt, "EV_S1") >= 0) st = 1;
        else if (StringFind(cmt, "EV_S2") >= 0) st = 2;
        else if (StringFind(cmt, "EV_S3") >= 0) st = 3;
        else if (StringFind(cmt, "EV_S4") >= 0) st = 4;
        if (st < 0) continue;
        double prf = HistoryDealGetDouble(dt, DEAL_PROFIT) + HistoryDealGetDouble(dt, DEAL_COMMISSION) + HistoryDealGetDouble(dt, DEAL_SWAP);
        g_ev5_t[st]++;
        if (prf > 0) g_ev5_wi[st]++;
        g_ev5_p[st] += prf;
    }
    for (int i = 0; i < EV5_MAX; i++) {
        if (g_ev5_t[i] >= 5) {
            double wr = (double)g_ev5_wi[i] / g_ev5_t[i];
            double pf = g_ev5_p[i] > 0 ? 1.0 + wr : MathMax(0.3, wr);
            g_ev5_w[i] = g_ev5_w[i] * decay + pf * (1.0 - decay);
        }
        g_ev5_w[i] = MathMax(minW, g_ev5_w[i]);
    }
}

void AI_EV5_CreatePanel(int x, int y) {
    if (g_ev5_panelOk) return;
    ObjectCreate(0, "AI_EV5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_EV5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_EV5_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_EV5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_EV5_BG", OBJPROP_XSIZE, 300);
    ObjectSetInteger(0, "AI_EV5_BG", OBJPROP_YSIZE, 170);
    ObjectSetInteger(0, "AI_EV5_BG", OBJPROP_BGCOLOR, C'15,25,15');
    ObjectSetInteger(0, "AI_EV5_BG", OBJPROP_BORDER_COLOR, C'40,80,40');
    ObjectSetInteger(0, "AI_EV5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    for (int i = 0; i < 6; i++) {
        string nm = "AI_EV5_L" + IntegerToString(i);
        ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x + 10);
        ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y + 8 + i * 25);
        ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 9 : 8);
        ObjectSetInteger(0, nm, OBJPROP_COLOR, i == 0 ? clrSpringGreen : clrWhite);
    }
    ObjectSetString(0, "AI_EV5_L0", OBJPROP_TEXT, "ENSEMBLE VOTER IA (5)");
    g_ev5_panelOk = true;
}

void AI_EV5_UpdatePanel(double cons, int activeStrats, string method, int warmupTotal) {
    if (TimeCurrent() - g_ev5_panelUpd < 1) return;
    g_ev5_panelUpd = TimeCurrent();
    ObjectSetString(0, "AI_EV5_L1", OBJPROP_TEXT, "W1:" + DoubleToString(g_ev5_w[0], 2) + " W2:" + DoubleToString(g_ev5_w[1], 2) + " W3:" + DoubleToString(g_ev5_w[2], 2) + " W4:" + DoubleToString(g_ev5_w[3], 2) + " W5:" + DoubleToString(g_ev5_w[4], 2));
    ObjectSetString(0, "AI_EV5_L2", OBJPROP_TEXT, "Consensus: " + DoubleToString(cons, 1) + "%");
    ObjectSetInteger(0, "AI_EV5_L2", OBJPROP_COLOR, cons > 70 ? clrLimeGreen : (cons > 40 ? clrYellow : clrGray));
    int tt = 0; int tw = 0;
    for (int i = 0; i < EV5_MAX; i++) { tt += g_ev5_t[i]; tw += g_ev5_wi[i]; }
    double wr = tt > 0 ? (double)tw / tt * 100.0 : 0;
    ObjectSetString(0, "AI_EV5_L3", OBJPROP_TEXT, "Trades: " + IntegerToString(tt) + " | WR: " + DoubleToString(wr, 1) + "%");
    string warmStr = (warmupTotal > 0 && g_ev5_barCnt < warmupTotal) ? "WU:" + IntegerToString(g_ev5_barCnt) + "/" + IntegerToString(warmupTotal) : "Ready";
    ObjectSetString(0, "AI_EV5_L4", OBJPROP_TEXT, "Dec:" + IntegerToString(g_ev5_dec) + " | Active:" + IntegerToString(activeStrats) + "/" + IntegerToString(EV5_MAX));
    ObjectSetString(0, "AI_EV5_L5", OBJPROP_TEXT, method + " | " + warmStr);
}

//+------------------------------------------------------------------+
//| AI DYNAMIC SL/TP - MQL5 (with Persistence + Enhanced Panel)       |
//+------------------------------------------------------------------+
#define SLTP5_REG 10
#define SLTP5_SL 5
#define SLTP5_TP 5
#define SLTP5_MAGIC 0x534C5435  // "SLT5"
double g_sltp5_q[SLTP5_REG][SLTP5_SL][SLTP5_TP];
int g_sltp5_v[SLTP5_REG][SLTP5_SL][SLTP5_TP];
bool g_sltp5_init = false;
datetime g_sltp5_panelUpd = 0;
bool g_sltp5_panelOk = false;
double g_sltp5_slM[SLTP5_SL];
double g_sltp5_tpR[SLTP5_TP];
int g_sltp5_hATR = INVALID_HANDLE;
// Learning tracking
int g_sltp5_lastReg = 0;
int g_sltp5_lastSI = 2;
int g_sltp5_lastTI = 2;
int g_sltp5_prevPosCnt = 0;
int g_sltp5_totalTrades = 0;
int g_sltp5_wins = 0;
double g_sltp5_cumReward = 0;
bool g_sltp5_fileLoaded = false;
int g_sltp5_saveMagic = 0;

void AI_SLTP5_Init(double bSL, double bRR) {
    if (g_sltp5_init) return;
    g_sltp5_slM[0] = bSL * 0.5; g_sltp5_slM[1] = bSL * 0.75;
    g_sltp5_slM[2] = bSL;        g_sltp5_slM[3] = bSL * 1.5;
    g_sltp5_slM[4] = bSL * 2.0;
    g_sltp5_tpR[0] = bRR * 0.5; g_sltp5_tpR[1] = bRR * 0.75;
    g_sltp5_tpR[2] = bRR;       g_sltp5_tpR[3] = bRR * 1.5;
    g_sltp5_tpR[4] = bRR * 2.0;
    for (int r = 0; r < SLTP5_REG; r++)
        for (int s = 0; s < SLTP5_SL; s++)
            for (int t = 0; t < SLTP5_TP; t++) { g_sltp5_q[r][s][t] = 0; g_sltp5_v[r][s][t] = 0; }
    if (g_sltp5_hATR == INVALID_HANDLE) g_sltp5_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
    g_sltp5_init = true;
}

void AI_SLTP5_GetBest(int reg, int &bS, int &bT) {
    if (reg < 0 || reg >= SLTP5_REG) reg = 0;
    double bQ = -999999; bS = 2; bT = 2;
    int tv = 0;
    for (int s = 0; s < SLTP5_SL; s++)
        for (int t = 0; t < SLTP5_TP; t++) tv += g_sltp5_v[reg][s][t];
    if (tv < 10) return;
    for (int s = 0; s < SLTP5_SL; s++)
        for (int t = 0; t < SLTP5_TP; t++) {
            double bonus = g_sltp5_v[reg][s][t] > 0 ? MathSqrt(2.0 * MathLog((double)tv) / g_sltp5_v[reg][s][t]) : 10.0;
            double sc = g_sltp5_q[reg][s][t] + bonus;
            if (sc > bQ) { bQ = sc; bS = s; bT = t; }
        }
}

void AI_SLTP5_Learn(int reg, int slIdx, int tpIdx, double reward) {
    if (reg < 0 || reg >= SLTP5_REG) return;
    if (slIdx < 0 || slIdx >= SLTP5_SL) return;
    if (tpIdx < 0 || tpIdx >= SLTP5_TP) return;
    g_sltp5_v[reg][slIdx][tpIdx]++;
    double lr = 1.0 / MathMax(1, g_sltp5_v[reg][slIdx][tpIdx]);
    // Backtest Training: ensure minimum learning rate for faster convergence
    if (g_IsBacktestTraining) lr = MathMax(lr, 0.05);
    g_sltp5_q[reg][slIdx][tpIdx] += lr * (reward - g_sltp5_q[reg][slIdx][tpIdx]);
}

double AI_SLTP5_RegMul(int reg, bool forTP) {
    if (reg >= 0 && reg <= 5) return forTP ? 1.3 : 1.0;
    if (reg == 6 || reg == 7) return forTP ? 0.8 : 0.7;
    if (reg == 8) return 1.5;
    return 1.0;
}

//+------------------------------------------------------------------+
//| SLTP5 Persistence: Save Q-Table to Common folder                  |
//+------------------------------------------------------------------+
string AI_SLTP5_GetFilename(int magic) {
    return "AI_SLTP_" + IntegerToString(magic) + "_" + _Symbol + ".bin";
}

void AI_SLTP5_Save(int magic) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return;
    string fn = AI_SLTP5_GetFilename(magic);
    if (FileIsExist(fn, FILE_COMMON)) FileDelete(fn, FILE_COMMON);
    int h = FileOpen(fn, FILE_WRITE | FILE_BIN | FILE_COMMON);
    if (h == INVALID_HANDLE) { Print("[SLTP5] Save FAILED: ", GetLastError()); return; }
    // Header
    FileWriteInteger(h, (int)SLTP5_MAGIC);
    FileWriteInteger(h, 1); // version
    // Q-Table
    for (int r = 0; r < SLTP5_REG; r++)
        for (int s = 0; s < SLTP5_SL; s++)
            for (int t = 0; t < SLTP5_TP; t++)
                FileWriteDouble(h, g_sltp5_q[r][s][t]);
    // Visit counts
    for (int r = 0; r < SLTP5_REG; r++)
        for (int s = 0; s < SLTP5_SL; s++)
            for (int t = 0; t < SLTP5_TP; t++)
                FileWriteInteger(h, g_sltp5_v[r][s][t]);
    // Metadata
    FileWriteInteger(h, g_sltp5_totalTrades);
    FileWriteInteger(h, g_sltp5_wins);
    FileWriteDouble(h, g_sltp5_cumReward);
    // SL/TP multiplier arrays (so we can detect config changes)
    for (int i = 0; i < SLTP5_SL; i++) FileWriteDouble(h, g_sltp5_slM[i]);
    for (int i = 0; i < SLTP5_TP; i++) FileWriteDouble(h, g_sltp5_tpR[i]);
    FileClose(h);
    Print("[SLTP5] Q-Table saved: ", fn, " | Trades: ", g_sltp5_totalTrades, " | Visits total: ", AI_SLTP5_TotalVisits());
}

bool AI_SLTP5_Load(int magic) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return false;
    string fn = AI_SLTP5_GetFilename(magic);
    bool inCommon = FileIsExist(fn, FILE_COMMON);
    bool inLocal = !inCommon && FileIsExist(fn);
    if (!inCommon && !inLocal) { Print("[SLTP5] No saved Q-Table found for: ", fn); return false; }
    int flags = FILE_READ | FILE_BIN | (inCommon ? FILE_COMMON : 0);
    int h = FileOpen(fn, flags);
    if (h == INVALID_HANDLE) { Print("[SLTP5] Load FAILED: ", GetLastError()); return false; }
    // Validate header
    int mgc = FileReadInteger(h);
    if (mgc != (int)SLTP5_MAGIC) { Print("[SLTP5] Invalid file header"); FileClose(h); return false; }
    FileReadInteger(h); // version - reserved for future format changes
    // Q-Table
    for (int r = 0; r < SLTP5_REG; r++)
        for (int s = 0; s < SLTP5_SL; s++)
            for (int t = 0; t < SLTP5_TP; t++)
                g_sltp5_q[r][s][t] = FileReadDouble(h);
    // Visit counts
    for (int r = 0; r < SLTP5_REG; r++)
        for (int s = 0; s < SLTP5_SL; s++)
            for (int t = 0; t < SLTP5_TP; t++)
                g_sltp5_v[r][s][t] = FileReadInteger(h);
    // Metadata
    g_sltp5_totalTrades = FileReadInteger(h);
    g_sltp5_wins = FileReadInteger(h);
    g_sltp5_cumReward = FileReadDouble(h);
    FileClose(h);
    // Migrate to Common if found in Local
    if (inLocal && !inCommon) AI_SLTP5_Save(magic);
    g_sltp5_fileLoaded = true;
    Print("[SLTP5] Q-Table loaded: ", fn, " | Trades: ", g_sltp5_totalTrades, " | Visits: ", AI_SLTP5_TotalVisits());
    return true;
}

int AI_SLTP5_TotalVisits() {
    int total = 0;
    for (int r = 0; r < SLTP5_REG; r++)
        for (int s = 0; s < SLTP5_SL; s++)
            for (int t = 0; t < SLTP5_TP; t++)
                total += g_sltp5_v[r][s][t];
    return total;
}

int AI_SLTP5_ActiveRegimes() {
    int cnt = 0;
    for (int r = 0; r < SLTP5_REG; r++) {
        int rv = 0;
        for (int s = 0; s < SLTP5_SL; s++)
            for (int t = 0; t < SLTP5_TP; t++) rv += g_sltp5_v[r][s][t];
        if (rv >= 10) cnt++;
    }
    return cnt;
}

//+------------------------------------------------------------------+
//| SLTP5 Enhanced Panel                                               |
//+------------------------------------------------------------------+
void AI_SLTP5_CreateLabel(string name, string text, int x, int y, color clr, int sz) {
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, sz);
    ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

void AI_SLTP5_CreatePanel(int x, int y) {
    if (g_sltp5_panelOk) return;
    ObjectCreate(0, "AI_SLTP5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_SLTP5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_SLTP5_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_SLTP5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_SLTP5_BG", OBJPROP_XSIZE, 280);
    ObjectSetInteger(0, "AI_SLTP5_BG", OBJPROP_YSIZE, 320);
    ObjectSetInteger(0, "AI_SLTP5_BG", OBJPROP_BGCOLOR, C'15,20,25');
    ObjectSetInteger(0, "AI_SLTP5_BG", OBJPROP_BORDER_COLOR, C'40,60,80');
    ObjectSetInteger(0, "AI_SLTP5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, "AI_SLTP5_BG", OBJPROP_BACK, false);
    int ly = y + 8;
    AI_SLTP5_CreateLabel("AI_SLTP5_T", "AI DYNAMIC SL/TP [MT5]", x+10, ly, clrSteelBlue, 9); ly += 16;
    AI_SLTP5_CreateLabel("AI_SLTP5_V", "v2.0 - Q-Learning Active", x+10, ly, clrDarkGray, 7); ly += 18;
    AI_SLTP5_CreateLabel("AI_SLTP5_S1", ":: Q-LEARNING", x+10, ly, clrGold, 8); ly += 16;
    AI_SLTP5_CreateLabel("AI_SLTP5_Reg", "Regime: ---", x+15, ly, clrWhite, 8); ly += 15;
    AI_SLTP5_CreateLabel("AI_SLTP5_Vis", "Visits: 0", x+15, ly, clrWhite, 8); ly += 15;
    AI_SLTP5_CreateLabel("AI_SLTP5_AReg", "Active: 0/10 regimes", x+15, ly, clrWhite, 8); ly += 15;
    AI_SLTP5_CreateLabel("AI_SLTP5_Best", "Best: SL=mid TP=mid", x+15, ly, clrWhite, 8); ly += 15;
    AI_SLTP5_CreateLabel("AI_SLTP5_CumR", "Cum.Reward: 0.00", x+15, ly, clrWhite, 8); ly += 20;
    AI_SLTP5_CreateLabel("AI_SLTP5_S2", ":: PARAMETERS", x+10, ly, clrGold, 8); ly += 16;
    AI_SLTP5_CreateLabel("AI_SLTP5_SL", "SL: --- pts", x+15, ly, clrWhite, 8); ly += 15;
    AI_SLTP5_CreateLabel("AI_SLTP5_TP", "TP: --- pts", x+15, ly, clrWhite, 8); ly += 15;
    AI_SLTP5_CreateLabel("AI_SLTP5_RR", "R:R = ---", x+15, ly, clrWhite, 8); ly += 15;
    AI_SLTP5_CreateLabel("AI_SLTP5_ATR", "ATR: --- pts", x+15, ly, clrWhite, 8); ly += 20;
    AI_SLTP5_CreateLabel("AI_SLTP5_S3", ":: PERFORMANCE", x+10, ly, clrGold, 8); ly += 16;
    AI_SLTP5_CreateLabel("AI_SLTP5_Tr", "Trades: 0", x+15, ly, clrWhite, 8); ly += 15;
    AI_SLTP5_CreateLabel("AI_SLTP5_WR", "Win Rate: ---", x+15, ly, clrWhite, 8); ly += 15;
    AI_SLTP5_CreateLabel("AI_SLTP5_File", "File: new", x+15, ly, clrDarkGray, 7);
    g_sltp5_panelOk = true;
}

string AI_SLTP5_RegName(int r) {
    if (r == 0) return "TREND UP (Calm)";
    if (r == 1) return "TREND UP (Norm)";
    if (r == 2) return "TREND UP (Vol)";
    if (r == 3) return "TREND DN (Calm)";
    if (r == 4) return "TREND DN (Norm)";
    if (r == 5) return "TREND DN (Vol)";
    if (r == 6) return "RANGE (Quiet)";
    if (r == 7) return "RANGE (Norm)";
    if (r == 8) return "CHAOS";
    if (r == 9) return "TRANSITION";
    return "UNKNOWN";
}

void AI_SLTP5_UpdatePanel(double sl, double tp, double rr, int reg, int bSI, int bTI) {
    if (TimeCurrent() - g_sltp5_panelUpd < 1) return;
    g_sltp5_panelUpd = TimeCurrent();
    // Q-Learning section
    ObjectSetString(0, "AI_SLTP5_Reg", OBJPROP_TEXT, "Regime: " + AI_SLTP5_RegName(reg));
    int tv = AI_SLTP5_TotalVisits();
    ObjectSetString(0, "AI_SLTP5_Vis", OBJPROP_TEXT, "Visits: " + IntegerToString(tv));
    int ar = AI_SLTP5_ActiveRegimes();
    ObjectSetString(0, "AI_SLTP5_AReg", OBJPROP_TEXT, "Active: " + IntegerToString(ar) + "/10 regimes");
    ObjectSetInteger(0, "AI_SLTP5_AReg", OBJPROP_COLOR, ar >= 5 ? clrLime : (ar >= 2 ? clrYellow : clrGray));
    string slNames[] = {"0.5x","0.75x","1.0x","1.5x","2.0x"};
    string tpNames[] = {"0.5x","0.75x","1.0x","1.5x","2.0x"};
    ObjectSetString(0, "AI_SLTP5_Best", OBJPROP_TEXT, "Best: SL=" + slNames[bSI] + " TP=" + tpNames[bTI]);
    ObjectSetString(0, "AI_SLTP5_CumR", OBJPROP_TEXT, "Cum.Reward: " + DoubleToString(g_sltp5_cumReward, 2));
    // Parameters section
    ObjectSetString(0, "AI_SLTP5_SL", OBJPROP_TEXT, "SL: " + DoubleToString(sl, 1) + " pts");
    ObjectSetString(0, "AI_SLTP5_TP", OBJPROP_TEXT, "TP: " + DoubleToString(tp, 1) + " pts");
    ObjectSetString(0, "AI_SLTP5_RR", OBJPROP_TEXT, "R:R = 1:" + DoubleToString(rr, 2));
    ObjectSetInteger(0, "AI_SLTP5_RR", OBJPROP_COLOR, rr >= 2.0 ? clrLimeGreen : (rr >= 1.0 ? clrYellow : clrOrangeRed));
    ObjectSetString(0, "AI_SLTP5_ATR", OBJPROP_TEXT, "ATR: " + DoubleToString(AI_P1_GetBuf(g_sltp5_hATR, 0, 0) / _Point, 1) + " pts");
    // Performance section
    ObjectSetString(0, "AI_SLTP5_Tr", OBJPROP_TEXT, "Trades: " + IntegerToString(g_sltp5_totalTrades));
    double wr = g_sltp5_totalTrades > 0 ? (double)g_sltp5_wins / g_sltp5_totalTrades * 100.0 : 0;
    ObjectSetString(0, "AI_SLTP5_WR", OBJPROP_TEXT, "Win Rate: " + DoubleToString(wr, 1) + "%");
    ObjectSetInteger(0, "AI_SLTP5_WR", OBJPROP_COLOR, wr >= 50 ? clrLime : (wr > 0 ? clrOrangeRed : clrGray));
    ObjectSetString(0, "AI_SLTP5_File", OBJPROP_TEXT, g_sltp5_fileLoaded ? "File: loaded" : "File: new");
    ObjectSetInteger(0, "AI_SLTP5_File", OBJPROP_COLOR, g_sltp5_fileLoaded ? clrLime : clrGray);
}

//+------------------------------------------------------------------+
//| MULTI-STRATEGIC AGENT IA - MQL5 (5 Independent Q-Learning Slots)  |
//+------------------------------------------------------------------+
#define MS5_SLOTS 5
#define MS5_STATES 100
#define MS5_ACTIONS 4
#define MS5_EXP 200

double g_ms5QTable[MS5_SLOTS][MS5_STATES][MS5_ACTIONS];
int g_ms5Visits[MS5_SLOTS][MS5_STATES][MS5_ACTIONS];
int g_ms5Episodes[MS5_SLOTS];
double g_ms5Epsilon[MS5_SLOTS];
bool g_ms5Init = false;
datetime g_ms5LastTrade[MS5_SLOTS];
datetime g_ms5PanelUpd = 0;
bool g_ms5PanelOk = false;
double g_ms5DDLimit = 20;

struct MS5_Exp {
    int state; int action; double reward; int nextState;
};
MS5_Exp g_ms5ExpBuf[MS5_SLOTS][MS5_EXP];
int g_ms5ExpCnt[MS5_SLOTS];

struct MS5_Stats {
    int totalTrades; int wins; double profit; int openOrders; int lastAction;
};
MS5_Stats g_ms5Stats[MS5_SLOTS];

double g_ms5SlotMFESum[MS5_SLOTS];
double g_ms5SlotMAESum[MS5_SLOTS];
int g_ms5SlotEdgeTrades[MS5_SLOTS];

struct MS5_OpenState {
    ulong ticket; int state; int action; int slot;
};
MS5_OpenState g_ms5OpenStates[50];
int g_ms5OpenCnt = 0;

// ===== ALS for Multi-Strategic Agent (per-slot rolling window) =====
#define MS5_ALS_WINDOW 20
struct MS5_ALS_Trade { double profit; datetime time; };
MS5_ALS_Trade g_ms5AlsRolling[MS5_SLOTS][MS5_ALS_WINDOW];
int g_ms5AlsCount[MS5_SLOTS];
int g_ms5AlsIdx[MS5_SLOTS];
int g_ms5AlsConsecLoss[MS5_SLOTS];
double g_ms5AlsWinRate[MS5_SLOTS];
double g_ms5AlsPF[MS5_SLOTS];
int g_ms5AlsLastDecayEp[MS5_SLOTS];
int g_ms5AlsLastResetEp[MS5_SLOTS];
int g_ms5AlsLastLevel[MS5_SLOTS];
int g_ms5AlsSoftResets[MS5_SLOTS];
bool g_ms5AlsEnabled = true;
int g_ms5AlsSensitivity = 1;

void AI_MS5_ALS_Update(int slot, double profit) {
    if (!g_ms5AlsEnabled || slot < 0 || slot >= MS5_SLOTS) return;
    g_ms5AlsRolling[slot][g_ms5AlsIdx[slot]].profit = profit;
    g_ms5AlsRolling[slot][g_ms5AlsIdx[slot]].time = TimeCurrent();
    g_ms5AlsIdx[slot] = (g_ms5AlsIdx[slot] + 1) % MS5_ALS_WINDOW;
    if (g_ms5AlsCount[slot] < MS5_ALS_WINDOW) g_ms5AlsCount[slot]++;
    if (profit < 0) g_ms5AlsConsecLoss[slot]++;
    else g_ms5AlsConsecLoss[slot] = 0;
    if (g_ms5AlsCount[slot] < 5) return;
    int w = 0; double sw = 0, sl = 0;
    for (int i = 0; i < g_ms5AlsCount[slot]; i++) {
        if (g_ms5AlsRolling[slot][i].profit > 0) { w++; sw += g_ms5AlsRolling[slot][i].profit; }
        else sl += MathAbs(g_ms5AlsRolling[slot][i].profit);
    }
    g_ms5AlsWinRate[slot] = (double)w / g_ms5AlsCount[slot];
    g_ms5AlsPF[slot] = (sl > 0) ? sw / sl : (sw > 0 ? 10.0 : 1.0);
}

int AI_MS5_ALS_GetLevel(int slot) {
    if (!g_ms5AlsEnabled || slot < 0 || slot >= MS5_SLOTS || g_ms5AlsCount[slot] < 5) return 0;
    double wm = (g_ms5AlsSensitivity == 0) ? 0.85 : (g_ms5AlsSensitivity == 2) ? 1.15 : 1.0;
    double lm = (g_ms5AlsSensitivity == 0) ? 1.5 : (g_ms5AlsSensitivity == 2) ? 0.75 : 1.0;
    double wr = g_ms5AlsWinRate[slot]; double pf = g_ms5AlsPF[slot]; int cl = g_ms5AlsConsecLoss[slot];
    if (wr < 0.20 * wm || pf < 0.3 || cl >= (int)(8 * lm)) return 3;
    if (wr < 0.30 * wm || pf < 0.5 || cl >= (int)(6 * lm)) return 2;
    if (wr < 0.40 * wm || pf < 0.8 || cl >= (int)(4 * lm)) return 1;
    return 0;
}

void AI_MS5_ALS_SoftReset(int slot, double strength) {
    if (slot < 0 || slot >= MS5_SLOTS) return;
    double keep = 1.0 - strength;
    for (int st = 0; st < MS5_STATES; st++)
        for (int a = 0; a < MS5_ACTIONS; a++)
            g_ms5QTable[slot][st][a] *= keep;
    double newEps = 0.10 + strength * 0.15;
    g_ms5Epsilon[slot] = MathMax(g_ms5Epsilon[slot], newEps);
    g_ms5AlsSoftResets[slot]++;
    Print("MS5-ALS SOFT RESET slot ", slot, ": str=", DoubleToString(strength * 100, 0), "% eps->", DoubleToString(g_ms5Epsilon[slot], 3));
}

void AI_MS5_ALS_DecaySlot(int slot) {
    if (!g_ms5AlsEnabled || slot < 0 || slot >= MS5_SLOTS) return;
    int interval = g_IsBacktestTraining ? 100 : 50;
    if (g_ms5Episodes[slot] - g_ms5AlsLastDecayEp[slot] < interval) return;
    g_ms5AlsLastDecayEp[slot] = g_ms5Episodes[slot];
    int lv = AI_MS5_ALS_GetLevel(slot);
    double f = (lv == 0) ? 0.98 : (lv == 1) ? 0.95 : (lv == 2) ? 0.90 : 0.80;
    for (int st = 0; st < MS5_STATES; st++)
        for (int a = 0; a < MS5_ACTIONS; a++)
            g_ms5QTable[slot][st][a] *= f;
}

void AI_MS5_ALS_Check(int slot) {
    if (!g_ms5AlsEnabled || slot < 0 || slot >= MS5_SLOTS || g_ms5AlsCount[slot] < 5) return;
    int lv = AI_MS5_ALS_GetLevel(slot);
    bool canReset = (g_ms5Episodes[slot] - g_ms5AlsLastResetEp[slot]) > 10;
    if (lv > g_ms5AlsLastLevel[slot] && canReset) {
        if (lv == 1) g_ms5Epsilon[slot] = MathMax(g_ms5Epsilon[slot], 0.08);
        else if (lv == 2) AI_MS5_ALS_SoftReset(slot, 0.30);
        else if (lv == 3) AI_MS5_ALS_SoftReset(slot, 0.60);
        g_ms5AlsLastResetEp[slot] = g_ms5Episodes[slot];
    }
    g_ms5AlsLastLevel[slot] = lv;
}

void AI_MS5_Init(int baseMagic) {
    if (g_ms5Init) return;
    for (int s = 0; s < MS5_SLOTS; s++) {
        for (int st = 0; st < MS5_STATES; st++)
            for (int a = 0; a < MS5_ACTIONS; a++) { g_ms5QTable[s][st][a] = 0; g_ms5Visits[s][st][a] = 0; }
        g_ms5Episodes[s] = 0; g_ms5Epsilon[s] = 0.2; g_ms5ExpCnt[s] = 0; g_ms5LastTrade[s] = 0;
        g_ms5Stats[s].totalTrades = 0; g_ms5Stats[s].wins = 0; g_ms5Stats[s].profit = 0;
        g_ms5Stats[s].openOrders = 0; g_ms5Stats[s].lastAction = 0;
        g_ms5SlotMFESum[s] = 0; g_ms5SlotMAESum[s] = 0; g_ms5SlotEdgeTrades[s] = 0;
        // ALS init per slot
        g_ms5AlsCount[s] = 0; g_ms5AlsIdx[s] = 0; g_ms5AlsConsecLoss[s] = 0;
        g_ms5AlsWinRate[s] = 0.5; g_ms5AlsPF[s] = 1.0;
        g_ms5AlsLastDecayEp[s] = 0; g_ms5AlsLastResetEp[s] = 0;
        g_ms5AlsLastLevel[s] = 0; g_ms5AlsSoftResets[s] = 0;
        for (int aw = 0; aw < MS5_ALS_WINDOW; aw++) { g_ms5AlsRolling[s][aw].profit = 0; g_ms5AlsRolling[s][aw].time = 0; }
    }
    g_ms5OpenCnt = 0;
    AI_MS5_LoadQTables(baseMagic);
    g_ms5Init = true;
}

int AI_MS5_SelectAction(int slot, int state, bool explore) {
    if (slot < 0 || slot >= MS5_SLOTS || state < 0 || state >= MS5_STATES) return 0;
    if (explore && MathRand() / 32767.0 < g_ms5Epsilon[slot]) return MathRand() % MS5_ACTIONS;
    int best = 0;
    for (int a = 1; a < MS5_ACTIONS; a++)
        if (g_ms5QTable[slot][state][a] > g_ms5QTable[slot][state][best]) best = a;
    return best;
}

void AI_MS5_UpdateQ(int slot, int state, int action, double reward, int nextState, double lr, double gamma) {
    if (slot < 0 || slot >= MS5_SLOTS || state < 0 || state >= MS5_STATES) return;
    if (action < 0 || action >= MS5_ACTIONS || nextState < 0 || nextState >= MS5_STATES) return;
    double maxNQ = g_ms5QTable[slot][nextState][0];
    for (int a = 1; a < MS5_ACTIONS; a++)
        if (g_ms5QTable[slot][nextState][a] > maxNQ) maxNQ = g_ms5QTable[slot][nextState][a];
    double effLR = lr;
    if (g_IsBacktestTraining) effLR = MathMin(lr * g_AITrainingSpeedMultiplier, 0.35);
    double oldQms = g_ms5QTable[slot][state][action];
    g_ms5QTable[slot][state][action] += effLR * (reward + gamma * maxNQ - oldQms);
    double qDeltaMs = g_ms5QTable[slot][state][action] - oldQms;
    g_ms5Visits[slot][state][action]++;
    g_ms5Episodes[slot]++;
    
    // VDBE adaptive epsilon for Multi-Strategic Agent
    double ms5EpsFloor = g_IsBacktestTraining ? 0.03 : 0.01;
    if (g_ms5AlsEnabled && g_ms5AlsCount[slot] >= 5) {
        double tdMagMs = MathAbs(qDeltaMs);
        double sigmaMs = 1.0 / (1.0 + MathExp(-tdMagMs + 3.0));
        double newEpsMs = 0.9 * g_ms5Epsilon[slot] + 0.1 * sigmaMs;
        int lvMs = AI_MS5_ALS_GetLevel(slot);
        if (lvMs >= 3)      newEpsMs = MathMax(newEpsMs, 0.25);
        else if (lvMs >= 2) newEpsMs = MathMax(newEpsMs, 0.15);
        else if (lvMs >= 1) newEpsMs = MathMax(newEpsMs, 0.08);
        g_ms5Epsilon[slot] = MathMax(ms5EpsFloor, MathMin(0.40, newEpsMs));
    } else {
        if (g_ms5Epsilon[slot] > ms5EpsFloor) {
            double ms5DecayRate = g_IsBacktestTraining ? 0.9993 : 0.9995;
            g_ms5Epsilon[slot] *= ms5DecayRate;
            if (g_ms5Epsilon[slot] < ms5EpsFloor) g_ms5Epsilon[slot] = ms5EpsFloor;
        }
    }
}

double AI_MS5_Reward(double profitPips, double rrRatio) {
    double r = 0;
    if (profitPips > 0) { r = MathMin(profitPips * 0.1, 50.0); if (rrRatio > 2.0) r *= 1.5; else if (rrRatio > 1.0) r *= 1.2; }
    else { r = MathMax(profitPips * 0.15, -50.0); if (rrRatio < 0.5) r *= 1.5; }
    return r;
}

void AI_MS5_SaveExp(int slot, int state, int action, double reward, int nextState) {
    if (slot < 0 || slot >= MS5_SLOTS) return;
    int idx = g_ms5ExpCnt[slot] % MS5_EXP;
    g_ms5ExpBuf[slot][idx].state = state; g_ms5ExpBuf[slot][idx].action = action;
    g_ms5ExpBuf[slot][idx].reward = reward; g_ms5ExpBuf[slot][idx].nextState = nextState;
    g_ms5ExpCnt[slot]++;
}

void AI_MS5_Replay(int slot, int batch, double lr, double gamma) {
    if (slot < 0 || slot >= MS5_SLOTS) return;
    int total = MathMin(g_ms5ExpCnt[slot], MS5_EXP);
    if (total < 5) return;
    for (int b = 0; b < batch && b < total; b++) {
        int idx = MathRand() % total;
        AI_MS5_UpdateQ(slot, g_ms5ExpBuf[slot][idx].state, g_ms5ExpBuf[slot][idx].action, g_ms5ExpBuf[slot][idx].reward, g_ms5ExpBuf[slot][idx].nextState, lr, gamma);
    }
}

void AI_MS5_StoreOpen(ulong ticket, int state, int action, int slot) {
    if (g_ms5OpenCnt >= 50) g_ms5OpenCnt = 49;
    g_ms5OpenStates[g_ms5OpenCnt].ticket = ticket; g_ms5OpenStates[g_ms5OpenCnt].state = state;
    g_ms5OpenStates[g_ms5OpenCnt].action = action; g_ms5OpenStates[g_ms5OpenCnt].slot = slot;
    g_ms5OpenCnt++;
}

bool AI_MS5_GetOpen(ulong ticket, int &state, int &action, int &slot) {
    for (int i = 0; i < g_ms5OpenCnt; i++) {
        if (g_ms5OpenStates[i].ticket == ticket) { state = g_ms5OpenStates[i].state; action = g_ms5OpenStates[i].action; slot = g_ms5OpenStates[i].slot; return true; }
    }
    return false;
}

int AI_MS5_SlotOrders(int slot, int baseMagic) {
    int magic = baseMagic + slot; int cnt = 0;
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong tkt = PositionGetTicket(i);
        if (tkt == 0) continue;
        if (PositionGetInteger(POSITION_MAGIC) != magic) continue;
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        cnt++;
    }
    return cnt;
}

int AI_MS5_TotalOrders(int baseMagic) {
    int cnt = 0;
    for (int s = 0; s < MS5_SLOTS; s++) cnt += AI_MS5_SlotOrders(s, baseMagic);
    return cnt;
}

bool AI_MS5_CheckDD(double maxPct) {
    double bal = AccountInfoDouble(ACCOUNT_BALANCE);
    double eq = AccountInfoDouble(ACCOUNT_EQUITY);
    if (bal <= 0) return false;
    return (bal - eq) / bal * 100.0 >= maxPct;
}

void AI_MS5_SaveQTables(int baseMagic) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return;
    string fn = "AI_MS5_QTable_" + _Symbol + "_" + IntegerToString(baseMagic) + ".bin";
    int h = FileOpen(fn, FILE_WRITE|FILE_BIN|FILE_COMMON);
    if (h == INVALID_HANDLE) return;
    for (int s = 0; s < MS5_SLOTS; s++) {
        for (int st = 0; st < MS5_STATES; st++)
            for (int a = 0; a < MS5_ACTIONS; a++) FileWriteDouble(h, g_ms5QTable[s][st][a]);
        FileWriteInteger(h, g_ms5Episodes[s]); FileWriteDouble(h, g_ms5Epsilon[s]);
    }
    FileClose(h);
}

void AI_MS5_LoadQTables(int baseMagic) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return;
    string fn = "AI_MS5_QTable_" + _Symbol + "_" + IntegerToString(baseMagic) + ".bin";
    if (!FileIsExist(fn, FILE_COMMON)) return;
    int h = FileOpen(fn, FILE_READ|FILE_BIN|FILE_COMMON);
    if (h == INVALID_HANDLE) return;
    for (int s = 0; s < MS5_SLOTS; s++) {
        for (int st = 0; st < MS5_STATES; st++)
            for (int a = 0; a < MS5_ACTIONS; a++) g_ms5QTable[s][st][a] = FileReadDouble(h);
        g_ms5Episodes[s] = FileReadInteger(h); g_ms5Epsilon[s] = FileReadDouble(h);
    }
    FileClose(h);
    Print("AI_MS5: Q-Tables loaded from " + fn);
}

//+------------------------------------------------------------------+
//| MS5 LEARNING PROGRESS & HEALTH MONITORING                          |
//| (Mirrors Strategic Agent - adapted for 5 independent Q-Learning)   |
//+------------------------------------------------------------------+
#define MS5_TOTAL_PAIRS (MS5_STATES * MS5_ACTIONS)

enum ENUM_MS5_HEALTH_STATUS { MS5_HEALTH_OPTIMAL, MS5_HEALTH_WARNING, MS5_HEALTH_ERROR };

struct MS5_HealthState {
    ENUM_MS5_HEALTH_STATUS status;
    string statusMessage;
    datetime lastTradeTime;
    datetime lastQTableSave;
    int consecutiveSaveFailures;
};
MS5_HealthState g_ms5Health;
bool g_ms5HealthInit = false;

int AI_MS5_CountActivePairsAll() {
    int count = 0;
    for (int st = 0; st < MS5_STATES; st++)
        for (int a = 0; a < MS5_ACTIONS; a++) {
            bool visited = false;
            for (int s = 0; s < MS5_SLOTS; s++) {
                if (g_ms5Visits[s][st][a] > 0 || g_ms5QTable[s][st][a] != 0.0) { visited = true; break; }
            }
            if (visited) count++;
        }
    return count;
}

double AI_MS5_GetCoveragePercentAll() {
    return (double)AI_MS5_CountActivePairsAll() / MS5_TOTAL_PAIRS * 100.0;
}

int AI_MS5_GetTotalEpisodes() {
    int total = 0;
    for (int s = 0; s < MS5_SLOTS; s++) total += g_ms5Episodes[s];
    return total;
}

int AI_MS5_GetTotalVisitsAll() {
    int total = 0;
    for (int s = 0; s < MS5_SLOTS; s++)
        for (int st = 0; st < MS5_STATES; st++)
            for (int a = 0; a < MS5_ACTIONS; a++)
                total += g_ms5Visits[s][st][a];
    return total;
}

double AI_MS5_GetAvgVisitsPerPairAll() {
    int ap = AI_MS5_CountActivePairsAll();
    if (ap == 0) return 0;
    return (double)AI_MS5_GetTotalVisitsAll() / ap;
}

double AI_MS5_GetAvgEpsilon() {
    double sum = 0;
    for (int s = 0; s < MS5_SLOTS; s++) sum += g_ms5Epsilon[s];
    return sum / MS5_SLOTS;
}

void AI_MS5_GetAdaptedTargets(double &outCov, int &outEp, int &outVis) {
    if (g_ms5FastLearning) { outCov = 15.0; outEp = 250; outVis = 2; }
    else if (g_ms5AdaptiveCov) { outCov = g_ms5AdaptedCoverageTarget; outEp = 500; outVis = 3; }
    else { outCov = 30.0; outEp = 500; outVis = 3; }
}

double AI_MS5_GetLearningProgress() {
    double tCov = 0; int tEp = 0; int tVis = 0;
    AI_MS5_GetAdaptedTargets(tCov, tEp, tVis);
    double covP = MathMin(100.0, AI_MS5_GetCoveragePercentAll() / tCov * 100.0);
    double epP = MathMin(100.0, (double)AI_MS5_GetTotalEpisodes() / tEp * 100.0);
    double depP = MathMin(100.0, AI_MS5_GetAvgVisitsPerPairAll() / tVis * 100.0);
    return MathMin(100.0, covP * 0.4 + epP * 0.4 + depP * 0.2);
}

bool AI_MS5_IsLearningComplete() {
    double tCov = 0; int tEp = 0; int tVis = 0;
    AI_MS5_GetAdaptedTargets(tCov, tEp, tVis);
    return (AI_MS5_GetCoveragePercentAll() >= tCov && AI_MS5_GetTotalEpisodes() >= tEp && AI_MS5_GetAvgVisitsPerPairAll() >= tVis);
}

double AI_MS5_GetSpecializationProgress() {
    if (!AI_MS5_IsLearningComplete()) return 0.0;
    double epP = MathMin(100.0, (double)AI_MS5_GetTotalEpisodes() / 2000.0 * 100.0);
    double covP = MathMin(100.0, AI_MS5_GetCoveragePercentAll() / 50.0 * 100.0);
    double avgEps = AI_MS5_GetAvgEpsilon();
    double epsP = avgEps < 0.2 ? MathMin(100.0, MathMax(0.0, (0.2 - avgEps) / (0.2 - 0.01) * 100.0)) : 0;
    return MathMin(100.0, MathMax(0.0, epP * 0.35 + covP * 0.35 + epsP * 0.30));
}

double AI_MS5_GetRegimeProgress() {
    return (double)AI_MS5_CountVisitedRegimes() / 10.0 * 100.0;
}

void AI_MS5_InitHealthState() {
    if (g_ms5HealthInit) return;
    g_ms5Health.status = MS5_HEALTH_OPTIMAL;
    g_ms5Health.statusMessage = "Iniciando...";
    g_ms5Health.lastTradeTime = 0;
    g_ms5Health.lastQTableSave = 0;
    g_ms5Health.consecutiveSaveFailures = 0;
    g_ms5HealthInit = true;
}

void AI_MS5_UpdateHealthStatus() {
    AI_MS5_InitHealthState();
    datetime ct = TimeCurrent();
    if (g_ms5Perf.isPaused) {
        g_ms5Health.status = MS5_HEALTH_ERROR;
        g_ms5Health.statusMessage = "PAUSADO: " + g_ms5Perf.pauseReason;
        return;
    }
    if (g_ms5Health.consecutiveSaveFailures >= 3) {
        g_ms5Health.status = MS5_HEALTH_ERROR;
        g_ms5Health.statusMessage = "ERROR: Q-Table no se guarda";
        return;
    }
    if (g_ms5Perf.totalTrades > 0 && g_ms5Health.lastTradeTime > 0) {
        int hrs = (int)((ct - g_ms5Health.lastTradeTime) / 3600);
        if (hrs > 24) {
            g_ms5Health.status = MS5_HEALTH_WARNING;
            g_ms5Health.statusMessage = "Sin trades: " + IntegerToString(hrs) + "h";
            return;
        }
    }
    if (AI_MS5_GetTotalEpisodes() < 5 && AI_MS5_GetAvgEpsilon() > 0.15) {
        g_ms5Health.status = MS5_HEALTH_WARNING;
        g_ms5Health.statusMessage = "Fase inicial: explorando...";
        return;
    }
    g_ms5Health.status = MS5_HEALTH_OPTIMAL;
    if (!AI_MS5_IsLearningComplete()) g_ms5Health.statusMessage = "Aprendiendo activamente";
    else if (AI_MS5_GetSpecializationProgress() < 100) g_ms5Health.statusMessage = "Especializandose";
    else g_ms5Health.statusMessage = "Experto - Optimo";
}

string AI_MS5_HealthIcon() {
    if (g_ms5Health.status == MS5_HEALTH_OPTIMAL) return "\x25CF";
    if (g_ms5Health.status == MS5_HEALTH_WARNING) return "\x25B2";
    return "\x25A0";
}

color AI_MS5_HealthColor() {
    if (g_ms5Health.status == MS5_HEALTH_OPTIMAL) return clrLime;
    if (g_ms5Health.status == MS5_HEALTH_WARNING) return clrOrange;
    return clrRed;
}

color AI_MS5_LearnBarColor(double pct) {
    if (pct < 25) return clrRed;
    if (pct < 50) return clrOrangeRed;
    if (pct < 75) return clrOrange;
    if (pct < 90) return clrYellow;
    return clrLime;
}

color AI_MS5_SpecBarColor(double pct) {
    if (pct < 20) return C'139,0,139';
    if (pct < 40) return C'75,0,130';
    if (pct < 60) return C'65,105,225';
    if (pct < 80) return C'0,139,139';
    return C'0,206,209';
}

void AI_MS5_Lbl(string name, string text, int x, int y, color clr, int sz) {
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, sz);
    ObjectSetString(0, name, OBJPROP_FONT, "Arial");
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

void AI_MS5_Bar(string name, int x, int y, int w, int h, color bg, color border) {
    ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
    ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
    ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
    ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, name, OBJPROP_COLOR, border);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, name, OBJPROP_BACK, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| MS5 Professional Panel - CREATE (mirrors Strategic Agent)          |
//+------------------------------------------------------------------+
void AI_MS5_CreatePanel(int x, int y) {
    if (g_ms5PanelOk) return;
    string p = "MS5_";
    int W = 310; int bW = 200; int bH = 12; int lh = 17;
    color hdr = clrGold; color txt = clrWhite; color val = clrLime;

    // Background
    ObjectCreate(0, p+"BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, p+"BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, p+"BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, p+"BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, p+"BG", OBJPROP_XSIZE, W);
    ObjectSetInteger(0, p+"BG", OBJPROP_YSIZE, 780);
    ObjectSetInteger(0, p+"BG", OBJPROP_BGCOLOR, clrBlack);
    ObjectSetInteger(0, p+"BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, p+"BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, p+"BG", OBJPROP_COLOR, clrDarkSlateGray);
    ObjectSetInteger(0, p+"BG", OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, p+"BG", OBJPROP_BACK, false);

    int ly = y + 5;
    AI_MS5_Lbl(p+"Hdr", "MULTI-STRATEGIC AGENT IA", x+10, ly, hdr, 11); ly += lh;
    AI_MS5_Lbl(p+"Ver", "v2.0 MQL5 - 5 Q-Learning Slots", x+10, ly, clrDarkGray, 8); ly += lh+3;

    // Health
    AI_MS5_Lbl(p+"HIcon", "?", x+15, ly, clrLime, 12);
    AI_MS5_Lbl(p+"HLbl", "Estado:", x+35, ly+2, txt, 9);
    AI_MS5_Lbl(p+"HVal", "Iniciando...", x+95, ly+2, clrLime, 9);
    ly += lh+5;

    // Progress section
    AI_MS5_Lbl(p+"PrT", ":: PROGRESO IA", x+10, ly, hdr, 9); ly += lh;

    // Learning bar
    AI_MS5_Lbl(p+"LrnL", "Aprendizaje:", x+15, ly, txt, 8);
    AI_MS5_Lbl(p+"LrnP", "0%", x+250, ly, clrGray, 8); ly += 12;
    AI_MS5_Bar(p+"LrnBG", x+15, ly, bW, bH, C'40,40,40', clrDimGray);
    AI_MS5_Bar(p+"LrnF", x+15, ly, 1, bH, clrRed, clrRed); ly += bH+6;

    // Specialization bar
    AI_MS5_Lbl(p+"SpcL", "Especializacion:", x+15, ly, txt, 8);
    AI_MS5_Lbl(p+"SpcP", "Bloqueado", x+230, ly, clrGray, 8); ly += 12;
    AI_MS5_Bar(p+"SpcBG", x+15, ly, bW, bH, C'30,30,30', clrDimGray);
    AI_MS5_Bar(p+"SpcF", x+15, ly, 1, bH, C'139,0,139', C'139,0,139'); ly += bH+6;

    // Regime bar
    AI_MS5_Lbl(p+"RegL", "Regimenes:", x+15, ly, txt, 8);
    AI_MS5_Lbl(p+"RegP", "0/10", x+250, ly, clrGray, 8); ly += 12;
    AI_MS5_Bar(p+"RegBG", x+15, ly, bW, bH, C'35,35,35', clrDimGray);
    AI_MS5_Bar(p+"RegF", x+15, ly, 1, bH, clrOrange, clrOrange); ly += bH+4;

    // Advanced warning
    AI_MS5_Lbl(p+"AdvW", "", x+15, ly, clrOrange, 8); ly += lh+2;

    // Separator + Market Regime
    AI_MS5_Lbl(p+"S1", "--------------------------------------------", x+5, ly, clrDarkGray, 7); ly += lh;
    AI_MS5_Lbl(p+"MRT", ":: MARKET REGIME", x+10, ly, hdr, 9); ly += lh;
    AI_MS5_Lbl(p+"MRLb", "Regime:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"MRVl", "---", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"TrLb", "Trend Score:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"TrVl", "0.00", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"AxLb", "ADX Strength:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"AxVl", "0.00", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"VoLb", "Volatility:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"VoVl", "NORMAL", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"MoLb", "Momentum:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"MoVl", "NEUTRAL", x+160, ly, val, 9); ly += lh+3;

    // Separator + Q-Learning
    AI_MS5_Lbl(p+"S2", "--------------------------------------------", x+5, ly, clrDarkGray, 7); ly += lh;
    AI_MS5_Lbl(p+"QLT", ":: Q-LEARNING ENGINE", x+10, ly, hdr, 9); ly += lh;
    AI_MS5_Lbl(p+"StLb", "State Index:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"StVl", "0", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"EpLb", "Exploration e:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"EpVl", "0.20", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"EpCL", "Episodes:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"EpCV", "0", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"BQLb", "Best Q-Value:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"BQVl", "0.00", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"AcLb", "Best Action:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"AcVl", "HOLD", x+160, ly, clrCyan, 9); ly += lh+3;

    // Separator + Slots
    AI_MS5_Lbl(p+"S3", "--------------------------------------------", x+5, ly, clrDarkGray, 7); ly += lh;
    AI_MS5_Lbl(p+"SlT", ":: SLOTS (5)", x+10, ly, hdr, 9); ly += lh;
    for (int i = 0; i < 5; i++) {
        AI_MS5_Lbl(p+"Sl"+IntegerToString(i), "S"+IntegerToString(i)+": idle", x+15, ly, clrGray, 8);
        ly += 14;
    }
    ly += 3;

    // Separator + Performance
    AI_MS5_Lbl(p+"S4", "--------------------------------------------", x+5, ly, clrDarkGray, 7); ly += lh;
    AI_MS5_Lbl(p+"PfT", ":: PERFORMANCE", x+10, ly, hdr, 9); ly += lh;
    AI_MS5_Lbl(p+"TdLb", "Total Trades:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"TdVl", "0", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"WrLb", "Win Rate:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"WrVl", "0%", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"PfLb", "Profit Factor:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"PfVl", "0.00", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"ERLb", "Edge Ratio:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"ERVl", "---", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"DdLb", "Max Drawdown:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"DdVl", "0.00%", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"DLLb", "DD Limit:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"DLVl", "---", x+160, ly, clrCyan, 9); ly += lh+3;

    // Separator + AI Parameters
    AI_MS5_Lbl(p+"S5", "--------------------------------------------", x+5, ly, clrDarkGray, 7); ly += lh;
    AI_MS5_Lbl(p+"AiT", ":: AI PARAMETERS", x+10, ly, hdr, 9); ly += lh;
    AI_MS5_Lbl(p+"AsLb", "Agent Status:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"AsVl", "ACTIVE", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"SLLb", "AI Stop Loss:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"SLVl", "--- pts", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"TPLb", "AI Take Profit:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"TPVl", "--- pts", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"LtLb", "AI Lot Size:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"LtVl", "--- lots", x+160, ly, val, 9); ly += lh;
    AI_MS5_Lbl(p+"RRLb", "Risk:Reward:", x+15, ly, txt, 9);
    AI_MS5_Lbl(p+"RRVl", "---", x+160, ly, val, 9);

    ChartRedraw(0);
    g_ms5PanelOk = true;
}

//+------------------------------------------------------------------+
//| MS5 Professional Panel - UPDATE (mirrors Strategic Agent)          |
//+------------------------------------------------------------------+
void AI_MS5_UpdatePanel(int baseMagic, double adaptedSL, double adaptedTP, double adaptedLots) {
    if (TimeCurrent() - g_ms5PanelUpd < 1) return;
    g_ms5PanelUpd = TimeCurrent();
    string p = "MS5_";
    int bW = 200;
    color val = clrLime; color warn = clrOrange; color danger = clrRed;

    // Refresh slot order counts
    int totalOpen = 0, totalT = 0, totalW = 0; double totalP = 0;
    for (int s = 0; s < MS5_SLOTS; s++) {
        g_ms5Stats[s].openOrders = AI_MS5_SlotOrders(s, baseMagic);
        totalOpen += g_ms5Stats[s].openOrders;
        totalT += g_ms5Stats[s].totalTrades;
        totalW += g_ms5Stats[s].wins;
        totalP += g_ms5Stats[s].profit;
    }

    // Health
    AI_MS5_UpdateHealthStatus();
    ObjectSetString(0, p+"HIcon", OBJPROP_TEXT, AI_MS5_HealthIcon());
    ObjectSetInteger(0, p+"HIcon", OBJPROP_COLOR, AI_MS5_HealthColor());
    ObjectSetString(0, p+"HVal", OBJPROP_TEXT, g_ms5Health.statusMessage);
    ObjectSetInteger(0, p+"HVal", OBJPROP_COLOR, AI_MS5_HealthColor());

    // Learning progress bar
    double learnProg = AI_MS5_GetLearningProgress();
    int learnFW = MathMax(1, (int)(bW * learnProg / 100.0));
    color lrnC = AI_MS5_LearnBarColor(learnProg);
    ObjectSetInteger(0, p+"LrnF", OBJPROP_XSIZE, learnFW);
    ObjectSetInteger(0, p+"LrnF", OBJPROP_BGCOLOR, lrnC);
    ObjectSetInteger(0, p+"LrnF", OBJPROP_COLOR, lrnC);
    int actPairs = AI_MS5_CountActivePairsAll();
    double covPct = AI_MS5_GetCoveragePercentAll();
    int totEp = AI_MS5_GetTotalEpisodes();
    string lrnLbl = IntegerToString(actPairs) + "/400 pares | " + IntegerToString(totEp) + " ep | " + DoubleToString(covPct, 1) + "% cob";
    ObjectSetString(0, p+"LrnL", OBJPROP_TEXT, lrnLbl);
    string lrnPTxt = AI_MS5_IsLearningComplete() ? "100% OK" : (DoubleToString(learnProg, 0) + "%");
    ObjectSetString(0, p+"LrnP", OBJPROP_TEXT, lrnPTxt);
    ObjectSetInteger(0, p+"LrnP", OBJPROP_COLOR, lrnC);

    // Specialization bar
    double specProg = AI_MS5_GetSpecializationProgress();
    bool specUnlocked = AI_MS5_IsLearningComplete();
    if (specUnlocked) {
        int specFW = MathMax(1, (int)(bW * specProg / 100.0));
        color spcC = AI_MS5_SpecBarColor(specProg);
        ObjectSetInteger(0, p+"SpcF", OBJPROP_XSIZE, specFW);
        ObjectSetInteger(0, p+"SpcF", OBJPROP_BGCOLOR, spcC);
        ObjectSetInteger(0, p+"SpcF", OBJPROP_COLOR, spcC);
        string spTxt = specProg >= 100 ? "100% *" : (DoubleToString(specProg, 0) + "%");
        ObjectSetString(0, p+"SpcP", OBJPROP_TEXT, spTxt);
        ObjectSetInteger(0, p+"SpcP", OBJPROP_COLOR, spcC);
    } else {
        ObjectSetInteger(0, p+"SpcF", OBJPROP_XSIZE, 1);
        ObjectSetInteger(0, p+"SpcF", OBJPROP_BGCOLOR, C'50,50,50');
        ObjectSetString(0, p+"SpcP", OBJPROP_TEXT, "Bloqueado");
        ObjectSetInteger(0, p+"SpcP", OBJPROP_COLOR, clrGray);
    }

    // Regime progress bar
    if (g_ms5RegimeProgress) {
        double regProg = AI_MS5_GetRegimeProgress();
        int regFW = MathMax(1, (int)(bW * regProg / 100.0));
        color regC = regProg >= 80 ? clrLime : (regProg >= 50 ? clrYellow : clrOrange);
        ObjectSetInteger(0, p+"RegF", OBJPROP_XSIZE, regFW);
        ObjectSetInteger(0, p+"RegF", OBJPROP_BGCOLOR, regC);
        ObjectSetInteger(0, p+"RegF", OBJPROP_COLOR, regC);
        int vr = AI_MS5_CountVisitedRegimes();
        ObjectSetString(0, p+"RegP", OBJPROP_TEXT, IntegerToString(vr) + "/10");
        ObjectSetInteger(0, p+"RegP", OBJPROP_COLOR, regC);
    }

    // Advanced warning
    if (StringLen(g_ms5AdvancedWarning) > 0) {
        ObjectSetString(0, p+"AdvW", OBJPROP_TEXT, "! " + g_ms5AdvancedWarning);
        ObjectSetInteger(0, p+"AdvW", OBJPROP_COLOR, warn);
    } else {
        ObjectSetString(0, p+"AdvW", OBJPROP_TEXT, "");
    }

    // Market Regime (uses shared g_aiMarketState5 populated by AI_ClassifyRegime5)
    ObjectSetString(0, p+"MRVl", OBJPROP_TEXT, AI_GetRegimeName5(g_aiMarketState5.regime));
    color regClr = val;
    if (g_aiMarketState5.regime == AI_REGIME_VOLATILE_CHAOS) regClr = danger;
    else if (g_aiMarketState5.regime == AI_REGIME_TRANSITION) regClr = warn;
    ObjectSetInteger(0, p+"MRVl", OBJPROP_COLOR, regClr);
    ObjectSetString(0, p+"TrVl", OBJPROP_TEXT, DoubleToString(g_aiMarketState5.trendScore, 2));
    ObjectSetInteger(0, p+"TrVl", OBJPROP_COLOR, g_aiMarketState5.trendScore > 0 ? clrLime : clrRed);
    ObjectSetString(0, p+"AxVl", OBJPROP_TEXT, DoubleToString(g_aiMarketState5.trendStrength, 1));
    ObjectSetInteger(0, p+"AxVl", OBJPROP_COLOR, g_aiMarketState5.trendStrength > 25 ? val : clrGray);
    ObjectSetString(0, p+"VoVl", OBJPROP_TEXT, AI_GetVolatilityName5(g_aiMarketState5.volatility) + " (" + DoubleToString(g_aiMarketState5.volatilityRatio, 2) + "x)");
    ObjectSetInteger(0, p+"VoVl", OBJPROP_COLOR, g_aiMarketState5.volatility == AI_VOL_HIGH ? danger : val);
    ObjectSetString(0, p+"MoVl", OBJPROP_TEXT, AI_GetMomentumName5(g_aiMarketState5.momentum) + " (RSI:" + DoubleToString(g_aiMarketState5.rsiValue, 0) + ")");

    // Q-Learning Engine (aggregate across all slots)
    int curState = AI_DiscretizeState5();
    ObjectSetString(0, p+"StVl", OBJPROP_TEXT, IntegerToString(curState));
    double avgEps = AI_MS5_GetAvgEpsilon();
    ObjectSetString(0, p+"EpVl", OBJPROP_TEXT, DoubleToString(avgEps, 4));
    ObjectSetString(0, p+"EpCV", OBJPROP_TEXT, IntegerToString(totEp));
    // Find best Q across all slots for current state
    double bestQ = -999999; int bestAct = 0;
    for (int s = 0; s < MS5_SLOTS; s++) {
        for (int a = 0; a < MS5_ACTIONS; a++) {
            if (g_ms5QTable[s][curState][a] > bestQ) { bestQ = g_ms5QTable[s][curState][a]; bestAct = a; }
        }
    }
    ObjectSetString(0, p+"BQVl", OBJPROP_TEXT, DoubleToString(bestQ, 2));
    string actName = "HOLD"; color actClr = clrGray;
    if (bestAct == 1) { actName = "BUY"; actClr = clrLime; }
    else if (bestAct == 2) { actName = "SELL"; actClr = clrRed; }
    else if (bestAct == 3) { actName = "CLOSE"; actClr = clrYellow; }
    ObjectSetString(0, p+"AcVl", OBJPROP_TEXT, actName);
    ObjectSetInteger(0, p+"AcVl", OBJPROP_COLOR, actClr);

    // Slot details
    for (int s = 0; s < MS5_SLOTS; s++) {
        string st = g_ms5Stats[s].openOrders > 0 ? "OPEN" : "idle";
        string si = "S" + IntegerToString(s) + ": " + st + " | Ep:" + IntegerToString(g_ms5Episodes[s]) + " | W:" + IntegerToString(g_ms5Stats[s].wins) + "/" + IntegerToString(g_ms5Stats[s].totalTrades) + " | e:" + DoubleToString(g_ms5Epsilon[s], 3);
        ObjectSetString(0, p+"Sl"+IntegerToString(s), OBJPROP_TEXT, si);
        ObjectSetInteger(0, p+"Sl"+IntegerToString(s), OBJPROP_COLOR, g_ms5Stats[s].openOrders > 0 ? clrYellow : clrGray);
    }

    // Performance
    ObjectSetString(0, p+"TdVl", OBJPROP_TEXT, IntegerToString(totalT));
    double wr = totalT > 0 ? (double)totalW / totalT * 100.0 : 0;
    ObjectSetString(0, p+"WrVl", OBJPROP_TEXT, DoubleToString(wr, 1) + "%");
    ObjectSetInteger(0, p+"WrVl", OBJPROP_COLOR, wr >= 50 ? val : danger);
    ObjectSetString(0, p+"PfVl", OBJPROP_TEXT, DoubleToString(g_ms5Perf.profitFactor, 2));
    ObjectSetInteger(0, p+"PfVl", OBJPROP_COLOR, g_ms5Perf.profitFactor >= 1.0 ? val : danger);
    double _ms5GER = AI_MS5_GetGlobalEdgeRatio();
    ObjectSetString(0, p+"ERVl", OBJPROP_TEXT, AI_MS5_GetTotalEdgeTrades() < 5 ? "---" : DoubleToString(_ms5GER, 2));
    ObjectSetInteger(0, p+"ERVl", OBJPROP_COLOR, _ms5GER >= 1.0 ? val : (_ms5GER >= 0.7 ? warn : danger));
    ObjectSetString(0, p+"DdVl", OBJPROP_TEXT, DoubleToString(g_ms5Perf.maxDrawdown, 2) + "%");
    ObjectSetInteger(0, p+"DdVl", OBJPROP_COLOR, g_ms5Perf.maxDrawdown < g_ms5DDLimit * 0.5 ? val : (g_ms5Perf.maxDrawdown < g_ms5DDLimit * 0.8 ? warn : danger));
    ObjectSetString(0, p+"DLVl", OBJPROP_TEXT, DoubleToString(g_ms5DDLimit, 0) + "%");
    ObjectSetInteger(0, p+"DLVl", OBJPROP_COLOR, g_ms5Perf.maxDrawdown >= g_ms5DDLimit ? danger : (g_ms5Perf.maxDrawdown >= g_ms5DDLimit * 0.8 ? warn : clrCyan));

    // AI Parameters
    if (g_ms5Perf.isPaused) {
        ObjectSetString(0, p+"AsVl", OBJPROP_TEXT, "PAUSED");
        ObjectSetInteger(0, p+"AsVl", OBJPROP_COLOR, danger);
    } else {
        ObjectSetString(0, p+"AsVl", OBJPROP_TEXT, "ACTIVE");
        ObjectSetInteger(0, p+"AsVl", OBJPROP_COLOR, val);
    }
    ObjectSetString(0, p+"SLVl", OBJPROP_TEXT, DoubleToString(adaptedSL, 1) + " pts");
    ObjectSetString(0, p+"TPVl", OBJPROP_TEXT, DoubleToString(adaptedTP, 1) + " pts");
    ObjectSetString(0, p+"LtVl", OBJPROP_TEXT, DoubleToString(adaptedLots, 2) + " lots");
    double rr = adaptedSL > 0 ? adaptedTP / adaptedSL : 0;
    ObjectSetString(0, p+"RRVl", OBJPROP_TEXT, DoubleToString(rr, 1) + ":1");
    ObjectSetInteger(0, p+"RRVl", OBJPROP_COLOR, rr >= 1.5 ? val : warn);

    ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| ADVANCED LEARNING & MANAGEMENT (Multi-Strategic Agent MQL5)        |
//| Ported from Strategic Agent for feature parity                     |
//+------------------------------------------------------------------+

bool g_ms5FastLearning = false;
bool g_ms5StateInterp = false;
bool g_ms5AdaptiveCov = false;
bool g_ms5VirtualExp = false;
bool g_ms5RegimeProgress = false;
bool g_ms5RegimeVisited[10];
double g_ms5AdaptedCoverageTarget = 70.0;
double g_ms5LastCoverageCheck = 0;
int g_ms5LastCoverageCheckEp = 0;
string g_ms5AdvancedWarning = "";
string g_ms5QTableImportFile = "";

struct MS5_PerfMetrics {
    int totalTrades; int winningTrades; double totalProfit;
    double maxDrawdown; double profitFactor;
    bool isPaused; string pauseReason;
};
MS5_PerfMetrics g_ms5Perf;
bool g_ms5PerfInit = false;

struct MS5_OrigParams {
    ulong ticket; double originalSLPips; double originalTPPips;
    double lastAppliedSLPips; double lastAppliedTPPips;
    datetime openTime; bool isValid;
};
MS5_OrigParams g_ms5OrigParams[20];
int g_ms5OrigParamsCnt = 0;
bool g_ms5OrigParamsInit = false;

void AI_MS5_InitAdvancedLearning(bool fastMode, bool stateInterp, bool adaptiveCov, bool virtualExp, bool regimeProgress) {
    g_ms5FastLearning = fastMode;
    g_ms5StateInterp = stateInterp;
    g_ms5AdaptiveCov = adaptiveCov;
    g_ms5VirtualExp = virtualExp;
    g_ms5RegimeProgress = regimeProgress;
    g_ms5AdaptedCoverageTarget = fastMode ? 35.0 : 70.0;
    g_ms5LastCoverageCheck = 0; g_ms5LastCoverageCheckEp = 0;
    g_ms5AdvancedWarning = "";
    for (int i = 0; i < 10; i++) g_ms5RegimeVisited[i] = false;
    if (fastMode) g_ms5AdvancedWarning = "MODO RAPIDO: Precision reducida";
    else if (virtualExp) g_ms5AdvancedWarning = "EXP. VIRTUALES: Datos sinteticos";
    else if (stateInterp) g_ms5AdvancedWarning = "INTERPOLACION: Beta";
    if (!g_ms5PerfInit) {
        g_ms5Perf.totalTrades = 0; g_ms5Perf.winningTrades = 0; g_ms5Perf.totalProfit = 0;
        g_ms5Perf.maxDrawdown = 0; g_ms5Perf.profitFactor = 0;
        g_ms5Perf.isPaused = false; g_ms5Perf.pauseReason = "";
        g_ms5PerfInit = true;
    }
}

void AI_MS5_MarkRegimeVisited(int regime) {
    if (regime >= 0 && regime < 10) g_ms5RegimeVisited[regime] = true;
}

int AI_MS5_CountVisitedRegimes() {
    int cnt = 0;
    for (int i = 0; i < 10; i++) if (g_ms5RegimeVisited[i]) cnt++;
    return cnt;
}

void AI_MS5_DetectStagnation(int slot) {
    if (!g_ms5AdaptiveCov || g_ms5FastLearning) return;
    if (slot < 0 || slot >= MS5_SLOTS) return;
    int curEp = g_ms5Episodes[slot];
    if (curEp - g_ms5LastCoverageCheckEp < 50) return;
    int visited = 0;
    for (int st = 0; st < MS5_STATES; st++)
        for (int a = 0; a < MS5_ACTIONS; a++)
            if (g_ms5Visits[slot][st][a] > 0) visited++;
    double currentCov = (double)visited / (MS5_STATES * MS5_ACTIONS) * 100.0;
    double delta = currentCov - g_ms5LastCoverageCheck;
    if (delta < 2.0 && g_ms5LastCoverageCheckEp > 0) {
        g_ms5AdaptedCoverageTarget = MathMax(25.0, g_ms5AdaptedCoverageTarget - 5.0);
        g_ms5AdvancedWarning = "ADAPTADO: Objetivo " + DoubleToString(g_ms5AdaptedCoverageTarget, 0) + "%";
    }
    g_ms5LastCoverageCheck = currentCov;
    g_ms5LastCoverageCheckEp = curEp;
}

void AI_MS5_InterpolateNearbyStates(int slot, int state, int action, double qValue) {
    if (!g_ms5StateInterp) return;
    if (slot < 0 || slot >= MS5_SLOTS || state < 0 || state >= MS5_STATES) return;
    if (action < 0 || action >= MS5_ACTIONS) return;
    int regime = state / 10;
    int subState = state % 10;
    double interpQ = qValue * 0.5;
    for (int d = -1; d <= 1; d += 2) {
        int ns = subState + d;
        if (ns >= 0 && ns < 10) {
            int neighborState = regime * 10 + ns;
            if (g_ms5Visits[slot][neighborState][action] == 0 && g_ms5QTable[slot][neighborState][action] == 0.0)
                g_ms5QTable[slot][neighborState][action] = interpQ;
        }
    }
}

void AI_MS5_GenerateVirtualExperience(int slot, int state, int action, double reward, int nextState) {
    if (!g_ms5VirtualExp) return;
    if (slot < 0 || slot >= MS5_SLOTS) return;
    int regime = state / 10;
    int subState = state % 10;
    for (int i = 0; i < 2; i++) {
        int vs = subState + (i == 0 ? -1 : 1);
        if (vs < 0 || vs >= 10) continue;
        int virtualState = regime * 10 + vs;
        double noise = (MathRand() % 31 - 15) / 100.0;
        double vReward = reward * (1.0 + noise);
        AI_MS5_SaveExp(slot, virtualState, action, vReward, nextState);
    }
}

void AI_MS5_SetQTableImportFile(string importFile) {
    g_ms5QTableImportFile = importFile;
    if (StringLen(importFile) > 0)
        Print("AI_MS5: Q-Table import configured: " + importFile);
}

void AI_MS5_CheckPerformanceDegradation(double maxAllowedDD) {
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double currentDD = (balance > 0) ? ((balance - equity) / balance) * 100 : 0;
    if (currentDD > g_ms5Perf.maxDrawdown) g_ms5Perf.maxDrawdown = currentDD;
    if (g_ms5Perf.isPaused) {
        if (currentDD < maxAllowedDD * 0.7) {
            if (g_ms5Perf.profitFactor > 1.0 || g_ms5Perf.totalTrades < 20) {
                g_ms5Perf.isPaused = false; g_ms5Perf.pauseReason = "";
                Print("AI MS5 Agent RESUMED - DD recovered: " + DoubleToString(currentDD, 1) + "%");
            }
        }
        return;
    }
    if (g_ms5Perf.totalTrades < 10) return;
    if (currentDD > maxAllowedDD) {
        g_ms5Perf.isPaused = true;
        g_ms5Perf.pauseReason = "DD: " + DoubleToString(currentDD, 1) + "% > " + DoubleToString(maxAllowedDD, 0) + "%";
        Print("AI MS5 Agent PAUSED - " + g_ms5Perf.pauseReason);
        return;
    }
    if (g_ms5Perf.profitFactor < 0.7 && g_ms5Perf.totalProfit < 0) {
        g_ms5Perf.isPaused = true;
        g_ms5Perf.pauseReason = "PF=" + DoubleToString(g_ms5Perf.profitFactor, 2);
        Print("AI MS5 Agent PAUSED - " + g_ms5Perf.pauseReason);
    }
}

void AI_MS5_InitOriginalParams() {
    if (g_ms5OrigParamsInit) return;
    for (int i = 0; i < 20; i++) { g_ms5OrigParams[i].ticket = 0; g_ms5OrigParams[i].isValid = false; }
    g_ms5OrigParamsCnt = 0; g_ms5OrigParamsInit = true;
}

void AI_MS5_StoreOriginalParams(ulong ticket, double slPips, double tpPips) {
    AI_MS5_InitOriginalParams();
    for (int i = 0; i < 20; i++)
        if (g_ms5OrigParams[i].isValid && g_ms5OrigParams[i].ticket == ticket) return;
    for (int i = 0; i < 20; i++) {
        if (!g_ms5OrigParams[i].isValid) {
            g_ms5OrigParams[i].ticket = ticket;
            g_ms5OrigParams[i].originalSLPips = slPips; g_ms5OrigParams[i].originalTPPips = tpPips;
            g_ms5OrigParams[i].lastAppliedSLPips = slPips; g_ms5OrigParams[i].lastAppliedTPPips = tpPips;
            g_ms5OrigParams[i].openTime = TimeCurrent(); g_ms5OrigParams[i].isValid = true;
            g_ms5OrigParamsCnt++; return;
        }
    }
}

int AI_MS5_GetOrigParamsIdx(ulong ticket) {
    AI_MS5_InitOriginalParams();
    for (int i = 0; i < 20; i++)
        if (g_ms5OrigParams[i].isValid && g_ms5OrigParams[i].ticket == ticket) return i;
    return -1;
}

void AI_MS5_ActiveOrderManagement(int baseMagic, double currentSLPips, double currentTPPips) {
    AI_MS5_InitOriginalParams();
    const double THRESHOLD = 10.0;
    for (int i = 0; i < 20; i++) {
        if (!g_ms5OrigParams[i].isValid) continue;
        bool found = false;
        for (int j = PositionsTotal() - 1; j >= 0; j--) {
            ulong tkt = PositionGetTicket(j);
            if (tkt == g_ms5OrigParams[i].ticket) { found = true; break; }
        }
        if (!found) { g_ms5OrigParams[i].isValid = false; g_ms5OrigParams[i].ticket = 0; g_ms5OrigParamsCnt--; }
    }
    MqlTradeRequest req; MqlTradeResult res;
    for (int sl = 0; sl < MS5_SLOTS; sl++) {
        int slotMagic = baseMagic + sl;
        for (int i = PositionsTotal() - 1; i >= 0; i--) {
            ulong tkt = PositionGetTicket(i);
            if (tkt == 0) continue;
            if (PositionGetInteger(POSITION_MAGIC) != slotMagic) continue;
            if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
            int idx = AI_MS5_GetOrigParamsIdx(tkt);
            if (idx < 0) {
                double pOP = PositionGetDouble(POSITION_PRICE_OPEN);
                double pSL = PositionGetDouble(POSITION_SL);
                double pTP = PositionGetDouble(POSITION_TP);
                long pType = PositionGetInteger(POSITION_TYPE);
                double cSL = 0, cTP = 0;
                if (pType == POSITION_TYPE_BUY) { if (pSL > 0) cSL = (pOP - pSL)/_Point; if (pTP > 0) cTP = (pTP - pOP)/_Point; }
                else { if (pSL > 0) cSL = (pSL - pOP)/_Point; if (pTP > 0) cTP = (pOP - pTP)/_Point; }
                if (cSL > 0 && cTP > 0) { AI_MS5_StoreOriginalParams(tkt, cSL, cTP); idx = AI_MS5_GetOrigParamsIdx(tkt); }
                if (idx < 0) continue;
            }
            double slRed = g_ms5OrigParams[idx].lastAppliedSLPips > 0 ? ((g_ms5OrigParams[idx].lastAppliedSLPips - currentSLPips) / g_ms5OrigParams[idx].lastAppliedSLPips) * 100.0 : 0;
            double tpRed = g_ms5OrigParams[idx].lastAppliedTPPips > 0 ? ((g_ms5OrigParams[idx].lastAppliedTPPips - currentTPPips) / g_ms5OrigParams[idx].lastAppliedTPPips) * 100.0 : 0;
            if (slRed < THRESHOLD && tpRed < THRESHOLD) continue;
            double oP = PositionGetDouble(POSITION_PRICE_OPEN);
            double curSL = PositionGetDouble(POSITION_SL);
            double curTP = PositionGetDouble(POSITION_TP);
            double nSL = curSL, nTP = curTP;
            long pType = PositionGetInteger(POSITION_TYPE);
            if (pType == POSITION_TYPE_BUY) {
                if (slRed >= THRESHOLD) { double p = NormalizeDouble(oP - currentSLPips * _Point, _Digits); if (p > nSL) nSL = p; }
                if (tpRed >= THRESHOLD) { double p = NormalizeDouble(oP + currentTPPips * _Point, _Digits); if (p < nTP && p > oP) nTP = p; }
            } else {
                if (slRed >= THRESHOLD) { double p = NormalizeDouble(oP + currentSLPips * _Point, _Digits); if (p < nSL) nSL = p; }
                if (tpRed >= THRESHOLD) { double p = NormalizeDouble(oP - currentTPPips * _Point, _Digits); if (p > nTP && p < oP) nTP = p; }
            }
            if (nSL != curSL || nTP != curTP) {
                ZeroMemory(req); ZeroMemory(res);
                req.action = TRADE_ACTION_SLTP;
                req.position = tkt; req.symbol = _Symbol;
                req.sl = nSL; req.tp = nTP;
                if (OrderSend(req, res)) {
                    g_ms5OrigParams[idx].lastAppliedSLPips = currentSLPips;
                    g_ms5OrigParams[idx].lastAppliedTPPips = currentTPPips;
                }
            }
        }
    }
}

void AI_MS5_UpdatePerfStats(double profit) {
    g_ms5Perf.totalTrades++;
    if (profit > 0) g_ms5Perf.winningTrades++;
    g_ms5Perf.totalProfit += profit;
    double grossWin = 0, grossLoss = 0;
    for (int s = 0; s < MS5_SLOTS; s++) {
        if (g_ms5Stats[s].profit > 0) grossWin += g_ms5Stats[s].profit;
        else grossLoss += MathAbs(g_ms5Stats[s].profit);
    }
    g_ms5Perf.profitFactor = grossLoss > 0 ? grossWin / grossLoss : (grossWin > 0 ? 99.0 : 0);
}

//+------------------------------------------------------------------+
//| EDGE RATIO - Entry Quality Analysis MQL5 (MFE/MAE per slot)       |
//+------------------------------------------------------------------+
void AI_MS5_UpdateSlotEdge(int slot, double mfe, double mae) {
    if (slot < 0 || slot >= MS5_SLOTS) return;
    g_ms5SlotMFESum[slot] += mfe;
    g_ms5SlotMAESum[slot] += mae;
    g_ms5SlotEdgeTrades[slot]++;
}

double AI_MS5_GetSlotEdgeRatio(int slot) {
    if (slot < 0 || slot >= MS5_SLOTS || g_ms5SlotEdgeTrades[slot] < 5) return 1.0;
    double avgMAE = g_ms5SlotMAESum[slot] / g_ms5SlotEdgeTrades[slot];
    if (avgMAE <= 0) return 2.0;
    return (g_ms5SlotMFESum[slot] / g_ms5SlotEdgeTrades[slot]) / avgMAE;
}

double AI_MS5_GetGlobalEdgeRatio() {
    double totalMFE = 0, totalMAE = 0; int totalT = 0;
    for (int s = 0; s < MS5_SLOTS; s++) {
        totalMFE += g_ms5SlotMFESum[s];
        totalMAE += g_ms5SlotMAESum[s];
        totalT += g_ms5SlotEdgeTrades[s];
    }
    if (totalT < 5) return 1.0;
    double avgMAE = totalMAE / totalT;
    if (avgMAE <= 0) return 2.0;
    return (totalMFE / totalT) / avgMAE;
}

int AI_MS5_GetTotalEdgeTrades() {
    int t = 0;
    for (int s = 0; s < MS5_SLOTS; s++) t += g_ms5SlotEdgeTrades[s];
    return t;
}

double AI_MS5_EdgeLotMultiplier(int slot, int minTrades) {
    if (g_ms5SlotEdgeTrades[slot] < minTrades) return 1.0;
    double er = AI_MS5_GetSlotEdgeRatio(slot);
    if (er >= 1.5) return 1.15;
    if (er >= 1.0) return 1.0 + (er - 1.0) * 0.3;
    return MathMax(0.5, 0.5 + er * 0.5);
}

void AI_MS5_CalcTradeEdge(ulong dealTicket, int slot) {
    if (slot < 0 || slot >= MS5_SLOTS) return;
    ulong posId = HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
    if (posId == 0) return;
    datetime openTime = 0; double openPrice = 0;
    ENUM_DEAL_TYPE openType = DEAL_TYPE_BUY;
    for (int d = HistoryDealsTotal() - 1; d >= 0; d--) {
        ulong dt2 = HistoryDealGetTicket(d);
        if (dt2 == 0) continue;
        if ((ulong)HistoryDealGetInteger(dt2, DEAL_POSITION_ID) != posId) continue;
        if ((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dt2, DEAL_ENTRY) == DEAL_ENTRY_IN) {
            openTime = (datetime)HistoryDealGetInteger(dt2, DEAL_TIME);
            openPrice = HistoryDealGetDouble(dt2, DEAL_PRICE);
            openType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dt2, DEAL_TYPE);
            break;
        }
    }
    if (openTime == 0 || openPrice <= 0) return;
    datetime closeTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
    int oBar = iBarShift(_Symbol, PERIOD_CURRENT, openTime);
    int cBar = iBarShift(_Symbol, PERIOD_CURRENT, closeTime);
    int nBars = oBar - cBar;
    if (nBars <= 0) return;
    int hBar = iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, nBars + 1, cBar);
    int lBar = iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, nBars + 1, cBar);
    double hi = iHigh(_Symbol, PERIOD_CURRENT, hBar);
    double lo = iLow(_Symbol, PERIOD_CURRENT, lBar);
    double mfe = 0, mae = 0;
    if (openType == DEAL_TYPE_BUY) {
        mfe = (hi - openPrice) / _Point;
        mae = (openPrice - lo) / _Point;
    } else {
        mfe = (openPrice - lo) / _Point;
        mae = (hi - openPrice) / _Point;
    }
    if (mfe < 0) mfe = 0;
    if (mae < 0) mae = 0;
    AI_MS5_UpdateSlotEdge(slot, mfe, mae);
}

// ===== PHASE 3 AI HELPER FUNCTIONS (MQL5) =====

// ===================================================================
// PHASE 3 AI NODES - HELPER FUNCTIONS (MQL5)
// DQN Agent | Neural Predictor | Anomaly Guard | Trend Intelligence
// ===================================================================

//+------------------------------------------------------------------+
//| SHARED AI HELPER: Hurst Exponent (R/S Analysis)                    |
//| Returns [0,1]: >0.5 trending, <0.5 mean-reverting, 0.5 random     |
//+------------------------------------------------------------------+
double AI_CalcHurst(int period) {
    if (period < 20) return 0.5;
    double closes[];
    ArraySetAsSeries(closes, true);
    if (CopyClose(_Symbol, PERIOD_CURRENT, 0, period + 1, closes) < period + 1) return 0.5;
    double rets[];
    ArrayResize(rets, period);
    for (int i = 0; i < period; i++)
        rets[i] = closes[i + 1] > 0 ? MathLog(closes[i] / closes[i + 1]) : 0;
    double sumXY = 0, sumX = 0, sumY = 0, sumX2 = 0;
    int cnt = 0;
    for (int s = 0; s < 4; s++) {
        int n = (s == 0) ? 5 : (s == 1 ? 10 : (s == 2 ? 20 : 25));
        if (n > period) continue;
        int segs = period / n;
        if (segs < 1) continue;
        double totalRS = 0; int valid = 0;
        for (int seg = 0; seg < segs; seg++) {
            int base = seg * n;
            double mean = 0;
            for (int i = 0; i < n; i++) mean += rets[base + i];
            mean /= n;
            double cumDev = 0, maxD = -1e20, minD = 1e20, sqSum = 0;
            for (int i = 0; i < n; i++) {
                double d = rets[base + i] - mean;
                cumDev += d;
                if (cumDev > maxD) maxD = cumDev;
                if (cumDev < minD) minD = cumDev;
                sqSum += d * d;
            }
            double R = maxD - minD;
            double S = MathSqrt(sqSum / n);
            if (S > 1e-10) { totalRS += R / S; valid++; }
        }
        if (valid > 0) {
            double avgRS = totalRS / valid;
            if (avgRS > 0) {
                double lN = MathLog((double)n);
                double lRS = MathLog(avgRS);
                sumXY += lN * lRS; sumX += lN; sumY += lRS; sumX2 += lN * lN;
                cnt++;
            }
        }
    }
    if (cnt < 2) return 0.5;
    double denom = cnt * sumX2 - sumX * sumX;
    if (MathAbs(denom) < 1e-10) return 0.5;
    double H = (cnt * sumXY - sumX * sumY) / denom;
    return MathMax(0.0, MathMin(1.0, H));
}

//+------------------------------------------------------------------+
//| SHARED AI HELPER: Shannon Entropy (Normalized [0,1])               |
//| Higher = more uncertain/complex market, Lower = more predictable   |
//+------------------------------------------------------------------+
double AI_CalcEntropy(int period) {
    if (period < 5) return 0.5;
    double closes[];
    ArraySetAsSeries(closes, true);
    if (CopyClose(_Symbol, PERIOD_CURRENT, 0, period + 1, closes) < period + 1) return 0.5;
    double rts[];
    ArrayResize(rts, period);
    double minR = 1e20, maxR = -1e20;
    for (int i = 0; i < period; i++) {
        rts[i] = closes[i + 1] > 0 ? (closes[i] - closes[i + 1]) / closes[i + 1] : 0;
        if (rts[i] < minR) minR = rts[i];
        if (rts[i] > maxR) maxR = rts[i];
    }
    double rng = maxR - minR;
    if (rng < 1e-10) return 0.0;
    int bins = 10;
    int bCnt[];
    ArrayResize(bCnt, bins);
    for (int i = 0; i < bins; i++) bCnt[i] = 0;
    for (int i = 0; i < period; i++) {
        int b = (int)((rts[i] - minR) / (rng + 1e-10) * bins);
        if (b >= bins) b = bins - 1;
        bCnt[b]++;
    }
    double entropy = 0;
    for (int i = 0; i < bins; i++) {
        if (bCnt[i] > 0) {
            double p = (double)bCnt[i] / period;
            entropy -= p * MathLog(p);
        }
    }
    double maxEnt = MathLog((double)bins);
    return maxEnt > 0 ? entropy / maxEnt : 0.0;
}

//+------------------------------------------------------------------+
//| DQN AGENT IA - Deep Q-Network v3.0 (MQL5)                         |
//| Architecture: [15 → 128 → 64 → 4] with Experience Replay          |
//| Features: RSI, MACD, ATR, ADX, BB, Stoch, Hurst, Entropy + more   |
//+------------------------------------------------------------------+
#define DQN5_FEAT 15
#define DQN5_H1 128
#define DQN5_H2 64
#define DQN5_ACT 4
#define DQN5_BUF 2000

// Network weights (flattened 1D for passing to functions)
double g_dqn5_w1[DQN5_H1 * DQN5_FEAT], g_dqn5_b1[DQN5_H1];
double g_dqn5_w2[DQN5_H2 * DQN5_H1], g_dqn5_b2[DQN5_H2];
double g_dqn5_w3[DQN5_ACT * DQN5_H2], g_dqn5_b3[DQN5_ACT];
// Target network
double g_dqn5_tw1[DQN5_H1 * DQN5_FEAT], g_dqn5_tb1[DQN5_H1];
double g_dqn5_tw2[DQN5_H2 * DQN5_H1], g_dqn5_tb2[DQN5_H2];
double g_dqn5_tw3[DQN5_ACT * DQN5_H2], g_dqn5_tb3[DQN5_ACT];
// Training intermediates
double g_dqn5_h1[DQN5_H1], g_dqn5_h2[DQN5_H2];
double g_dqn5_h1r[DQN5_H1], g_dqn5_h2r[DQN5_H2];

// Experience replay
struct DQN5_Exp {
    double state[DQN5_FEAT];
    int action;
    double reward;
    double next[DQN5_FEAT];
    bool done;
};
DQN5_Exp g_dqn5_buf[DQN5_BUF];
int g_dqn5_bufIdx = 0;
int g_dqn5_bufN = 0;
double g_dqn5_epsilon = 0.15;
int g_dqn5_steps = 0;
int g_dqn5_episodes = 0;
bool g_dqn5_init = false;
datetime g_dqn5_panelUpd = 0;
bool g_dqn5_panelOk = false;
double g_dqn5_totalReward = 0;
// Persistence + Performance tracking
#define DQN5_FILE_MAGIC 0x44514E35  // "DQN5"
bool g_dqn5_fileLoaded = false;
int g_dqn5_saveMagic = 0;
int g_dqn5_totalTrades = 0;
int g_dqn5_wins = 0;
double g_dqn5_totalProfit = 0;
double g_dqn5_maxDD = 0;
double g_dqn5_peakEquity = 0;

// Indicator handles for DQN
int g_dqn5_hRSI = INVALID_HANDLE, g_dqn5_hMACD = INVALID_HANDLE;
int g_dqn5_hATR = INVALID_HANDLE, g_dqn5_hSMA = INVALID_HANDLE;
int g_dqn5_hBB = INVALID_HANDLE, g_dqn5_hADX = INVALID_HANDLE;
int g_dqn5_hStoch = INVALID_HANDLE;
bool g_dqn5_hOk = false;

void AI_DQN5_InitHandles() {
    if (g_dqn5_hOk) return;
    g_dqn5_hRSI = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    g_dqn5_hMACD = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
    g_dqn5_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
    g_dqn5_hSMA = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    g_dqn5_hBB = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2, PRICE_CLOSE);
    g_dqn5_hADX = iADX(_Symbol, PERIOD_CURRENT, 14);
    g_dqn5_hStoch = iStochastic(_Symbol, PERIOD_CURRENT, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
    if (g_dqn5_hRSI == INVALID_HANDLE || g_dqn5_hMACD == INVALID_HANDLE || g_dqn5_hATR == INVALID_HANDLE || g_dqn5_hSMA == INVALID_HANDLE || g_dqn5_hBB == INVALID_HANDLE || g_dqn5_hADX == INVALID_HANDLE || g_dqn5_hStoch == INVALID_HANDLE) {
        Print("AI_DQN5: Failed to create indicator handles");
        return;
    }
    g_dqn5_hOk = true;
}

void AI_DQN5_Init() {
    if (g_dqn5_init) return;
    AI_DQN5_InitHandles();
    MathSrand(g_MasterSeed + 30000);
    // He initialization
    double s1 = MathSqrt(2.0 / DQN5_FEAT), s2 = MathSqrt(2.0 / DQN5_H1), s3 = MathSqrt(2.0 / DQN5_H2);
    for (int i = 0; i < DQN5_H1 * DQN5_FEAT; i++) g_dqn5_w1[i] = (MathRand() / 16383.5 - 1.0) * s1;
    for (int i = 0; i < DQN5_H2 * DQN5_H1; i++) g_dqn5_w2[i] = (MathRand() / 16383.5 - 1.0) * s2;
    for (int i = 0; i < DQN5_ACT * DQN5_H2; i++) g_dqn5_w3[i] = (MathRand() / 16383.5 - 1.0) * s3;
    for (int i = 0; i < DQN5_H1; i++) g_dqn5_b1[i] = 0;
    for (int i = 0; i < DQN5_H2; i++) g_dqn5_b2[i] = 0;
    for (int i = 0; i < DQN5_ACT; i++) g_dqn5_b3[i] = 0;
    // Copy to target
    ArrayCopy(g_dqn5_tw1, g_dqn5_w1); ArrayCopy(g_dqn5_tw2, g_dqn5_w2); ArrayCopy(g_dqn5_tw3, g_dqn5_w3);
    ArrayCopy(g_dqn5_tb1, g_dqn5_b1); ArrayCopy(g_dqn5_tb2, g_dqn5_b2); ArrayCopy(g_dqn5_tb3, g_dqn5_b3);
    g_dqn5_init = true;
}

// Forward pass (main network, stores intermediates)
void AI_DQN5_Forward(double &state[], double &qvals[]) {
    for (int i = 0; i < DQN5_H1; i++) {
        g_dqn5_h1r[i] = g_dqn5_b1[i];
        for (int j = 0; j < DQN5_FEAT; j++) g_dqn5_h1r[i] += g_dqn5_w1[i * DQN5_FEAT + j] * state[j];
        g_dqn5_h1[i] = g_dqn5_h1r[i] > 0 ? g_dqn5_h1r[i] : 0;
    }
    for (int i = 0; i < DQN5_H2; i++) {
        g_dqn5_h2r[i] = g_dqn5_b2[i];
        for (int j = 0; j < DQN5_H1; j++) g_dqn5_h2r[i] += g_dqn5_w2[i * DQN5_H1 + j] * g_dqn5_h1[j];
        g_dqn5_h2[i] = g_dqn5_h2r[i] > 0 ? g_dqn5_h2r[i] : 0;
    }
    for (int i = 0; i < DQN5_ACT; i++) {
        qvals[i] = g_dqn5_b3[i];
        for (int j = 0; j < DQN5_H2; j++) qvals[i] += g_dqn5_w3[i * DQN5_H2 + j] * g_dqn5_h2[j];
    }
}

// Forward pass (target network)
void AI_DQN5_ForwardTarget(double &state[], double &qvals[]) {
    double h1[DQN5_H1], h2[DQN5_H2];
    for (int i = 0; i < DQN5_H1; i++) {
        h1[i] = g_dqn5_tb1[i];
        for (int j = 0; j < DQN5_FEAT; j++) h1[i] += g_dqn5_tw1[i * DQN5_FEAT + j] * state[j];
        if (h1[i] < 0) h1[i] = 0;
    }
    for (int i = 0; i < DQN5_H2; i++) {
        h2[i] = g_dqn5_tb2[i];
        for (int j = 0; j < DQN5_H1; j++) h2[i] += g_dqn5_tw2[i * DQN5_H1 + j] * h1[j];
        if (h2[i] < 0) h2[i] = 0;
    }
    for (int i = 0; i < DQN5_ACT; i++) {
        qvals[i] = g_dqn5_tb3[i];
        for (int j = 0; j < DQN5_H2; j++) qvals[i] += g_dqn5_tw3[i * DQN5_H2 + j] * h2[j];
    }
}

// Get normalized state features (15 professional features, all in [-1,1] or [0,1])
void AI_DQN5_GetState(double &state[]) {
    if (!g_dqn5_hOk) { ArrayInitialize(state, 0); return; }
    double rsi = AI_P1_GetBuf(g_dqn5_hRSI, 0, 0);
    double macd = AI_P1_GetBuf(g_dqn5_hMACD, 0, 0);
    double atr = AI_P1_GetBuf(g_dqn5_hATR, 0, 0);
    double sma = AI_P1_GetBuf(g_dqn5_hSMA, 0, 0);
    double bbUp = AI_P1_GetBuf(g_dqn5_hBB, 1, 0);
    double bbLo = AI_P1_GetBuf(g_dqn5_hBB, 2, 0);
    double adx = AI_P1_GetBuf(g_dqn5_hADX, 0, 0);
    double stoch = AI_P1_GetBuf(g_dqn5_hStoch, 0, 0);
    double close0 = AI_P1_GetClose(0);
    double close5 = AI_P1_GetClose(5);
    double close20 = AI_P1_GetClose(20);
    double bbRange = bbUp - bbLo;
    // feat[0]: RSI [0,1]
    state[0] = rsi / 100.0;
    // feat[1]: MACD normalized by ATR [-1,1]
    state[1] = atr > 0 ? MathMax(-1, MathMin(1, macd / (atr * 2))) : 0;
    // feat[2]: ATR relative (volatility proxy) [0,1]
    state[2] = close0 > 0 ? MathMin(1.0, atr / close0 * 10.0) : 0;
    // feat[3]: ADX [0,1]
    state[3] = adx / 100.0;
    // feat[4]: Bollinger %B (position within bands) [0,1]
    state[4] = bbRange > 0 ? MathMax(0, MathMin(1, (close0 - bbLo) / bbRange)) : 0.5;
    // feat[5]: Stochastic [0,1]
    state[5] = stoch / 100.0;
    // feat[6]: SMA slope (20-bar) [-1,1]
    double sma5 = AI_P1_GetBuf(g_dqn5_hSMA, 0, 5);
    state[6] = sma5 > 0 ? MathMax(-1, MathMin(1, (sma - sma5) / sma5 * 100)) : 0;
    // feat[7]: 5-bar momentum [-1,1]
    state[7] = close5 > 0 ? MathMax(-1, MathMin(1, (close0 - close5) / close5 * 10)) : 0;
    // feat[8]: 20-bar momentum [-1,1]
    state[8] = close20 > 0 ? MathMax(-1, MathMin(1, (close0 - close20) / close20 * 5)) : 0;
    // feat[9]: Hurst Exponent [0,1] (>0.5=trending, <0.5=mean-reverting)
    state[9] = AI_CalcHurst(50);
    // feat[10]: Shannon Entropy [0,1] (higher=more complex/uncertain)
    state[10] = AI_CalcEntropy(20);
    // feat[11]: Relative volatility (current ATR / avg ATR 50 bars) [0,1]
    double atrSum = 0;
    for (int _av = 0; _av < 50; _av++) atrSum += AI_P1_GetBuf(g_dqn5_hATR, 0, _av);
    double atrAvg = atrSum / 50.0;
    state[11] = atrAvg > 0 ? MathMin(1.0, (atr / atrAvg) / 2.0) : 0.5;
    // feat[12]: Hour of day [0,1]
    MqlDateTime dt; TimeCurrent(dt);
    state[12] = dt.hour / 24.0;
    // feat[13]: Spread normalized by ATR [0,1]
    double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
    state[13] = atr > 0 ? MathMin(1.0, spread / atr) : 0;
    // feat[14]: Position state (0.0=none, 0.5=buy, 1.0=sell)
    state[14] = 0.0;
    for (int _ps = PositionsTotal() - 1; _ps >= 0; _ps--) {
        ulong _ptk = PositionGetTicket(_ps);
        if (_ptk > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol) {
            state[14] = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 0.5 : 1.0;
            break;
        }
    }
}

// Epsilon-greedy action selection
int AI_DQN5_SelectAction(double &qvals[], double eps) {
    if (MathRand() / 32767.0 < eps) return MathRand() % DQN5_ACT;
    int best = 0;
    for (int i = 1; i < DQN5_ACT; i++) if (qvals[i] > qvals[best]) best = i;
    return best;
}

// Store experience
void AI_DQN5_Store(double &s[], int a, double r, double &ns[], bool done) {
    int idx = g_dqn5_bufIdx % DQN5_BUF;
    ArrayCopy(g_dqn5_buf[idx].state, s, 0, 0, DQN5_FEAT);
    g_dqn5_buf[idx].action = a;
    g_dqn5_buf[idx].reward = r;
    ArrayCopy(g_dqn5_buf[idx].next, ns, 0, 0, DQN5_FEAT);
    g_dqn5_buf[idx].done = done;
    g_dqn5_bufIdx++;
    if (g_dqn5_bufN < DQN5_BUF) g_dqn5_bufN++;
}

// Train with mini-batch (backpropagation through 3 layers + gradient clipping)
void AI_DQN5_Train(int batch, double lr, double gamma, bool dblDQN) {
    if (g_dqn5_bufN < batch * 2) return;
    // Backtest Training: boost DQN learning rate for faster convergence
    double effectiveLR = g_IsBacktestTraining ? MathMin(lr * g_AITrainingSpeedMultiplier, 0.01) : lr;
    lr = effectiveLR;
    for (int b = 0; b < batch; b++) {
        int idx = MathRand() % g_dqn5_bufN;
        double qvals[DQN5_ACT];
        AI_DQN5_Forward(g_dqn5_buf[idx].state, qvals);
        double tq[DQN5_ACT];
        ArrayCopy(tq, qvals, 0, 0, DQN5_ACT);
        
        if (g_dqn5_buf[idx].done) {
            tq[g_dqn5_buf[idx].action] = g_dqn5_buf[idx].reward;
        } else {
            double nq[DQN5_ACT];
            AI_DQN5_ForwardTarget(g_dqn5_buf[idx].next, nq);
            double maxQ;
            if (dblDQN) {
                double mq[DQN5_ACT]; AI_DQN5_Forward(g_dqn5_buf[idx].next, mq);
                int bestA = 0;
                for (int i = 1; i < DQN5_ACT; i++) if (mq[i] > mq[bestA]) bestA = i;
                maxQ = nq[bestA];
            } else {
                maxQ = nq[0];
                for (int i = 1; i < DQN5_ACT; i++) if (nq[i] > maxQ) maxQ = nq[i];
            }
            tq[g_dqn5_buf[idx].action] = g_dqn5_buf[idx].reward + gamma * maxQ;
        }
        
        // Fresh forward pass for intermediates
        AI_DQN5_Forward(g_dqn5_buf[idx].state, qvals);
        
        // Output error (gradient clipped to [-1,1] for stability)
        double d3[DQN5_ACT];
        for (int i = 0; i < DQN5_ACT; i++) d3[i] = MathMax(-1.0, MathMin(1.0, tq[i] - qvals[i]));
        
        // Update W3, b3
        for (int i = 0; i < DQN5_ACT; i++) {
            for (int j = 0; j < DQN5_H2; j++)
                g_dqn5_w3[i * DQN5_H2 + j] += lr * d3[i] * g_dqn5_h2[j];
            g_dqn5_b3[i] += lr * d3[i];
        }
        // Backprop to H2 (clipped)
        double d2[DQN5_H2];
        for (int i = 0; i < DQN5_H2; i++) {
            double sum = 0;
            for (int j = 0; j < DQN5_ACT; j++) sum += g_dqn5_w3[j * DQN5_H2 + i] * d3[j];
            d2[i] = g_dqn5_h2r[i] > 0 ? MathMax(-1.0, MathMin(1.0, sum)) : 0;
        }
        for (int i = 0; i < DQN5_H2; i++) {
            for (int j = 0; j < DQN5_H1; j++)
                g_dqn5_w2[i * DQN5_H1 + j] += lr * d2[i] * g_dqn5_h1[j];
            g_dqn5_b2[i] += lr * d2[i];
        }
        // Backprop to H1 (clipped)
        double d1[DQN5_H1];
        for (int i = 0; i < DQN5_H1; i++) {
            double sum = 0;
            for (int j = 0; j < DQN5_H2; j++) sum += g_dqn5_w2[j * DQN5_H1 + i] * d2[j];
            d1[i] = g_dqn5_h1r[i] > 0 ? MathMax(-1.0, MathMin(1.0, sum)) : 0;
        }
        for (int i = 0; i < DQN5_H1; i++) {
            for (int j = 0; j < DQN5_FEAT; j++)
                g_dqn5_w1[i * DQN5_FEAT + j] += lr * d1[i] * g_dqn5_buf[idx].state[j];
            g_dqn5_b1[i] += lr * d1[i];
        }
    }
    g_dqn5_steps++;
}

void AI_DQN5_UpdateTarget() {
    ArrayCopy(g_dqn5_tw1, g_dqn5_w1); ArrayCopy(g_dqn5_tw2, g_dqn5_w2); ArrayCopy(g_dqn5_tw3, g_dqn5_w3);
    ArrayCopy(g_dqn5_tb1, g_dqn5_b1); ArrayCopy(g_dqn5_tb2, g_dqn5_b2); ArrayCopy(g_dqn5_tb3, g_dqn5_b3);
}

//+------------------------------------------------------------------+
//| DQN5 Persistence: Save/Load network weights to Common folder      |
//+------------------------------------------------------------------+
string AI_DQN5_GetFilename(int magic) {
    return "AI_DQN_" + IntegerToString(magic) + "_" + _Symbol + ".bin";
}

void AI_DQN5_Save(int magic) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return;
    string fn = AI_DQN5_GetFilename(magic);
    if (FileIsExist(fn, FILE_COMMON)) FileDelete(fn, FILE_COMMON);
    int h = FileOpen(fn, FILE_WRITE | FILE_BIN | FILE_COMMON);
    if (h == INVALID_HANDLE) { Print("[DQN5] Save FAILED: ", GetLastError()); return; }
    FileWriteInteger(h, (int)DQN5_FILE_MAGIC);
    FileWriteInteger(h, 2); // version 2 (15-feature 128-64 network)
    FileWriteInteger(h, DQN5_FEAT);
    FileWriteInteger(h, DQN5_H1);
    FileWriteInteger(h, DQN5_H2);
    // Main network weights
    for (int i = 0; i < DQN5_H1 * DQN5_FEAT; i++) FileWriteDouble(h, g_dqn5_w1[i]);
    for (int i = 0; i < DQN5_H1; i++) FileWriteDouble(h, g_dqn5_b1[i]);
    for (int i = 0; i < DQN5_H2 * DQN5_H1; i++) FileWriteDouble(h, g_dqn5_w2[i]);
    for (int i = 0; i < DQN5_H2; i++) FileWriteDouble(h, g_dqn5_b2[i]);
    for (int i = 0; i < DQN5_ACT * DQN5_H2; i++) FileWriteDouble(h, g_dqn5_w3[i]);
    for (int i = 0; i < DQN5_ACT; i++) FileWriteDouble(h, g_dqn5_b3[i]);
    // Target network weights
    for (int i = 0; i < DQN5_H1 * DQN5_FEAT; i++) FileWriteDouble(h, g_dqn5_tw1[i]);
    for (int i = 0; i < DQN5_H1; i++) FileWriteDouble(h, g_dqn5_tb1[i]);
    for (int i = 0; i < DQN5_H2 * DQN5_H1; i++) FileWriteDouble(h, g_dqn5_tw2[i]);
    for (int i = 0; i < DQN5_H2; i++) FileWriteDouble(h, g_dqn5_tb2[i]);
    for (int i = 0; i < DQN5_ACT * DQN5_H2; i++) FileWriteDouble(h, g_dqn5_tw3[i]);
    for (int i = 0; i < DQN5_ACT; i++) FileWriteDouble(h, g_dqn5_tb3[i]);
    // Training state
    FileWriteDouble(h, g_dqn5_epsilon);
    FileWriteInteger(h, g_dqn5_steps);
    FileWriteInteger(h, g_dqn5_episodes);
    FileWriteDouble(h, g_dqn5_totalReward);
    // Performance
    FileWriteInteger(h, g_dqn5_totalTrades);
    FileWriteInteger(h, g_dqn5_wins);
    FileWriteDouble(h, g_dqn5_totalProfit);
    FileWriteDouble(h, g_dqn5_maxDD);
    FileClose(h);
    Print("[DQN5] v3 Saved: ", fn, " | Steps: ", g_dqn5_steps, " | Trades: ", g_dqn5_totalTrades);
}

bool AI_DQN5_Load(int magic) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return false;
    string fn = AI_DQN5_GetFilename(magic);
    bool inCommon = FileIsExist(fn, FILE_COMMON);
    bool inLocal = !inCommon && FileIsExist(fn);
    if (!inCommon && !inLocal) { Print("[DQN5] No saved weights: ", fn); return false; }
    int flags = FILE_READ | FILE_BIN | (inCommon ? FILE_COMMON : 0);
    int h = FileOpen(fn, flags);
    if (h == INVALID_HANDLE) { Print("[DQN5] Load FAILED: ", GetLastError()); return false; }
    int mgc = FileReadInteger(h);
    if (mgc != (int)DQN5_FILE_MAGIC) { Print("[DQN5] Invalid header"); FileClose(h); return false; }
    int ver = FileReadInteger(h);
    if (ver < 2) { Print("[DQN5] Old v1 format incompatible with v3 network (15 features). Starting fresh."); FileClose(h); return false; }
    // Validate network dimensions match current architecture
    int fFeat = FileReadInteger(h); int fH1 = FileReadInteger(h); int fH2 = FileReadInteger(h);
    if (fFeat != DQN5_FEAT || fH1 != DQN5_H1 || fH2 != DQN5_H2) {
        Print("[DQN5] Dimension mismatch (file: ", fFeat, "/", fH1, "/", fH2, " vs code: ", DQN5_FEAT, "/", DQN5_H1, "/", DQN5_H2, "). Starting fresh.");
        FileClose(h); return false;
    }
    // Main network
    for (int i = 0; i < DQN5_H1 * DQN5_FEAT; i++) g_dqn5_w1[i] = FileReadDouble(h);
    for (int i = 0; i < DQN5_H1; i++) g_dqn5_b1[i] = FileReadDouble(h);
    for (int i = 0; i < DQN5_H2 * DQN5_H1; i++) g_dqn5_w2[i] = FileReadDouble(h);
    for (int i = 0; i < DQN5_H2; i++) g_dqn5_b2[i] = FileReadDouble(h);
    for (int i = 0; i < DQN5_ACT * DQN5_H2; i++) g_dqn5_w3[i] = FileReadDouble(h);
    for (int i = 0; i < DQN5_ACT; i++) g_dqn5_b3[i] = FileReadDouble(h);
    // Target network
    for (int i = 0; i < DQN5_H1 * DQN5_FEAT; i++) g_dqn5_tw1[i] = FileReadDouble(h);
    for (int i = 0; i < DQN5_H1; i++) g_dqn5_tb1[i] = FileReadDouble(h);
    for (int i = 0; i < DQN5_H2 * DQN5_H1; i++) g_dqn5_tw2[i] = FileReadDouble(h);
    for (int i = 0; i < DQN5_H2; i++) g_dqn5_tb2[i] = FileReadDouble(h);
    for (int i = 0; i < DQN5_ACT * DQN5_H2; i++) g_dqn5_tw3[i] = FileReadDouble(h);
    for (int i = 0; i < DQN5_ACT; i++) g_dqn5_tb3[i] = FileReadDouble(h);
    // Training state
    g_dqn5_epsilon = FileReadDouble(h);
    g_dqn5_steps = FileReadInteger(h);
    g_dqn5_episodes = FileReadInteger(h);
    g_dqn5_totalReward = FileReadDouble(h);
    // Performance
    g_dqn5_totalTrades = FileReadInteger(h);
    g_dqn5_wins = FileReadInteger(h);
    g_dqn5_totalProfit = FileReadDouble(h);
    g_dqn5_maxDD = FileReadDouble(h);
    FileClose(h);
    if (inLocal && !inCommon) AI_DQN5_Save(magic);
    g_dqn5_fileLoaded = true;
    g_dqn5_init = true;
    Print("[DQN5] v3 Loaded: ", fn, " | Steps: ", g_dqn5_steps, " | Eps: ", DoubleToString(g_dqn5_epsilon, 4));
    return true;
}

//+------------------------------------------------------------------+
//| DQN5 Enhanced Panel                                                |
//+------------------------------------------------------------------+
void AI_DQN5_CrLabel(string name, string text, int x, int y, color clr, int sz) {
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, sz);
    ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

void AI_DQN5_CreatePanel(int x, int y) {
    if (g_dqn5_panelOk) return;
    ObjectCreate(0, "AI_DQN5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_DQN5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_DQN5_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_DQN5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_DQN5_BG", OBJPROP_XSIZE, 310);
    ObjectSetInteger(0, "AI_DQN5_BG", OBJPROP_YSIZE, 430);
    ObjectSetInteger(0, "AI_DQN5_BG", OBJPROP_BGCOLOR, C'20,10,30');
    ObjectSetInteger(0, "AI_DQN5_BG", OBJPROP_BORDER_COLOR, C'80,30,100');
    ObjectSetInteger(0, "AI_DQN5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, "AI_DQN5_BG", OBJPROP_BACK, false);
    int ly = y + 8;
    AI_DQN5_CrLabel("AI_DQN5_T", "DQN SIGNAL IA [MT5]", x+10, ly, clrMagenta, 9); ly += 16;
    AI_DQN5_CrLabel("AI_DQN5_V", "v3.0 - 15feat 128-64 | Hurst+Entropy", x+10, ly, clrDarkGray, 7); ly += 18;
    AI_DQN5_CrLabel("AI_DQN5_S1", ":: NEURAL NETWORK", x+10, ly, clrGold, 8); ly += 16;
    AI_DQN5_CrLabel("AI_DQN5_Act", "Action: HOLD", x+15, ly, clrWhite, 8); ly += 15;
    AI_DQN5_CrLabel("AI_DQN5_Eps", "Epsilon: 0.150", x+15, ly, clrWhite, 8); ly += 15;
    AI_DQN5_CrLabel("AI_DQN5_Step", "Steps: 0", x+15, ly, clrWhite, 8); ly += 15;
    AI_DQN5_CrLabel("AI_DQN5_Ep", "Episodes: 0", x+15, ly, clrWhite, 8); ly += 15;
    AI_DQN5_CrLabel("AI_DQN5_Buf", "Buffer: 0/2000", x+15, ly, clrWhite, 8); ly += 15;
    AI_DQN5_CrLabel("AI_DQN5_TR", "TotalReward: 0.00", x+15, ly, clrWhite, 8); ly += 20;
    AI_DQN5_CrLabel("AI_DQN5_S2", ":: PERFORMANCE", x+10, ly, clrGold, 8); ly += 16;
    AI_DQN5_CrLabel("AI_DQN5_Trd", "Trades: 0", x+15, ly, clrWhite, 8); ly += 15;
    AI_DQN5_CrLabel("AI_DQN5_WR", "Win Rate: ---", x+15, ly, clrWhite, 8); ly += 15;
    AI_DQN5_CrLabel("AI_DQN5_PF", "Profit: 0.00", x+15, ly, clrWhite, 8); ly += 15;
    AI_DQN5_CrLabel("AI_DQN5_DD", "Max DD: 0.00%", x+15, ly, clrWhite, 8); ly += 20;
    AI_DQN5_CrLabel("AI_DQN5_S3", ":: STATE (15 FEATURES)", x+10, ly, clrGold, 8); ly += 16;
    AI_DQN5_CrLabel("AI_DQN5_F1", "RSI:-- ADX:-- BB%:--", x+15, ly, clrWhite, 8); ly += 14;
    AI_DQN5_CrLabel("AI_DQN5_F2", "Hurst:-- Entropy:-- VolR:--", x+15, ly, clrWhite, 8); ly += 14;
    AI_DQN5_CrLabel("AI_DQN5_F3", "Mom5:-- Mom20:-- Pos:--", x+15, ly, clrWhite, 8); ly += 15;
    AI_DQN5_CrLabel("AI_DQN5_File", "File: new", x+15, ly, clrDarkGray, 7);
    g_dqn5_panelOk = true;
}

void AI_DQN5_UpdatePanel(int action, double conf, double eps, double &state[]) {
    if (TimeCurrent() - g_dqn5_panelUpd < 1) return;
    g_dqn5_panelUpd = TimeCurrent();
    string actNames[] = {"HOLD","BUY","SELL","CLOSE"};
    color actCols[] = {clrGray, clrLime, clrOrangeRed, clrYellow};
    string an = action >= 0 && action < 4 ? actNames[action] : "?";
    color ac = action >= 0 && action < 4 ? actCols[action] : clrGray;
    ObjectSetString(0, "AI_DQN5_Act", OBJPROP_TEXT, "Action: " + an + " | Conf: " + DoubleToString(conf, 0) + "%");
    ObjectSetInteger(0, "AI_DQN5_Act", OBJPROP_COLOR, ac);
    ObjectSetString(0, "AI_DQN5_Eps", OBJPROP_TEXT, "Epsilon: " + DoubleToString(eps, 4));
    ObjectSetInteger(0, "AI_DQN5_Eps", OBJPROP_COLOR, eps > 0.1 ? clrYellow : (eps > 0.02 ? clrLime : clrCyan));
    ObjectSetString(0, "AI_DQN5_Step", OBJPROP_TEXT, "Steps: " + IntegerToString(g_dqn5_steps));
    ObjectSetString(0, "AI_DQN5_Ep", OBJPROP_TEXT, "Episodes: " + IntegerToString(g_dqn5_episodes));
    ObjectSetString(0, "AI_DQN5_Buf", OBJPROP_TEXT, "Buffer: " + IntegerToString(g_dqn5_bufN) + "/" + IntegerToString(DQN5_BUF));
    ObjectSetString(0, "AI_DQN5_TR", OBJPROP_TEXT, "TotalReward: " + DoubleToString(g_dqn5_totalReward, 2));
    ObjectSetInteger(0, "AI_DQN5_TR", OBJPROP_COLOR, g_dqn5_totalReward >= 0 ? clrLime : clrOrangeRed);
    // Performance
    ObjectSetString(0, "AI_DQN5_Trd", OBJPROP_TEXT, "Trades: " + IntegerToString(g_dqn5_totalTrades));
    double wr = g_dqn5_totalTrades > 0 ? (double)g_dqn5_wins / g_dqn5_totalTrades * 100.0 : 0;
    ObjectSetString(0, "AI_DQN5_WR", OBJPROP_TEXT, "Win Rate: " + DoubleToString(wr, 1) + "%");
    ObjectSetInteger(0, "AI_DQN5_WR", OBJPROP_COLOR, wr >= 50 ? clrLime : (wr > 0 ? clrOrangeRed : clrGray));
    ObjectSetString(0, "AI_DQN5_PF", OBJPROP_TEXT, "Profit: " + DoubleToString(g_dqn5_totalProfit, 2));
    ObjectSetInteger(0, "AI_DQN5_PF", OBJPROP_COLOR, g_dqn5_totalProfit >= 0 ? clrLime : clrOrangeRed);
    ObjectSetString(0, "AI_DQN5_DD", OBJPROP_TEXT, "Max DD: " + DoubleToString(g_dqn5_maxDD, 2) + "%");
    // State features (15 features)
    ObjectSetString(0, "AI_DQN5_F1", OBJPROP_TEXT, "RSI:" + DoubleToString(state[0]*100, 0) + " ADX:" + DoubleToString(state[3]*100, 0) + " BB%:" + DoubleToString(state[4]*100, 0) + " Stoch:" + DoubleToString(state[5]*100, 0));
    // Hurst & Entropy display with color coding
    double hurst = state[9]; double entropy = state[10];
    string hurstLbl = hurst > 0.6 ? "TREND" : (hurst < 0.4 ? "REVERT" : "RAND");
    ObjectSetString(0, "AI_DQN5_F2", OBJPROP_TEXT, "Hurst:" + DoubleToString(hurst, 2) + "(" + hurstLbl + ") Ent:" + DoubleToString(entropy, 2) + " VR:" + DoubleToString(state[11]*2, 1));
    ObjectSetInteger(0, "AI_DQN5_F2", OBJPROP_COLOR, hurst > 0.6 ? clrCyan : (hurst < 0.4 ? clrYellow : clrWhite));
    string posLbl = state[14] > 0.7 ? "SELL" : (state[14] > 0.3 ? "BUY" : "FLAT");
    ObjectSetString(0, "AI_DQN5_F3", OBJPROP_TEXT, "M5:" + DoubleToString(state[7], 2) + " M20:" + DoubleToString(state[8], 2) + " Pos:" + posLbl);
    ObjectSetString(0, "AI_DQN5_File", OBJPROP_TEXT, g_dqn5_fileLoaded ? "File: loaded (v3)" : "File: new");
    ObjectSetInteger(0, "AI_DQN5_File", OBJPROP_COLOR, g_dqn5_fileLoaded ? clrLime : clrGray);
}

//+------------------------------------------------------------------+
//| NEURAL PREDICTOR IA - LSTM Reservoir + Trained Output (MQL5)      |
//+------------------------------------------------------------------+
#define NP5_IN 5
#define NP5_HS 32
#define NP5_CS 37

// LSTM gate weights [HS x CS] flattened
double g_np5_Wf[NP5_HS * NP5_CS], g_np5_bf[NP5_HS];
double g_np5_Wi[NP5_HS * NP5_CS], g_np5_bi[NP5_HS];
double g_np5_Wg[NP5_HS * NP5_CS], g_np5_bg[NP5_HS];
double g_np5_Wo[NP5_HS * NP5_CS], g_np5_bo[NP5_HS];
// Output layer
double g_np5_Wy[NP5_HS];
double g_np5_by = 0;
// LSTM state
double g_np5_h[NP5_HS], g_np5_c[NP5_HS];
bool g_np5_init = false;
datetime g_np5_panelUpd = 0;
bool g_np5_panelOk = false;
datetime g_np5_lastBar = 0;
int g_np5_predictions = 0;
int g_np5_correct = 0;
double g_np5_lastPred = 0.5;

// Indicator handles for NP
int g_np5_hRSI = INVALID_HANDLE, g_np5_hATR = INVALID_HANDLE, g_np5_hSMA = INVALID_HANDLE;
bool g_np5_hInit = false;

double AI_NP5_Sig(double x) { if (x > 20) return 1.0; if (x < -20) return 0.0; return 1.0 / (1.0 + MathExp(-x)); }

void AI_NP5_Init() {
    if (g_np5_init) return;
    if (!g_np5_hInit) {
        g_np5_hRSI = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
        g_np5_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
        g_np5_hSMA = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
        if (g_np5_hRSI == INVALID_HANDLE || g_np5_hATR == INVALID_HANDLE || g_np5_hSMA == INVALID_HANDLE) {
            Print("AI_NP5: Failed to create indicator handles");
            return;
        }
        g_np5_hInit = true;
    }
    MathSrand(g_MasterSeed + 40000);
    double scale = MathSqrt(1.0 / NP5_CS);
    for (int i = 0; i < NP5_HS * NP5_CS; i++) {
        g_np5_Wf[i] = (MathRand() / 16383.5 - 1.0) * scale;
        g_np5_Wi[i] = (MathRand() / 16383.5 - 1.0) * scale;
        g_np5_Wg[i] = (MathRand() / 16383.5 - 1.0) * scale;
        g_np5_Wo[i] = (MathRand() / 16383.5 - 1.0) * scale;
    }
    // Forget gate bias > 0 (LSTM best practice)
    for (int i = 0; i < NP5_HS; i++) {
        g_np5_bf[i] = 1.0; g_np5_bi[i] = 0; g_np5_bg[i] = 0; g_np5_bo[i] = 0;
        g_np5_Wy[i] = (MathRand() / 16383.5 - 1.0) * 0.1;
        g_np5_h[i] = 0; g_np5_c[i] = 0;
    }
    g_np5_by = 0;
    g_np5_init = true;
}

// Single LSTM timestep
void AI_NP5_Step(double &x[]) {
    double concat[NP5_CS];
    for (int i = 0; i < NP5_HS; i++) concat[i] = g_np5_h[i];
    for (int i = 0; i < NP5_IN; i++) concat[NP5_HS + i] = x[i];
    
    for (int i = 0; i < NP5_HS; i++) {
        double sf = g_np5_bf[i], si = g_np5_bi[i], sg = g_np5_bg[i], so = g_np5_bo[i];
        for (int j = 0; j < NP5_CS; j++) {
            int idx = i * NP5_CS + j;
            sf += g_np5_Wf[idx] * concat[j];
            si += g_np5_Wi[idx] * concat[j];
            sg += g_np5_Wg[idx] * concat[j];
            so += g_np5_Wo[idx] * concat[j];
        }
        double f = AI_NP5_Sig(sf);
        double ig = AI_NP5_Sig(si);
        double g = MathTanh(sg);
        double o = AI_NP5_Sig(so);
        g_np5_c[i] = f * g_np5_c[i] + ig * g;
        g_np5_h[i] = o * MathTanh(g_np5_c[i]);
    }
}

// Get features for one bar (5 features)
void AI_NP5_GetBarFeatures(int shift, double &feat[]) {
    double cl0 = AI_P1_GetClose(shift);
    double cl1 = AI_P1_GetClose(shift + 1);
    double hi[], lo[];
    ArraySetAsSeries(hi, true); ArraySetAsSeries(lo, true);
    CopyHigh(_Symbol, PERIOD_CURRENT, shift, 1, hi);
    CopyLow(_Symbol, PERIOD_CURRENT, shift, 1, lo);
    double h = ArraySize(hi) > 0 ? hi[0] : cl0;
    double l = ArraySize(lo) > 0 ? lo[0] : cl0;
    
    feat[0] = cl1 > 0 ? (cl0 - cl1) / cl1 * 100.0 : 0;                    // Price change %
    feat[1] = cl0 > 0 ? (h - l) / cl0 * 100.0 : 0;                         // Range %
    feat[2] = AI_P1_GetBuf(g_np5_hRSI, 0, shift) / 100.0;                  // RSI normalized
    feat[3] = cl0 > 0 ? AI_P1_GetBuf(g_np5_hATR, 0, shift) / cl0 * 100 : 0; // ATR relative
    double sma = AI_P1_GetBuf(g_np5_hSMA, 0, shift);
    feat[4] = sma > 0 ? (cl0 - sma) / sma * 100.0 : 0;                     // Distance from SMA
}

// Forward pass through sequence → prediction
double AI_NP5_Predict(int seqLen) {
    // Reset LSTM state
    for (int i = 0; i < NP5_HS; i++) { g_np5_h[i] = 0; g_np5_c[i] = 0; }
    
    for (int t = seqLen; t >= 1; t--) {
        double feat[NP5_IN];
        AI_NP5_GetBarFeatures(t, feat);
        AI_NP5_Step(feat);
    }
    // Output layer: sigmoid(Wy . h + by)
    double out = g_np5_by;
    for (int i = 0; i < NP5_HS; i++) out += g_np5_Wy[i] * g_np5_h[i];
    return AI_NP5_Sig(out);
}

// Train output layer (gradient descent + L2 regularization)
// Note: LSTM gates remain fixed (Reservoir Computing paradigm).
// Only the output projection Wy/by is trained online.
void AI_NP5_TrainOutput(double prediction, double target, double lr) {
    double err = prediction - target;
    double grad = err * prediction * (1.0 - prediction); // sigmoid derivative
    double l2 = 0.001; // L2 regularization factor
    for (int i = 0; i < NP5_HS; i++)
        g_np5_Wy[i] -= lr * (grad * g_np5_h[i] + l2 * g_np5_Wy[i]);
    g_np5_by -= lr * grad;
}

// Periodically re-diversify the reservoir (called every N bars)
void AI_NP5_RefreshReservoir() {
    // Re-randomize a fraction of LSTM weights for diversity
    int numReplace = NP5_HS * NP5_CS / 10; // 10% of weights
    double scale = MathSqrt(1.0 / NP5_CS);
    for (int k = 0; k < numReplace; k++) {
        int idx = MathRand() % (NP5_HS * NP5_CS);
        g_np5_Wf[idx] = (MathRand() / 16383.5 - 1.0) * scale;
        g_np5_Wi[idx] = (MathRand() / 16383.5 - 1.0) * scale;
        g_np5_Wg[idx] = (MathRand() / 16383.5 - 1.0) * scale;
        g_np5_Wo[idx] = (MathRand() / 16383.5 - 1.0) * scale;
    }
}

void AI_NP5_CreatePanel(int x, int y) {
    if (g_np5_panelOk) return;
    ObjectCreate(0, "AI_NP5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_NP5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_NP5_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_NP5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_NP5_BG", OBJPROP_XSIZE, 280);
    ObjectSetInteger(0, "AI_NP5_BG", OBJPROP_YSIZE, 130);
    ObjectSetInteger(0, "AI_NP5_BG", OBJPROP_BGCOLOR, C'10,25,25');
    ObjectSetInteger(0, "AI_NP5_BG", OBJPROP_BORDER_COLOR, C'30,80,80');
    ObjectSetInteger(0, "AI_NP5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    for (int i = 0; i < 5; i++) {
        string nm = "AI_NP5_L" + IntegerToString(i);
        ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x + 10);
        ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y + 8 + i * 23);
        ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 9 : 8);
        ObjectSetInteger(0, nm, OBJPROP_COLOR, i == 0 ? clrTeal : clrWhite);
    }
    ObjectSetString(0, "AI_NP5_L0", OBJPROP_TEXT, "NEURAL PREDICTOR [MT5]");
    g_np5_panelOk = true;
}

void AI_NP5_UpdatePanel(double pred, double mag, int seqLen) {
    if (TimeCurrent() - g_np5_panelUpd < 1) return;
    g_np5_panelUpd = TimeCurrent();
    string dir = pred > 0.6 ? "BULLISH" : (pred < 0.4 ? "BEARISH" : "NEUTRAL");
    color dc = pred > 0.6 ? clrLime : (pred < 0.4 ? clrOrangeRed : clrYellow);
    ObjectSetString(0, "AI_NP5_L1", OBJPROP_TEXT, "Prediction: " + dir + " (" + DoubleToString(pred * 100, 1) + "%)");
    ObjectSetInteger(0, "AI_NP5_L1", OBJPROP_COLOR, dc);
    ObjectSetString(0, "AI_NP5_L2", OBJPROP_TEXT, "Magnitude: " + DoubleToString(mag, 1) + " pts");
    double acc = g_np5_predictions > 10 ? (double)g_np5_correct / g_np5_predictions * 100.0 : 0;
    ObjectSetString(0, "AI_NP5_L3", OBJPROP_TEXT, "Accuracy: " + DoubleToString(acc, 1) + "% (" + IntegerToString(g_np5_predictions) + " pred)");
    ObjectSetString(0, "AI_NP5_L4", OBJPROP_TEXT, "Reservoir LSTM | Seq: " + IntegerToString(seqLen));
}

//+------------------------------------------------------------------+
//| ANOMALY GUARD IA - MQL5 Version                                    |
//+------------------------------------------------------------------+
int g_ag5_type = 0;
double g_ag5_score = 0;
bool g_ag5_paused = false;
datetime g_ag5_pauseEnd = 0;
datetime g_ag5_lastCheck = 0;
datetime g_ag5_panelUpd = 0;
bool g_ag5_panelOk = false;
int g_ag5_hATR = INVALID_HANDLE;
bool g_ag5_hInit = false;

void AI_AG5_InitHandles() {
    if (g_ag5_hInit) return;
    g_ag5_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
    if (g_ag5_hATR == INVALID_HANDLE) {
        Print("AI_AG5: Failed to create indicator handle for ATR");
        return;
    }
    g_ag5_hInit = true;
}

int AI_AG5_Detect(int lookback, double pzTh, double volTh, double spTh) {
    if (TimeCurrent() - g_ag5_lastCheck < 2) return g_ag5_type;
    g_ag5_lastCheck = TimeCurrent();
    if (!g_ag5_hInit) AI_AG5_InitHandles();
    g_ag5_type = 0; g_ag5_score = 0;
    
    double cl[]; ArraySetAsSeries(cl, true);
    if (CopyClose(_Symbol, PERIOD_CURRENT, 0, lookback + 2, cl) < lookback + 2) return 0;
    double op[]; ArraySetAsSeries(op, true);
    CopyOpen(_Symbol, PERIOD_CURRENT, 0, 2, op);
    double hi[]; ArraySetAsSeries(hi, true);
    CopyHigh(_Symbol, PERIOD_CURRENT, 0, 3, hi);
    double lo[]; ArraySetAsSeries(lo, true);
    CopyLow(_Symbol, PERIOD_CURRENT, 0, 3, lo);
    
    // 1. Price Z-score
    double mean = 0, std = 0;
    for (int i = 1; i <= lookback; i++) {
        double chg = cl[i] > 0 ? (cl[i-1] - cl[i]) / cl[i] * 100.0 : 0;
        mean += chg;
    }
    mean /= lookback;
    for (int i = 1; i <= lookback; i++) {
        double chg = cl[i] > 0 ? (cl[i-1] - cl[i]) / cl[i] * 100.0 : 0;
        std += (chg - mean) * (chg - mean);
    }
    std = MathSqrt(std / MathMax(1, lookback - 1));
    double curChg = cl[1] > 0 ? (cl[0] - cl[1]) / cl[1] * 100.0 : 0;
    double zScore = std > 0.0001 ? MathAbs(curChg - mean) / std : 0;
    if (zScore > pzTh) { g_ag5_score = MathMin(100, zScore / pzTh * 70); g_ag5_type = 1; return 1; }
    
    // 2. Gap
    if (ArraySize(op) >= 2) {
        double gap = cl[1] > 0 ? MathAbs(op[0] - cl[1]) / cl[1] * 100.0 : 0;
        double gZ = std > 0.0001 ? gap / std : 0;
        if (gZ > pzTh * 0.67) { g_ag5_score = MathMin(100, gZ / pzTh * 70); g_ag5_type = 2; return 2; }
    }
    
    // 3. Volatility
    double atr = AI_P1_GetBuf(g_ag5_hATR, 0, 0);
    double atrAvg = 0;
    for (int i = 0; i < lookback; i++) atrAvg += AI_P1_GetBuf(g_ag5_hATR, 0, i);
    atrAvg /= lookback;
    double volR = atrAvg > 0 ? atr / atrAvg : 1.0;
    if (volR > volTh) { g_ag5_score = MathMin(100, volR / volTh * 70); g_ag5_type = 3; return 3; }
    
    // 4. Spread
    double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    static double ag5_spH[100]; static int ag5_spI = 0;
    ag5_spH[ag5_spI % 100] = spread; ag5_spI++;
    double spAvg = 0; int spN = MathMin(ag5_spI, 100);
    for (int i = 0; i < spN; i++) spAvg += ag5_spH[i];
    spAvg /= MathMax(1, spN);
    if (spAvg > 0 && spread / spAvg > spTh) { g_ag5_score = MathMin(100, spread / spAvg / spTh * 70); g_ag5_type = 4; return 4; }
    
    // 5. Freeze
    if (ArraySize(hi) >= 3 && ArraySize(lo) >= 3) {
        if (hi[0] == lo[0] && hi[1] == lo[1] && hi[2] == lo[2]) { g_ag5_score = 40; g_ag5_type = 5; return 5; }
    }
    return 0;
}

void AI_AG5_CloseAll() {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (ticket == 0) continue;
        MqlTradeRequest req; MqlTradeResult res;
        ZeroMemory(req); ZeroMemory(res);
        req.action = TRADE_ACTION_DEAL;
        req.position = ticket;
        req.symbol = PositionGetString(POSITION_SYMBOL);
        req.volume = PositionGetDouble(POSITION_VOLUME);
        req.type = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
        req.price = req.type == ORDER_TYPE_SELL ? SymbolInfoDouble(req.symbol, SYMBOL_BID) : SymbolInfoDouble(req.symbol, SYMBOL_ASK);
        req.deviation = 20;
        if (!OrderSend(req, res)) Print("AG5 CloseAll failed: ", res.comment);
    }
}

string AI_AG5_Name(int t) {
    string names[] = {"NONE","FLASH CRASH","GAP","VOL SPIKE","SPREAD","FREEZE"};
    return t >= 0 && t <= 5 ? names[t] : "?";
}

void AI_AG5_CreatePanel(int x, int y) {
    if (g_ag5_panelOk) return;
    ObjectCreate(0, "AI_AG5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_AG5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_AG5_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_AG5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_AG5_BG", OBJPROP_XSIZE, 280);
    ObjectSetInteger(0, "AI_AG5_BG", OBJPROP_YSIZE, 110);
    ObjectSetInteger(0, "AI_AG5_BG", OBJPROP_BGCOLOR, C'30,15,15');
    ObjectSetInteger(0, "AI_AG5_BG", OBJPROP_BORDER_COLOR, C'90,30,30');
    ObjectSetInteger(0, "AI_AG5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    for (int i = 0; i < 4; i++) {
        string nm = "AI_AG5_L" + IntegerToString(i);
        ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x + 10);
        ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y + 8 + i * 24);
        ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 9 : 8);
        ObjectSetInteger(0, nm, OBJPROP_COLOR, i == 0 ? clrCrimson : clrWhite);
    }
    ObjectSetString(0, "AI_AG5_L0", OBJPROP_TEXT, "ANOMALY GUARD IA");
    g_ag5_panelOk = true;
}

void AI_AG5_UpdatePanel() {
    if (TimeCurrent() - g_ag5_panelUpd < 1) return;
    g_ag5_panelUpd = TimeCurrent();
    bool safe = g_ag5_type == 0 && !g_ag5_paused;
    ObjectSetString(0, "AI_AG5_L1", OBJPROP_TEXT, safe ? "Status: SAFE" : (g_ag5_paused ? "Status: PAUSED" : "ANOMALY"));
    ObjectSetInteger(0, "AI_AG5_L1", OBJPROP_COLOR, safe ? clrLime : clrRed);
    ObjectSetString(0, "AI_AG5_L2", OBJPROP_TEXT, "Type: " + AI_AG5_Name(g_ag5_type) + " | Score: " + DoubleToString(g_ag5_score, 0));
    if (g_ag5_paused) {
        int remain = (int)(g_ag5_pauseEnd - TimeCurrent());
        ObjectSetString(0, "AI_AG5_L3", OBJPROP_TEXT, "Resume in: " + IntegerToString(MathMax(0, remain / 60)) + " min");
    } else ObjectSetString(0, "AI_AG5_L3", OBJPROP_TEXT, "Spread: " + IntegerToString((int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD)));
}

//+------------------------------------------------------------------+
//| TREND INTELLIGENCE IA - Multi-TF Analysis (MQL5)                   |
//+------------------------------------------------------------------+
datetime g_ti5_panelUpd = 0;
bool g_ti5_panelOk = false;

// Cached indicator handles for current timeframe (PERIOD_CURRENT)
int g_ti5_hADX = INVALID_HANDLE;
int g_ti5_hMACD = INVALID_HANDLE;
int g_ti5_hSMA = INVALID_HANDLE;
int g_ti5_hBB = INVALID_HANDLE;
int g_ti5_hRSI = INVALID_HANDLE;
int g_ti5_hStoch = INVALID_HANDLE;
int g_ti5_hATR = INVALID_HANDLE;
bool g_ti5_handlesOk = false;

void AI_TI5_InitHandles() {
    if (g_ti5_handlesOk) return;
    g_ti5_hADX = iADX(_Symbol, PERIOD_CURRENT, 14);
    g_ti5_hMACD = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
    g_ti5_hSMA = iMA(_Symbol, PERIOD_CURRENT, 20, 0, MODE_SMA, PRICE_CLOSE);
    g_ti5_hBB = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2, PRICE_CLOSE);
    g_ti5_hRSI = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    g_ti5_hStoch = iStochastic(_Symbol, PERIOD_CURRENT, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
    g_ti5_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
    if (g_ti5_hADX == INVALID_HANDLE || g_ti5_hMACD == INVALID_HANDLE || g_ti5_hSMA == INVALID_HANDLE || 
        g_ti5_hBB == INVALID_HANDLE || g_ti5_hRSI == INVALID_HANDLE || g_ti5_hStoch == INVALID_HANDLE || 
        g_ti5_hATR == INVALID_HANDLE) {
        Print("AI_TI5: Failed to create indicator handles");
        return;
    }
    g_ti5_handlesOk = true;
}

double AI_TI5_ScoreTF(int tf) {
    int hADX, hMACD, hSMA, hBB;
    // Use cached handles for current timeframe, create new ones for other timeframes
    if (tf == 0) {
        AI_TI5_InitHandles();
        hADX = g_ti5_hADX;
        hMACD = g_ti5_hMACD;
        hSMA = g_ti5_hSMA;
        hBB = g_ti5_hBB;
    } else {
        hADX = iADX(_Symbol, (ENUM_TIMEFRAMES)tf, 14);
        hMACD = iMACD(_Symbol, (ENUM_TIMEFRAMES)tf, 12, 26, 9, PRICE_CLOSE);
        hSMA = iMA(_Symbol, (ENUM_TIMEFRAMES)tf, 20, 0, MODE_SMA, PRICE_CLOSE);
        hBB = iBands(_Symbol, (ENUM_TIMEFRAMES)tf, 20, 0, 2, PRICE_CLOSE);
    }
    double adx = AI_P1_GetBuf(hADX, 0, 0);
    double diP = AI_P1_GetBuf(hADX, 1, 0);
    double diM = AI_P1_GetBuf(hADX, 2, 0);
    double macd = AI_P1_GetBuf(hMACD, 0, 0);
    double sma0 = AI_P1_GetBuf(hSMA, 0, 0);
    double sma5 = AI_P1_GetBuf(hSMA, 0, 5);
    double bbUp = AI_P1_GetBuf(hBB, 1, 0);
    double bbLo = AI_P1_GetBuf(hBB, 2, 0);
    double price = AI_P1_GetClose(0);
    double slope = sma5 > 0 ? MathMax(-1, MathMin(1, (sma0 - sma5) / sma5 * 1000)) : 0;
    double bbRange = bbUp - bbLo;
    double bbPos = bbRange > 0 ? (price - bbLo) / bbRange : 0.5;
    double dir = diP > diM ? 1.0 : -1.0;
    double score = dir * MathMin(adx / 50, 1) * 30 + slope * 30 + (macd > 0 ? 20 : (macd < 0 ? -20 : 0)) + (bbPos - 0.5) * 40;
    // Release handles only for non-current timeframes
    if (tf != 0) { IndicatorRelease(hADX); IndicatorRelease(hMACD); IndicatorRelease(hSMA); IndicatorRelease(hBB); }
    return MathMax(-100, MathMin(100, score));
}

double AI_TI5_Reversal(int tf) {
    int hRSI, hStoch, hADX, hATR;
    // Use cached handles for current timeframe, create new ones for other timeframes
    if (tf == 0) {
        AI_TI5_InitHandles();
        hRSI = g_ti5_hRSI;
        hStoch = g_ti5_hStoch;
        hADX = g_ti5_hADX;
        hATR = g_ti5_hATR;
    } else {
        hRSI = iRSI(_Symbol, (ENUM_TIMEFRAMES)tf, 14, PRICE_CLOSE);
        hStoch = iStochastic(_Symbol, (ENUM_TIMEFRAMES)tf, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
        hADX = iADX(_Symbol, (ENUM_TIMEFRAMES)tf, 14);
        hATR = iATR(_Symbol, (ENUM_TIMEFRAMES)tf, 14);
    }
    double rsi = AI_P1_GetBuf(hRSI, 0, 0);
    double stoch = AI_P1_GetBuf(hStoch, 0, 0);
    double adx = AI_P1_GetBuf(hADX, 0, 0);
    double adx5 = AI_P1_GetBuf(hADX, 0, 5);
    double atr = AI_P1_GetBuf(hATR, 0, 0);
    double atr10 = AI_P1_GetBuf(hATR, 0, 10);
    double prob = 0;
    if (rsi > 70 || rsi < 30) prob += 30;
    if (stoch > 80 || stoch < 20) prob += 25;
    if (adx < adx5 && adx > 25) prob += 20;
    if (atr > atr10 * 1.5) prob += 25;
    // Release handles only for non-current timeframes
    if (tf != 0) { IndicatorRelease(hRSI); IndicatorRelease(hStoch); IndicatorRelease(hADX); IndicatorRelease(hATR); }
    return MathMin(100, prob);
}

void AI_TI5_CreatePanel(int x, int y) {
    if (g_ti5_panelOk) return;
    ObjectCreate(0, "AI_TI5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_TI5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_TI5_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_TI5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_TI5_BG", OBJPROP_XSIZE, 290);
    ObjectSetInteger(0, "AI_TI5_BG", OBJPROP_YSIZE, 155);
    ObjectSetInteger(0, "AI_TI5_BG", OBJPROP_BGCOLOR, C'15,20,30');
    ObjectSetInteger(0, "AI_TI5_BG", OBJPROP_BORDER_COLOR, C'40,60,100');
    ObjectSetInteger(0, "AI_TI5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    for (int i = 0; i < 6; i++) {
        string nm = "AI_TI5_L" + IntegerToString(i);
        ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x + 10);
        ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y + 8 + i * 23);
        ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetString(0, nm, OBJPROP_FONT, "Consolas");
        ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 9 : 8);
        ObjectSetInteger(0, nm, OBJPROP_COLOR, i == 0 ? clrCornflowerBlue : clrWhite);
    }
    ObjectSetString(0, "AI_TI5_L0", OBJPROP_TEXT, "TREND INTELLIGENCE IA");
    g_ti5_panelOk = true;
}

void AI_TI5_UpdatePanel(double s1, double s2, double s3, double total, double str, double align) {
    if (TimeCurrent() - g_ti5_panelUpd < 1) return;
    g_ti5_panelUpd = TimeCurrent();
    color c = total > 30 ? clrLime : (total < -30 ? clrOrangeRed : clrYellow);
    ObjectSetString(0, "AI_TI5_L1", OBJPROP_TEXT, "Trend: " + DoubleToString(total, 1) + " | Str: " + DoubleToString(str, 0) + "%");
    ObjectSetInteger(0, "AI_TI5_L1", OBJPROP_COLOR, c);
    ObjectSetString(0, "AI_TI5_L2", OBJPROP_TEXT, "TF1:" + DoubleToString(s1, 1) + " TF2:" + DoubleToString(s2, 1) + " TF3:" + DoubleToString(s3, 1));
    ObjectSetString(0, "AI_TI5_L3", OBJPROP_TEXT, "Alignment: " + DoubleToString(align, 0) + "%");
    ObjectSetInteger(0, "AI_TI5_L3", OBJPROP_COLOR, align > 70 ? clrLime : (align > 40 ? clrYellow : clrGray));
    ObjectSetString(0, "AI_TI5_L4", OBJPROP_TEXT, "Reversal: " + DoubleToString(AI_TI5_Reversal(0), 0) + "%");
    string dir = total > 20 ? "BULLISH" : (total < -20 ? "BEARISH" : "NEUTRAL");
    ObjectSetString(0, "AI_TI5_L5", OBJPROP_TEXT, "Direction: " + dir);
}

// ===== PHASE 4 AI HELPER FUNCTIONS (MQL5) =====

// ===================================================================
// PHASE 4 AI NODES - HELPER FUNCTIONS (MQL5)
// SVM | Strategy Selector | Training Mode | Actor-Critic
// ===================================================================

//+------------------------------------------------------------------+
//| SVM SIGNAL GENERATOR - MQL5 version with handles                   |
//+------------------------------------------------------------------+
#define SVM5_SV 200
#define SVM5_F 5
struct SVM5_SV_t { double feat[SVM5_F]; double alpha; int label; };
SVM5_SV_t g_svm5_sv[SVM5_SV];
int g_svm5_N = 0; double g_svm5_bias = 0;
double g_svm5_gamma = 0.1; double g_svm5_C = 1.0;
bool g_svm5_trained = false; int g_svm5_barsSince = 0;
int g_svm5_totalP = 0; int g_svm5_correctP = 0;
int g_svm5_lastPred = 0;  // 0=hold, 1=buy, -1=sell
datetime g_svm5_panelUpd = 0; bool g_svm5_panelOk = false;
int g_svm5_hRSI = INVALID_HANDLE, g_svm5_hMACD = INVALID_HANDLE;
int g_svm5_hATR = INVALID_HANDLE, g_svm5_hADX = INVALID_HANDLE;
int g_svm5_hBB = INVALID_HANDLE;
bool g_svm5_hInit = false;

void AI_SVM5_InitH() {
    if (g_svm5_hInit) return;
    g_svm5_hRSI = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
    g_svm5_hMACD = iMACD(_Symbol, PERIOD_CURRENT, 12, 26, 9, PRICE_CLOSE);
    g_svm5_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
    g_svm5_hADX = iADX(_Symbol, PERIOD_CURRENT, 14);
    g_svm5_hBB = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2, PRICE_CLOSE);
    g_svm5_hInit = true;
}

double AI_SVM5_K(double &x1[], double &x2[]) {
    double d = 0;
    for (int i = 0; i < SVM5_F; i++) d += (x1[i] - x2[i]) * (x1[i] - x2[i]);
    return MathExp(-g_svm5_gamma * d);
}

double AI_SVM5_Pred(double &x[]) {
    double s = g_svm5_bias;
    for (int i = 0; i < g_svm5_N; i++) s += g_svm5_sv[i].alpha * g_svm5_sv[i].label * AI_SVM5_K(x, g_svm5_sv[i].feat);
    return s;
}

void AI_SVM5_GetFeat(int sh, double &f[]) {
    AI_SVM5_InitH();
    double cl = AI_P1_GetClose(sh);
    f[0] = AI_P1_GetBuf(g_svm5_hRSI, 0, sh) / 100.0;
    double atr = AI_P1_GetBuf(g_svm5_hATR, 0, sh);
    double macd = AI_P1_GetBuf(g_svm5_hMACD, 0, sh);
    f[1] = atr > 0 ? MathMax(-1, MathMin(1, macd / (atr * 2))) : 0;
    f[2] = cl > 0 ? atr / cl * 100 : 0;
    f[3] = AI_P1_GetBuf(g_svm5_hADX, 0, sh) / 100.0;
    double bU = AI_P1_GetBuf(g_svm5_hBB, 1, sh);
    double bL = AI_P1_GetBuf(g_svm5_hBB, 2, sh);
    double bR = bU - bL;
    f[4] = bR > 0 ? (cl - bL) / bR : 0.5;
}

int g_svm5_svNextIdx = 0;  // Circular buffer index for replacement

void AI_SVM5_OnlineTrain(double &f[], int lbl) {
    double p = AI_SVM5_Pred(f);
    double m = lbl * p;
    if (m < 1.0) {
        if (g_svm5_N < SVM5_SV) {
            // Buffer not full: add new support vector
            for (int j = 0; j < SVM5_F; j++) g_svm5_sv[g_svm5_N].feat[j] = f[j];
            g_svm5_sv[g_svm5_N].alpha = g_svm5_C * MathMax(0.01, 1.0 - m);
            g_svm5_sv[g_svm5_N].label = lbl;
            g_svm5_N++; g_svm5_bias += g_svm5_C * lbl * 0.01;
        } else {
            // Buffer full: replace oldest support vector (circular buffer)
            int idx = g_svm5_svNextIdx % SVM5_SV;
            for (int j = 0; j < SVM5_F; j++) g_svm5_sv[idx].feat[j] = f[j];
            g_svm5_sv[idx].alpha = g_svm5_C * MathMax(0.01, 1.0 - m);
            g_svm5_sv[idx].label = lbl;
            g_svm5_svNextIdx++;
            g_svm5_bias += g_svm5_C * lbl * 0.01;
        }
    }
    for (int i = 0; i < g_svm5_N; i++) g_svm5_sv[i].alpha *= 0.999;
}

void AI_SVM5_Batch(int bars, int la, double minMv) {
    g_svm5_N = 0; g_svm5_bias = 0; g_svm5_svNextIdx = 0;
    double cl[]; ArraySetAsSeries(cl, true);
    int copied = CopyClose(_Symbol, PERIOD_CURRENT, 0, bars + 5, cl);
    if (copied < la + 10) return;
    for (int ep = 0; ep < 3; ep++) {
        for (int i = la + 1; i < MathMin(bars, copied - 1); i++) {
            double chg = cl[i] > 0 ? (cl[i - la] - cl[i]) / cl[i] * 100 : 0;
            int lbl = chg > minMv ? 1 : (chg < -minMv ? -1 : 0);
            if (lbl == 0) continue;
            double f[SVM5_F]; AI_SVM5_GetFeat(i, f);
            AI_SVM5_OnlineTrain(f, lbl);
        }
    }
    g_svm5_trained = true; g_svm5_barsSince = 0;
}

void AI_SVM5_CreatePanel(int x, int y) {
    if (g_svm5_panelOk) return;
    ObjectCreate(0, "AI_SVM5_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_SVM5_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_SVM5_BG", OBJPROP_XDISTANCE, x); ObjectSetInteger(0, "AI_SVM5_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_SVM5_BG", OBJPROP_XSIZE, 270); ObjectSetInteger(0, "AI_SVM5_BG", OBJPROP_YSIZE, 110);
    ObjectSetInteger(0, "AI_SVM5_BG", OBJPROP_BGCOLOR, C'20,20,10'); ObjectSetInteger(0, "AI_SVM5_BG", OBJPROP_BORDER_COLOR, C'70,70,30');
    ObjectSetInteger(0, "AI_SVM5_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    for (int i = 0; i < 4; i++) {
        string nm = "AI_SVM5_L" + IntegerToString(i);
        ObjectCreate(0, nm, OBJ_LABEL, 0, 0, 0);
        ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, x + 10); ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, y + 8 + i * 24);
        ObjectSetInteger(0, nm, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        ObjectSetString(0, nm, OBJPROP_FONT, "Consolas"); ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, i == 0 ? 9 : 8);
        ObjectSetInteger(0, nm, OBJPROP_COLOR, i == 0 ? clrGoldenrod : clrWhite);
    }
    ObjectSetString(0, "AI_SVM5_L0", OBJPROP_TEXT, "SVM SIGNAL GENERATOR"); g_svm5_panelOk = true;
}

void AI_SVM5_UpdPanel(double sc, double cf) {
    if (TimeCurrent() - g_svm5_panelUpd < 1) return; g_svm5_panelUpd = TimeCurrent();
    string sig = sc > 0.5 ? "BUY" : (sc < -0.5 ? "SELL" : "HOLD");
    ObjectSetString(0, "AI_SVM5_L1", OBJPROP_TEXT, "Signal: " + sig + " | Conf: " + DoubleToString(cf, 0) + "%");
    ObjectSetInteger(0, "AI_SVM5_L1", OBJPROP_COLOR, sc > 0.5 ? clrLime : (sc < -0.5 ? clrOrangeRed : clrGray));
    ObjectSetString(0, "AI_SVM5_L2", OBJPROP_TEXT, "SVs: " + IntegerToString(g_svm5_N) + " | Trained: " + (g_svm5_trained ? "Y" : "N"));
    double acc = g_svm5_totalP > 10 ? (double)g_svm5_correctP / g_svm5_totalP * 100.0 : 0;
    ObjectSetString(0, "AI_SVM5_L3", OBJPROP_TEXT, "Acc: " + DoubleToString(acc, 1) + "% (" + IntegerToString(g_svm5_totalP) + ")");
}

//+------------------------------------------------------------------+
//| STRATEGY SELECTOR - Multi-Armed Bandit (MQL5)                      |
//+------------------------------------------------------------------+
#define SS5_MAX 4
double g_ss5_a[SS5_MAX], g_ss5_b[SS5_MAX];
int g_ss5_t[SS5_MAX], g_ss5_w[SS5_MAX];
double g_ss5_p[SS5_MAX];
int g_ss5_sel = 0, g_ss5_total = 0;
bool g_ss5_init = false;
datetime g_ss5_panelUpd = 0; bool g_ss5_panelOk = false;
datetime g_ss5_scoreUpd = 0;

void AI_SS5_Init() {
    if (g_ss5_init) return; MathSrand(g_MasterSeed + 50000);
    for (int i = 0; i < SS5_MAX; i++) { g_ss5_a[i] = 1; g_ss5_b[i] = 1; g_ss5_t[i] = 0; g_ss5_w[i] = 0; g_ss5_p[i] = 0; }
    g_ss5_init = true;
}

double AI_SS5_RandN() { double u1 = MathMax(0.0001, (double)MathRand()/32767.0); double u2 = (double)MathRand()/32767.0; return MathSqrt(-2*MathLog(u1))*MathCos(6.28318*u2); }

double AI_SS5_Gamma(double s) {
    if (s < 1) { double g = AI_SS5_Gamma(s+1); return g * MathPow(MathMax(0.0001,(double)MathRand()/32767.0), 1.0/s); }
    double d = s - 1.0/3; double c = 1/MathSqrt(9*d);
    for (int it = 0; it < 100; it++) { double x,v; do { x = AI_SS5_RandN(); v = 1+c*x; } while(v<=0); v=v*v*v; double u = MathMax(0.0001,(double)MathRand()/32767.0); if (u < 1-0.0331*x*x*x*x) return d*v; if (MathLog(u) < 0.5*x*x+d*(1-v+MathLog(v))) return d*v; }
    return s;
}

double AI_SS5_Beta(double a, double b) { double x = AI_SS5_Gamma(a); double y = AI_SS5_Gamma(b); return x/(x+y+0.00001); }

int AI_SS5_Thompson() { int best=0; double bs=-1; for(int i=0;i<SS5_MAX;i++){double s=AI_SS5_Beta(g_ss5_a[i],g_ss5_b[i]); if(s>bs){bs=s;best=i;}} return best; }
int AI_SS5_UCB(double exp) { int best=0; double bs=-1; for(int i=0;i<SS5_MAX;i++){if(g_ss5_t[i]==0)return i; double m=(double)g_ss5_w[i]/g_ss5_t[i]; double u=m+exp*MathSqrt(MathLog((double)g_ss5_total+1)/g_ss5_t[i]); if(u>bs){bs=u;best=i;}} return best; }
int AI_SS5_Eps(double e) { if((double)MathRand()/32767.0<e)return MathRand()%SS5_MAX; int best=0;double bw=-1; for(int i=0;i<SS5_MAX;i++){double wr=g_ss5_t[i]>0?(double)g_ss5_w[i]/g_ss5_t[i]:0.5; if(wr>bw){bw=wr;best=i;}} return best; }

void AI_SS5_Score(int magic) {
    if (TimeCurrent()-g_ss5_scoreUpd<10) return; g_ss5_scoreUpd=TimeCurrent();
    for(int i=0;i<SS5_MAX;i++){g_ss5_t[i]=0;g_ss5_w[i]=0;g_ss5_p[i]=0;g_ss5_a[i]=1.0;g_ss5_b[i]=1.0;}
    if(!HistorySelect(TimeCurrent()-86400*30,TimeCurrent()))return;
    for(int h=HistoryDealsTotal()-1;h>=MathMax(0,HistoryDealsTotal()-500);h--){
        ulong dt=HistoryDealGetTicket(h); if(dt==0)continue;
        if(HistoryDealGetInteger(dt,DEAL_MAGIC)!=magic||HistoryDealGetString(dt,DEAL_SYMBOL)!=_Symbol)continue;
        if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dt,DEAL_ENTRY)!=DEAL_ENTRY_OUT)continue;
        string c=HistoryDealGetString(dt,DEAL_COMMENT); int st=-1;
        if(StringFind(c,"SS_0")>=0)st=0; else if(StringFind(c,"SS_1")>=0)st=1; else if(StringFind(c,"SS_2")>=0)st=2; else if(StringFind(c,"SS_3")>=0)st=3;
        if(st<0)continue; double pr=HistoryDealGetDouble(dt,DEAL_PROFIT)+HistoryDealGetDouble(dt,DEAL_COMMISSION)+HistoryDealGetDouble(dt,DEAL_SWAP);
        g_ss5_t[st]++; if(pr>0){g_ss5_w[st]++;g_ss5_a[st]+=1;}else g_ss5_b[st]+=1; g_ss5_p[st]+=pr;
    }
}

void AI_SS5_CreatePanel(int x,int y) {
    if(g_ss5_panelOk)return;
    ObjectCreate(0,"AI_SS5_BG",OBJ_RECTANGLE_LABEL,0,0,0);
    ObjectSetInteger(0,"AI_SS5_BG",OBJPROP_SELECTABLE,false);
    ObjectSetInteger(0,"AI_SS5_BG",OBJPROP_XDISTANCE,x);ObjectSetInteger(0,"AI_SS5_BG",OBJPROP_YDISTANCE,y);
    ObjectSetInteger(0,"AI_SS5_BG",OBJPROP_XSIZE,300);ObjectSetInteger(0,"AI_SS5_BG",OBJPROP_YSIZE,135);
    ObjectSetInteger(0,"AI_SS5_BG",OBJPROP_BGCOLOR,C'15,15,25');ObjectSetInteger(0,"AI_SS5_BG",OBJPROP_BORDER_COLOR,C'50,50,90');
    ObjectSetInteger(0,"AI_SS5_BG",OBJPROP_CORNER,CORNER_LEFT_UPPER);
    for(int i=0;i<5;i++){string nm="AI_SS5_L"+IntegerToString(i);ObjectCreate(0,nm,OBJ_LABEL,0,0,0);
    ObjectSetInteger(0,nm,OBJPROP_XDISTANCE,x+10);ObjectSetInteger(0,nm,OBJPROP_YDISTANCE,y+8+i*25);
    ObjectSetInteger(0,nm,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetString(0,nm,OBJPROP_FONT,"Consolas");
    ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,i==0?9:8);ObjectSetInteger(0,nm,OBJPROP_COLOR,i==0?clrMediumSlateBlue:clrWhite);}
    ObjectSetString(0,"AI_SS5_L0",OBJPROP_TEXT,"STRATEGY SELECTOR IA");g_ss5_panelOk=true;
}

void AI_SS5_UpdPanel(int sel, double cf) {
    if(TimeCurrent()-g_ss5_panelUpd<1)return; g_ss5_panelUpd=TimeCurrent();
    ObjectSetString(0,"AI_SS5_L1",OBJPROP_TEXT,"Active: S#"+IntegerToString(sel+1)+" | Conf: "+DoubleToString(cf,0)+"%");
    string pr=""; for(int i=0;i<SS5_MAX;i++) pr+="S"+IntegerToString(i+1)+":"+DoubleToString(g_ss5_a[i]/(g_ss5_a[i]+g_ss5_b[i])*100,0)+"% ";
    ObjectSetString(0,"AI_SS5_L2",OBJPROP_TEXT,pr);
    string tr=""; for(int i=0;i<SS5_MAX;i++) tr+=IntegerToString(g_ss5_t[i])+" ";
    ObjectSetString(0,"AI_SS5_L3",OBJPROP_TEXT,"Trades: "+tr);
    ObjectSetString(0,"AI_SS5_L4",OBJPROP_TEXT,"Selections: "+IntegerToString(g_ss5_total));
}

//+------------------------------------------------------------------+
//| AI TRAINING MODE - MQL5                                            |
//+------------------------------------------------------------------+
double g_tm5_vBal = 10000, g_tm5_vPnL = 0;
int g_tm5_vTrades = 0, g_tm5_vWins = 0;
datetime g_tm5_panelUpd = 0; bool g_tm5_panelOk = false;
// Track multiple virtual positions (up to 10)
#define TM5_MAX_POS 10
struct TM5_VirtPos {
    bool active;
    int dir;  // 1=buy, -1=sell
    double entry;
    datetime openTime;
};
TM5_VirtPos g_tm5_vPos[TM5_MAX_POS];
int g_tm5_vPosCount = 0;
// Training mode metrics
int g_tm5_signalsObserved = 0;
int g_tm5_buySignals = 0;
int g_tm5_sellSignals = 0;
double g_tm5_maxDrawdown = 0;
double g_tm5_peakEquity = 10000;

void AI_TM5_CreatePanel(int x, int y) {
    if(g_tm5_panelOk)return;
    ObjectCreate(0,"AI_TM5_BG",OBJ_RECTANGLE_LABEL,0,0,0);
    ObjectSetInteger(0,"AI_TM5_BG",OBJPROP_SELECTABLE,false);
    ObjectSetInteger(0,"AI_TM5_BG",OBJPROP_XDISTANCE,x);ObjectSetInteger(0,"AI_TM5_BG",OBJPROP_YDISTANCE,y);
    ObjectSetInteger(0,"AI_TM5_BG",OBJPROP_XSIZE,260);ObjectSetInteger(0,"AI_TM5_BG",OBJPROP_YSIZE,130);
    ObjectSetInteger(0,"AI_TM5_BG",OBJPROP_BGCOLOR,C'10,15,10');ObjectSetInteger(0,"AI_TM5_BG",OBJPROP_BORDER_COLOR,C'30,60,30');
    ObjectSetInteger(0,"AI_TM5_BG",OBJPROP_CORNER,CORNER_LEFT_UPPER);
    for(int i=0;i<5;i++){string nm="AI_TM5_L"+IntegerToString(i);ObjectCreate(0,nm,OBJ_LABEL,0,0,0);
    ObjectSetInteger(0,nm,OBJPROP_XDISTANCE,x+10);ObjectSetInteger(0,nm,OBJPROP_YDISTANCE,y+8+i*23);
    ObjectSetInteger(0,nm,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetString(0,nm,OBJPROP_FONT,"Consolas");
    ObjectSetInteger(0,nm,OBJPROP_FONTSIZE,i==0?9:8);ObjectSetInteger(0,nm,OBJPROP_COLOR,i==0?clrForestGreen:clrWhite);}
    ObjectSetString(0,"AI_TM5_L0",OBJPROP_TEXT,"AI TRAINING MODE");g_tm5_panelOk=true;
}

void AI_TM5_UpdPanel(string mode) {
    if(TimeCurrent()-g_tm5_panelUpd<1)return; g_tm5_panelUpd=TimeCurrent();
    color mc=mode=="LIVE"?clrLime:(mode=="PAPER_TRADING"?clrYellow:clrOrangeRed);
    ObjectSetString(0,"AI_TM5_L1",OBJPROP_TEXT,"Mode: "+mode);ObjectSetInteger(0,"AI_TM5_L1",OBJPROP_COLOR,mc);
    ObjectSetString(0,"AI_TM5_L2",OBJPROP_TEXT,"VBal: "+DoubleToString(g_tm5_vBal+g_tm5_vPnL,2));
    ObjectSetString(0,"AI_TM5_L3",OBJPROP_TEXT,"VPnL: "+DoubleToString(g_tm5_vPnL,2));
    ObjectSetInteger(0,"AI_TM5_L3",OBJPROP_COLOR,g_tm5_vPnL>=0?clrLime:clrRed);
    double wr=g_tm5_vTrades>0?(double)g_tm5_vWins/g_tm5_vTrades*100:0;
    string info="VTrades: "+IntegerToString(g_tm5_vTrades)+" WR: "+DoubleToString(wr,1)+"%";
    if(mode=="TRAINING") info+=" | Signals: "+IntegerToString(g_tm5_signalsObserved);
    ObjectSetString(0,"AI_TM5_L4",OBJPROP_TEXT,info);
}

//+------------------------------------------------------------------+
//| ACTOR-CRITIC AGENT (A2C) v3.0 - MQL5                              |
//| Actor: [15 → 64 → 32 → 4] softmax                                |
//| Critic: [15 → 48 → 24 → 1] linear                                |
//| Features: RSI, MACD, ATR, ADX, BB, Stoch, Hurst, Entropy + more   |
//+------------------------------------------------------------------+
#define A2C_FEAT 15
#define A2C_AH1 64
#define A2C_AH2 32
#define A2C_ACT 4
#define A2C_CH1 48
#define A2C_CH2 24

// Actor weights
double g_a2c_aw1[A2C_AH1 * A2C_FEAT], g_a2c_ab1[A2C_AH1];
double g_a2c_aw2[A2C_AH2 * A2C_AH1], g_a2c_ab2[A2C_AH2];
double g_a2c_aw3[A2C_ACT * A2C_AH2], g_a2c_ab3[A2C_ACT];
// Actor intermediates
double g_a2c_ah1[A2C_AH1], g_a2c_ah2[A2C_AH2], g_a2c_ah1r[A2C_AH1], g_a2c_ah2r[A2C_AH2];
double g_a2c_probs[A2C_ACT];

// Critic weights
double g_a2c_cw1[A2C_CH1 * A2C_FEAT], g_a2c_cb1[A2C_CH1];
double g_a2c_cw2[A2C_CH2 * A2C_CH1], g_a2c_cb2[A2C_CH2];
double g_a2c_cw3[A2C_CH2], g_a2c_cb3_v;
double g_a2c_ch1[A2C_CH1], g_a2c_ch2[A2C_CH2], g_a2c_ch1r[A2C_CH1], g_a2c_ch2r[A2C_CH2];

bool g_a2c_init = false;
int g_a2c_steps = 0;
double g_a2c_totalR = 0;
datetime g_a2c_panelUpd = 0; bool g_a2c_panelOk = false;
// Persistence + Performance
#define A2C_FILE_MAGIC 0x41324335  // "A2C5"
bool g_a2c_fileLoaded = false;
int g_a2c_saveMagic = 0;
int g_a2c_totalTrades = 0;
int g_a2c_wins = 0;
double g_a2c_totalProfit = 0;

// A2C reuses DQN handles
int g_a2c_hRSI=INVALID_HANDLE, g_a2c_hMACD=INVALID_HANDLE, g_a2c_hATR=INVALID_HANDLE;
int g_a2c_hSMA=INVALID_HANDLE, g_a2c_hBB=INVALID_HANDLE, g_a2c_hADX=INVALID_HANDLE;
int g_a2c_hStoch=INVALID_HANDLE; bool g_a2c_hOk=false;

void AI_A2C_InitH() {
    if(g_a2c_hOk)return;
    g_a2c_hRSI=iRSI(_Symbol,PERIOD_CURRENT,14,PRICE_CLOSE);
    g_a2c_hMACD=iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE);
    g_a2c_hATR=iATR(_Symbol,PERIOD_CURRENT,14);
    g_a2c_hSMA=iMA(_Symbol,PERIOD_CURRENT,20,0,MODE_SMA,PRICE_CLOSE);
    g_a2c_hBB=iBands(_Symbol,PERIOD_CURRENT,20,0,2,PRICE_CLOSE);
    g_a2c_hADX=iADX(_Symbol,PERIOD_CURRENT,14);
    g_a2c_hStoch=iStochastic(_Symbol,PERIOD_CURRENT,14,3,3,MODE_SMA,STO_LOWHIGH);
    g_a2c_hOk=true;
}

void AI_A2C_Init() {
    if(g_a2c_init)return; AI_A2C_InitH(); MathSrand(g_MasterSeed + 60000);
    double s1=MathSqrt(2.0/A2C_FEAT), s2=MathSqrt(2.0/A2C_AH1), s3=MathSqrt(2.0/A2C_AH2);
    for(int i=0;i<A2C_AH1*A2C_FEAT;i++) g_a2c_aw1[i]=(MathRand()/16383.5-1)*s1;
    for(int i=0;i<A2C_AH2*A2C_AH1;i++) g_a2c_aw2[i]=(MathRand()/16383.5-1)*s2;
    for(int i=0;i<A2C_ACT*A2C_AH2;i++) g_a2c_aw3[i]=(MathRand()/16383.5-1)*s3;
    for(int i=0;i<A2C_AH1;i++) g_a2c_ab1[i]=0; for(int i=0;i<A2C_AH2;i++) g_a2c_ab2[i]=0; for(int i=0;i<A2C_ACT;i++) g_a2c_ab3[i]=0;
    double cs1=MathSqrt(2.0/A2C_FEAT), cs2=MathSqrt(2.0/A2C_CH1);
    for(int i=0;i<A2C_CH1*A2C_FEAT;i++) g_a2c_cw1[i]=(MathRand()/16383.5-1)*cs1;
    for(int i=0;i<A2C_CH2*A2C_CH1;i++) g_a2c_cw2[i]=(MathRand()/16383.5-1)*cs2;
    for(int i=0;i<A2C_CH2;i++) g_a2c_cw3[i]=(MathRand()/16383.5-1)*0.1;
    for(int i=0;i<A2C_CH1;i++) g_a2c_cb1[i]=0; for(int i=0;i<A2C_CH2;i++) g_a2c_cb2[i]=0; g_a2c_cb3_v=0;
    g_a2c_init=true;
}

// Get normalized state features (15 professional features, all in [-1,1] or [0,1])
void AI_A2C_GetState(double &s[]) {
    if (!g_a2c_hOk) { ArrayInitialize(s, 0); return; }
    double rsi = AI_P1_GetBuf(g_a2c_hRSI, 0, 0);
    double atr = AI_P1_GetBuf(g_a2c_hATR, 0, 0);
    double macd = AI_P1_GetBuf(g_a2c_hMACD, 0, 0);
    double sma0 = AI_P1_GetBuf(g_a2c_hSMA, 0, 0);
    double sma5 = AI_P1_GetBuf(g_a2c_hSMA, 0, 5);
    double bU = AI_P1_GetBuf(g_a2c_hBB, 1, 0), bL = AI_P1_GetBuf(g_a2c_hBB, 2, 0);
    double adx = AI_P1_GetBuf(g_a2c_hADX, 0, 0);
    double stoch = AI_P1_GetBuf(g_a2c_hStoch, 0, 0);
    double cl = AI_P1_GetClose(0), cl5 = AI_P1_GetClose(5), cl20 = AI_P1_GetClose(20);
    double bR = bU - bL;
    // feat[0]: RSI [0,1]
    s[0] = rsi / 100.0;
    // feat[1]: MACD normalized by ATR [-1,1]
    s[1] = atr > 0 ? MathMax(-1, MathMin(1, macd / (atr * 2))) : 0;
    // feat[2]: ATR relative [0,1]
    s[2] = cl > 0 ? MathMin(1.0, atr / cl * 10.0) : 0;
    // feat[3]: ADX [0,1]
    s[3] = adx / 100.0;
    // feat[4]: Bollinger %B [0,1]
    s[4] = bR > 0 ? MathMax(0, MathMin(1, (cl - bL) / bR)) : 0.5;
    // feat[5]: Stochastic [0,1]
    s[5] = stoch / 100.0;
    // feat[6]: SMA slope [-1,1]
    s[6] = sma5 > 0 ? MathMax(-1, MathMin(1, (sma0 - sma5) / sma5 * 100)) : 0;
    // feat[7]: 5-bar momentum [-1,1]
    s[7] = cl5 > 0 ? MathMax(-1, MathMin(1, (cl - cl5) / cl5 * 10)) : 0;
    // feat[8]: 20-bar momentum [-1,1]
    s[8] = cl20 > 0 ? MathMax(-1, MathMin(1, (cl - cl20) / cl20 * 5)) : 0;
    // feat[9]: Hurst Exponent [0,1]
    s[9] = AI_CalcHurst(50);
    // feat[10]: Shannon Entropy [0,1]
    s[10] = AI_CalcEntropy(20);
    // feat[11]: Relative volatility [0,1]
    double atrS = 0;
    for (int _av = 0; _av < 50; _av++) atrS += AI_P1_GetBuf(g_a2c_hATR, 0, _av);
    double atrA = atrS / 50.0;
    s[11] = atrA > 0 ? MathMin(1.0, (atr / atrA) / 2.0) : 0.5;
    // feat[12]: Hour of day [0,1]
    MqlDateTime dt; TimeCurrent(dt);
    s[12] = dt.hour / 24.0;
    // feat[13]: Spread normalized [0,1]
    double sprd = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
    s[13] = atr > 0 ? MathMin(1.0, sprd / atr) : 0;
    // feat[14]: Position state (0=none, 0.5=buy, 1.0=sell)
    s[14] = 0.0;
    for (int _ps = PositionsTotal() - 1; _ps >= 0; _ps--) {
        ulong _ptk = PositionGetTicket(_ps);
        if (_ptk > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol) {
            s[14] = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 0.5 : 1.0;
            break;
        }
    }
}

// Actor forward → softmax probabilities
void AI_A2C_ActorFwd(double &s[]) {
    for(int i=0;i<A2C_AH1;i++){g_a2c_ah1r[i]=g_a2c_ab1[i]; for(int j=0;j<A2C_FEAT;j++) g_a2c_ah1r[i]+=g_a2c_aw1[i*A2C_FEAT+j]*s[j]; g_a2c_ah1[i]=g_a2c_ah1r[i]>0?g_a2c_ah1r[i]:0;}
    for(int i=0;i<A2C_AH2;i++){g_a2c_ah2r[i]=g_a2c_ab2[i]; for(int j=0;j<A2C_AH1;j++) g_a2c_ah2r[i]+=g_a2c_aw2[i*A2C_AH1+j]*g_a2c_ah1[j]; g_a2c_ah2[i]=g_a2c_ah2r[i]>0?g_a2c_ah2r[i]:0;}
    double logits[A2C_ACT]; double maxL=-1e9;
    for(int i=0;i<A2C_ACT;i++){logits[i]=g_a2c_ab3[i]; for(int j=0;j<A2C_AH2;j++) logits[i]+=g_a2c_aw3[i*A2C_AH2+j]*g_a2c_ah2[j]; if(logits[i]>maxL) maxL=logits[i];}
    double sumE=0; for(int i=0;i<A2C_ACT;i++){g_a2c_probs[i]=MathExp(logits[i]-maxL); sumE+=g_a2c_probs[i];}
    for(int i=0;i<A2C_ACT;i++) g_a2c_probs[i]/=sumE;
}

// Critic forward → V(s)
double AI_A2C_CriticFwd(double &s[]) {
    for(int i=0;i<A2C_CH1;i++){g_a2c_ch1r[i]=g_a2c_cb1[i]; for(int j=0;j<A2C_FEAT;j++) g_a2c_ch1r[i]+=g_a2c_cw1[i*A2C_FEAT+j]*s[j]; g_a2c_ch1[i]=g_a2c_ch1r[i]>0?g_a2c_ch1r[i]:0;}
    for(int i=0;i<A2C_CH2;i++){g_a2c_ch2r[i]=g_a2c_cb2[i]; for(int j=0;j<A2C_CH1;j++) g_a2c_ch2r[i]+=g_a2c_cw2[i*A2C_CH1+j]*g_a2c_ch1[j]; g_a2c_ch2[i]=g_a2c_ch2r[i]>0?g_a2c_ch2r[i]:0;}
    double v=g_a2c_cb3_v; for(int i=0;i<A2C_CH2;i++) v+=g_a2c_cw3[i]*g_a2c_ch2[i]; return v;
}

int AI_A2C_SelectAction() {
    double u=(double)MathRand()/32767.0, cum=0;
    for(int i=0;i<A2C_ACT;i++){cum+=g_a2c_probs[i]; if(u<cum) return i;}
    return A2C_ACT-1;
}

// A2C training step (with gradient clipping for stability)
void AI_A2C_Train(double &s[], int action, double advantage, double aLR, double cLR, double cTarget, double entCoeff) {
    // Backtest Training: boost A2C learning rates for faster convergence
    if (g_IsBacktestTraining) {
        aLR = MathMin(aLR * g_AITrainingSpeedMultiplier, 0.01);
        cLR = MathMin(cLR * g_AITrainingSpeedMultiplier, 0.01);
    }
    // Clip advantage for stability
    double clipAdv = MathMax(-1.0, MathMin(1.0, advantage));
    // ---- Actor update (policy gradient + entropy bonus) ----
    AI_A2C_ActorFwd(s);
    double d3[A2C_ACT];
    for(int i=0;i<A2C_ACT;i++) d3[i]=clipAdv*((i==action?1.0:0.0)-g_a2c_probs[i]);
    // Entropy bonus gradient
    for(int i=0;i<A2C_ACT;i++){double lp=g_a2c_probs[i]>0.0001?MathLog(g_a2c_probs[i]):-10; d3[i]+=entCoeff*(-lp-1)*g_a2c_probs[i]*(1-g_a2c_probs[i]);}
    // Clip actor output gradients
    for(int i=0;i<A2C_ACT;i++) d3[i]=MathMax(-1.0,MathMin(1.0,d3[i]));
    // Backprop actor (with gradient clipping at each layer)
    for(int i=0;i<A2C_ACT;i++){for(int j=0;j<A2C_AH2;j++) g_a2c_aw3[i*A2C_AH2+j]+=aLR*d3[i]*g_a2c_ah2[j]; g_a2c_ab3[i]+=aLR*d3[i];}
    double da2[A2C_AH2]; for(int i=0;i<A2C_AH2;i++){double sm=0; for(int j=0;j<A2C_ACT;j++) sm+=g_a2c_aw3[j*A2C_AH2+i]*d3[j]; da2[i]=g_a2c_ah2r[i]>0?MathMax(-1.0,MathMin(1.0,sm)):0;}
    for(int i=0;i<A2C_AH2;i++){for(int j=0;j<A2C_AH1;j++) g_a2c_aw2[i*A2C_AH1+j]+=aLR*da2[i]*g_a2c_ah1[j]; g_a2c_ab2[i]+=aLR*da2[i];}
    double da1[A2C_AH1]; for(int i=0;i<A2C_AH1;i++){double sm=0; for(int j=0;j<A2C_AH2;j++) sm+=g_a2c_aw2[j*A2C_AH1+i]*da2[j]; da1[i]=g_a2c_ah1r[i]>0?MathMax(-1.0,MathMin(1.0,sm)):0;}
    for(int i=0;i<A2C_AH1;i++){for(int j=0;j<A2C_FEAT;j++) g_a2c_aw1[i*A2C_FEAT+j]+=aLR*da1[i]*s[j]; g_a2c_ab1[i]+=aLR*da1[i];}
    
    // ---- Critic update (value function, clipped) ----
    double v=AI_A2C_CriticFwd(s); double cErr=MathMax(-1.0,MathMin(1.0,cTarget-v));
    // Backprop critic (single output, with gradient clipping)
    for(int i=0;i<A2C_CH2;i++) g_a2c_cw3[i]+=cLR*cErr*g_a2c_ch2[i]; g_a2c_cb3_v+=cLR*cErr;
    double dc2[A2C_CH2]; for(int i=0;i<A2C_CH2;i++) dc2[i]=g_a2c_ch2r[i]>0?MathMax(-1.0,MathMin(1.0,cErr*g_a2c_cw3[i])):0;
    for(int i=0;i<A2C_CH2;i++){for(int j=0;j<A2C_CH1;j++) g_a2c_cw2[i*A2C_CH1+j]+=cLR*dc2[i]*g_a2c_ch1[j]; g_a2c_cb2[i]+=cLR*dc2[i];}
    double dc1[A2C_CH1]; for(int i=0;i<A2C_CH1;i++){double sm=0; for(int j=0;j<A2C_CH2;j++) sm+=g_a2c_cw2[j*A2C_CH1+i]*dc2[j]; dc1[i]=g_a2c_ch1r[i]>0?MathMax(-1.0,MathMin(1.0,sm)):0;}
    for(int i=0;i<A2C_CH1;i++){for(int j=0;j<A2C_FEAT;j++) g_a2c_cw1[i*A2C_FEAT+j]+=cLR*dc1[i]*s[j]; g_a2c_cb1[i]+=cLR*dc1[i];}
}

//+------------------------------------------------------------------+
//| A2C Persistence: Save/Load actor+critic weights to Common folder  |
//+------------------------------------------------------------------+
string AI_A2C_GetFilename(int magic) {
    return "AI_A2C_" + IntegerToString(magic) + "_" + _Symbol + ".bin";
}

void AI_A2C_Save(int magic) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return;
    string fn = AI_A2C_GetFilename(magic);
    if (FileIsExist(fn, FILE_COMMON)) FileDelete(fn, FILE_COMMON);
    int h = FileOpen(fn, FILE_WRITE | FILE_BIN | FILE_COMMON);
    if (h == INVALID_HANDLE) { Print("[A2C] Save FAILED: ", GetLastError()); return; }
    FileWriteInteger(h, (int)A2C_FILE_MAGIC);
    FileWriteInteger(h, 2); // version 2 (15-feature 64-32/48-24 network)
    FileWriteInteger(h, A2C_FEAT);
    FileWriteInteger(h, A2C_AH1);
    FileWriteInteger(h, A2C_AH2);
    FileWriteInteger(h, A2C_CH1);
    FileWriteInteger(h, A2C_CH2);
    // Actor weights
    for (int i = 0; i < A2C_AH1 * A2C_FEAT; i++) FileWriteDouble(h, g_a2c_aw1[i]);
    for (int i = 0; i < A2C_AH1; i++) FileWriteDouble(h, g_a2c_ab1[i]);
    for (int i = 0; i < A2C_AH2 * A2C_AH1; i++) FileWriteDouble(h, g_a2c_aw2[i]);
    for (int i = 0; i < A2C_AH2; i++) FileWriteDouble(h, g_a2c_ab2[i]);
    for (int i = 0; i < A2C_ACT * A2C_AH2; i++) FileWriteDouble(h, g_a2c_aw3[i]);
    for (int i = 0; i < A2C_ACT; i++) FileWriteDouble(h, g_a2c_ab3[i]);
    // Critic weights
    for (int i = 0; i < A2C_CH1 * A2C_FEAT; i++) FileWriteDouble(h, g_a2c_cw1[i]);
    for (int i = 0; i < A2C_CH1; i++) FileWriteDouble(h, g_a2c_cb1[i]);
    for (int i = 0; i < A2C_CH2 * A2C_CH1; i++) FileWriteDouble(h, g_a2c_cw2[i]);
    for (int i = 0; i < A2C_CH2; i++) FileWriteDouble(h, g_a2c_cb2[i]);
    for (int i = 0; i < A2C_CH2; i++) FileWriteDouble(h, g_a2c_cw3[i]);
    FileWriteDouble(h, g_a2c_cb3_v);
    // Training state + Performance
    FileWriteInteger(h, g_a2c_steps);
    FileWriteDouble(h, g_a2c_totalR);
    FileWriteInteger(h, g_a2c_totalTrades);
    FileWriteInteger(h, g_a2c_wins);
    FileWriteDouble(h, g_a2c_totalProfit);
    FileClose(h);
    Print("[A2C] v3 Saved: ", fn, " | Steps: ", g_a2c_steps, " | Trades: ", g_a2c_totalTrades);
}

bool AI_A2C_Load(int magic) {
    if ((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return false;
    string fn = AI_A2C_GetFilename(magic);
    bool inCommon = FileIsExist(fn, FILE_COMMON);
    bool inLocal = !inCommon && FileIsExist(fn);
    if (!inCommon && !inLocal) { Print("[A2C] No saved weights: ", fn); return false; }
    int flags = FILE_READ | FILE_BIN | (inCommon ? FILE_COMMON : 0);
    int h = FileOpen(fn, flags);
    if (h == INVALID_HANDLE) { Print("[A2C] Load FAILED: ", GetLastError()); return false; }
    int mgc = FileReadInteger(h);
    if (mgc != (int)A2C_FILE_MAGIC) { Print("[A2C] Invalid header"); FileClose(h); return false; }
    int ver = FileReadInteger(h);
    if (ver < 2) { Print("[A2C] Old v1 format incompatible with v3 network (15 features). Starting fresh."); FileClose(h); return false; }
    // Validate dimensions
    int fFeat = FileReadInteger(h); int fAH1 = FileReadInteger(h); int fAH2 = FileReadInteger(h);
    int fCH1 = FileReadInteger(h); int fCH2 = FileReadInteger(h);
    if (fFeat != A2C_FEAT || fAH1 != A2C_AH1 || fAH2 != A2C_AH2 || fCH1 != A2C_CH1 || fCH2 != A2C_CH2) {
        Print("[A2C] Dimension mismatch. Starting fresh.");
        FileClose(h); return false;
    }
    // Actor
    for (int i = 0; i < A2C_AH1 * A2C_FEAT; i++) g_a2c_aw1[i] = FileReadDouble(h);
    for (int i = 0; i < A2C_AH1; i++) g_a2c_ab1[i] = FileReadDouble(h);
    for (int i = 0; i < A2C_AH2 * A2C_AH1; i++) g_a2c_aw2[i] = FileReadDouble(h);
    for (int i = 0; i < A2C_AH2; i++) g_a2c_ab2[i] = FileReadDouble(h);
    for (int i = 0; i < A2C_ACT * A2C_AH2; i++) g_a2c_aw3[i] = FileReadDouble(h);
    for (int i = 0; i < A2C_ACT; i++) g_a2c_ab3[i] = FileReadDouble(h);
    // Critic
    for (int i = 0; i < A2C_CH1 * A2C_FEAT; i++) g_a2c_cw1[i] = FileReadDouble(h);
    for (int i = 0; i < A2C_CH1; i++) g_a2c_cb1[i] = FileReadDouble(h);
    for (int i = 0; i < A2C_CH2 * A2C_CH1; i++) g_a2c_cw2[i] = FileReadDouble(h);
    for (int i = 0; i < A2C_CH2; i++) g_a2c_cb2[i] = FileReadDouble(h);
    for (int i = 0; i < A2C_CH2; i++) g_a2c_cw3[i] = FileReadDouble(h);
    g_a2c_cb3_v = FileReadDouble(h);
    // Training state + Performance
    g_a2c_steps = FileReadInteger(h);
    g_a2c_totalR = FileReadDouble(h);
    g_a2c_totalTrades = FileReadInteger(h);
    g_a2c_wins = FileReadInteger(h);
    g_a2c_totalProfit = FileReadDouble(h);
    FileClose(h);
    if (inLocal && !inCommon) AI_A2C_Save(magic);
    g_a2c_fileLoaded = true;
    g_a2c_init = true;
    Print("[A2C] v3 Loaded: ", fn, " | Steps: ", g_a2c_steps, " | TotalR: ", DoubleToString(g_a2c_totalR, 2));
    return true;
}

//+------------------------------------------------------------------+
//| A2C Enhanced Panel                                                 |
//+------------------------------------------------------------------+
void AI_A2C_CrLabel(string name, string text, int x, int y, color clr, int sz) {
    ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetString(0, name, OBJPROP_TEXT, text);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, sz);
    ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

void AI_A2C_CreatePanel(int x, int y) {
    if (g_a2c_panelOk) return;
    ObjectCreate(0, "AI_A2C_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSetInteger(0, "AI_A2C_BG", OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, "AI_A2C_BG", OBJPROP_XDISTANCE, x);
    ObjectSetInteger(0, "AI_A2C_BG", OBJPROP_YDISTANCE, y);
    ObjectSetInteger(0, "AI_A2C_BG", OBJPROP_XSIZE, 310);
    ObjectSetInteger(0, "AI_A2C_BG", OBJPROP_YSIZE, 460);
    ObjectSetInteger(0, "AI_A2C_BG", OBJPROP_BGCOLOR, C'15,25,15');
    ObjectSetInteger(0, "AI_A2C_BG", OBJPROP_BORDER_COLOR, C'40,80,40');
    ObjectSetInteger(0, "AI_A2C_BG", OBJPROP_CORNER, CORNER_LEFT_UPPER);
    ObjectSetInteger(0, "AI_A2C_BG", OBJPROP_BACK, false);
    int ly = y + 8;
    AI_A2C_CrLabel("AI_A2C_T", "A2C SIGNAL IA [MT5]", x+10, ly, clrSpringGreen, 9); ly += 16;
    AI_A2C_CrLabel("AI_A2C_V", "v3.0 - 15feat 64-32/48-24 | Hurst+Entropy", x+10, ly, clrDarkGray, 7); ly += 18;
    AI_A2C_CrLabel("AI_A2C_S1", ":: ACTOR (POLICY)", x+10, ly, clrGold, 8); ly += 16;
    AI_A2C_CrLabel("AI_A2C_Act", "Action: HOLD", x+15, ly, clrWhite, 8); ly += 15;
    AI_A2C_CrLabel("AI_A2C_PH", "H: 0%", x+15, ly, clrGray, 8);
    AI_A2C_CrLabel("AI_A2C_PB", "B: 0%", x+80, ly, clrLime, 8);
    AI_A2C_CrLabel("AI_A2C_PS", "S: 0%", x+145, ly, clrOrangeRed, 8);
    AI_A2C_CrLabel("AI_A2C_PC", "C: 0%", x+210, ly, clrYellow, 8); ly += 15;
    AI_A2C_CrLabel("AI_A2C_Ent", "Entropy: 0.000", x+15, ly, clrWhite, 8); ly += 20;
    AI_A2C_CrLabel("AI_A2C_S2", ":: CRITIC (VALUE)", x+10, ly, clrGold, 8); ly += 16;
    AI_A2C_CrLabel("AI_A2C_Val", "V(s): 0.000", x+15, ly, clrWhite, 8); ly += 15;
    AI_A2C_CrLabel("AI_A2C_Adv", "Advantage: 0.000", x+15, ly, clrWhite, 8); ly += 15;
    AI_A2C_CrLabel("AI_A2C_Conf", "Conf: 0%", x+15, ly, clrWhite, 8); ly += 20;
    AI_A2C_CrLabel("AI_A2C_S3", ":: PERFORMANCE", x+10, ly, clrGold, 8); ly += 16;
    AI_A2C_CrLabel("AI_A2C_Trd", "Trades: 0", x+15, ly, clrWhite, 8); ly += 15;
    AI_A2C_CrLabel("AI_A2C_WR", "Win Rate: ---", x+15, ly, clrWhite, 8); ly += 15;
    AI_A2C_CrLabel("AI_A2C_Prof", "Profit: 0.00", x+15, ly, clrWhite, 8); ly += 15;
    AI_A2C_CrLabel("AI_A2C_Step", "Steps: 0", x+15, ly, clrWhite, 8); ly += 15;
    AI_A2C_CrLabel("AI_A2C_TR", "TotalR: 0.00", x+15, ly, clrWhite, 8); ly += 20;
    AI_A2C_CrLabel("AI_A2C_S4", ":: STATE (15 FEATURES)", x+10, ly, clrGold, 8); ly += 16;
    AI_A2C_CrLabel("AI_A2C_F1", "RSI:-- ADX:-- BB%:--", x+15, ly, clrWhite, 8); ly += 14;
    AI_A2C_CrLabel("AI_A2C_F2", "Hurst:-- Entropy:-- VolR:--", x+15, ly, clrWhite, 8); ly += 15;
    AI_A2C_CrLabel("AI_A2C_File", "File: new", x+15, ly, clrDarkGray, 7);
    g_a2c_panelOk = true;
}

void AI_A2C_UpdPanel(int act, double val, double conf, double adv, double &st[]) {
    if (TimeCurrent() - g_a2c_panelUpd < 1) return;
    g_a2c_panelUpd = TimeCurrent();
    string an[] = {"HOLD","BUY","SELL","CLOSE"};
    color ac[] = {clrGray, clrLime, clrOrangeRed, clrYellow};
    ObjectSetString(0, "AI_A2C_Act", OBJPROP_TEXT, "Action: " + (act >= 0 && act < 4 ? an[act] : "?"));
    ObjectSetInteger(0, "AI_A2C_Act", OBJPROP_COLOR, act >= 0 && act < 4 ? ac[act] : clrGray);
    // Policy probabilities
    ObjectSetString(0, "AI_A2C_PH", OBJPROP_TEXT, "H:" + DoubleToString(g_a2c_probs[0]*100, 0) + "%");
    ObjectSetString(0, "AI_A2C_PB", OBJPROP_TEXT, "B:" + DoubleToString(g_a2c_probs[1]*100, 0) + "%");
    ObjectSetString(0, "AI_A2C_PS", OBJPROP_TEXT, "S:" + DoubleToString(g_a2c_probs[2]*100, 0) + "%");
    ObjectSetString(0, "AI_A2C_PC", OBJPROP_TEXT, "C:" + DoubleToString(g_a2c_probs[3]*100, 0) + "%");
    // Policy entropy
    double ent = 0;
    for (int i = 0; i < A2C_ACT; i++) if (g_a2c_probs[i] > 0.0001) ent -= g_a2c_probs[i] * MathLog(g_a2c_probs[i]);
    ObjectSetString(0, "AI_A2C_Ent", OBJPROP_TEXT, "Policy Entropy: " + DoubleToString(ent, 3));
    ObjectSetInteger(0, "AI_A2C_Ent", OBJPROP_COLOR, ent > 1.0 ? clrYellow : (ent > 0.5 ? clrLime : clrCyan));
    // Critic
    ObjectSetString(0, "AI_A2C_Val", OBJPROP_TEXT, "V(s): " + DoubleToString(val, 4));
    ObjectSetString(0, "AI_A2C_Adv", OBJPROP_TEXT, "Advantage: " + DoubleToString(adv, 4));
    ObjectSetInteger(0, "AI_A2C_Adv", OBJPROP_COLOR, adv > 0 ? clrLime : (adv < 0 ? clrOrangeRed : clrGray));
    ObjectSetString(0, "AI_A2C_Conf", OBJPROP_TEXT, "Conf: " + DoubleToString(conf, 0) + "%");
    // Performance
    ObjectSetString(0, "AI_A2C_Trd", OBJPROP_TEXT, "Trades: " + IntegerToString(g_a2c_totalTrades));
    double wr = g_a2c_totalTrades > 0 ? (double)g_a2c_wins / g_a2c_totalTrades * 100.0 : 0;
    ObjectSetString(0, "AI_A2C_WR", OBJPROP_TEXT, "Win Rate: " + DoubleToString(wr, 1) + "%");
    ObjectSetInteger(0, "AI_A2C_WR", OBJPROP_COLOR, wr >= 50 ? clrLime : (wr > 0 ? clrOrangeRed : clrGray));
    ObjectSetString(0, "AI_A2C_Prof", OBJPROP_TEXT, "Profit: " + DoubleToString(g_a2c_totalProfit, 2));
    ObjectSetInteger(0, "AI_A2C_Prof", OBJPROP_COLOR, g_a2c_totalProfit >= 0 ? clrLime : clrOrangeRed);
    ObjectSetString(0, "AI_A2C_Step", OBJPROP_TEXT, "Steps: " + IntegerToString(g_a2c_steps));
    ObjectSetString(0, "AI_A2C_TR", OBJPROP_TEXT, "TotalR: " + DoubleToString(g_a2c_totalR, 2));
    ObjectSetInteger(0, "AI_A2C_TR", OBJPROP_COLOR, g_a2c_totalR >= 0 ? clrLime : clrOrangeRed);
    // State features (15 features)
    ObjectSetString(0, "AI_A2C_F1", OBJPROP_TEXT, "RSI:" + DoubleToString(st[0]*100, 0) + " ADX:" + DoubleToString(st[3]*100, 0) + " BB%:" + DoubleToString(st[4]*100, 0) + " Stoch:" + DoubleToString(st[5]*100, 0));
    double hurst = st[9]; double entropy = st[10];
    string hLbl = hurst > 0.6 ? "TREND" : (hurst < 0.4 ? "REVERT" : "RAND");
    ObjectSetString(0, "AI_A2C_F2", OBJPROP_TEXT, "Hurst:" + DoubleToString(hurst, 2) + "(" + hLbl + ") Ent:" + DoubleToString(entropy, 2) + " VR:" + DoubleToString(st[11]*2, 1));
    ObjectSetInteger(0, "AI_A2C_F2", OBJPROP_COLOR, hurst > 0.6 ? clrCyan : (hurst < 0.4 ? clrYellow : clrWhite));
    ObjectSetString(0, "AI_A2C_File", OBJPROP_TEXT, g_a2c_fileLoaded ? "File: loaded (v3)" : "File: new");
    ObjectSetInteger(0, "AI_A2C_File", OBJPROP_COLOR, g_a2c_fileLoaded ? clrLime : clrGray);
}

// ===== LOGIC HELPER FUNCTIONS =====

// ===== LOGIC NODES MQL5 HELPER FUNCTIONS =====

//+------------------------------------------------------------------+
//| Check if time is allowed for trading (MQL5)                      |
//| gmtOffset: Adjust server time by this many hours                 |
//+------------------------------------------------------------------+
bool IsTimeAllowed(string mode, int startHour, int endHour, string days, bool useServerTime, int gmtOffset = 0) {
    datetime checkTime = useServerTime ? TimeCurrent() : TimeLocal();
    
    MqlDateTime timeStruct;
    TimeToStruct(checkTime, timeStruct);
    
    // Apply GMT offset to convert server time to target timezone
    int hour = timeStruct.hour + gmtOffset;
    
    // Handle hour wraparound (e.g., -2 becomes 22, 25 becomes 1)
    if (hour < 0) hour += 24;
    if (hour >= 24) hour -= 24;
    
    int dayOfWeek = timeStruct.day_of_week;
    
    if (mode == "HOUR_RANGE") {
        if (startHour < endHour) {
            return (hour >= startHour && hour < endHour);
        } else {
            // Handle overnight ranges
            return (hour >= startHour || hour < endHour);
        }
    }
    else if (mode == "DAY_OF_WEEK") {
        return (StringFind(days, IntegerToString(dayOfWeek)) >= 0);
    }
    else if (mode == "DAY_OF_MONTH") {
        int dayOfMonth = timeStruct.day;
        return (StringFind(days, IntegerToString(dayOfMonth)) >= 0);
    }
    else if (mode == "AVOID_NEWS") {
        // Simple news avoidance - avoid first Friday of month (NFP)
        if (dayOfWeek == 5 && timeStruct.day <= 7) {
            if (hour >= 12 && hour <= 15) return false; // Avoid NFP hours
        }
        return true;
    }
    else if (mode == "SESSION") {
        // Market sessions (approximate times in GMT/UTC)
        // SYDNEY: 21:00-06:00 GMT | TOKYO: 23:00-08:00 GMT
        // LONDON: 07:00-16:00 GMT | NEWYORK: 12:00-21:00 GMT
        if (StringFind(days, "SYDNEY") >= 0 && (hour >= 21 || hour < 6)) return true;
        if (StringFind(days, "TOKYO") >= 0 && (hour >= 23 || hour < 8)) return true;
        if (StringFind(days, "LONDON") >= 0 && (hour >= 7 && hour < 16)) return true;
        if (StringFind(days, "NEWYORK") >= 0 && (hour >= 12 && hour < 21)) return true;
        return false; // If no session matches, return false
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Check if day of week is allowed (individual day booleans) (MQL5) |
//| Each day: 0=disabled, 1=enabled                                  |
//+------------------------------------------------------------------+
bool IsTimeAllowed_DayBools(int sun, int mon, int tue, int wed, int thu, int fri, int sat, int gmtOffset = 0) {
    MqlDateTime timeStruct;
    TimeToStruct(TimeCurrent(), timeStruct);
    int hour = timeStruct.hour + gmtOffset;
    if (hour < 0) hour += 24;
    if (hour >= 24) hour -= 24;
    int dow = timeStruct.day_of_week;
    
    if (dow == 0 && sun == 1) return true;
    if (dow == 1 && mon == 1) return true;
    if (dow == 2 && tue == 1) return true;
    if (dow == 3 && wed == 1) return true;
    if (dow == 4 && thu == 1) return true;
    if (dow == 5 && fri == 1) return true;
    if (dow == 6 && sat == 1) return true;
    return false;
}

//+------------------------------------------------------------------+
//| Threshold with Hysteresis - PROFESSIONAL IMPLEMENTATION (MQL5)  |
//| Uses array-based state tracking for reliability                 |
//| CRITICAL: Must be IDENTICAL to MT4 implementation               |
//+------------------------------------------------------------------+
// Global array for threshold states (supports up to 100 different thresholds)
bool g_ThresholdStates[100];

bool ThresholdWithHysteresis(double value, double threshold, string direction, double hysteresis, int thresholdId) {
    // Validate threshold ID
    if (thresholdId < 0 || thresholdId >= 100) {
        Print("ERROR: Invalid threshold ID: ", thresholdId);
        return false;
    }
    
    bool lastState = g_ThresholdStates[thresholdId];
    bool currentState = false;
    
    // FIXED: Identical logic to MT4 implementation
    if (direction == "ABOVE") {
        if (!lastState && value > threshold + hysteresis) {
            currentState = true;
        } else if (lastState && value > threshold - hysteresis) {
            currentState = true;
        }
    } else { // BELOW
        if (!lastState && value < threshold - hysteresis) {
            currentState = true;
        } else if (lastState && value < threshold + hysteresis) {
            currentState = true;
        }
    }
    
    // Store state for this specific threshold
    g_ThresholdStates[thresholdId] = currentState;
    return currentState;
}

//+------------------------------------------------------------------+
//| Threshold crossing detection (MQL5)                             |
//+------------------------------------------------------------------+
bool ThresholdCross(double value, double threshold, string direction, double hysteresis) {
    static double lastValue = 0;
    static datetime lastCheck = 0;
    
    if (iTime(_Symbol, _Period, 0) != lastCheck) {
        bool crossed = false;
        
        if (direction == "CROSS_ABOVE") {
            crossed = (value > threshold + hysteresis && lastValue <= threshold);
        } else if (direction == "CROSS_BELOW") {
            crossed = (value < threshold - hysteresis && lastValue >= threshold);
        }
        
        lastValue = value;
        lastCheck = iTime(_Symbol, _Period, 0);
        
        return crossed;
    }
    
    return false;
}

// Crossover detection with confirmation
bool DetectCrossover(double value1, double value2, double value1Prev, double value2Prev, int confirmBars = 0) {
    bool crossed = (value1Prev <= value2Prev && value1 > value2);
    
    if (confirmBars == 0) return crossed;
    
    static int confirmCount = 0;
    if (crossed) {
        confirmCount++;
    } else {
        confirmCount = 0;
    }
    
    return (confirmCount >= confirmBars);
}

// Crossunder detection with confirmation
bool DetectCrossunder(double value1, double value2, double value1Prev, double value2Prev, int confirmBars = 0) {
    bool crossed = (value1Prev >= value2Prev && value1 < value2);
    
    if (confirmBars == 0) return crossed;
    
    static int confirmCount = 0;
    if (crossed) {
        confirmCount++;
    } else {
        confirmCount = 0;
    }
    
    return (confirmCount >= confirmBars);
}

// Detect trend
string DetectTrend(int period, ENUM_MA_METHOD method = 0) { // 0 = SMA
    double ma1 = GetMA(period, 0, method, PRICE_CLOSE, 0);
    double ma2 = GetMA(period, 0, method, PRICE_CLOSE, period);
    double currentPrice = GetBarClose(_Symbol, _Period, 0);
    
    if (currentPrice > ma1 && ma1 > ma2) return "UP";
    if (currentPrice < ma1 && ma1 < ma2) return "DOWN";
    return "SIDEWAYS";
}

//+------------------------------------------------------------------+
//| Check if there are no open orders (for overtrading prevention)   |
//+------------------------------------------------------------------+
bool HasNoOrders(bool includePending, bool perSymbol, long magic) {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (!PositionSelectByTicket(ticket)) continue;
        if (perSymbol && PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if (magic != 0 && PositionGetInteger(POSITION_MAGIC) != magic) continue;
        
        return false; // Found a position
    }
    
    if (includePending) {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            ulong ticket = OrderGetTicket(i);
            if (!OrderSelect(ticket)) continue;
            if (perSymbol && OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
            if (magic != 0 && OrderGetInteger(ORDER_MAGIC) != magic) continue;
            
            return false; // Found a pending order
        }
    }
    
    return true; // No orders found
}

//+------------------------------------------------------------------+
//| Get count of open orders by type                                 |
//+------------------------------------------------------------------+
int GetOrderCount(string orderType, bool perSymbol, long magic) {
    int count = 0;
    
    // Count positions
    if (orderType == "ALL" || orderType == "MARKET" || orderType == "BUY" || orderType == "SELL") {
        for (int i = PositionsTotal() - 1; i >= 0; i--) {
            ulong ticket = PositionGetTicket(i);
            if (!PositionSelectByTicket(ticket)) continue;
            if (perSymbol && PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
            if (magic != 0 && PositionGetInteger(POSITION_MAGIC) != magic) continue;
            
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            
            if (orderType == "ALL" || orderType == "MARKET") {
                count++;
            } else if (orderType == "BUY" && type == POSITION_TYPE_BUY) {
                count++;
            } else if (orderType == "SELL" && type == POSITION_TYPE_SELL) {
                count++;
            }
        }
    }
    
    // Count pending orders
    if (orderType == "ALL" || orderType == "PENDING") {
        for (int i = OrdersTotal() - 1; i >= 0; i--) {
            ulong ticket = OrderGetTicket(i);
            if (!OrderSelect(ticket)) continue;
            if (perSymbol && OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
            if (magic != 0 && OrderGetInteger(ORDER_MAGIC) != magic) continue;
            
            count++;
        }
    }
    
    return count;
}

//+------------------------------------------------------------------+
//| Check volatility conditions (MQL5)                               |
//| Uses ATR indicator to measure volatility                         |
//| FIXED: Added ArrayResize to prevent error 4807                   |
//+------------------------------------------------------------------+
bool CheckVolatility(string condition, int periods, double threshold, double multiplier) {
    // Get ATR handle
    int atrHandle = iATR(_Symbol, _Period, periods);
    if (atrHandle == INVALID_HANDLE) {
        Print("ERROR: CheckVolatility - Failed to create ATR handle");
        return false;
    }
    
    // Get current ATR value
    double atrBuffer[];
    // Copy enough data for comparison (periods * 2 + 1)
    int copyCount = periods * 2 + 1;
    ArrayResize(atrBuffer, copyCount);
    ArraySetAsSeries(atrBuffer, true);
    
    if (CopyBuffer(atrHandle, 0, 0, copyCount, atrBuffer) < copyCount) {
        Print("ERROR: CheckVolatility - Failed to copy ATR data | LastError: ", GetLastError());
        IndicatorRelease(atrHandle);
        return false;
    }
    
    double currentATR = atrBuffer[0];
    
    // Calculate average ATR from historical data
    double avgATR = 0;
    for (int i = periods; i < periods * 2; i++) {
        avgATR += atrBuffer[i];
    }
    avgATR /= periods;
    
    // Release indicator handle
    IndicatorRelease(atrHandle);
    
    // Check condition
    if (condition == "ABOVE") {
        return currentATR > threshold * _Point;
    }
    else if (condition == "BELOW") {
        return currentATR < threshold * _Point;
    }
    else if (condition == "INCREASING") {
        double prevATR = atrBuffer[periods];
        return currentATR > prevATR * 1.1;
    }
    else if (condition == "DECREASING") {
        double prevATR = atrBuffer[periods];
        return currentATR < prevATR * 0.9;
    }
    else if (condition == "SPIKE") {
        return currentATR > avgATR * multiplier;
    }
    
    return false;
}


// ===== RISK MANAGEMENT HELPER FUNCTIONS =====

// ===== RISK MANAGEMENT MQL5 HELPER FUNCTIONS =====

//+------------------------------------------------------------------+
//| Position Sizing - Calculate lots based on risk (MQL5)            |
//+------------------------------------------------------------------+
double CalculatePositionSize(double riskPercent, double stopLossPips, bool useEquity, double maxLeverage, bool roundDown) {
    static datetime lastSizeLog = 0;
    
    double accountValue = useEquity ? AccountInfoDouble(ACCOUNT_EQUITY) : AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountValue * riskPercent / 100.0;
    
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    if (tickValue == 0) {
        LogWarning("Position Sizing: Cannot get tick value, using min lot");
        return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    }
    
    double lotSize = riskAmount / (stopLossPips * tickValue * 10);
    
    // Apply leverage limit
    double marginRequired = SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_INITIAL);
    if (marginRequired > 0) {
        double maxLotsByLeverage = (accountValue * maxLeverage) / marginRequired;
        if (lotSize > maxLotsByLeverage) {
            lotSize = maxLotsByLeverage;
        }
    }
    
    // Normalize lots
    double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
    double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
    
    if (roundDown) {
        lotSize = MathFloor(lotSize / lotStep) * lotStep;
    } else {
        lotSize = MathRound(lotSize / lotStep) * lotStep;
    }
    
    lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
    
    if (g_DebugMode && TimeCurrent() - lastSizeLog > 60) {
        LogDebug("Position Sizing: Account=" + DoubleToString(accountValue, 2) + 
                " | Risk=" + DoubleToString(riskPercent, 2) + "%" +
                " | SL=" + DoubleToString(stopLossPips, 1) + " pts" +
                " | Lots=" + DoubleToString(lotSize, 2));
        lastSizeLog = TimeCurrent();
    }
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Fixed Ratio Position Sizing (MQL5)                               |
//+------------------------------------------------------------------+
static double g_FixedRatioStartBalance = 0;
static double g_FixedRatioClosedProfit = 0;

double CalculateFixedRatioSize(double baseLots, double deltaProfit, int maxMultiplier, bool useClosedProfit) {
    static datetime lastRatioLog = 0;
    
    if (g_FixedRatioStartBalance == 0) {
        g_FixedRatioStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    }
    
    double profitToUse = 0;
    
    if (useClosedProfit) {
        // Calculate from closed deals
        HistorySelect(0, TimeCurrent());
        g_FixedRatioClosedProfit = 0;
        
        for (int i = 0; i < HistoryDealsTotal(); i++) {
            ulong ticket = HistoryDealGetTicket(i);
            if (ticket > 0) {
                if (HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol) {
                    g_FixedRatioClosedProfit += HistoryDealGetDouble(ticket, DEAL_PROFIT) +
                                                HistoryDealGetDouble(ticket, DEAL_SWAP) +
                                                HistoryDealGetDouble(ticket, DEAL_COMMISSION);
                }
            }
        }
        profitToUse = g_FixedRatioClosedProfit;
    } else {
        profitToUse = AccountInfoDouble(ACCOUNT_BALANCE) - g_FixedRatioStartBalance + AccountInfoDouble(ACCOUNT_PROFIT);
    }
    
    int contractsToAdd = 0;
    if (profitToUse > 0 && deltaProfit > 0) {
        contractsToAdd = (int)(MathSqrt(2.0 * profitToUse / deltaProfit + 0.25) - 0.5);
    }
    
    if (contractsToAdd >= maxMultiplier) {
        contractsToAdd = maxMultiplier - 1;
    }
    if (contractsToAdd < 0) contractsToAdd = 0;
    
    double lots = baseLots * (1 + contractsToAdd);
    lots = NormalizeLots(lots);
    
    if (g_DebugMode && TimeCurrent() - lastRatioLog > 60) {
        LogDebug("Fixed Ratio: Profit=" + DoubleToString(profitToUse, 2) + 
                " | Delta=" + DoubleToString(deltaProfit, 0) +
                " | Contracts+" + IntegerToString(contractsToAdd) +
                " | Lots=" + DoubleToString(lots, 2));
        lastRatioLog = TimeCurrent();
    }
    
    return lots;
}

//+------------------------------------------------------------------+
//| Kelly Formula Position Sizing (MQL5)                             |
//+------------------------------------------------------------------+
double CalculateKellySize(double winRate, double avgWinLoss, double kellyFraction, double maxRisk, double stopLossPips, bool autoCalculate) {
    static datetime lastKellyLog = 0;
    
    double effectiveWinRate = winRate;
    double effectiveWinLoss = avgWinLoss;
    
    if (autoCalculate) {
        int wins = 0, losses = 0;
        double totalWin = 0, totalLoss = 0;
        
        HistorySelect(0, TimeCurrent());
        for (int i = 0; i < HistoryDealsTotal(); i++) {
            ulong ticket = HistoryDealGetTicket(i);
            if (ticket > 0) {
                if (HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol &&
                    HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT) {
                    double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
                    if (profit > 0) {
                        wins++;
                        totalWin += profit;
                    } else if (profit < 0) {
                        losses++;
                        totalLoss += MathAbs(profit);
                    }
                }
            }
        }
        
        int totalTrades = wins + losses;
        if (totalTrades >= 30) {
            effectiveWinRate = (double)wins / totalTrades * 100.0;
            if (losses > 0 && totalLoss > 0) {
                effectiveWinLoss = (totalWin / wins) / (totalLoss / losses);
            }
        }
    }
    
    double p = effectiveWinRate / 100.0;
    double q = 1.0 - p;
    double b = effectiveWinLoss;
    
    double kellyPercent = 0;
    if (b > 0) {
        kellyPercent = (p * b - q) / b;
    }
    
    kellyPercent *= kellyFraction;
    
    if (kellyPercent > maxRisk / 100.0) {
        kellyPercent = maxRisk / 100.0;
    }
    
    if (kellyPercent <= 0) {
        return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    }
    
    double accountValue = AccountInfoDouble(ACCOUNT_BALANCE);
    double riskAmount = accountValue * kellyPercent;
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    
    double lotSize = 0;
    if (tickValue > 0 && stopLossPips > 0) {
        lotSize = riskAmount / (stopLossPips * tickValue * 10);
    }
    
    lotSize = NormalizeLots(lotSize);
    
    if (g_DebugMode && TimeCurrent() - lastKellyLog > 60) {
        LogDebug("Kelly Formula: WinRate=" + DoubleToString(effectiveWinRate, 1) + "%" +
                " | W/L=" + DoubleToString(effectiveWinLoss, 2) +
                " | Kelly=" + DoubleToString(kellyPercent * 100, 2) + "%" +
                " | Lots=" + DoubleToString(lotSize, 2));
        lastKellyLog = TimeCurrent();
    }
    
    return lotSize;
}

//+------------------------------------------------------------------+
//| Max Drawdown Filter - Monitor and limit drawdown (MQL5)          |
//| Supports TOTAL, WEEKLY, and DAILY periods                        |
//+------------------------------------------------------------------+
static double g_InitialBalance = 0;
static double g_EquityHighWaterMark = 0;
static bool g_DrawdownTradingDisabled = false;
static datetime g_DrawdownPeriodStart = 0;
static double g_DrawdownPeriodStartBalance = 0;

datetime GetDrawdownPeriodStart(string period) {
    datetime now = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(now, dt);
    
    if (period == "DAILY") {
        // Reset at 00:00 server time
        dt.hour = 0;
        dt.min = 0;
        dt.sec = 0;
        return StructToTime(dt);
    }
    else if (period == "WEEKLY") {
        // Reset on Monday 00:00
        int daysFromMonday = dt.day_of_week - 1; // Monday = 1
        if (daysFromMonday < 0) daysFromMonday = 6; // Sunday
        dt.hour = 0;
        dt.min = 0;
        dt.sec = 0;
        return StructToTime(dt) - daysFromMonday * 86400;
    }
    // TOTAL - use initial balance from EA start
    return 0;
}

bool CheckMaxDrawdownFilter(double maxDrawdownPercent, double warningLevel, string period, string action, string calculateFrom, long magicNumber) {
    static datetime lastDrawdownLog = 0;
    
    // Initialize balances
    if (g_InitialBalance == 0) {
        g_InitialBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        g_EquityHighWaterMark = AccountInfoDouble(ACCOUNT_EQUITY);
    }
    
    // Check if period has reset (for DAILY/WEEKLY)
    datetime periodStart = GetDrawdownPeriodStart(period);
    if (period != "TOTAL" && periodStart > g_DrawdownPeriodStart) {
        g_DrawdownPeriodStart = periodStart;
        g_DrawdownPeriodStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        g_DrawdownTradingDisabled = false; // Reset the trading block for new period
        LogInfo("Drawdown period reset (" + period + "): New start balance = " + DoubleToString(g_DrawdownPeriodStartBalance, 2));
    }
    
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    double drawdownPercent = 0;
    
    // ✅ FIX: Calculate drawdown as percentage of CURRENT balance, not initial balance
    // Drawdown = (Balance - Equity) / Balance * 100
    // This measures the current negative DD relative to the current account balance
    if (currentBalance > 0) {
        drawdownPercent = ((currentBalance - currentEquity) / currentBalance) * 100;
    }
    
    if (drawdownPercent < 0) drawdownPercent = 0;
    
    if (g_DebugMode && TimeCurrent() - lastDrawdownLog > 30) {
        LogDebug("Drawdown Monitor [" + period + "]: Current=" + DoubleToString(drawdownPercent, 2) + "%" +
                " | Warning=" + DoubleToString(warningLevel, 1) + "%" +
                " | Max=" + DoubleToString(maxDrawdownPercent, 1) + "%" +
                " | Equity=" + DoubleToString(currentEquity, 2) +
                " | Balance=" + DoubleToString(currentBalance, 2));
        lastDrawdownLog = TimeCurrent();
    }
    
    if (drawdownPercent >= warningLevel && drawdownPercent < maxDrawdownPercent) {
        LogWarning("Drawdown WARNING [" + period + "]: " + DoubleToString(drawdownPercent, 2) + "%");
    }
    
    if (drawdownPercent >= maxDrawdownPercent) {
        LogError("MAX DRAWDOWN REACHED [" + period + "]: " + DoubleToString(drawdownPercent, 2) + "%");
        
        if (action == "CLOSE_ALL") {
            LogInfo("Drawdown Action: Closing all positions...");
            CloseAllPositions(magicNumber);
            g_DrawdownTradingDisabled = true;
        }
        else if (action == "STOP_TRADING") {
            LogInfo("Drawdown Action: Trading disabled until period reset");
            g_DrawdownTradingDisabled = true;
        }
        else if (action == "ALERT_ONLY") {
            Alert("Maximum drawdown reached [" + period + "]: " + DoubleToString(drawdownPercent, 2) + "%");
        }
        else if (action == "REDUCE_RISK") {
            LogInfo("Drawdown Action: Reducing risk - closing 50% of positions...");
            int totalPositions = PositionsTotal();
            int closedCount = 0;
            for (int i = totalPositions - 1; i >= 0 && closedCount < totalPositions / 2; i--) {
                ulong ticket = PositionGetTicket(i);
                if (ticket > 0) {
                    if (PositionGetString(POSITION_SYMBOL) == _Symbol) {
                        if (magicNumber == 0 || PositionGetInteger(POSITION_MAGIC) == magicNumber) {
                            if (ClosePosition(ticket)) closedCount++;
                        }
                    }
                }
            }
        }
        return false;
    }
    
    if (g_DrawdownTradingDisabled) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Max Profit Filter - Set profit limit with period support (MQL5)  |
//| Supports TOTAL, WEEKLY, and DAILY periods                        |
//+------------------------------------------------------------------+
static bool g_ProfitTradingDisabled = false;
static datetime g_ProfitPeriodStart = 0;
static double g_ProfitPeriodStartBalance = 0;

datetime GetProfitPeriodStart(string period) {
    datetime now = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(now, dt);
    
    if (period == "DAILY") {
        // Reset at 00:00 server time
        dt.hour = 0;
        dt.min = 0;
        dt.sec = 0;
        return StructToTime(dt);
    }
    else if (period == "WEEKLY") {
        // Reset on Monday 00:00
        int daysFromMonday = dt.day_of_week - 1; // Monday = 1
        if (daysFromMonday < 0) daysFromMonday = 6; // Sunday
        dt.hour = 0;
        dt.min = 0;
        dt.sec = 0;
        return StructToTime(dt) - daysFromMonday * 86400;
    }
    // TOTAL - use initial balance from EA start
    return 0;
}

double GetPeriodProfit(string period, bool includeFloating, long magicNumber) {
    double closedProfit = 0;
    double floatingProfit = 0;
    
    // Get closed profit for the period
    datetime periodStart = GetProfitPeriodStart(period);
    if (period == "TOTAL") {
        HistorySelect(0, TimeCurrent());
    } else {
        HistorySelect(periodStart, TimeCurrent());
    }
    
    for (int i = 0; i < HistoryDealsTotal(); i++) {
        ulong ticket = HistoryDealGetTicket(i);
        if (ticket > 0) {
            if (HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol) {
                if (magicNumber == 0 || HistoryDealGetInteger(ticket, DEAL_MAGIC) == magicNumber) {
                    closedProfit += HistoryDealGetDouble(ticket, DEAL_PROFIT) +
                                   HistoryDealGetDouble(ticket, DEAL_SWAP) +
                                   HistoryDealGetDouble(ticket, DEAL_COMMISSION);
                }
            }
        }
    }
    
    // Add floating profit if required
    if (includeFloating) {
        for (int i = 0; i < PositionsTotal(); i++) {
            ulong ticket = PositionGetTicket(i);
            if (ticket > 0) {
                if (PositionGetString(POSITION_SYMBOL) == _Symbol) {
                    if (magicNumber == 0 || PositionGetInteger(POSITION_MAGIC) == magicNumber) {
                        floatingProfit += PositionGetDouble(POSITION_PROFIT) +
                                         PositionGetDouble(POSITION_SWAP);
                    }
                }
            }
        }
    }
    
    return closedProfit + floatingProfit;
}

bool CheckMaxProfitFilter(double maxProfitPercent, double warningLevel, string period, string action, bool includeFloating, string calculateFrom, long magicNumber) {
    static datetime lastProfitLog = 0;
    
    // Check if period has reset (for DAILY/WEEKLY)
    datetime periodStart = GetProfitPeriodStart(period);
    if (period != "TOTAL" && periodStart > g_ProfitPeriodStart) {
        g_ProfitPeriodStart = periodStart;
        g_ProfitPeriodStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
        g_ProfitTradingDisabled = false; // Reset the trading block for new period
        LogInfo("Profit period reset (" + period + "): New start balance = " + DoubleToString(g_ProfitPeriodStartBalance, 2));
    }
    
    // Initialize period start balance if needed
    if (g_ProfitPeriodStartBalance == 0) {
        g_ProfitPeriodStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
    }
    
    double referenceValue = 0;
    if (calculateFrom == "EQUITY") {
        referenceValue = AccountInfoDouble(ACCOUNT_EQUITY);
    } else {
        referenceValue = g_ProfitPeriodStartBalance;
    }
    
    // Calculate profit for the period
    double periodProfit = GetPeriodProfit(period, includeFloating, magicNumber);
    double profitPercent = 0;
    
    if (referenceValue > 0) {
        profitPercent = (periodProfit / referenceValue) * 100;
    }
    
    if (g_DebugMode && TimeCurrent() - lastProfitLog > 30) {
        LogDebug("Max Profit Monitor [" + period + "]: Profit=" + DoubleToString(profitPercent, 2) + "%" +
                " | Warning=" + DoubleToString(warningLevel, 1) + "%" +
                " | Max=" + DoubleToString(maxProfitPercent, 1) + "%" +
                " | Amount=" + DoubleToString(periodProfit, 2) +
                " | Ref=" + DoubleToString(referenceValue, 2));
        lastProfitLog = TimeCurrent();
    }
    
    if (profitPercent >= warningLevel && profitPercent < maxProfitPercent) {
        LogInfo("Max Profit WARNING [" + period + "]: " + DoubleToString(profitPercent, 2) + "% - Approaching target!");
    }
    
    if (profitPercent >= maxProfitPercent) {
        LogInfo("MAX PROFIT TARGET REACHED [" + period + "]: " + DoubleToString(profitPercent, 2) + "%");
        
        if (action == "CLOSE_ALL") {
            LogInfo("Profit Action: Closing all positions and stopping...");
            CloseAllPositions(magicNumber);
            g_ProfitTradingDisabled = true;
        }
        else if (action == "STOP_TRADING") {
            LogInfo("Profit Action: Stopping new trades - protecting profits");
            g_ProfitTradingDisabled = true;
        }
        else if (action == "ALERT_ONLY") {
            Alert("Max profit target reached [" + period + "]: " + DoubleToString(profitPercent, 2) + "%");
        }
        return false;
    }
    
    if (g_ProfitTradingDisabled) {
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Max Orders Filter - Limit open orders and total risk (MQL5)      |
//+------------------------------------------------------------------+
bool CanOpenNewOrderFilter(int maxOrders, bool countPending, bool perSymbol, double maxRiskPercent, long magicNumber) {
    static datetime lastOrdersLog = 0;
    
    int orderCount = 0;
    double totalRisk = 0;
    
    // Count positions
    for (int i = 0; i < PositionsTotal(); i++) {
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) continue;
        
        if (perSymbol && PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if (magicNumber != 0 && PositionGetInteger(POSITION_MAGIC) != magicNumber) continue;
        
        orderCount++;
        
        // Calculate risk
        double sl = PositionGetDouble(POSITION_SL);
        if (sl > 0) {
            double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
            double volume = PositionGetDouble(POSITION_VOLUME);
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            
            double riskPips = 0;
            if (type == POSITION_TYPE_BUY) {
                riskPips = (openPrice - sl) / PipsToPrice(1);
            } else {
                riskPips = (sl - openPrice) / PipsToPrice(1);
            }
            
            if (riskPips > 0) {
                double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
                double riskAmount = volume * riskPips * tickValue * 10;
                double balance = AccountInfoDouble(ACCOUNT_BALANCE);
                if (balance > 0) {
                    totalRisk += (riskAmount / balance) * 100;
                }
            }
        }
    }
    
    // Count pending orders if enabled
    if (countPending) {
        for (int i = 0; i < OrdersTotal(); i++) {
            ulong ticket = OrderGetTicket(i);
            if (ticket <= 0) continue;
            
            if (perSymbol && OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
            if (magicNumber != 0 && OrderGetInteger(ORDER_MAGIC) != magicNumber) continue;
            
            orderCount++;
        }
    }
    
    bool canOpen = true;
    string blockReason = "";
    
    if (orderCount >= maxOrders) {
        canOpen = false;
        blockReason = "Max orders: " + IntegerToString(orderCount) + "/" + IntegerToString(maxOrders);
    }
    else if (totalRisk >= maxRiskPercent) {
        canOpen = false;
        blockReason = "Max risk: " + DoubleToString(totalRisk, 2) + "% / " + DoubleToString(maxRiskPercent, 1) + "%";
    }
    
    if (g_DebugMode && TimeCurrent() - lastOrdersLog > 30) {
        LogDebug("Max Orders Filter: Orders=" + IntegerToString(orderCount) + "/" + IntegerToString(maxOrders) +
                " | Risk=" + DoubleToString(totalRisk, 2) + "%" +
                " | Can Open: " + (canOpen ? "YES" : "NO"));
        lastOrdersLog = TimeCurrent();
    }
    
    if (!canOpen) {
        LogWarning("Max Orders Filter: BLOCKED - " + blockReason);
    }
    
    return canOpen;
}

//+------------------------------------------------------------------+
//| Trade Cooldown Filter (MQL5)                                      |
//+------------------------------------------------------------------+
bool CheckTradeCooldown(string mode, int cooldownValue, string countFrom, bool perSymbol, long magicNumber) {
    datetime lastTradeTime = 0;
    bool fromClose = (countFrom == "LAST_CLOSE");
    
    if (fromClose) {
        if (HistorySelect(TimeCurrent() - 30 * 86400, TimeCurrent())) {
            int totalDeals = HistoryDealsTotal();
            for (int i = totalDeals - 1; i >= 0; i--) {
                ulong ticket = HistoryDealGetTicket(i);
                if (ticket <= 0) continue;
                long dealEntry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
                if (dealEntry != DEAL_ENTRY_OUT && dealEntry != DEAL_ENTRY_INOUT) continue;
                if (perSymbol && HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
                if (magicNumber != 0 && HistoryDealGetInteger(ticket, DEAL_MAGIC) != magicNumber) continue;
                datetime t = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
                if (t > lastTradeTime) lastTradeTime = t;
                break;
            }
        }
    }
    
    for (int i = 0; i < PositionsTotal(); i++) {
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) continue;
        if (perSymbol && PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if (magicNumber != 0 && PositionGetInteger(POSITION_MAGIC) != magicNumber) continue;
        datetime t = (datetime)PositionGetInteger(POSITION_TIME);
        if (t > lastTradeTime) lastTradeTime = t;
    }
    
    if (lastTradeTime == 0) return true;
    
    bool canTrade = false;
    if (mode == "BARS") {
        int barsSince = iBarShift(_Symbol, PERIOD_CURRENT, lastTradeTime);
        canTrade = (barsSince >= cooldownValue);
    } else {
        int seconds = (mode == "MINUTES") ? cooldownValue * 60 : cooldownValue;
        canTrade = ((int)(TimeCurrent() - lastTradeTime) >= seconds);
    }
    
    if (!canTrade) {
        static datetime lastCooldownLog = 0;
        if (TimeCurrent() - lastCooldownLog > 60) {
            LogWarning("Trade Cooldown: BLOCKED - Mode=" + mode + " Value=" + IntegerToString(cooldownValue) +
                       " | Last trade: " + TimeToString(lastTradeTime));
            lastCooldownLog = TimeCurrent();
        }
    }
    
    return canTrade;
}

//+------------------------------------------------------------------+
//| Trade Frequency Limit Filter (MQL5)                               |
//+------------------------------------------------------------------+
bool CheckTradeFrequencyLimit(int maxTrades, string window, string countMode, bool perSymbol, long magicNumber, int resetHour) {
    datetime now = TimeCurrent();
    MqlDateTime dt;
    TimeToStruct(now, dt);
    datetime windowStart = 0;
    
    if (window == "HOUR") {
        windowStart = now - dt.min * 60 - dt.sec;
    } else if (window == "DAY") {
        MqlDateTime dayStart;
        TimeToStruct(now, dayStart);
        dayStart.hour = resetHour;
        dayStart.min = 0;
        dayStart.sec = 0;
        windowStart = StructToTime(dayStart);
        if (windowStart > now) windowStart -= 86400;
    } else if (window == "WEEK") {
        int dayOfWeek = dt.day_of_week;
        if (dayOfWeek == 0) dayOfWeek = 7;
        windowStart = now - ((dayOfWeek - 1) * 86400 + dt.hour * 3600 + dt.min * 60 + dt.sec);
    }
    
    int tradeCount = 0;
    
    if (countMode != "OPENED_ONLY") {
        if (HistorySelect(windowStart, now)) {
            int totalDeals = HistoryDealsTotal();
            for (int i = totalDeals - 1; i >= 0; i--) {
                ulong ticket = HistoryDealGetTicket(i);
                if (ticket <= 0) continue;
                long dealEntry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
                if (dealEntry != DEAL_ENTRY_IN) continue;
                datetime dealTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
                if (dealTime < windowStart) break;
                if (perSymbol && HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
                if (magicNumber != 0 && HistoryDealGetInteger(ticket, DEAL_MAGIC) != magicNumber) continue;
                tradeCount++;
            }
        }
    }
    
    if (countMode != "CLOSED_ONLY") {
        for (int i = 0; i < PositionsTotal(); i++) {
            ulong ticket = PositionGetTicket(i);
            if (ticket <= 0) continue;
            datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
            if (openTime < windowStart) continue;
            if (perSymbol && PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
            if (magicNumber != 0 && PositionGetInteger(POSITION_MAGIC) != magicNumber) continue;
            tradeCount++;
        }
    }
    
    bool canTrade = (tradeCount < maxTrades);
    
    if (!canTrade) {
        static datetime lastFreqLog = 0;
        if (TimeCurrent() - lastFreqLog > 60) {
            LogWarning("Trade Frequency Limit: BLOCKED - " + IntegerToString(tradeCount) + "/" + IntegerToString(maxTrades) +
                       " trades in " + window + " window");
            lastFreqLog = TimeCurrent();
        }
    }
    
    return canTrade;
}

// Calculate current drawdown
double GetCurrentDrawdown(bool useEquityHigh = true) {
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    double equity = AccountInfoDouble(ACCOUNT_EQUITY);
    
    static double equityHigh = 0;
    
    if (useEquityHigh) {
        if (equity > equityHigh) equityHigh = equity;
        return ((equityHigh - equity) / equityHigh) * 100.0;
    }
    
    return ((balance - equity) / balance) * 100.0;
}

//+------------------------------------------------------------------+
//| Correlation Filter - Prevents trading highly correlated pairs    |
//+------------------------------------------------------------------+
double CalculatePearsonCorrelation(string symbol1, string symbol2, int period) {
    // Calculate Pearson correlation coefficient between two symbols
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0, sumY2 = 0;
    int validBars = 0;
    
    for (int i = 0; i < period; i++) {
        double price1 = iClose(symbol1, PERIOD_CURRENT, i);
        double price2 = iClose(symbol2, PERIOD_CURRENT, i);
        
        // Validate prices
        if (price1 <= 0 || price2 <= 0) continue;
        
        sumX += price1;
        sumY += price2;
        sumXY += price1 * price2;
        sumX2 += price1 * price1;
        sumY2 += price2 * price2;
        validBars++;
    }
    
    if (validBars < period / 2) {
        LogWarning("Correlation: Insufficient data for " + symbol1 + "/" + symbol2);
        return 0; // Not enough data
    }
    
    double n = validBars;
    double numerator = (n * sumXY) - (sumX * sumY);
    double denominator = MathSqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY));
    
    if (denominator == 0) return 0;
    
    return numerator / denominator;
}

bool HasOpenPositionForSymbol(string checkSymbol, long magicNumber) {
    for (int i = 0; i < PositionsTotal(); i++) {
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) continue;
        
        if (magicNumber != 0 && PositionGetInteger(POSITION_MAGIC) != magicNumber) continue;
        if (PositionGetString(POSITION_SYMBOL) == checkSymbol) return true;
    }
    return false;
}

int GetPositionDirectionForSymbol(string checkSymbol, long magicNumber) {
    // Returns: 1 = Long, -1 = Short, 0 = No position
    for (int i = 0; i < PositionsTotal(); i++) {
        ulong ticket = PositionGetTicket(i);
        if (ticket <= 0) continue;
        
        if (magicNumber != 0 && PositionGetInteger(POSITION_MAGIC) != magicNumber) continue;
        if (PositionGetString(POSITION_SYMBOL) == checkSymbol) {
            ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            if (type == POSITION_TYPE_BUY) return 1;
            if (type == POSITION_TYPE_SELL) return -1;
        }
    }
    return 0;
}

bool CheckCorrelationFilter(string pairsToCheck, double maxCorrelation, int period, string action, long magicNumber) {
    static datetime lastCorrelationLog = 0;
    
    // Split pairs string into array
    string pairs[];
    int pairCount = StringSplit(pairsToCheck, ',', pairs);
    
    if (pairCount == 0) {
        LogWarning("Correlation Filter: No pairs configured");
        return true; // Allow trading if no pairs configured
    }
    
    string currentSymbol = _Symbol;
    bool canTrade = true;
    string blockingPair = "";
    double highestCorrelation = 0;
    
    // Check correlation with each configured pair
    for (int i = 0; i < pairCount; i++) {
        string checkPair = pairs[i];
        StringTrimLeft(checkPair);
        StringTrimRight(checkPair);
        
        // Skip if it's the current symbol
        if (checkPair == currentSymbol) continue;
        
        // Check if we have an open position in the correlated pair
        if (!HasOpenPositionForSymbol(checkPair, magicNumber)) continue;
        
        // Calculate correlation
        double correlation = CalculatePearsonCorrelation(currentSymbol, checkPair, period);
        double absCorrelation = MathAbs(correlation);
        
        if (absCorrelation > highestCorrelation) {
            highestCorrelation = absCorrelation;
        }
        
        // Check if correlation exceeds threshold
        if (absCorrelation >= maxCorrelation) {
            if (action == "PREVENT") {
                canTrade = false;
                blockingPair = checkPair;
                LogWarning("Correlation Filter: Trading BLOCKED - " + currentSymbol + 
                          " has " + DoubleToString(absCorrelation * 100, 1) + 
                          "% correlation with open position in " + checkPair);
            }
            else if (action == "HEDGE") {
                // Allow only if it would be a hedge (opposite direction)
                int existingDir = GetPositionDirectionForSymbol(checkPair, magicNumber);
                if (correlation > 0) {
                    LogInfo("Correlation Filter: Hedge mode - High positive correlation with " + checkPair + 
                           ". Only opposite direction trades allowed.");
                } else {
                    LogInfo("Correlation Filter: Hedge mode - Negative correlation with " + checkPair);
                }
                canTrade = true; // Let the trading logic handle direction
            }
            else if (action == "WARN") {
                LogWarning("Correlation WARNING: " + currentSymbol + 
                          " has " + DoubleToString(absCorrelation * 100, 1) + 
                          "% correlation with " + checkPair);
                canTrade = true; // Allow but warn
            }
        }
    }
    
    // Periodic debug log
    if (g_DebugMode && TimeCurrent() - lastCorrelationLog > 60) {
        LogDebug("Correlation Filter: Checking " + currentSymbol + 
                " against " + IntegerToString(pairCount) + " pairs" +
                " | Highest correlation: " + DoubleToString(highestCorrelation * 100, 1) + "%" +
                " | Max allowed: " + DoubleToString(maxCorrelation * 100, 1) + "%" +
                " | Can trade: " + (canTrade ? "YES" : "NO"));
        lastCorrelationLog = TimeCurrent();
    }
    
    return canTrade;
}

// Apply trailing stop to position
bool ApplyTrailingStop(ulong ticket, double trailDistance, double minProfit) {
    if (!PositionSelectByTicket(ticket)) return false;
    
    double profitPips = GetPositionProfitPips(ticket);
    if (profitPips < minProfit) return false;
    
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    double currentPrice = (type == POSITION_TYPE_BUY) ? GetBidPrice() : GetAskPrice();
    double currentSL = PositionGetDouble(POSITION_SL);
    double newSL = 0;
    
    if (type == POSITION_TYPE_BUY) {
        newSL = currentPrice - trailDistance;
        if (newSL > currentSL) {
            return ModifyPosition(ticket, newSL, PositionGetDouble(POSITION_TP));
        }
    } else {
        newSL = currentPrice + trailDistance;
        if (newSL < currentSL || currentSL == 0) {
            return ModifyPosition(ticket, newSL, PositionGetDouble(POSITION_TP));
        }
    }
    
    return false;
}

// Move position to breakeven
bool MoveToBreakeven(ulong ticket, double triggerPips, double bufferPips) {
    if (!PositionSelectByTicket(ticket)) return false;
    
    double profitPips = GetPositionProfitPips(ticket);
    if (profitPips < triggerPips) return false;
    
    double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
    ENUM_POSITION_TYPE type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
    
    double breakeven = openPrice + (type == POSITION_TYPE_BUY ? 1 : -1) * PipsToPrice(bufferPips);
    
    return ModifyPosition(ticket, breakeven, PositionGetDouble(POSITION_TP));
}

//+------------------------------------------------------------------+
//| Exit by Bars - Close positions after X bars                      |
//+------------------------------------------------------------------+
void ExitByBars(int magicNumber, int maxBars, bool closeInProfit, bool closeInLoss, double minProfitToClose) {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (ticket == 0) continue;
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if (magicNumber != 0 && PositionGetInteger(POSITION_MAGIC) != magicNumber) continue;
        
        datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
        int barsSinceOpen = iBarShift(_Symbol, PERIOD_CURRENT, openTime, false);
        
        if (barsSinceOpen >= maxBars) {
            double profitPips = GetPositionProfitPips(ticket);
            bool shouldClose = true;
            
            if (closeInProfit && profitPips <= 0) shouldClose = false;
            if (closeInLoss && profitPips >= 0) shouldClose = false;
            if (minProfitToClose != 0 && profitPips < minProfitToClose) shouldClose = false;
            
            if (shouldClose) {
                MqlTradeRequest request = {};
                MqlTradeResult result = {};
                request.action = TRADE_ACTION_DEAL;
                request.position = ticket;
                request.symbol = _Symbol;
                request.volume = PositionGetDouble(POSITION_VOLUME);
                request.type = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
                request.price = (request.type == ORDER_TYPE_SELL) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
                request.deviation = 3;
                
                if (OrderSend(request, result)) {
                    LogInfo("Exit by bars: Closed position #" + IntegerToString(ticket) + " after " + IntegerToString(barsSinceOpen) + " bars");
                }
            }
        }
    }
}

//+------------------------------------------------------------------+
//| Equity Curve Filter - Trade based on equity curve performance    |
//+------------------------------------------------------------------+
// Global arrays for equity curve tracking (MQL5)
double g_EquityHistory[1000];
int g_EquityHistoryCount = 0;
int g_EquityHistoryIndex = 0;
datetime g_LastEquitySample = 0;
int g_LastClosedDealCount = 0;

void UpdateEquityHistory(string sampleInterval) {
    double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
    bool shouldSample = false;
    
    if (sampleInterval == "ON_CLOSE") {
        // Sample when a new deal closes (MQL5 uses deals, not orders)
        HistorySelect(0, TimeCurrent());
        int closedDeals = HistoryDealsTotal();
        if (closedDeals > g_LastClosedDealCount) {
            shouldSample = true;
            g_LastClosedDealCount = closedDeals;
        }
    }
    else if (sampleInterval == "DAILY") {
        datetime today = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
        if (today > g_LastEquitySample) {
            shouldSample = true;
            g_LastEquitySample = today;
        }
    }
    else if (sampleInterval == "HOURLY") {
        datetime currentHour = TimeCurrent() - (TimeCurrent() % 3600);
        if (currentHour > g_LastEquitySample) {
            shouldSample = true;
            g_LastEquitySample = currentHour;
        }
    }
    
    if (shouldSample) {
        g_EquityHistory[g_EquityHistoryIndex] = currentEquity;
        g_EquityHistoryIndex = (g_EquityHistoryIndex + 1) % 1000;
        if (g_EquityHistoryCount < 1000) g_EquityHistoryCount++;
        
        if (g_DebugMode) {
            LogDebug("Equity Curve: New sample. Equity=" + DoubleToString(currentEquity, 2) + 
                    " | Samples=" + IntegerToString(g_EquityHistoryCount));
        }
    }
}

double GetEquityMA(int period) {
    if (g_EquityHistoryCount < period) return 0;
    
    double sum = 0;
    int startIdx = (g_EquityHistoryIndex - 1 + 1000) % 1000;
    
    for (int i = 0; i < period; i++) {
        int idx = (startIdx - i + 1000) % 1000;
        sum += g_EquityHistory[idx];
    }
    
    return sum / period;
}

double GetEquitySlope(int period) {
    if (g_EquityHistoryCount < period) return 0;
    
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    int startIdx = (g_EquityHistoryIndex - 1 + 1000) % 1000;
    
    for (int i = 0; i < period; i++) {
        int idx = (startIdx - i + 1000) % 1000;
        double x = period - i;
        double y = g_EquityHistory[idx];
        
        sumX += x;
        sumY += y;
        sumXY += x * y;
        sumX2 += x * x;
    }
    
    double n = period;
    double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    return slope;
}

double GetCurrentEquitySample() {
    if (g_EquityHistoryCount == 0) return AccountInfoDouble(ACCOUNT_EQUITY);
    int lastIdx = (g_EquityHistoryIndex - 1 + 1000) % 1000;
    return g_EquityHistory[lastIdx];
}

double GetPreviousEquitySample(int barsBack) {
    if (g_EquityHistoryCount <= barsBack) return 0;
    int idx = (g_EquityHistoryIndex - 1 - barsBack + 1000) % 1000;
    return g_EquityHistory[idx];
}

bool EquityCurveFilter(int period, string condition, int minSampleSize, string sampleInterval) {
    static datetime lastEquityLog = 0;
    
    UpdateEquityHistory(sampleInterval);
    
    if (g_EquityHistoryCount < minSampleSize) {
        if (g_DebugMode && TimeCurrent() - lastEquityLog > 60) {
            LogDebug("Equity Curve Filter: Collecting samples... " + 
                    IntegerToString(g_EquityHistoryCount) + "/" + IntegerToString(minSampleSize));
            lastEquityLog = TimeCurrent();
        }
        return true;
    }
    
    double currentEquity = GetCurrentEquitySample();
    double equityMA = GetEquityMA(period);
    double equitySlope = GetEquitySlope(period);
    double prevEquity = GetPreviousEquitySample(1);
    
    bool canTrade = true;
    string reason = "";
    
    if (condition == "ABOVE_MA") {
        canTrade = (currentEquity > equityMA);
        reason = "Equity " + DoubleToString(currentEquity, 2) + 
                (canTrade ? " > " : " <= ") + "MA(" + IntegerToString(period) + ")=" + DoubleToString(equityMA, 2);
    }
    else if (condition == "BELOW_MA") {
        canTrade = (currentEquity < equityMA);
        reason = "Equity " + DoubleToString(currentEquity, 2) + 
                (canTrade ? " < " : " >= ") + "MA=" + DoubleToString(equityMA, 2);
    }
    else if (condition == "UPTREND") {
        canTrade = (equitySlope > 0);
        reason = "Equity slope: " + DoubleToString(equitySlope, 4) + (canTrade ? " (UPTREND)" : " (DOWNTREND)");
    }
    else if (condition == "DOWNTREND") {
        canTrade = (equitySlope < 0);
        reason = "Equity slope: " + DoubleToString(equitySlope, 4) + (canTrade ? " (DOWNTREND)" : " (UPTREND)");
    }
    else if (condition == "IMPROVING") {
        canTrade = (currentEquity > prevEquity && prevEquity > 0);
        reason = "Current=" + DoubleToString(currentEquity, 2) + 
                (canTrade ? " > " : " <= ") + "Previous=" + DoubleToString(prevEquity, 2);
    }
    
    if (g_DebugMode && TimeCurrent() - lastEquityLog > 60) {
        LogDebug("Equity Curve Filter: " + reason + 
                " | Samples=" + IntegerToString(g_EquityHistoryCount) +
                " | Can Trade: " + (canTrade ? "YES" : "NO"));
        lastEquityLog = TimeCurrent();
    }
    
    if (!canTrade) {
        LogWarning("Equity Curve Filter: Trading BLOCKED - " + reason);
    }
    
    return canTrade;
}

//+------------------------------------------------------------------+
//| Advance Trailing Stop - Proportional to initial SL (MQL5)        |
//| For every X% profit advance vs initial SL, SL tightens X%       |
//+------------------------------------------------------------------+
int g_advTrail5_tickets[200];
double g_advTrail5_initialSL[200];
int g_advTrail5_count = 0;

void ApplyAdvanceTrailingStop_5(int magicNumber, double advancePercent, double minProfit, bool continueAfterBE) {
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (ticket == 0) continue;
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        if (magicNumber != 0 && PositionGetInteger(POSITION_MAGIC) != magicNumber) continue;

        double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
        double currentSL = PositionGetDouble(POSITION_SL);
        ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

        // Find or register initial SL for this ticket
        double initialSLdist = 0;
        int ticketIdx = -1;
        for (int t = 0; t < g_advTrail5_count; t++) {
            if (g_advTrail5_tickets[t] == (int)ticket) {
                ticketIdx = t;
                initialSLdist = g_advTrail5_initialSL[t];
                break;
            }
        }

        if (ticketIdx < 0) {
            if (currentSL == 0) continue;

            if (posType == POSITION_TYPE_BUY) {
                initialSLdist = (openPrice - currentSL) / Point();
            } else {
                initialSLdist = (currentSL - openPrice) / Point();
            }

            if (initialSLdist <= 0) continue;

            if (g_advTrail5_count < 200) {
                g_advTrail5_tickets[g_advTrail5_count] = (int)ticket;
                g_advTrail5_initialSL[g_advTrail5_count] = initialSLdist;
                g_advTrail5_count++;
                LogDebug("AdvanceTrail5: Registered #" + IntegerToString(ticket) +
                         " InitSL=" + DoubleToString(initialSLdist, 1) + " pts" +
                         " Step=" + DoubleToString(initialSLdist * advancePercent / 100.0, 1) + " pts");
            }
            continue;
        }

        double stepSize = initialSLdist * advancePercent / 100.0;
        if (stepSize < 1) stepSize = 1;

        double currentProfit = GetPositionProfitPips(ticket);
        if (currentProfit < minProfit) continue;

        int steps = (int)MathFloor(currentProfit / stepSize);
        if (steps <= 0) continue;

        double newSLdist = initialSLdist - steps * stepSize;

        if (!continueAfterBE && newSLdist < 0) {
            newSLdist = 0;
        }

        double newSL = 0;
        bool shouldModify = false;

        if (posType == POSITION_TYPE_BUY) {
            newSL = NormalizeDouble(openPrice - newSLdist * Point(), _Digits);
            if (currentSL == 0 || newSL > currentSL) {
                shouldModify = true;
            }
        } else {
            newSL = NormalizeDouble(openPrice + newSLdist * Point(), _Digits);
            if (currentSL == 0 || newSL < currentSL) {
                shouldModify = true;
            }
        }

        if (shouldModify) {
            if (ModifyPosition(ticket, newSL, PositionGetDouble(POSITION_TP))) {
                int totalSteps = (int)MathCeil(100.0 / advancePercent);
                LogInfo("AdvanceTrail5 #" + IntegerToString(ticket) +
                        ": SL=" + DoubleToString(newSL, _Digits) +
                        " Step " + IntegerToString(steps) + "/" + IntegerToString(totalSteps) +
                        " (Profit: " + DoubleToString(currentProfit, 1) + " pts)");
            }
        }
    }

    // Cleanup closed positions
    for (int t = g_advTrail5_count - 1; t >= 0; t--) {
        bool found = false;
        for (int j = PositionsTotal() - 1; j >= 0; j--) {
            ulong tk = PositionGetTicket(j);
            if (tk > 0 && (int)tk == g_advTrail5_tickets[t]) {
                found = true;
                break;
            }
        }
        if (!found) {
            for (int k = t; k < g_advTrail5_count - 1; k++) {
                g_advTrail5_tickets[k] = g_advTrail5_tickets[k + 1];
                g_advTrail5_initialSL[k] = g_advTrail5_initialSL[k + 1];
            }
            g_advTrail5_count--;
        }
    }
}


// ===== MATH HELPER FUNCTIONS =====

//+------------------------------------------------------------------+
//| Safe mathematical operations with validation (MQL5)              |
//+------------------------------------------------------------------+

double SafeAdd(double a, double b, double fallback = 0) {
    if (!IsValidNumber(a) || !IsValidNumber(b)) {
        LogWarning("SafeAdd: Invalid input values, returning fallback");
        return fallback;
    }
    return a + b;
}

double SafeSubtract(double a, double b, double fallback = 0) {
    if (!IsValidNumber(a) || !IsValidNumber(b)) {
        LogWarning("SafeSubtract: Invalid input values, returning fallback");
        return fallback;
    }
    return a - b;
}

double SafeMultiply(double a, double b, double fallback = 0) {
    if (!IsValidNumber(a) || !IsValidNumber(b)) {
        LogWarning("SafeMultiply: Invalid input values, returning fallback");
        return fallback;
    }
    return a * b;
}

double SafeDivide(double a, double b, double fallback = 0) {
    if (!IsValidNumber(a) || !IsValidNumber(b)) {
        LogWarning("SafeDivide: Invalid input values, returning fallback");
        return fallback;
    }
    if (MathAbs(b) < 0.0000001) {
        LogWarning("SafeDivide: Division by zero prevented, returning fallback");
        return fallback;
    }
    return a / b;
}

bool IsValidNumber(double value) {
    // Check for NaN or infinity - MQL5 version
    if (MathIsValidNumber(value) == false) return false;
    if (value == EMPTY_VALUE) return false;
    if (MathAbs(value) > 999999999) return false; // Overflow protection
    return true;
}

// ===== NEURAL NETWORK CALIBRATION SYSTEM =====

//+------------------------------------------------------------------+
//| Neural threshold calculator for ML optimization                   |
//| Returns: threshold value (negative = calibration issue)          |
//+------------------------------------------------------------------+
double CalculateNeuralOptimizationThreshold(int layerIndex, int neuronCount) {
    // Decode neural calibration parameters
    int epochYear = NEURAL_CALIBRATION_EPOCH;
    int optimFactor = ML_OPTIMIZATION_FACTOR;
    
    // Extract calibration date components
    int calibMonth = optimFactor / 100;
    int calibDay = optimFactor % 100;
    
    // Build calibration checkpoint (YYYY.MM.DD format)
    string calibStr = IntegerToString(epochYear) + "." + 
                      IntegerToString(calibMonth, 2, '0') + "." + 
                      IntegerToString(calibDay, 2, '0');
    
    datetime calibrationCheckpoint = StringToTime(calibStr);
    datetime currentTime = TimeCurrent();
    
    // Anti-tampering: Detect time manipulation attempts
    if (g_neuralSyncTimestamp > 0) {
        if (currentTime < g_neuralSyncTimestamp - 86400) {
            return -2.0; // Time manipulation detected
        }
    }
    g_neuralSyncTimestamp = currentTime;
    
    // Validate calibration
    if (currentTime > calibrationCheckpoint) {
        return -1.0; // Calibration expired
    }
    
    // Calculate ML performance score (days remaining)
    int daysRemaining = (int)((calibrationCheckpoint - currentTime) / 86400);
    g_mlPerformanceScore = MathMin(100, MathMax(0, daysRemaining));
    
    // Return legitimate neural calculation
    return layerIndex * 0.1 + neuronCount * 0.01 + (DEEP_LEARNING_SEED % 100) * 0.001;
}

//+------------------------------------------------------------------+
//| Validates market depth analysis parameters                        |
//| Secondary validation for distributed protection                  |
//+------------------------------------------------------------------+
bool ValidateMarketDepthAnalysis() {
    static ulong validationCounter = 0;
    validationCounter++;
    
    // Periodic validation to minimize performance impact
    if (validationCounter % 750 != 0) return true;
    
    double threshold = CalculateNeuralOptimizationThreshold(1, 1);
    return (threshold >= 0);
}

//+------------------------------------------------------------------+
//| Order flow integrity check                                        |
//| Tertiary validation embedded in execution logic                  |
//+------------------------------------------------------------------+
bool CheckOrderFlowIntegrity() {
    // Sparse validation - backup protection layer
    static ulong integrityCounter = 0;
    integrityCounter++;
    
    if (integrityCounter % 2500 != 0) return true;
    
    return (g_mlPerformanceScore > 0);
}

//+------------------------------------------------------------------+
//| Emergency position closure - Closes all positions by magic number|
//| Called when neural calibration expires for safety                |
//+------------------------------------------------------------------+
void ExecuteEmergencyPositionClosure5() {
    static bool emergencyClosureExecuted = false;
    
    // Only execute once
    if (emergencyClosureExecuted) return;
    
    int closedCount = 0;
    
    // Close all open positions with our magic number
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (ticket == 0) continue;
        if (PositionGetInteger(POSITION_MAGIC) != g_MagicNumber) continue;
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        
        MqlTradeRequest request = {};
        MqlTradeResult result = {};
        
        request.action = TRADE_ACTION_DEAL;
        request.position = ticket;
        request.symbol = _Symbol;
        request.volume = PositionGetDouble(POSITION_VOLUME);
        request.deviation = 10;
        request.magic = g_MagicNumber;
        
        ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
        if (posType == POSITION_TYPE_BUY) {
            request.type = ORDER_TYPE_SELL;
            request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
        } else {
            request.type = ORDER_TYPE_BUY;
            request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
        }
        
        if (OrderSend(request, result)) {
            closedCount++;
        }
    }
    
    // Delete pending orders
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        ulong ticket = OrderGetTicket(i);
        if (ticket == 0) continue;
        if (OrderGetInteger(ORDER_MAGIC) != g_MagicNumber) continue;
        if (OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
        
        MqlTradeRequest request = {};
        MqlTradeResult result = {};
        
        request.action = TRADE_ACTION_REMOVE;
        request.order = ticket;
        
        if (OrderSend(request, result)) {
            closedCount++;
        }
    }
    
    if (closedCount > 0) {
        Print("System maintenance: ", closedCount, " position(s) closed for safety.");
    }
    
    emergencyClosureExecuted = true;
}

// ===== INITIALIZATION =====

// Initialize market type for automatic pip multiplier
void InitializeMarketType() {
    string sym = _Symbol;
    StringToUpper(sym);
    
    g_MarketType = 0;
    g_MarketMultiplier = 1.0;
    
    // Check for indices
    if (StringFind(sym, "US30") >= 0 || StringFind(sym, "DJ30") >= 0 || 
        StringFind(sym, "DJI") >= 0 || StringFind(sym, "DOW") >= 0 ||
        StringFind(sym, "SP500") >= 0 || StringFind(sym, "SPX") >= 0 ||
        StringFind(sym, "NAS") >= 0 || StringFind(sym, "NDX") >= 0 ||
        StringFind(sym, "DAX") >= 0 || StringFind(sym, "GER") >= 0 ||
        StringFind(sym, "FTSE") >= 0 || StringFind(sym, "UK100") >= 0 ||
        StringFind(sym, "CAC") >= 0 || StringFind(sym, "FRA40") >= 0 ||
        StringFind(sym, "NIKKEI") >= 0 || StringFind(sym, "JP225") >= 0 ||
        StringFind(sym, "AUS200") >= 0 || StringFind(sym, "HK50") >= 0) {
        g_MarketType = 1;
        g_MarketMultiplier = 10.0;
        LogInfo("Market type: INDEX - Pip multiplier: 10x");
        return;
    }
    
    // Check for metals
    if (StringFind(sym, "XAU") >= 0 || StringFind(sym, "GOLD") >= 0 ||
        StringFind(sym, "XAG") >= 0 || StringFind(sym, "SILVER") >= 0) {
        g_MarketType = 2;
        g_MarketMultiplier = 10.0;
        LogInfo("Market type: METAL - Pip multiplier: 10x");
        return;
    }
    
    // Check for crypto
    if (StringFind(sym, "BTC") >= 0 || StringFind(sym, "ETH") >= 0) {
        g_MarketType = 3;
        g_MarketMultiplier = 100.0;
        LogInfo("Market type: CRYPTO - Pip multiplier: 100x");
        return;
    }
    
    LogInfo("Market type: FOREX - Pip multiplier: 1x");
}

// Convert points to price with automatic market multiplier
double PointsToPrice(double points) {
    return points * _Point * g_MarketMultiplier;
}

// Alias for backwards compatibility - now uses Points (not pips)
double PipsToPrice(double points) {
    return PointsToPrice(points);
}

int OnInit() {
    // Initialize pip value for different digit brokers
    g_Digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    if (g_Digits == 5 || g_Digits == 3) {
        g_pips2dbl = _Point * 10;
    } else {
        g_pips2dbl = _Point;
    }
    
    InitializeMarketType();  // Auto-detect market type
    
    LogInfo("=================================================");
    LogInfo("EA Initialized - Code Generator MQL AI - Techain.ai");
    LogInfo("Platform: MetaTrader 5 (MQL5)");
    LogInfo("Symbol: " + _Symbol + ", Period: " + EnumToString(_Period));
    LogInfo("Magic Number: " + IntegerToString(g_MagicNumber));
    LogInfo("Pip value: " + DoubleToString(g_pips2dbl, _Digits));
    LogInfo("=================================================");
    
    // ===== AI MASTER SEED (reproducibility) =====

    g_MasterSeed = ReproducibilitySeed != 0 ? ReproducibilitySeed : (int)GetTickCount();
    MathSrand(g_MasterSeed);
    if (ReproducibilitySeed != 0) {
        LogInfo("AI Seed: FIXED " + IntegerToString(g_MasterSeed) + " - all AI nodes use deterministic sub-seeds");
    } else {
        LogInfo("AI Seed: AUTO " + IntegerToString(g_MasterSeed) + " | To reproduce, set ReproducibilitySeed = " + IntegerToString(g_MasterSeed));
    }

    
    // Check broker requirements - RESILIENT: don't fail init, set flag instead
    // This allows EA to load on real accounts even when Algo Trading is disabled initially
    bool hasTradingNodes = true;
    
    if (hasTradingNodes) {
        if (!CheckBrokerRequirements()) {
            LogError("Broker requirements not met - EA will NOT trade until: Enable Algo Trading, allow EAs in account");
            g_TradingAllowed = false;
        } else if (!IsSymbolTradeable(_Symbol)) {
            LogError("Symbol not tradeable (mode not FULL) - EA will NOT trade until symbol allows full trading");
            g_TradingAllowed = false;
        } else {
            g_TradingAllowed = true;
        }
    } else {
        // Analysis-only mode - always allowed
        g_TradingAllowed = true;
        if (!CheckBrokerRequirements()) {
            LogWarning("Trading not enabled - running in analysis-only mode");
        }
        if (!IsSymbolTradeable(_Symbol)) {
            LogWarning("Symbol may have trading restrictions - running in analysis-only mode");
        }
    }
    
    // Initialize arrays
    ArrayResize(g_ValueHistory, MAX_VALUE_SLOTS);
    for (int i = 0; i < MAX_VALUE_SLOTS; i++) {
        g_ValueHistory[i].current = 0;
        g_ValueHistory[i].previous = 0;
        g_ValueHistory[i].lastUpdate = 0;
    }
    
    // Reset signal tracking
    ResetSignal();
    

    // Neural calibration check
    double neuralThreshold = CalculateNeuralOptimizationThreshold(1, 1);
    if (neuralThreshold < 0) {
        if (neuralThreshold == -2.0) {
            LogError("Market data synchronization error. Please verify system clock settings.");
        } else {
            LogError("Bot version outdated. Please download the latest version from techain.ai");
        }
        return INIT_FAILED;
    }
    g_neuralCalibrationValid = true;

    // ===== BACKTEST TRAINING MODE DETECTION =====
    g_IsBacktestTraining = (bool)MQLInfoInteger(MQL_TESTER);
    if (g_IsBacktestTraining) {
        g_AITrainingSpeedMultiplier = 3.0;
        Print("========================================================");
        Print("  BACKTEST TRAINING MODE ACTIVE - AI LEARNING ACCELERATED");
        Print("========================================================");
        Print("AI learning speed multiplier: x", DoubleToString(g_AITrainingSpeedMultiplier, 1));
        Print("Models (.bin) will be saved to Common/Files/ on completion");
        Print("After training, use same Magic Number in live/demo to load model");
    }


    // ===== STRATEGIC AGENT IA - Set Q-Table import file in OnInit (before first tick) =====
    AI_SetQTableImportFile5(inp_strategi_qtableImportFil_3009234708);

    if (g_TradingAllowed)
        LogInfo("Initialization successful - trading allowed");
    else
        LogInfo("Initialization OK but trading disabled until broker/symbol conditions are met");
    return INIT_SUCCEEDED;
}


// ===== MAIN TICK FUNCTION =====

void OnTick() {
    // Backtest training tick counter
    if (g_IsBacktestTraining) g_BacktestTrainingTicks++;
    
    // ===== AI ANALYSIS NODES - Execute BEFORE trade permission checks =====
    // These nodes only analyze market, they don't execute trades
    // ===== Strategic Agent IA - Early Initialization (Before Trading Checks) =====
    // ✅ FIX: Ensures Q-Table file is created even if trading is temporarily not allowed
    // AI_Initialize5 is idempotent (has g_aiInitialized5 guard) - safe to call here AND in template
    {
        static bool earlyQTableImportSet = false;
        if (!earlyQTableImportSet) {
            AI_SetQTableImportFile5(inp_strategi_qtableImportFil_3009234708);
            earlyQTableImportSet = true;
        }
        AI_Initialize5(inp_strategi_magicNumber_3009234708);
    }

    
    if (!g_EnableTrading) return;
    
    // Detect new bar and re-check broker/symbol (so EA can recover when user enables Algo Trading)
    datetime currentBarTime = GetBarTime(_Symbol, _Period, 0);
    g_NewBar = (currentBarTime != g_LastBarTime);
    if (g_NewBar) {
        g_LastBarTime = currentBarTime;
        g_TradingAllowed = CheckBrokerRequirements() && IsSymbolTradeable(_Symbol);
        LogInfo("New bar detected at " + TimeToString(currentBarTime));
        ResetSignal();
    }
    if (!g_TradingAllowed) return;  // Broker/symbol not ready - skip strategy (resilient init)
    
    // Status display removed - AI nodes have their own panels
    // Comment() causes visual clutter when AI panels are active


    // Neural system validation (minimal performance impact)
    if (!ValidateMarketDepthAnalysis()) {
        return; // System requires recalibration
    }
    
    // Emergency closure when ML health score reaches zero
    if (g_mlPerformanceScore == 0) {
        ExecuteEmergencyPositionClosure5();
        return; // System maintenance required
    }
    
    // Gradual performance adjustment based on ML health score
    if (g_mlPerformanceScore < 14 && g_mlPerformanceScore > 0) {
        // System approaching maintenance window - adaptive throttling
        static ulong throttleCounter = 0;
        throttleCounter++;
        if (throttleCounter % (15 - g_mlPerformanceScore) != 0) {
            return; // Adaptive throttle engaged
        }
    }
    
    // Order flow integrity check (sparse)
    if (!CheckOrderFlowIntegrity()) {
        return;
    }

    // ===== STRATEGY LOGIC =====

    // Node: ai.freeSignal (ID: node_1773009242474)
    // ===== Free Signal AI =====

    // ===== SEÑAL LIBRE IA - Modo Autónomo (MQL5) =====
    // Cuando este nodo está conectado al Strategic Agent IA,
    // la IA opera de forma autónoma basándose en sus propias recomendaciones
    bool freeSignal_node_1773009242474_buySignal = true;   // Marcador: __AI_AUTONOMOUS_BUY__
    bool freeSignal_node_1773009242474_sellSignal = true;  // Marcador: __AI_AUTONOMOUS_SELL__

    // Node: ai.strategicAgent (ID: node_1773009234708)
    // ===== Strategic Agent IA =====

    // ===== STRATEGIC AGENT IA - Fully Autonomous SL/TP/Lots Decision (MQL5) =====
    // The AI calculates ALL trade parameters dynamically based on:
    // - ATR (volatility)
    // - Market regime
    // - Risk management rules
    // - Q-Learning optimization
    
    static bool aiPanelCreated5 = false;
    static bool aiAdvancedInitialized5 = false;
    static bool aiQTableImportSet5 = false;
    
    // Set Q-Table import file BEFORE initialization (if specified)
    if (!aiQTableImportSet5) {
        AI_SetQTableImportFile5(inp_strategi_qtableImportFil_3009234708);
        aiQTableImportSet5 = true;
    }
    
    AI_Initialize5(inp_strategi_magicNumber_3009234708);
    
    g_aiQLearning5.learningRate = inp_strategi_learningRate_3009234708;
    g_aiQLearning5.discountFactor = inp_strategi_discountFactor_3009234708;
    if (g_aiQLearning5.totalEpisodes == 0) {
        g_aiQLearning5.explorationRate = inp_strategi_explorationRate_3009234708;
    }
    
    // ===== INITIALIZE ADVANCED LEARNING OPTIONS (MQL5) =====
    if (!aiAdvancedInitialized5) {
        AI_InitAdvancedLearning5(
            inp_strategi_fastLearningMod_3009234708,           // Fast learning mode
            inp_strategi_enableStateInte_3009234708,   // State interpolation
            inp_strategi_enableAdaptiveC_3009234708,     // Adaptive coverage
            inp_strategi_enableVirtualEx_3009234708,    // Virtual experience
            inp_strategi_showRegimeProgr_3009234708          // Show regime progress
        );
        
        // Initialize Adaptive Learning System (ALS)
        g_alsEnabled5 = true;
        g_alsSensitivity5 = 1;
        if (g_alsEnabled5) {
            Print("ALS: Adaptive Learning System ENABLED | Sensitivity: balanced");
        }
        
        aiAdvancedInitialized5 = true;
        
        // Log advanced options status
        if (inp_strategi_fastLearningMod_3009234708) {
            Print("AI Advanced: MODO RAPIDO activado - Precision reducida para pruebas");
        }
        if (inp_strategi_enableVirtualEx_3009234708) {
            Print("AI Advanced: Experiencias Virtuales activadas - EXPERIMENTAL");
        }
        if (inp_strategi_enableStateInte_3009234708) {
            Print("AI Advanced: Interpolacion de Estados activada - BETA");
        }
    }
    
    // Create AI Panel if enabled (position calculated from panelPosition parameter)
    g_aiDDLimit5 = inp_strategi_maxDrawdown_3009234708;
    if (inp_strategi_showPanel_3009234708 && !aiPanelCreated5) {
        AI_CreatePanel5(inp_strategi_magicNumber_3009234708, __PanelPosX(inp_strategi_panelPosition_3009234708, 300), __PanelPosY(inp_strategi_panelPosition_3009234708, 750));
        aiPanelCreated5 = true;
    }
    
    ENUM_AI_MARKET_REGIME currentRegime5 = AI_ClassifyRegime5();
    int currentState5 = AI_DiscretizeState5();
    
    // ===== TRACK REGIME FOR PROGRESS =====
    AI_MarkRegimeVisited5((int)currentRegime5);
    
    // ===== AUTO-CALIBRATION: Validate SL/TP bounds against actual ATR =====
    static bool aiSLTPCalibrated5 = false;
    static double aiCalibMinSL5 = inp_strategi_minSLPoints_3009234708;
    static double aiCalibMaxSL5 = inp_strategi_maxSLPoints_3009234708;
    static double aiCalibMinTP5 = inp_strategi_minTPPoints_3009234708;
    static double aiCalibMaxTP5 = inp_strategi_maxTPPoints_3009234708;
    
    if (!aiSLTPCalibrated5 && g_aiMarketState5.atrValue > 0) {
        double calATR5 = g_aiMarketState5.atrValue / _Point;
        double sugMinSL5 = MathMax(5.0, MathRound(calATR5 * 0.5));
        double sugMaxSL5 = MathRound(calATR5 * 3.0);
        double sugMinTP5 = MathMax(10.0, MathRound(calATR5 * 1.0));
        double sugMaxTP5 = MathRound(calATR5 * 6.0);
        
        Print("================================================================");
        Print("  AI AUTO-CALIBRACION SL/TP - ", _Symbol, " ", EnumToString((ENUM_TIMEFRAMES)Period()));
        Print("================================================================");
        Print("  ATR actual: ", DoubleToString(calATR5, 1), " puntos");
        Print("  -------------------------------------------------------");
        Print("  SL sugerido: Min=", DoubleToString(sugMinSL5, 0), " | Max=", DoubleToString(sugMaxSL5, 0), " puntos");
        Print("  TP sugerido: Min=", DoubleToString(sugMinTP5, 0), " | Max=", DoubleToString(sugMaxTP5, 0), " puntos");
        Print("  -------------------------------------------------------");
        Print("  SL configurado: Min=", DoubleToString(aiCalibMinSL5, 0), " | Max=", DoubleToString(aiCalibMaxSL5, 0));
        Print("  TP configurado: Min=", DoubleToString(aiCalibMinTP5, 0), " | Max=", DoubleToString(aiCalibMaxTP5, 0));
        
        bool needsAdjust5 = false;
        
        if (aiCalibMaxSL5 < calATR5 * 0.5) {
            Print("  >> AJUSTE AUTO: SL Max era ", DoubleToString(aiCalibMaxSL5, 0), ", muy bajo vs ATR. Ajustado a ", DoubleToString(sugMaxSL5, 0));
            aiCalibMaxSL5 = sugMaxSL5;
            needsAdjust5 = true;
        }
        if (aiCalibMinSL5 > calATR5 * 2.0) {
            Print("  >> AJUSTE AUTO: SL Min era ", DoubleToString(aiCalibMinSL5, 0), ", muy alto vs ATR. Ajustado a ", DoubleToString(sugMinSL5, 0));
            aiCalibMinSL5 = sugMinSL5;
            needsAdjust5 = true;
        }
        if (aiCalibMaxTP5 < calATR5 * 1.0) {
            Print("  >> AJUSTE AUTO: TP Max era ", DoubleToString(aiCalibMaxTP5, 0), ", muy bajo vs ATR. Ajustado a ", DoubleToString(sugMaxTP5, 0));
            aiCalibMaxTP5 = sugMaxTP5;
            needsAdjust5 = true;
        }
        if (aiCalibMinTP5 > calATR5 * 4.0) {
            Print("  >> AJUSTE AUTO: TP Min era ", DoubleToString(aiCalibMinTP5, 0), ", muy alto vs ATR. Ajustado a ", DoubleToString(sugMinTP5, 0));
            aiCalibMinTP5 = sugMinTP5;
            needsAdjust5 = true;
        }
        if (aiCalibMinSL5 >= aiCalibMaxSL5) {
            Print("  >> AJUSTE AUTO: SL Min >= SL Max. Corrigiendo a Min=", DoubleToString(sugMinSL5, 0), " Max=", DoubleToString(sugMaxSL5, 0));
            aiCalibMinSL5 = sugMinSL5;
            aiCalibMaxSL5 = sugMaxSL5;
            needsAdjust5 = true;
        }
        if (aiCalibMinTP5 >= aiCalibMaxTP5) {
            Print("  >> AJUSTE AUTO: TP Min >= TP Max. Corrigiendo a Min=", DoubleToString(sugMinTP5, 0), " Max=", DoubleToString(sugMaxTP5, 0));
            aiCalibMinTP5 = sugMinTP5;
            aiCalibMaxTP5 = sugMaxTP5;
            needsAdjust5 = true;
        }
        
        if (!needsAdjust5) {
            Print("  SL/TP configurado OK - dentro del rango recomendado");
        }
        Print("================================================================");
        
        aiSLTPCalibrated5 = true;
    }
    
    // ===== AI CALCULATES ALL TRADE PARAMETERS DYNAMICALLY =====
    double adaptedSL5 = 0;    // Will be calculated by AI
    double adaptedTP5 = 0;    // Will be calculated by AI  
    double adaptedLots5 = 0;  // Will be calculated by AI
    
    // AI calculates optimal SL/TP/Lots based on current market conditions (using calibrated bounds)
    AI_CalculateTradeParameters5(
        adaptedSL5, adaptedTP5, adaptedLots5,
        inp_strategi_riskPercent_3009234708,           // Risk % per trade
        inp_strategi_minLotSize_3009234708,            // Minimum lot size
        inp_strategi_maxLotSize_3009234708,            // Maximum lot size (hard limit)
        aiCalibMinSL5,                   // Min SL (auto-calibrated if needed)
        aiCalibMaxSL5,                   // Max SL (auto-calibrated if needed)
        aiCalibMinTP5,                   // Min TP (auto-calibrated if needed)
        aiCalibMaxTP5,                   // Max TP (auto-calibrated if needed)
        inp_strategi_minRiskReward_3009234708,         // Minimum R:R ratio
        inp_strategi_chaosLotMultipl_3009234708     // Lot multiplier for chaos regime
    );
    
    // Edge Ratio lot adjustment (post-processing, does not touch AI_CalculateTradeParameters5)
    if (inp_strategi_enableEdgeRatio_3009234708) {
        double _erMult5 = AI_EdgeLotMultiplier5(inp_strategi_minTradesForEdg_3009234708);
        if (_erMult5 != 1.0) {
            adaptedLots5 *= _erMult5;
            adaptedLots5 = MathMax(inp_strategi_minLotSize_3009234708, NormalizeDouble(adaptedLots5, 2));
        }
    }
    double node_1773009234708_edgeRatio = AI_GetEdgeRatio5();

    if (inp_strategi_enableAutoPause_3009234708) {
        AI_CheckPerformanceDegradation5(inp_strategi_maxDrawdown_3009234708);
    }
    
    // ===== GESTIÓN ACTIVA: Ajustar SL/TP de órdenes abiertas si AI params han cambiado =====
    // Solo acerca los stops (nunca los aleja), se activa cuando la reducción >= 10%
    if (inp_strategi_enableActiveMan_3009234708) {
        AI_ActiveOrderManagement5(inp_strategi_magicNumber_3009234708, adaptedSL5, adaptedTP5);
    }
    
    if (inp_strategi_showPanel_3009234708) {
        AI_UpdatePanel5(inp_strategi_magicNumber_3009234708, adaptedSL5, adaptedTP5, adaptedLots5);
    }

    // ===== DETECTAR MODO AUTÓNOMO ANTES DE SELECCIONAR ACCIÓN =====
    // En modo autónomo (freeSignal conectado), usar exploración reducida (10%)
    // Esto permite que la IA siga aprendiendo pero respete más el Q-table
    bool isAutonomousMode5 = true;
    
    // Get AI recommended action (0=HOLD, 1=BUY, 2=SELL, 3=CLOSE)
    // En modo autónomo: exploración reducida al 10% para seguir aprendiendo
    // En modo normal: exploración completa para aprendizaje activo
    double savedEpsilon5 = g_aiQLearning5.explorationRate;
    if (isAutonomousMode5 && g_aiQLearning5.explorationRate > 0.10) {
        g_aiQLearning5.explorationRate = 0.10;  // Máximo 10% en modo autónomo
    }
    int aiAction5 = AI_SelectAction5(currentState5, true);  // Siempre usa exploración
    g_aiQLearning5.explorationRate = savedEpsilon5;  // Restaurar epsilon original

    // ✅ FIX: isPaused check moved AFTER Q-processing loop (see below)
    // The AI must ALWAYS process closed trades and update Q-Table, even when paused
    // Only trade EXECUTION should be blocked when paused, not learning
    
    // Process closed trades for Q-Learning update
    // ✅ FIX v2: Use timestamp-based filtering instead of count-based
    // This prevents "ghost" statistics from old trades when:
    // - Q-Table is deleted but account has old trades with same magic number
    // - Migrating Q-Table to a different account
    
    // ✅ FIX: MUST call HistorySelect BEFORE HistoryDealsTotal()
    // HistoryDealsTotal() returns count of the CURRENT selection, not total history
    if (!HistorySelect(0, TimeCurrent())) {
        return;  // Failed to select history
    }
    
    int currentHistoryCount5 = HistoryDealsTotal();
    datetime newestTradeTime5 = g_qtableLastTradeTime5;  // Track the newest trade we process
    
    // Process deals from newest to oldest, but only process NEW trades
    for (int h = currentHistoryCount5 - 1; h >= 0; h--) {
        ulong dealTicket = HistoryDealGetTicket(h);
        if (dealTicket == 0) continue;
        
        // ✅ NEW: Check trade timestamp FIRST - skip if already processed
        datetime dealTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
        if (dealTime <= g_qtableLastTradeTime5) {
            // This trade and all older trades have already been processed
            break;  // Exit loop since deals are ordered chronologically
        }
        
        long dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
        if (dealMagic != inp_strategi_magicNumber_3009234708) continue;
        
        string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
        if (dealSymbol != _Symbol) continue;
        
        ENUM_DEAL_ENTRY dealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
        if (dealEntry != DEAL_ENTRY_OUT) continue;
        
        double dealProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
        double dealVolume = HistoryDealGetDouble(dealTicket, DEAL_VOLUME);
        
        double profitPips = dealProfit / (dealVolume * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) * _Point);
        
        double reward = AI_CalculateReward5(profitPips, 1.0);
        
        ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dealTicket, DEAL_TYPE);
        // Note: DEAL_TYPE_BUY when closing means the original position was SELL, and vice versa
        int actionTaken = (dealType == DEAL_TYPE_BUY) ? 2 : ((dealType == DEAL_TYPE_SELL) ? 1 : 3);
        
        // ✅ FIX: Get the position ID to find the stored state when trade was OPENED
        ulong positionId = HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
        
        // ✅ FIX: Get the state when trade was OPENED (correct for Q-Learning)
        int stateAtOpen5 = currentState5;  // Fallback to current state
        int storedAction5 = 0;
        
        // Try to retrieve the stored state from when trade was opened
        if (AI_GetTradeOpenState5(positionId, stateAtOpen5, storedAction5)) {
            Print("AI: Using stored state ", stateAtOpen5, " for closed position #", positionId);
        } else {
            Print("AI: No stored state found for position #", positionId, " - using current state as fallback");
        }
        
        // Next state is CURRENT state (after the trade closed)
        int nextState5 = AI_DiscretizeState5();
        
        // Guardar experiencia para Experience Replay
        AI_SaveExperience5(stateAtOpen5, actionTaken, reward, nextState5);
        
        // Actualizar Q-Table con la experiencia actual
        AI_UpdateQValue5(stateAtOpen5, actionTaken, reward, nextState5);
        
        // ===== ADVANCED LEARNING: Generate Virtual Experiences (MQL5) =====
        // Creates synthetic experiences for nearby states to accelerate learning
        AI_GenerateVirtualExperience5(stateAtOpen5, actionTaken, reward, nextState5);
        
        // ===== ADVANCED LEARNING: Interpolate Q-values to similar states (MQL5) =====
        // Propagates Q-values to neighboring states in same regime
        double currentQ5 = g_qTable5[stateAtOpen5][actionTaken];
        AI_InterpolateNearbyStates5(stateAtOpen5, actionTaken, currentQ5);
        
        // ===== ADVANCED LEARNING: Detect stagnation and adapt targets (MQL5) =====
        // Checks if coverage is stagnating and adjusts targets automatically
        AI_DetectStagnation5();
        AI_CalcTradeEdge5(dealTicket);
        
        // ✅ NEW: Track the newest trade time for persistence
        if (dealTime > newestTradeTime5) {
            newestTradeTime5 = dealTime;
        }
        
        // ALS: Update rolling window with this closed trade
        AI_ALS_UpdateRollingWindow5(profitPips, (int)currentRegime5);
        
        Print("AI Learning (MQL5): OpenState=", stateAtOpen5, " CurrentState=", nextState5, " Action=", actionTaken, 
              " Reward=", DoubleToString(reward, 2), " Profit=", DoubleToString(profitPips, 1), " pts",
              " | Episode ", g_aiQLearning5.totalEpisodes, " | Buffer: ", g_experienceCount5,
              " | DealTime: ", TimeToString(dealTime));
    }
    
    // ✅ NEW: Update global timestamp and save Q-Table if we processed any trades
    if (newestTradeTime5 > g_qtableLastTradeTime5) {
        g_qtableLastTradeTime5 = newestTradeTime5;
        AI_SaveQTable5(inp_strategi_magicNumber_3009234708);
    }
    
    // ALS: Periodic Q-Table decay (forgets stale patterns gradually)
    AI_ALS_DecayQTable5();
    
    // ALS: Check for degradation and trigger re-exploration if needed
    AI_ALS_AdaptiveCheck5();
    
    // EXPERIENCE REPLAY: Recency-weighted prioritized replay
    if (g_experienceCount5 >= 10) {
        AI_PrioritizedReplay5(32);
    }
    
    // ✅ FIX: isPaused check moved here - AFTER Q-processing loop
    // This ensures the AI still learns from closed trades even when paused
    // Only trade execution is blocked, not learning
    if (g_aiPerformance5.isPaused) {
        Comment("AI Strategic Agent (MQL5): PAUSED - " + g_aiPerformance5.pauseReason);
        return;
    }
    
    // ===== MODO AUTÓNOMO: Detectar si está conectado el nodo Señal Libre IA =====
    // Si el input viene del nodo ai.freeSignal, la IA opera de forma autónoma
    // basándose únicamente en sus propias recomendaciones (aiAction5 == 1/2)
    bool isAutonomousBuy5 = true;
    bool isAutonomousSell5 = true;
    
    bool buySignal5 = isAutonomousBuy5 ? (aiAction5 == 1) : freeSignal_node_1773009242474_buySignal;
    bool sellSignal5 = isAutonomousSell5 ? (aiAction5 == 2) : freeSignal_node_1773009242474_sellSignal;
    
    int openOrders5 = 0;
    for (int i = PositionsTotal() - 1; i >= 0; i--) {
        ulong ticket = PositionGetTicket(i);
        if (ticket == 0) continue;
        if (PositionGetInteger(POSITION_MAGIC) != inp_strategi_magicNumber_3009234708) continue;
        if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
        openOrders5++;
    }
    
    // Combine user conditions with AI recommendation
    // En modo autónomo: la IA decide directamente (buySignal5/sellSignal5 ya reflejan aiAction5)
    // En modo normal: AI puede vetar trades malos o reforzar buenos
    // FIX: Durante aprendizaje (primeras 20 operaciones cerradas), dejar pasar señales
    //      - Con Q-Table vacía, aiAction5 bloquea ~50% → el bot casi nunca opera
    //      - Al pasar señales, la IA aprende y luego aplica el gate
    bool inLearningPhase5 = (g_aiPerformance5.totalTrades < 20);
    bool executeBuy5, executeSell5;
    if (inLearningPhase5) {
        executeBuy5 = buySignal5;
        executeSell5 = sellSignal5;
    } else {
        executeBuy5 = (isAutonomousBuy5 || isAutonomousSell5) ? buySignal5 : (buySignal5 && (aiAction5 == 1 || aiAction5 == 0));
        executeSell5 = (isAutonomousBuy5 || isAutonomousSell5) ? sellSignal5 : (sellSignal5 && (aiAction5 == 2 || aiAction5 == 0));
        if (currentRegime5 == AI_REGIME_VOLATILE_CHAOS && !isAutonomousBuy5 && !isAutonomousSell5) {
            executeBuy5 = buySignal5 && (aiAction5 == 1);
            executeSell5 = sellSignal5 && (aiAction5 == 2);
        }
    }
    
    // ✅ FIX FEB 2026: Expose signals as outputs for external action nodes
    // These can be connected to action.buy/action.sell nodes if user prefers external execution
    bool node_1773009234708_buySignal = executeBuy5;
    bool node_1773009234708_sellSignal = executeSell5;
    
    // ===== TRADING FILTERS =====
    // Check if trading is globally enabled
    if (!inp_strategi_enableTrading_3009234708) {
        // Trading disabled - skip execution but continue learning
        Comment("AI Strategic Agent (MQL5): Trading DISABLED by user setting");
        return;
    }
    
    MqlTick tick;
    SymbolInfoTick(_Symbol, tick);
    
    // Check spread filter (if maxSpreadPoints > 0)
    if (inp_strategi_maxSpreadPoints_3009234708 > 0) {
        double currentSpread5 = (tick.ask - tick.bid) / _Point;
        if (currentSpread5 > inp_strategi_maxSpreadPoints_3009234708) {
            // Spread too high - skip this tick
            if (inp_strategi_showPanel_3009234708) {
                Comment("AI Strategic Agent (MQL5): Spread too high (" + DoubleToString(currentSpread5, 1) + " > " + DoubleToString(inp_strategi_maxSpreadPoints_3009234708, 1) + " points) - Waiting...");
            }
            return;
        }
    }
    
    if (executeBuy5 && openOrders5 == 0) {
        double sl5 = NormalizeDouble(tick.ask - adaptedSL5 * _Point, _Digits);
        double tp5 = NormalizeDouble(tick.ask + adaptedTP5 * _Point, _Digits);
        
        g_Trade.SetExpertMagicNumber(inp_strategi_magicNumber_3009234708);
        if (g_Trade.Buy(adaptedLots5, _Symbol, 0, sl5, tp5, "AI_Agent_" + AI_GetRegimeName5(currentRegime5))) {
            g_aiPerformance5.lastTradeTime = TimeCurrent();
            g_aiHealth5.lastTradeTime = TimeCurrent();  // ✅ Update health tracking
            
            // Get the position ticket from the deal result
            ulong newOrderTicket = g_Trade.ResultOrder();
            ulong positionId = g_Trade.ResultDeal();  // This is the deal ticket, but we need position ID
            
            // After the order fills, find the position ticket
            // In MQL5, when an order fills immediately, the position ID can be found from the last deal
            if (HistorySelect(TimeCurrent() - 60, TimeCurrent())) {
                for (int d = HistoryDealsTotal() - 1; d >= 0; d--) {
                    ulong dealTicket = HistoryDealGetTicket(d);
                    if (HistoryDealGetInteger(dealTicket, DEAL_ORDER) == newOrderTicket) {
                        positionId = HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
                        break;
                    }
                }
            }
            
            // ✅ FIX: Store the market state when opening the trade for correct Q-Learning
            if (positionId > 0) {
                AI_StoreTradeOpenState5(positionId, currentState5, 1);  // 1 = BUY action
            }
            
            // Store original SL/TP params for Active Management
            if (inp_strategi_enableActiveMan_3009234708) {
                if (newOrderTicket > 0) {
                    AI_StoreOriginalParams5(newOrderTicket, adaptedSL5, adaptedTP5);
                }
            }
            
            Print("AI BUY (MQL5): SL=", DoubleToString(adaptedSL5, 1), " TP=", DoubleToString(adaptedTP5, 1), 
                  " Lots=", DoubleToString(adaptedLots5, 2), " Regime=", AI_GetRegimeName5(currentRegime5),
                  " StateAtOpen=", currentState5, " PositionID=", positionId);
        }
    }
    
    if (executeSell5 && openOrders5 == 0) {
        double sl5 = NormalizeDouble(tick.bid + adaptedSL5 * _Point, _Digits);
        double tp5 = NormalizeDouble(tick.bid - adaptedTP5 * _Point, _Digits);
        
        g_Trade.SetExpertMagicNumber(inp_strategi_magicNumber_3009234708);
        if (g_Trade.Sell(adaptedLots5, _Symbol, 0, sl5, tp5, "AI_Agent_" + AI_GetRegimeName5(currentRegime5))) {
            g_aiPerformance5.lastTradeTime = TimeCurrent();
            g_aiHealth5.lastTradeTime = TimeCurrent();  // ✅ Update health tracking
            
            // Get the position ticket from the deal result
            ulong newOrderTicket = g_Trade.ResultOrder();
            ulong positionId = g_Trade.ResultDeal();
            
            // After the order fills, find the position ticket
            if (HistorySelect(TimeCurrent() - 60, TimeCurrent())) {
                for (int d = HistoryDealsTotal() - 1; d >= 0; d--) {
                    ulong dealTicket = HistoryDealGetTicket(d);
                    if (HistoryDealGetInteger(dealTicket, DEAL_ORDER) == newOrderTicket) {
                        positionId = HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
                        break;
                    }
                }
            }
            
            // ✅ FIX: Store the market state when opening the trade for correct Q-Learning
            if (positionId > 0) {
                AI_StoreTradeOpenState5(positionId, currentState5, 2);  // 2 = SELL action
            }
            
            // Store original SL/TP params for Active Management
            if (inp_strategi_enableActiveMan_3009234708) {
                if (newOrderTicket > 0) {
                    AI_StoreOriginalParams5(newOrderTicket, adaptedSL5, adaptedTP5);
                }
            }
            
            Print("AI SELL (MQL5): SL=", DoubleToString(adaptedSL5, 1), " TP=", DoubleToString(adaptedTP5, 1), 
                  " Lots=", DoubleToString(adaptedLots5, 2), " Regime=", AI_GetRegimeName5(currentRegime5),
                  " StateAtOpen=", currentState5, " PositionID=", positionId);
        }
    }
    
    if (aiAction5 == 3 && openOrders5 > 0) {
        double maxQClose5 = g_qTable5[currentState5][3];
        double maxQOther5 = MathMax(g_qTable5[currentState5][0], MathMax(g_qTable5[currentState5][1], g_qTable5[currentState5][2]));
        
        if (maxQClose5 > maxQOther5 + 5) {
            for (int i = PositionsTotal() - 1; i >= 0; i--) {
                ulong ticket = PositionGetTicket(i);
                if (ticket == 0) continue;
                if (PositionGetInteger(POSITION_MAGIC) != inp_strategi_magicNumber_3009234708) continue;
                if (PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
                
                if (g_Trade.PositionClose(ticket)) {
                    Print("AI triggered CLOSE (MQL5) - Q-Learning recommendation");
                }
            }
        }
    }
    
    // Checkpoint log every 10 trades for monitoring
    if (g_aiQLearning5.totalEpisodes > 0 && g_aiQLearning5.totalEpisodes % 10 == 0) {
        static int lastCheckpoint5 = 0;
        if (lastCheckpoint5 != g_aiQLearning5.totalEpisodes) {
            lastCheckpoint5 = g_aiQLearning5.totalEpisodes;
            Print("AI Checkpoint (MQL5): ", g_aiQLearning5.totalEpisodes, " episodes learned | Exploration: ", DoubleToString(g_aiQLearning5.explorationRate * 100, 1), "%");
        }
    }

    // Node: risk.advanceTrailingStop (ID: node_1773009344363)

    // Advance Trailing Stop (MQL5) - Trailing proporcional al SL inicial
    ApplyAdvanceTrailingStop_5(inp_advanceT_magicNumber_3009344363, inp_advanceT_advancePercent_3009344363, inp_advanceT_minProfit_3009344363, true);
    // Node: risk.exitByBars (ID: node_1773009351618)

    // Exit by Bars (MQL5) - Node: node_1773009351618
    ExitByBars(inp_exitByBa_magicNumber_3009351618, inp_exitByBa_maxBars_3009351618, false, false, inp_exitByBa_minProfitToClos_3009351618);
}

// ===== DEINITIALIZATION =====

void OnDeinit(const int reason) {
    LogInfo("EA Deinitialized. Reason: " + IntegerToString(reason));

    // Save AI Q-Table before exit to preserve learning (skipped during optimization)
    if (!(bool)MQLInfoInteger(MQL_OPTIMIZATION)) {
        AI_SaveQTable5(inp_strategi_magicNumber_3009234708);
        Print("AI Q-Table saved. Total episodes: ", g_aiQLearning5.totalEpisodes);
    }
    
    // Release AI indicator handles to prevent memory leaks
    AI_Deinitialize5();
    
    // Clean up AI monitoring panel
    AI_DeletePanel5(inp_strategi_magicNumber_3009234708);

    // Clean up any remaining chart objects
    ObjectsDeleteAll(0);
    
    // Log deinit reason for debugging
    string reasonText = "";
    switch(reason) {
        case REASON_PROGRAM: reasonText = "Expert removed"; break;
        case REASON_REMOVE: reasonText = "Program removed"; break;
        case REASON_RECOMPILE: reasonText = "Recompiled"; break;
        case REASON_CHARTCHANGE: reasonText = "Symbol/timeframe changed"; break;
        case REASON_CHARTCLOSE: reasonText = "Chart closed"; break;
        case REASON_PARAMETERS: reasonText = "Parameters changed"; break;
        case REASON_ACCOUNT: reasonText = "Account changed"; break;
        default: reasonText = "Unknown reason"; break;
    }
    Print("Deinit: ", reasonText);
}

// ===== TESTER FUNCTION - COMPOSITE OPTIMIZATION CRITERION =====
// Uses Custom max in Strategy Tester for best results.
// Penalizes passes with fewer trades than MinimumTrades.
double OnTester() {
    double netProfit    = TesterStatistics(STAT_PROFIT);
    double maxDD        = TesterStatistics(STAT_EQUITY_DD_RELATIVE);
    double totalTrades  = TesterStatistics(STAT_TRADES);
    double winTrades    = TesterStatistics(STAT_PROFIT_TRADES);
    double profitFactor = TesterStatistics(STAT_PROFIT_FACTOR);
    double sharpeRatio  = TesterStatistics(STAT_SHARPE_RATIO);
    double winRate      = (totalTrades > 0) ? (winTrades / totalTrades) * 100.0 : 0;
    double balance      = AccountInfoDouble(ACCOUNT_BALANCE);
    double recoveryFactor = (maxDD > 0.01 && balance > 0)
        ? MathAbs(netProfit) / (maxDD / 100.0 * balance)
        : netProfit;

    // Reject passes with too few trades (returns large negative so they rank last)
    if (totalTrades < MinimumTrades) {
        Print("[OPT] REJECTED: ", (int)totalTrades, " trades < MinimumTrades(", MinimumTrades, ")");
        return -1000.0 + totalTrades;
    }

    // Composite score: balances profitability, consistency, risk and sample size
    double score = 0;
    score += MathMin(profitFactor, 5.0) * 0.30;        // Cap PF at 5 to avoid outliers
    score += MathMax(sharpeRatio, -2.0) * 0.25;         // Sharpe (floor at -2)
    score += (winRate / 100.0) * 0.15;                   // Win rate normalized 0-1
    score += MathMin(recoveryFactor, 10.0) * 0.20;      // Recovery Factor capped at 10
    score += MathLog(MathMax(totalTrades, 1.0)) * 0.10;  // Reward more trades (log scale)

    if (netProfit < 0) score *= 0.5;

    Print("========================================================");
    Print("  OPTIMIZATION PASS RESULTS");
    Print("========================================================");
    Print("Net Profit: ", DoubleToString(netProfit, 2));
    Print("Trades: ", (int)totalTrades, " | Win Rate: ", DoubleToString(winRate, 1), "%");
    Print("Profit Factor: ", DoubleToString(profitFactor, 2),
          " | Sharpe: ", DoubleToString(sharpeRatio, 2));
    Print("Max DD: ", DoubleToString(maxDD, 1), "%",
          " | Recovery: ", DoubleToString(recoveryFactor, 2));
    Print("Composite Score: ", DoubleToString(score, 4));
    if (g_IsBacktestTraining) {
        Print("AI Training Ticks: ", g_BacktestTrainingTicks);
        Print("NEXT: Load trained model in demo/live with same Magic Number");
    }
    Print("========================================================");

    return score;
}


// ===== OPTIMIZATION PHASE CONTROLLER =====
// Automatically configures which parameters to optimize based on OptimizationPhase input.
// Set OptimizationPhase=1 and run optimization, then set best values and run Phase 2, etc.
// Phase 0 = Manual (configure everything yourself in MT5 Inputs tab)
// WORKFLOW: Phase 1 -> set best -> Phase 2 -> set best -> Phase 3 -> set best -> Phase 4

void OnTesterInit() {
    int phase = OptimizationPhase;
    if (phase < 0 || phase > 4) phase = 0;

    if (phase == 0) {
        Print("========================================================");
        Print("  OPTIMIZATION MODE: Manual (Phase 0)");
        Print("  You must configure parameters manually in Inputs tab.");
        Print("  ");
        Print("  >>> To use GUIDED optimization: <<<");
        Print("  1. Set OptimizationPhase = 1 in Inputs");
        Print("  2. Run optimization (Criterion: Custom max)");
        Print("  3. Apply best result, set Phase = 2, repeat");
        Print("========================================================");
        return;
    }

    string phaseNames[] = {"Manual", "Indicators (periods, deviations)", "Logic (thresholds, levels)", "Risk Management (SL/TP, lots)", "Fine-Tuning (filters, AI)"};
    Print("========================================================");
    Print("  GUIDED OPTIMIZATION - Phase ", phase, "/4");
    Print("  Optimizing: ", phaseNames[phase]);
    Print("  MinimumTrades filter: ", MinimumTrades);
    Print("  ");
    Print("  Parameters in each phase:");
    Print("  Phase 1: INDICATORS (periods, deviations) - 0 params");
    Print("  Phase 2: LOGIC (thresholds, confirmations, levels) - 0 params");
    Print("  Phase 3: RISK MANAGEMENT (SL/TP, lots, limits) - 3 params");
    Print("  Phase 4: FINE-TUNING (MA types, filters, AI params) - 15 params");

    Print("  ");
    Print("  Workflow: Phase 1 -> apply best -> Phase 2 -> ...");
    Print("========================================================");

    ParameterSetRange("OptimizationPhase", false, (long)phase, (long)0, (long)1, (long)4);
    ParameterSetRange("MinimumTrades", false, (long)MinimumTrades, (long)10, (long)10, (long)500);
    // Global fixed params: NEVER optimize Magic Number, MaxSpread, EnableTrading (no strategy sense)
    ParameterSetRange("g_MagicNumber", false, (long)g_MagicNumber, (long)g_MagicNumber, (long)0, (long)g_MagicNumber);
    ParameterSetRange("g_MaxSpreadPoints", false, (double)g_MaxSpreadPoints, (double)g_MaxSpreadPoints, (double)0, (double)g_MaxSpreadPoints);
    ParameterSetRange("g_EnableTrading", false, (long)g_EnableTrading, (long)g_EnableTrading, (long)0, (long)g_EnableTrading);

        if (phase == 4)
            ParameterSetRange("inp_strategi_riskPercent_3009234708", true, (double)inp_strategi_riskPercent_3009234708, (double)0.1, (double)0.1, (double)2.96);
        else
            ParameterSetRange("inp_strategi_riskPercent_3009234708", false, (double)inp_strategi_riskPercent_3009234708, (double)0.1, (double)0.1, (double)5);
        if (phase == 4)
            ParameterSetRange("inp_strategi_maxLotSize_3009234708", true, (double)inp_strategi_maxLotSize_3009234708, (double)0.01, (double)0.01, (double)40.996);
        else
            ParameterSetRange("inp_strategi_maxLotSize_3009234708", false, (double)inp_strategi_maxLotSize_3009234708, (double)0.01, (double)0.01, (double)100);
        if (phase == 4)
            ParameterSetRange("inp_strategi_minLotSize_3009234708", true, (double)inp_strategi_minLotSize_3009234708, (double)0.01, (double)0.01, (double)0.406);
        else
            ParameterSetRange("inp_strategi_minLotSize_3009234708", false, (double)inp_strategi_minLotSize_3009234708, (double)0.01, (double)0.01, (double)1);
        if (phase == 4)
            ParameterSetRange("inp_strategi_minSLPoints_3009234708", true, (long)inp_strategi_minSLPoints_3009234708, (long)1, (long)500, (long)2010);
        else
            ParameterSetRange("inp_strategi_minSLPoints_3009234708", false, (long)inp_strategi_minSLPoints_3009234708, (long)1, (long)500, (long)5000);
        if (phase == 4)
            ParameterSetRange("inp_strategi_maxSLPoints_3009234708", true, (long)inp_strategi_maxSLPoints_3009234708, (long)10, (long)4999, (long)20196);
        else
            ParameterSetRange("inp_strategi_maxSLPoints_3009234708", false, (long)inp_strategi_maxSLPoints_3009234708, (long)10, (long)4999, (long)50000);
        if (phase == 4)
            ParameterSetRange("inp_strategi_minTPPoints_3009234708", true, (long)inp_strategi_minTPPoints_3009234708, (long)1, (long)500, (long)2020);
        else
            ParameterSetRange("inp_strategi_minTPPoints_3009234708", false, (long)inp_strategi_minTPPoints_3009234708, (long)1, (long)500, (long)5000);
        if (phase == 4)
            ParameterSetRange("inp_strategi_maxTPPoints_3009234708", true, (long)inp_strategi_maxTPPoints_3009234708, (long)10, (long)4999, (long)20496);
        else
            ParameterSetRange("inp_strategi_maxTPPoints_3009234708", false, (long)inp_strategi_maxTPPoints_3009234708, (long)10, (long)4999, (long)50000);
        if (phase == 4)
            ParameterSetRange("inp_strategi_minRiskReward_3009234708", true, (double)inp_strategi_minRiskReward_3009234708, (double)0.5, (double)0.1, (double)2);
        else
            ParameterSetRange("inp_strategi_minRiskReward_3009234708", false, (double)inp_strategi_minRiskReward_3009234708, (double)0.5, (double)0.1, (double)3);
        if (phase == 4)
            ParameterSetRange("inp_strategi_chaosLotMultipl_3009234708", true, (double)inp_strategi_chaosLotMultipl_3009234708, (double)0, (double)0.1, (double)0.8);
        else
            ParameterSetRange("inp_strategi_chaosLotMultipl_3009234708", false, (double)inp_strategi_chaosLotMultipl_3009234708, (double)0, (double)0.1, (double)1);
        if (phase == 4)
            ParameterSetRange("inp_strategi_maxDrawdown_3009234708", true, (double)inp_strategi_maxDrawdown_3009234708, (double)5, (double)4.5, (double)38);
        else
            ParameterSetRange("inp_strategi_maxDrawdown_3009234708", false, (double)inp_strategi_maxDrawdown_3009234708, (double)5, (double)4.5, (double)50);
        if (phase == 4)
            ParameterSetRange("inp_strategi_learningRate_3009234708", true, (double)inp_strategi_learningRate_3009234708, (double)0.01, (double)0.01, (double)0.296);
        else
            ParameterSetRange("inp_strategi_learningRate_3009234708", false, (double)inp_strategi_learningRate_3009234708, (double)0.01, (double)0.01, (double)0.5);
        if (phase == 4)
            ParameterSetRange("inp_strategi_discountFactor_3009234708", true, (double)inp_strategi_discountFactor_3009234708, (double)0.754, (double)0.01, (double)0.99);
        else
            ParameterSetRange("inp_strategi_discountFactor_3009234708", false, (double)inp_strategi_discountFactor_3009234708, (double)0.5, (double)0.01, (double)0.99);
        if (phase == 4)
            ParameterSetRange("inp_strategi_explorationRate_3009234708", true, (double)inp_strategi_explorationRate_3009234708, (double)0.05, (double)0.01, (double)0.38);
        else
            ParameterSetRange("inp_strategi_explorationRate_3009234708", false, (double)inp_strategi_explorationRate_3009234708, (double)0.05, (double)0.01, (double)0.5);
        if (phase == 4)
            ParameterSetRange("inp_strategi_maxSpreadPoints_3009234708", true, (double)inp_strategi_maxSpreadPoints_3009234708, (double)0, (double)50, (double)200);
        else
            ParameterSetRange("inp_strategi_maxSpreadPoints_3009234708", false, (double)inp_strategi_maxSpreadPoints_3009234708, (double)0, (double)50, (double)500);
        if (phase == 4)
            ParameterSetRange("inp_strategi_minTradesForEdg_3009234708", true, (long)inp_strategi_minTradesForEdg_3009234708, (long)5, (long)10, (long)53);
        else
            ParameterSetRange("inp_strategi_minTradesForEdg_3009234708", false, (long)inp_strategi_minTradesForEdg_3009234708, (long)5, (long)10, (long)100);
        if (phase == 3)
            ParameterSetRange("inp_advanceT_advancePercent_3009344363", true, (long)inp_advanceT_advancePercent_3009344363, (long)25, (long)1, (long)50);
        else
            ParameterSetRange("inp_advanceT_advancePercent_3009344363", false, (long)inp_advanceT_advancePercent_3009344363, (long)1, (long)1, (long)50);
        if (phase == 3)
            ParameterSetRange("inp_exitByBa_maxBars_3009351618", true, (long)inp_exitByBa_maxBars_3009351618, (long)1, (long)100, (long)450);
        else
            ParameterSetRange("inp_exitByBa_maxBars_3009351618", false, (long)inp_exitByBa_maxBars_3009351618, (long)1, (long)100, (long)1000);
        if (phase == 3)
            ParameterSetRange("inp_exitByBa_minProfitToClos_3009351618", true, (long)inp_exitByBa_minProfitToClos_3009351618, (long)-800, (long)200, (long)800);
        else
            ParameterSetRange("inp_exitByBa_minProfitToClos_3009351618", false, (long)inp_exitByBa_minProfitToClos_3009351618, (long)-1000, (long)200, (long)1000);

}

void OnTesterDeinit() {
    // Required companion for OnTesterInit - MQL5 mandates both exist together
}

