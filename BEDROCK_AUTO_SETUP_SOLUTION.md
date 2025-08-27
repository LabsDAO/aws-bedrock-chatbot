# AWS Bedrock Automatic Connection Setup for New Users

## Problem Investigation

After investigating the OpenWebUI codebase, I identified **3 main reasons** why new users signing up through the OpenWebUI frontend don't automatically have AWS Bedrock models loaded in their connections:

### **Reason 1: Limited User Settings Initialization**
The signup process only initializes default models in user settings but does not configure direct connections. In `terraform/assets/open-webui/backend/open_webui/routers/auths.py` (lines 603-615), the system only sets up the `models` list but **does not configure the direct connections** that would connect to the AWS Bedrock gateway.

### **Reason 2: Direct Connections are User-Specific Settings**
The direct connections (like the AWS Bedrock gateway connection) are stored in user-specific settings under `directConnections`, but this is not automatically configured during user creation. Users need to manually add these connections through the UI.

### **Reason 3: No Automatic Connection Setup for New Users**
There's no mechanism in the user registration process to automatically set up the AWS Bedrock connection with the URL `http://gateway.bedrock.local/api/v1` and the API key from AWS Secrets Manager.

## Solution Implemented

### **1. Created a Helper Function**
Created `terraform/assets/open-webui/backend/open_webui/utils/bedrock_setup.py` to handle AWS Bedrock connection setup for new users, avoiding code duplication.

### **2. Modified User Registration Processes**
Updated all user creation paths to automatically configure AWS Bedrock connections:

#### **Regular Signup** (`auths.py`)
- Modified the signup function to call `setup_bedrock_connection_for_user(user.id)`
- This automatically configures the connection when a new user signs up

#### **OAuth Signup** (`oauth.py`)
- Modified the OAuth user creation process to include automatic connection setup
- Added the helper function call for OAuth users

#### **LDAP Signup** (`auths.py`)
- Modified the LDAP user creation process to include automatic connection setup
- Added the helper function call for LDAP users

#### **Admin User Creation** (`auths.py`)
- Modified the admin user creation process to include automatic connection setup
- Added the helper function call for admin-created users

### **3. AWS Secrets Manager Integration**
The solution automatically retrieves the API key from AWS Secrets Manager using the secret name `bag-api-key-20250725043951908500000004` and configures the connection with:
- URL: `http://gateway.bedrock.local/api/v1`
- API Key: Retrieved from AWS Secrets Manager
- Model IDs: All the Bedrock models specified in your configuration

### **4. Error Handling**
The solution includes proper error handling:
- If AWS Secrets Manager access fails, it falls back to the hardcoded API key
- If the connection setup fails, it logs the error but continues with user creation
- All errors are logged for debugging purposes

## Configuration Details

The automatic connection setup configures:
- **Base URL**: `http://gateway.bedrock.local/api/v1`
- **API Key**: Retrieved from AWS Secrets Manager secret `bag-api-key-20250725043951908500000004`
- **Models**: All Bedrock models including Claude, Llama, Mistral, and Titan models
- **Connection Type**: OpenAI-compatible API endpoint

## Files Modified

1. **`terraform/assets/open-webui/backend/open_webui/utils/bedrock_setup.py`** (NEW)
   - Helper function for AWS Bedrock connection setup

2. **`terraform/assets/open-webui/backend/open_webui/routers/auths.py`**
   - Added automatic connection setup to regular signup
   - Added automatic connection setup to LDAP signup
   - Added automatic connection setup to admin user creation

3. **`terraform/assets/open-webui/backend/open_webui/utils/oauth.py`**
   - Added automatic connection setup to OAuth signup

## Benefits

1. **Automatic Setup**: New users no longer need to manually configure AWS Bedrock connections
2. **Consistent Experience**: All users get the same Bedrock models available immediately
3. **Reduced Admin Overhead**: No manual configuration required for each new user
4. **Secure**: API keys are retrieved from AWS Secrets Manager
5. **Robust**: Includes error handling and fallback mechanisms

## Testing

To test the solution:
1. Deploy the updated code
2. Create a new user through any signup method (regular, OAuth, LDAP, or admin)
3. Verify that the user automatically has AWS Bedrock models available in their connections
4. Check that the connection is properly configured with the correct URL and API key

## Future Enhancements

1. **Configuration Management**: Move the secret name and connection details to environment variables
2. **Model Selection**: Allow admins to configure which models are automatically available
3. **Multiple Connections**: Support for multiple Bedrock endpoints
4. **User Preferences**: Allow users to customize their default model selection 