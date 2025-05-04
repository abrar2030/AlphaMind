// Example code for using the AlphaMind API
// This file demonstrates how to access market data and run a simple strategy

// Import required libraries
const AlphaMind = require("alphamind-client");
const { MarketDataClient, StrategyRunner } = AlphaMind;

// Initialize the client with your API key
const client = new AlphaMind.Client({
  apiKey: "YOUR_API_KEY",
  environment: "production", // or 'sandbox' for testing
});

// Connect to market data stream
async function connectToMarketData() {
  const marketData = new MarketDataClient(client);

  // Subscribe to real-time data for specific tickers
  const subscription = await marketData.subscribe({
    tickers: ["AAPL", "MSFT", "GOOGL", "AMZN"],
    fields: ["bid", "ask", "last", "volume"],
    frequency: "tick", // or '1m', '5m', '1h', etc.
  });

  // Handle incoming data
  subscription.on("data", (tick) => {
    console.log(
      `${tick.ticker} @ ${tick.timestamp}: $${tick.last} (Vol: ${tick.volume})`,
    );
    // Process data in your strategy
    runStrategy(tick);
  });

  // Handle errors
  subscription.on("error", (error) => {
    console.error("Market data error:", error);
  });

  return subscription;
}

// Simple moving average crossover strategy
class MovingAverageCrossover {
  constructor(shortPeriod = 10, longPeriod = 50) {
    this.shortPeriod = shortPeriod;
    this.longPeriod = longPeriod;
    this.priceHistory = {};
    this.positions = {};
  }

  // Process new tick data
  processTick(tick) {
    const { ticker, last } = tick;

    // Initialize price history for new ticker
    if (!this.priceHistory[ticker]) {
      this.priceHistory[ticker] = [];
      this.positions[ticker] = "NONE";
    }

    // Add price to history
    this.priceHistory[ticker].push(last);

    // Keep only necessary history
    if (this.priceHistory[ticker].length > this.longPeriod) {
      this.priceHistory[ticker].shift();
    }

    // Check for trading signals if we have enough data
    if (this.priceHistory[ticker].length >= this.longPeriod) {
      this.checkForSignal(ticker);
    }
  }

  // Calculate moving average for a given period
  calculateMA(ticker, period) {
    const prices = this.priceHistory[ticker];
    const slice = prices.slice(prices.length - period);
    const sum = slice.reduce((total, price) => total + price, 0);
    return sum / period;
  }

  // Check for trading signals
  checkForSignal(ticker) {
    const shortMA = this.calculateMA(ticker, this.shortPeriod);
    const longMA = this.calculateMA(ticker, this.longPeriod);

    // Buy signal: short MA crosses above long MA
    if (shortMA > longMA && this.positions[ticker] !== "LONG") {
      console.log(
        `BUY SIGNAL for ${ticker}: Short MA (${shortMA.toFixed(2)}) crossed above Long MA (${longMA.toFixed(2)})`,
      );
      this.positions[ticker] = "LONG";
      // Place buy order
      this.placeOrder(ticker, "BUY");
    }
    // Sell signal: short MA crosses below long MA
    else if (shortMA < longMA && this.positions[ticker] !== "SHORT") {
      console.log(
        `SELL SIGNAL for ${ticker}: Short MA (${shortMA.toFixed(2)}) crossed below Long MA (${longMA.toFixed(2)})`,
      );
      this.positions[ticker] = "SHORT";
      // Place sell order
      this.placeOrder(ticker, "SELL");
    }
  }

  // Place order through AlphaMind API
  async placeOrder(ticker, side) {
    try {
      const order = await client.orders.create({
        ticker,
        side, // 'BUY' or 'SELL'
        quantity: 100,
        orderType: "MARKET",
        timeInForce: "DAY",
      });
      console.log(`Order placed: ${order.id}`);
    } catch (error) {
      console.error("Order placement error:", error);
    }
  }
}

// Initialize and run strategy
async function runStrategy(tick) {
  // Create strategy instance if not exists
  if (!global.strategy) {
    global.strategy = new MovingAverageCrossover(10, 50);
  }

  // Process new tick data
  global.strategy.processTick(tick);
}

// Main function
async function main() {
  try {
    console.log("Connecting to AlphaMind API...");
    await client.connect();

    console.log("Subscribing to market data...");
    const subscription = await connectToMarketData();

    // Handle application shutdown
    process.on("SIGINT", async () => {
      console.log("Shutting down...");
      await subscription.unsubscribe();
      await client.disconnect();
      process.exit(0);
    });
  } catch (error) {
    console.error("Error in main function:", error);
  }
}

// Run the application
main();
