import sys
import os
# Correct the path to the backend directory within the project
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'backend')))

try:
    from infrastructure.authentication import AuthenticationSystem
    print("✓ Successfully imported AuthenticationSystem")
    
    # Test token generation and verification
    import jwt
    from flask import Flask
    
    # Create a dummy Flask app context for the test if needed
    # This might be necessary if AuthenticationSystem relies on app context
    app = Flask(__name__)
    app.config["SECRET_KEY"] = "test-secret-key" # Ensure secret key is set
    
    # Use app context
    with app.app_context():
        auth = AuthenticationSystem(app, app.config["SECRET_KEY"])
        print("✓ Successfully initialized AuthenticationSystem")
        
        token = auth.generate_token("testuser")
        print("✓ Successfully generated token")
        
        username = auth.verify_token(token)
        if username == "testuser":
            print("✓ Successfully verified token")
        else:
            # Raise an assertion error instead of exiting
            raise AssertionError(f"Token verification failed: expected 'testuser', got '{username}'")
    
    print("All tests passed for authentication.py")
# Let pytest handle exceptions naturally instead of exiting
except Exception as e:
    print(f"✗ Error during test: {str(e)}")
    # Raise the exception again so pytest marks the test as failed
    raise e
