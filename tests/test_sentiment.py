import sys
import os
sys.path.append('/home/ubuntu/AlphaMind/backend')
try:
    from alternative_data.sentiment_analysis import MarketSentimentAnalyzer
    print("✓ Successfully imported MarketSentimentAnalyzer")
    
    # Test basic initialization
    analyzer = MarketSentimentAnalyzer()
    print("✓ Successfully initialized MarketSentimentAnalyzer")
    
    print("All tests passed for sentiment_analysis.py")
except Exception as e:
    print(f"✗ Error: {str(e)}")
    sys.exit(1)
