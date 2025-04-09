import sys
import os
sys.path.append('/home/ubuntu/AlphaMind/backend')
try:
    from ai_models.attention_mechanism import MultiHeadAttention, TemporalAttentionBlock
    print("✓ Successfully imported MultiHeadAttention and TemporalAttentionBlock")
    
    # Test basic initialization
    import tensorflow as tf
    attention = MultiHeadAttention(d_model=64, num_heads=4)
    print("✓ Successfully initialized MultiHeadAttention")
    
    block = TemporalAttentionBlock(d_model=64, num_heads=4, dff=256)
    print("✓ Successfully initialized TemporalAttentionBlock")
    
    print("All tests passed for attention_mechanism.py")
except Exception as e:
    print(f"✗ Error: {str(e)}")
    sys.exit(1)
