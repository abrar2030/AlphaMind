import sys
import os
# Correct the path to the backend directory within the project
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend')))

try:
    from alpha_research.portfolio_optimization import PortfolioOptimizer
    print("✓ Successfully imported PortfolioOptimizer")
    
    # Test basic initialization
    optimizer = PortfolioOptimizer(n_assets=5)
    print("✓ Successfully initialized PortfolioOptimizer")
    
    print("All tests passed for portfolio_optimization.py")
# Let pytest handle exceptions naturally instead of exiting
except Exception as e:
    print(f"✗ Error during test: {str(e)}")
    # Raise the exception again so pytest marks the test as failed
    raise e
