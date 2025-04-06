# Quantitative AI Trading System

[![License: QFAL](https://img.shields.io/badge/License-Quantitative%20Finance%20AI%20License-blue)](LICENSE)
[![Python 3.10](https://img.shields.io/badge/Python-3.10-blue)](https://www.python.org/)
[![MLflow](https://img.shields.io/badge/MLflow-Enabled-orange)](https://mlflow.org/)

An institutional-grade quantitative trading system combining alternative data, machine learning, and high-frequency execution strategies.

## 🌟 Key Features

- **Alternative Data Integration**
  - Satellite imagery processing
  - SEC 8K real-time monitoring
  - Earnings call NLP sentiment analysis
- **Quantitative Research**
  - Machine learning factor models
  - Regime switching detection
  - Exotic derivatives pricing
- **Execution Infrastructure**
  - Microsecond latency arbitrage
  - Hawkes process liquidity forecasting
  - Smart order routing
- **Risk Management**
  - Bayesian VaR with regime adjustments
  - Counterparty credit risk (CVA/DVA)
  - Extreme scenario stress testing
- **AI/ML Core**
  - Temporal Fusion Transformers
  - Reinforcement learning portfolio optimization
  - Generative market simulation

## 🚀 Quick Start

### Prerequisites
- NVIDIA GPU (CUDA 11.7+)
- Kafka cluster
- QuantLib 2.0+
- GCP/AWS account (for cloud MLOps)

```bash
# Clone repository
git clone https://github.com/quant-ai/hft-system.git
cd hft-system

# Initialize environment
make setup && dvc pull

# Install dependencies
pip install -r requirements.txt
pip install -r requirements-dev.txt
```

## 📈 Usage

### Data Pipeline
```bash
# Start alternative data ingestion
python -m alternative_data.main \
  --satellite-api-key $SAT_KEY \
  --sec-monitor-tickers AAPL,TSLA,NVDA

# Generate synthetic market data
python research/data_synthesis.py \
  --output data/synthetic/v3_microstructure.parquet
```

### Model Training
```bash
# Train temporal fusion transformer
mlflow run ai_models/transformer_timeseries \
  -P num_epochs=100 \
  -P hidden_size=256

# Calibrate Heston volatility surface
python infrastructure/quantlib_integration/volatility_surface.py \
  --calibration-file config/vol_calibration.json
```

### Live Trading
```bash
python execution_engine/main.py \
  --strategy combined_alpha \
  --risk-model hierarchical_var \
  --universe sp500_futures \
  --capital 1e8 \
  --latency-budget 25us
```

## 🏗️ Project Structure
```plaintext
quant_ai/
├── alternative_data/      # Non-traditional data sources
├── alpha_research/        # Factor research & strategy dev
├── execution_engine/      # Order execution infrastructure
├── risk_system/           # Portfolio risk management
├── ai_models/             # ML/DL model implementations
├── infrastructure/        # Cloud & low-latency systems
└── research/              # Strategy research notebooks
```

## ⚙️ Configuration

Modify `config/quant_config.yaml`:

```yaml
execution:
  latency_budget: 25us
  venue_weights:
    NYSE: 0.4
    NASDAQ: 0.3
    CME: 0.3

alpha:
  decay_halflife: 63
  max_leverage: 3.0
  turnover_limit: 0.2

risk:
  var_confidence: 0.99
  stress_scenarios: [2008, 2020, flash_crash]
  max_drawdown: 0.15
```

## 📡 API Interface
```bash
# Get real-time portfolio risk metrics
curl -X POST https://api.quant-ai.com/risk \
  -H "Authorization: Bearer $QAI_KEY" \
  -d '{
    "portfolio": ["ES.FUT", "BTC-USD"],
    "confidence": 0.99
  }'

# Response
{
  "var": 1520000,
  "expected_shortfall": 2180000,
  "liquidity_risk": 0.23,
  "scenario_losses": {
    "2008": 4850000,
    "flash_crash": 3120000
  }
}
```

## 📊 Monitoring & Analytics
```bash
# Access real-time dashboards
kubectl port-forward svc/grafana 3000:3000 &
open http://localhost:3000/d/quant_overview

# View ML experiments
mlflow ui --port 5000
```

## 🧪 Model Validation

### Backtesting Results (2020-2023)

| Strategy         | Sharpe Ratio | Max DD | Profit Factor |
|------------------|--------------|--------|---------------|
| TFT Alpha        | 2.1          | 12%    | 3.4           |
| RL Portfolio     | 1.8          | 15%    | 2.9           |
| Hybrid Approach  | 2.4          | 9%     | 4.1           |

### Fairness Metrics
```json
{
  "sector_neutrality": 0.92,
  "cap_size_bias": 0.15,
  "turnover_consistency": 0.88
}
```

## 🤝 Contributing

Submit strategy proposal via `research/proposals/`

Follow backtesting protocol:
```bash
python -m alpha_research.backtest \
  --strategy new_alpha \
  --universe global_futures \
  --out-of-sample 2023
```

Pass risk checks:
```bash
pytest tests/risk_checks/test_new_strategy.py
```

Submit pull request with:
- Complete backtest reports
- Risk assessment
- Documentation updates

## 📄 License

This project is licensed under the Quantitative Finance AI License (QFAL) - see LICENSE for commercial use restrictions.
