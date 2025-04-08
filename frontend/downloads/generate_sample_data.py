import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from datetime import datetime, timedelta

# Generate sample data for AlphaMind demo
def generate_sample_data(tickers, start_date, end_date, frequency='1d'):
    """
    Generate sample market data for demonstration purposes
    
    Parameters:
    -----------
    tickers : list
        List of ticker symbols
    start_date : str
        Start date in format 'YYYY-MM-DD'
    end_date : str
        End date in format 'YYYY-MM-DD'
    frequency : str
        Data frequency ('1d', '1h', etc.)
        
    Returns:
    --------
    DataFrame with sample market data
    """
    # Convert dates to datetime
    start = datetime.strptime(start_date, '%Y-%m-%d')
    end = datetime.strptime(end_date, '%Y-%m-%d')
    
    # Generate date range
    if frequency == '1d':
        dates = pd.date_range(start=start, end=end, freq='B')  # Business days
    elif frequency == '1h':
        dates = pd.date_range(start=start, end=end, freq='H')
    else:
        raise ValueError(f"Frequency {frequency} not supported")
    
    # Initialize empty dataframe
    data = []
    
    # Generate data for each ticker
    for ticker in tickers:
        # Set random seed based on ticker for reproducibility
        seed = sum(ord(c) for c in ticker)
        np.random.seed(seed)
        
        # Generate base price and volatility
        base_price = np.random.uniform(50, 500)
        volatility = np.random.uniform(0.01, 0.05)
        
        # Generate price series with random walk
        prices = [base_price]
        for i in range(1, len(dates)):
            # Random walk with drift
            change = np.random.normal(0.0002, volatility)
            new_price = prices[-1] * (1 + change)
            prices.append(new_price)
        
        prices = np.array(prices)
        
        # Generate OHLCV data
        for i, date in enumerate(dates):
            price = prices[i]
            open_price = price * np.random.uniform(0.995, 1.005)
            high_price = price * np.random.uniform(1.001, 1.02)
            low_price = price * np.random.uniform(0.98, 0.999)
            volume = int(np.random.uniform(100000, 10000000))
            
            data.append({
                'ticker': ticker,
                'date': date,
                'open': open_price,
                'high': high_price,
                'low': low_price,
                'close': price,
                'volume': volume
            })
    
    # Convert to DataFrame
    df = pd.DataFrame(data)
    
    return df

# Generate sample data
tickers = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'FB']
start_date = '2020-01-01'
end_date = '2023-01-01'
market_data = generate_sample_data(tickers, start_date, end_date)

# Save to CSV
market_data.to_csv('sample_market_data.csv', index=False)

# Create a simple visualization
plt.figure(figsize=(12, 8))

for ticker in tickers:
    ticker_data = market_data[market_data['ticker'] == ticker]
    plt.plot(ticker_data['date'], ticker_data['close'], label=ticker)

plt.title('Sample Stock Price Data (2020-2023)')
plt.xlabel('Date')
plt.ylabel('Price ($)')
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.savefig('sample_price_chart.png')

print(f"Generated sample data for {len(tickers)} tickers from {start_date} to {end_date}")
print(f"Total data points: {len(market_data)}")
print(f"Data saved to 'sample_market_data.csv'")
print(f"Chart saved to 'sample_price_chart.png'")

# Calculate some basic statistics
stats = []
for ticker in tickers:
    ticker_data = market_data[market_data['ticker'] == ticker]
    returns = ticker_data['close'].pct_change().dropna()
    
    stats.append({
        'ticker': ticker,
        'mean_return': returns.mean(),
        'volatility': returns.std(),
        'sharpe': returns.mean() / returns.std() * np.sqrt(252),  # Annualized Sharpe
        'min_price': ticker_data['low'].min(),
        'max_price': ticker_data['high'].max(),
        'avg_volume': ticker_data['volume'].mean()
    })

stats_df = pd.DataFrame(stats)
stats_df.to_csv('sample_statistics.csv', index=False)
print(f"Statistics saved to 'sample_statistics.csv'")
