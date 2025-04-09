import sys
import os
sys.path.append('/home/ubuntu/AlphaMind/backend')
try:
    from infrastructure.authentication import AuthenticationSystem
    print("✓ Successfully imported AuthenticationSystem")
    
    # Test token generation and verification
    import jwt
    from flask import Flask
    
    app = Flask(__name__)
    auth = AuthenticationSystem(app, 'test-secret-key')
    print("✓ Successfully initialized AuthenticationSystem")
    
    token = auth.generate_token('testuser')
    print("✓ Successfully generated token")
    
    username = auth.verify_token(token)
    if username == 'testuser':
        print("✓ Successfully verified token")
    else:
        print(f"✗ Token verification failed: {username}")
        sys.exit(1)
    
    print("All tests passed for authentication.py")
except Exception as e:
    print(f"✗ Error: {str(e)}")
    sys.exit(1)
