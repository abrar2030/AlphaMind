# AlphaMind API Reference

This document provides a comprehensive reference for the AlphaMind API, which allows you to access market data, execute trades, and leverage AlphaMind's machine learning models.

## Authentication

All API requests require authentication using an API key. You can obtain an API key from the AlphaMind dashboard.

```javascript
const client = new AlphaMind.Client({
  apiKey: 'YOUR_API_KEY',
  environment: 'production' // or 'sandbox' for testing
});
```

## Market Data API

### Get Historical Data

Retrieve historical market data for specified tickers and date range.

**Endpoint:** `GET /api/v1/market-data/historical`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| tickers | string[] | Array of ticker symbols |
| startDate | string | Start date in ISO format (YYYY-MM-DD) |
| endDate | string | End date in ISO format (YYYY-MM-DD) |
| frequency | string | Data frequency: 'tick', '1m', '5m', '1h', '1d' |
| fields | string[] | Data fields to include (default: all) |

**Example Request:**

```javascript
const historicalData = await client.marketData.getHistorical({
  tickers: ['AAPL', 'MSFT', 'GOOGL'],
  startDate: '2023-01-01',
  endDate: '2023-12-31',
  frequency: '1d',
  fields: ['open', 'high', 'low', 'close', 'volume']
});
```

**Example Response:**

```json
{
  "data": [
    {
      "ticker": "AAPL",
      "date": "2023-01-03",
      "open": 130.28,
      "high": 130.90,
      "low": 124.17,
      "close": 125.07,
      "volume": 112117500
    },
    // Additional data points...
  ],
  "metadata": {
    "count": 756,
    "frequency": "1d"
  }
}
```

### Subscribe to Real-time Data

Subscribe to real-time market data for specified tickers.

**Endpoint:** `WebSocket /api/v1/market-data/stream`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| tickers | string[] | Array of ticker symbols |
| fields | string[] | Data fields to include |
| frequency | string | Data frequency: 'tick', '1m', '5m', '1h' |

**Example:**

```javascript
const subscription = await client.marketData.subscribe({
  tickers: ['AAPL', 'MSFT', 'GOOGL'],
  fields: ['bid', 'ask', 'last', 'volume'],
  frequency: 'tick'
});

subscription.on('data', (tick) => {
  console.log(`${tick.ticker} @ ${tick.timestamp}: $${tick.last}`);
});

subscription.on('error', (error) => {
  console.error('Subscription error:', error);
});

// Unsubscribe when done
await subscription.unsubscribe();
```

## Trading API

### Create Order

Place a new order.

**Endpoint:** `POST /api/v1/orders`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| ticker | string | Ticker symbol |
| side | string | 'BUY' or 'SELL' |
| quantity | number | Order quantity |
| orderType | string | 'MARKET', 'LIMIT', 'STOP', 'STOP_LIMIT' |
| price | number | Limit price (required for LIMIT and STOP_LIMIT orders) |
| stopPrice | number | Stop price (required for STOP and STOP_LIMIT orders) |
| timeInForce | string | 'DAY', 'GTC', 'IOC', 'FOK' |

**Example Request:**

```javascript
const order = await client.orders.create({
  ticker: 'AAPL',
  side: 'BUY',
  quantity: 100,
  orderType: 'LIMIT',
  price: 150.00,
  timeInForce: 'DAY'
});
```

**Example Response:**

```json
{
  "id": "ord_12345",
  "ticker": "AAPL",
  "side": "BUY",
  "quantity": 100,
  "orderType": "LIMIT",
  "price": 150.00,
  "timeInForce": "DAY",
  "status": "PENDING",
  "createdAt": "2023-04-08T14:30:00Z"
}
```

### Get Order Status

Retrieve the status of an order.

**Endpoint:** `GET /api/v1/orders/{orderId}`

**Example Request:**

```javascript
const orderStatus = await client.orders.getStatus('ord_12345');
```

**Example Response:**

```json
{
  "id": "ord_12345",
  "ticker": "AAPL",
  "side": "BUY",
  "quantity": 100,
  "filledQuantity": 100,
  "orderType": "LIMIT",
  "price": 150.00,
  "timeInForce": "DAY",
  "status": "FILLED",
  "createdAt": "2023-04-08T14:30:00Z",
  "updatedAt": "2023-04-08T14:30:05Z",
  "fills": [
    {
      "price": 149.95,
      "quantity": 100,
      "timestamp": "2023-04-08T14:30:05Z"
    }
  ]
}
```

### Cancel Order

Cancel an open order.

**Endpoint:** `DELETE /api/v1/orders/{orderId}`

**Example Request:**

```javascript
const result = await client.orders.cancel('ord_12345');
```

**Example Response:**

```json
{
  "id": "ord_12345",
  "status": "CANCELLED",
  "updatedAt": "2023-04-08T14:35:00Z"
}
```

## Portfolio API

### Get Portfolio

Retrieve current portfolio holdings.

**Endpoint:** `GET /api/v1/portfolio`

**Example Request:**

```javascript
const portfolio = await client.portfolio.get();
```

**Example Response:**

```json
{
  "cash": 25000.50,
  "positions": [
    {
      "ticker": "AAPL",
      "quantity": 100,
      "averagePrice": 149.95,
      "marketValue": 15200.00,
      "unrealizedPnL": 205.00
    },
    {
      "ticker": "MSFT",
      "quantity": 50,
      "averagePrice": 280.50,
      "marketValue": 14200.00,
      "unrealizedPnL": 175.00
    }
  ],
  "totalValue": 54400.50,
  "dailyPnL": 380.00
}
```

## AI Models API

### Generate Predictions

Generate price predictions using AlphaMind's machine learning models.

**Endpoint:** `POST /api/v1/models/predict`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| modelType | string | 'TFT', 'RL', 'GAN' |
| tickers | string[] | Array of ticker symbols |
| horizon | number | Forecast horizon in days |
| features | object | Additional features for the model |

**Example Request:**

```javascript
const predictions = await client.models.predict({
  modelType: 'TFT',
  tickers: ['AAPL', 'MSFT', 'GOOGL'],
  horizon: 5,
  features: {
    includeMacroData: true,
    includeSentiment: true
  }
});
```

**Example Response:**

```json
{
  "predictions": [
    {
      "ticker": "AAPL",
      "timestamps": ["2023-04-09", "2023-04-10", "2023-04-11", "2023-04-12", "2023-04-13"],
      "values": [151.20, 152.45, 153.10, 152.80, 154.20],
      "confidence": [0.85, 0.82, 0.78, 0.75, 0.72]
    },
    {
      "ticker": "MSFT",
      "timestamps": ["2023-04-09", "2023-04-10", "2023-04-11", "2023-04-12", "2023-04-13"],
      "values": [285.30, 287.20, 288.50, 290.10, 291.40],
      "confidence": [0.88, 0.85, 0.82, 0.79, 0.76]
    },
    {
      "ticker": "GOOGL",
      "timestamps": ["2023-04-09", "2023-04-10", "2023-04-11", "2023-04-12", "2023-04-13"],
      "values": [108.20, 109.50, 110.30, 111.20, 112.40],
      "confidence": [0.86, 0.83, 0.80, 0.77, 0.74]
    }
  ],
  "modelMetadata": {
    "modelType": "TFT",
    "version": "2.3.0",
    "trainedOn": "2023-03-15",
    "accuracy": 0.87
  }
}
```

### Train Custom Model

Train a custom model on your own data.

**Endpoint:** `POST /api/v1/models/train`

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| modelType | string | 'TFT', 'RL', 'GAN' |
| datasetId | string | ID of the uploaded dataset |
| parameters | object | Model-specific parameters |
| callbackUrl | string | URL to notify when training is complete |

**Example Request:**

```javascript
const trainingJob = await client.models.train({
  modelType: 'TFT',
  datasetId: 'ds_67890',
  parameters: {
    epochs: 100,
    batchSize: 32,
    learningRate: 0.001
  },
  callbackUrl: 'https://your-server.com/model-callback'
});
```

**Example Response:**

```json
{
  "jobId": "job_54321",
  "status": "QUEUED",
  "estimatedCompletionTime": "2023-04-08T16:30:00Z",
  "modelType": "TFT",
  "datasetId": "ds_67890"
}
```

## Error Handling

The API uses standard HTTP status codes to indicate the success or failure of requests.

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 400 | Bad Request - Invalid parameters |
| 401 | Unauthorized - Invalid API key |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |

Error responses include a message and error code:

```json
{
  "error": {
    "code": "invalid_parameter",
    "message": "Invalid ticker symbol: INVALID"
  }
}
```

## Rate Limits

The API enforces rate limits to ensure fair usage:

- Market Data API: 120 requests per minute
- Trading API: 60 requests per minute
- Portfolio API: 60 requests per minute
- AI Models API: 30 requests per minute

Rate limit headers are included in all responses:

```
X-RateLimit-Limit: 120
X-RateLimit-Remaining: 115
X-RateLimit-Reset: 1680973800
```

## Websocket Connections

For real-time data and updates, the API provides WebSocket connections:

```javascript
const socket = client.createWebSocket();

socket.on('connect', () => {
  console.log('Connected to AlphaMind WebSocket');
});

socket.on('disconnect', () => {
  console.log('Disconnected from AlphaMind WebSocket');
});

// Subscribe to order updates
socket.subscribe('orders', (update) => {
  console.log('Order update:', update);
});

// Subscribe to portfolio updates
socket.subscribe('portfolio', (update) => {
  console.log('Portfolio update:', update);
});

// Close the connection when done
socket.close();
```
