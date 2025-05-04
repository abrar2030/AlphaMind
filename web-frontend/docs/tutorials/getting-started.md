# Getting Started with AlphaMind

This tutorial will guide you through the process of setting up and using AlphaMind for quantitative trading.

## Prerequisites

Before you begin, ensure you have the following:

- Python 3.10 or higher
- pip package manager
- Git
- NVIDIA GPU with CUDA support (recommended for optimal performance)

## Installation

### Step 1: Clone the Repository

First, clone the AlphaMind repository from GitHub:

```bash
git clone https://github.com/abrar2030/AlphaMind.git
cd AlphaMind
```

### Step 2: Install Dependencies

Install the required dependencies using pip:

```bash
pip install -r requirements.txt
```

This will install all the necessary packages, including:

- numpy
- pandas
- tensorflow
- scikit-learn
- gym
- stable-baselines3
- pymc3
- arviz
- sentinelhub
- confluent-kafka
- QuantLib

### Step 3: Set Up Environment Variables

Create a `.env` file in the root directory with your API keys and configuration:

```
# API Keys
SATELLITE_API_KEY=your_satellite_api_key
SEC_API_KEY=your_sec_api_key

# Kafka Configuration
KAFKA_BOOTSTRAP_SERVERS=localhost:9092
KAFKA_SCHEMA_REGISTRY=http://localhost:8081

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=alphamind
DB_USER=user
DB_PASSWORD=password

# Model Configuration
MODEL_SAVE_PATH=./models
```

## Basic Usage

### Importing Market Data

To import historical market data:

```python
from alphamind.data import MarketDataImporter

# Initialize the importer
importer = MarketDataImporter()

# Import daily data for specific tickers
data = importer.import_daily_data(
    tickers=['AAPL', 'MSFT', 'GOOGL'],
    start_date='2020-01-01',
    end_date='2023-01-01'
)

# Save to CSV
data.to_csv('market_data.csv')
```

### Processing Alternative Data

To process satellite imagery data:

```python
from alphamind.alternative_data.satellite_processing import SatelliteProcessor

# Initialize the processor
processor = SatelliteProcessor(api_key='your_satellite_api_key')

# Download and process satellite imagery for retail locations
results = processor.analyze_retail_locations(
    company='WMT',
    start_date='2023-01-01',
    end_date='2023-03-31',
    location_type='parking_lots'
)

# Print results
print(results)
```

### Training a Machine Learning Model

To train a Temporal Fusion Transformer model:

```python
from alphamind.ai_models.transformer_timeseries import TemporalFusionTransformer
import pandas as pd
import numpy as np

# Load your data
data = pd.read_csv('market_data.csv')

# Prepare features and targets
X, y = prepare_data_for_tft(data)

# Split into train and test sets
X_train, X_test = X[:-30], X[-30:]
y_train, y_test = y[:-30], y[-30:]

# Create and train the model
model = TemporalFusionTransformer(
    num_encoder_steps=30,
    num_features=X.shape[2]
)

# Train the model
model.fit(X_train, y_train, epochs=50, batch_size=32, validation_split=0.2)

# Make predictions
predictions = model.predict(X_test)

# Evaluate the model
mse = np.mean((predictions - y_test) ** 2)
print(f"Mean Squared Error: {mse}")
```

### Running a Trading Strategy

To run a simple moving average crossover strategy:

```python
from alphamind.strategies import MovingAverageCrossover
from alphamind.execution_engine import Executor

# Initialize the strategy
strategy = MovingAverageCrossover(
    tickers=['AAPL', 'MSFT', 'GOOGL'],
    short_window=10,
    long_window=50,
    initial_capital=100000
)

# Initialize the executor
executor = Executor(paper_trading=True)

# Run the backtest
results = strategy.backtest(
    start_date='2022-01-01',
    end_date='2023-01-01',
    executor=executor
)

# Print performance metrics
print(f"Total Return: {results.total_return:.2%}")
print(f"Sharpe Ratio: {results.sharpe_ratio:.2f}")
print(f"Max Drawdown: {results.max_drawdown:.2%}")

# Plot equity curve
results.plot_equity_curve()
```

## Advanced Topics

### Implementing a Custom Strategy

You can create your own trading strategy by extending the `Strategy` base class:

```python
from alphamind.strategies import Strategy
import pandas as pd
import numpy as np

class MeanReversionStrategy(Strategy):
    def __init__(self, tickers, lookback=20, z_threshold=2.0, **kwargs):
        super().__init__(tickers=tickers, **kwargs)
        self.lookback = lookback
        self.z_threshold = z_threshold

    def generate_signals(self, data):
        signals = pd.DataFrame(index=data.index, columns=self.tickers)

        for ticker in self.tickers:
            # Calculate z-score of price
            price = data[ticker]['close']
            rolling_mean = price.rolling(self.lookback).mean()
            rolling_std = price.rolling(self.lookback).std()
            z_score = (price - rolling_mean) / rolling_std

            # Generate signals
            signals[ticker] = np.where(z_score < -self.z_threshold, 1,  # Buy signal
                              np.where(z_score > self.z_threshold, -1,  # Sell signal
                              0))  # No signal

        return signals
```

### Using Reinforcement Learning for Portfolio Optimization

To use reinforcement learning for portfolio optimization:

```python
from alphamind.ai_models.reinforcement_learning import PortfolioOptimizer

# Initialize the optimizer
optimizer = PortfolioOptimizer(
    tickers=['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'FB'],
    lookback_window=50,
    risk_aversion=0.5
)

# Train the model
optimizer.train(
    start_date='2018-01-01',
    end_date='2022-01-01',
    total_timesteps=1000000
)

# Generate optimal portfolio weights
weights = optimizer.get_optimal_weights(
    current_prices={
        'AAPL': 150.0,
        'MSFT': 280.0,
        'GOOGL': 2800.0,
        'AMZN': 3300.0,
        'FB': 330.0
    },
    current_portfolio={
        'AAPL': 100,
        'MSFT': 50,
        'GOOGL': 10,
        'AMZN': 5,
        'FB': 20
    }
)

print("Optimal portfolio weights:")
for ticker, weight in weights.items():
    print(f"{ticker}: {weight:.2%}")
```

### Integrating with Kafka for Real-time Data

To process real-time market data from Kafka:

```python
from alphamind.infrastructure.kafka_streaming import MarketDataProcessor
import asyncio

async def process_market_data():
    # Initialize the processor
    processor = MarketDataProcessor(
        bootstrap_servers='localhost:9092',
        schema_registry_url='http://localhost:8081',
        input_topic='market-data-raw',
        output_topic='market-data-processed'
    )

    # Start processing
    await processor.start()

    try:
        # Run for 1 hour
        await asyncio.sleep(3600)
    finally:
        # Stop processing
        await processor.stop()

# Run the processor
asyncio.run(process_market_data())
```

## Troubleshooting

### Common Issues

1. **ImportError: No module named 'alphamind'**

   Make sure you're running Python from the project root directory or add the project to your Python path:

   ```python
   import sys
   sys.path.append('/path/to/AlphaMind')
   ```

2. **CUDA/GPU errors**

   If you encounter GPU-related errors, try setting the environment variable to use CPU only:

   ```bash
   export CUDA_VISIBLE_DEVICES=-1
   ```

3. **Kafka connection issues**

   Ensure Kafka and Schema Registry are running and accessible. Check your firewall settings if running on different machines.

### Getting Help

If you encounter any issues not covered here, please:

1. Check the [GitHub Issues](https://github.com/abrar2030/AlphaMind/issues) page
2. Join our [Discord community](https://discord.gg/alphamind)
3. Contact support at support@alphamind.ai

## Next Steps

Now that you've set up AlphaMind and learned the basics, you can:

1. Explore the [API Reference](/docs/api/api-reference.md) for detailed information on all available functions
2. Check out the [Example Notebooks](/docs/examples/) for more advanced use cases
3. Read our [Research Papers](/research.html) to understand the theory behind our models
4. Contribute to the project by submitting pull requests on GitHub
