import sys
import os
sys.path.append('/home/ubuntu/AlphaMind/backend')
try:
    from alpha_research.portfolio_optimization import PortfolioOptimizer
    print("✓ Successfully imported PortfolioOptimizer")
    
    # Test basic initialization
    optimizer = PortfolioOptimizer(n_assets=5)
    print("✓ Successfully initialized PortfolioOptimizer")
    
    print("All tests passed for portfolio_optimization.py")
except Exception as e:
    print(f"✗ Error: {str(e)}")
    sys.exit(1)
