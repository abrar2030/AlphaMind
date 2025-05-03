import sys
import os
# Correct the path to the backend directory within the project
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend')))

try:
    from alternative_data.sentiment_analysis import MarketSentimentAnalyzer
    print("✓ Successfully imported MarketSentimentAnalyzer")
    
    # Test basic initialization
    analyzer = MarketSentimentAnalyzer()
    print("✓ Successfully initialized MarketSentimentAnalyzer")
    
    print("All tests passed for sentiment_analysis.py")
# Let pytest handle exceptions naturally instead of exiting
except Exception as e:
    print(f"✗ Error during test: {str(e)}")
    # Raise the exception again so pytest marks the test as failed
    raise e
