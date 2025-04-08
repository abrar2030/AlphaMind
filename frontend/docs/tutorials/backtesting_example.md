# AlphaMind Backtesting Framework

This notebook demonstrates how to use AlphaMind's backtesting framework to evaluate trading strategies.

```python
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime
import seaborn as sns

# Set plotting style
plt.style.use('seaborn-v0_8-darkgrid')
sns.set_palette("viridis")

# Load sample data
def load_sample_data(file_path='sample_market_data.csv'):
    """Load sample market data for backtesting"""
    data = pd.read_csv(file_path)
    data['date'] = pd.to_datetime(data['date'])
    return data

# Simple Moving Average Crossover Strategy
class SMACrossoverStrategy:
    """
    Simple Moving Average Crossover Strategy
    
    Parameters:
    -----------
    short_window : int
        Short moving average window
    long_window : int
        Long moving average window
    """
    def __init__(self, short_window=20, long_window=50):
        self.short_window = short_window
        self.long_window = long_window
        self.positions = {}
        
    def generate_signals(self, data):
        """
        Generate trading signals based on SMA crossover
        
        Parameters:
        -----------
        data : DataFrame
            Market data with OHLCV information
            
        Returns:
        --------
        DataFrame with signals (1 for buy, -1 for sell, 0 for hold)
        """
        signals = pd.DataFrame(index=data.index)
        signals['ticker'] = data['ticker']
        signals['date'] = data['date']
        signals['price'] = data['close']
        
        # Calculate moving averages
        signals['short_ma'] = data['close'].rolling(window=self.short_window).mean()
        signals['long_ma'] = data['close'].rolling(window=self.long_window).mean()
        
        # Initialize signal column
        signals['signal'] = 0
        
        # Generate signals
        signals['signal'] = np.where(signals['short_ma'] > signals['long_ma'], 1, 0)
        
        # Generate positions (1, 0, -1)
        signals['position'] = signals['signal'].diff()
        
        return signals
    
# Backtester class
class Backtester:
    """
    Backtester for evaluating trading strategies
    
    Parameters:
    -----------
    strategy : object
        Trading strategy object with generate_signals method
    initial_capital : float
        Initial capital for the backtest
    """
    def __init__(self, strategy, initial_capital=100000.0):
        self.strategy = strategy
        self.initial_capital = initial_capital
        self.results = {}
        
    def run(self, data, ticker):
        """
        Run backtest for a specific ticker
        
        Parameters:
        -----------
        data : DataFrame
            Market data with OHLCV information
        ticker : str
            Ticker symbol to backtest
            
        Returns:
        --------
        DataFrame with backtest results
        """
        # Filter data for the ticker
        ticker_data = data[data['ticker'] == ticker].copy()
        ticker_data = ticker_data.sort_values('date').reset_index(drop=True)
        
        # Generate signals
        signals = self.strategy.generate_signals(ticker_data)
        
        # Create portfolio DataFrame
        portfolio = pd.DataFrame(index=signals.index)
        portfolio['ticker'] = ticker
        portfolio['date'] = signals['date']
        portfolio['price'] = signals['price']
        portfolio['signal'] = signals['signal']
        portfolio['position'] = signals['position']
        
        # Calculate holdings and cash
        portfolio['holdings'] = portfolio['signal'] * portfolio['price']
        portfolio['cash'] = self.initial_capital - (portfolio['position'] * portfolio['price']).cumsum()
        
        # Calculate total value
        portfolio['total'] = portfolio['holdings'] + portfolio['cash']
        
        # Calculate returns
        portfolio['returns'] = portfolio['total'].pct_change()
        
        self.results[ticker] = portfolio
        return portfolio
    
    def run_multiple(self, data, tickers):
        """
        Run backtest for multiple tickers
        
        Parameters:
        -----------
        data : DataFrame
            Market data with OHLCV information
        tickers : list
            List of ticker symbols to backtest
            
        Returns:
        --------
        Dictionary of DataFrames with backtest results for each ticker
        """
        for ticker in tickers:
            self.run(data, ticker)
        return self.results
    
    def calculate_metrics(self):
        """
        Calculate performance metrics for backtest results
        
        Returns:
        --------
        DataFrame with performance metrics for each ticker
        """
        metrics = []
        
        for ticker, portfolio in self.results.items():
            returns = portfolio['returns'].dropna()
            
            # Calculate metrics
            total_return = (portfolio['total'].iloc[-1] / self.initial_capital) - 1
            annual_return = total_return / (len(returns) / 252)  # Assuming 252 trading days per year
            sharpe_ratio = returns.mean() / returns.std() * np.sqrt(252)
            max_drawdown = (portfolio['total'] / portfolio['total'].cummax() - 1).min()
            
            metrics.append({
                'ticker': ticker,
                'total_return': total_return,
                'annual_return': annual_return,
                'sharpe_ratio': sharpe_ratio,
                'max_drawdown': max_drawdown,
                'win_rate': len(returns[returns > 0]) / len(returns)
            })
        
        return pd.DataFrame(metrics)
    
    def plot_results(self, ticker=None):
        """
        Plot backtest results
        
        Parameters:
        -----------
        ticker : str, optional
            Ticker symbol to plot. If None, plots all tickers.
        """
        if ticker:
            tickers = [ticker]
        else:
            tickers = list(self.results.keys())
        
        # Plot equity curves
        plt.figure(figsize=(12, 6))
        
        for ticker in tickers:
            portfolio = self.results[ticker]
            plt.plot(portfolio['date'], portfolio['total'], label=f"{ticker} Equity Curve")
        
        plt.title('Backtest Results - Equity Curve')
        plt.xlabel('Date')
        plt.ylabel('Portfolio Value ($)')
        plt.legend()
        plt.grid(True)
        plt.tight_layout()
        
        # Plot drawdowns
        plt.figure(figsize=(12, 6))
        
        for ticker in tickers:
            portfolio = self.results[ticker]
            drawdown = portfolio['total'] / portfolio['total'].cummax() - 1
            plt.plot(portfolio['date'], drawdown, label=f"{ticker} Drawdown")
        
        plt.title('Backtest Results - Drawdown')
        plt.xlabel('Date')
        plt.ylabel('Drawdown (%)')
        plt.legend()
        plt.grid(True)
        plt.tight_layout()
        
        # Plot moving averages and signals for the first ticker
        ticker = tickers[0]
        portfolio = self.results[ticker]
        signals = self.strategy.generate_signals(data[data['ticker'] == ticker])
        
        plt.figure(figsize=(12, 6))
        plt.plot(signals['date'], signals['price'], label='Price')
        plt.plot(signals['date'], signals['short_ma'], label=f"{self.strategy.short_window}-day SMA")
        plt.plot(signals['date'], signals['long_ma'], label=f"{self.strategy.long_window}-day SMA")
        
        # Plot buy signals
        buy_signals = signals[signals['position'] == 1]
        plt.scatter(buy_signals['date'], buy_signals['price'], marker='^', color='g', s=100, label='Buy')
        
        # Plot sell signals
        sell_signals = signals[signals['position'] == -1]
        plt.scatter(sell_signals['date'], sell_signals['price'], marker='v', color='r', s=100, label='Sell')
        
        plt.title(f'{ticker} - Moving Average Crossover Strategy')
        plt.xlabel('Date')
        plt.ylabel('Price ($)')
        plt.legend()
        plt.grid(True)
        plt.tight_layout()

# Load data
data = load_sample_data()

# Create strategy and backtester
strategy = SMACrossoverStrategy(short_window=20, long_window=50)
backtester = Backtester(strategy, initial_capital=100000.0)

# Run backtest
tickers = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'FB']
results = backtester.run_multiple(data, tickers)

# Calculate metrics
metrics = backtester.calculate_metrics()
print(metrics)

# Plot results
backtester.plot_results()

# Example of optimizing strategy parameters
def optimize_strategy(data, ticker, short_windows, long_windows):
    """
    Optimize strategy parameters
    
    Parameters:
    -----------
    data : DataFrame
        Market data with OHLCV information
    ticker : str
        Ticker symbol to optimize for
    short_windows : list
        List of short window values to test
    long_windows : list
        List of long window values to test
        
    Returns:
    --------
    DataFrame with optimization results
    """
    results = []
    
    for short_window in short_windows:
        for long_window in long_windows:
            if short_window >= long_window:
                continue
                
            strategy = SMACrossoverStrategy(short_window=short_window, long_window=long_window)
            backtester = Backtester(strategy, initial_capital=100000.0)
            backtester.run(data, ticker)
            metrics = backtester.calculate_metrics()
            
            results.append({
                'short_window': short_window,
                'long_window': long_window,
                'total_return': metrics.loc[0, 'total_return'],
                'sharpe_ratio': metrics.loc[0, 'sharpe_ratio'],
                'max_drawdown': metrics.loc[0, 'max_drawdown']
            })
    
    return pd.DataFrame(results)

# Example optimization
short_windows = [5, 10, 15, 20, 25, 30]
long_windows = [30, 40, 50, 60, 70, 80, 90, 100]
optimization_results = optimize_strategy(data, 'AAPL', short_windows, long_windows)

# Find best parameters
best_sharpe = optimization_results.loc[optimization_results['sharpe_ratio'].idxmax()]
best_return = optimization_results.loc[optimization_results['total_return'].idxmax()]

print(f"Best parameters by Sharpe ratio: Short window = {best_sharpe['short_window']}, Long window = {best_sharpe['long_window']}")
print(f"Best parameters by total return: Short window = {best_return['short_window']}, Long window = {best_return['long_window']}")

# Plot optimization results
plt.figure(figsize=(12, 8))
pivot_table = optimization_results.pivot_table(index='short_window', columns='long_window', values='sharpe_ratio')
sns.heatmap(pivot_table, annot=True, cmap='viridis', fmt='.2f')
plt.title('Parameter Optimization - Sharpe Ratio')
plt.tight_layout()
```
