import sys
import os
# Correct the path to the backend directory within the project
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend')))

try:
    # Attempt to import the necessary modules
    from ai_models.attention_mechanism import MultiHeadAttention, TemporalAttentionBlock
    print("✓ Successfully imported MultiHeadAttention and TemporalAttentionBlock")
    
    # Test basic initialization
    import tensorflow as tf
    attention = MultiHeadAttention(d_model=64, num_heads=4)
    print("✓ Successfully initialized MultiHeadAttention")
    
    block = TemporalAttentionBlock(d_model=64, num_heads=4, dff=256)
    print("✓ Successfully initialized TemporalAttentionBlock")
    
    print("All tests passed for attention_mechanism.py")
# Let pytest handle exceptions naturally instead of exiting
except Exception as e:
    print(f"✗ Error during test: {str(e)}")
    # Raise the exception again so pytest marks the test as failed
    raise e
