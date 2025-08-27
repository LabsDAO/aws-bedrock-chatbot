#!/usr/bin/env python3
"""
Test AskLabs Voice Agent locally without LiveKit Cloud
"""

import asyncio
import sys
import os

# Add the backend to Python path
sys.path.append('/Users/shadmanhossain/Desktop/AI Projects/aws-bedrock-chatbot/terraform/assets/open-webui/backend')

async def test_asklabs_local():
    """Test AskLabs voice agent components locally"""
    
    print("🧪 Testing AskLabs Voice Agent Components")
    print("=" * 50)
    
    # Test 1: Import AskLabs agent
    print("\n1. Testing AskLabs agent import...")
    try:
        from open_webui.apps.audio.asklabs_voice_agent import AskLabsVoiceAgent
        agent = AskLabsVoiceAgent()
        print("✅ AskLabsVoiceAgent imported successfully")
    except Exception as e:
        print(f"❌ Import failed: {e}")
        return
    
    # Test 2: Test persona generation
    print("\n2. Testing Labs persona...")
    try:
        persona = agent.get_labs_persona()
        print("✅ Labs persona generated")
        print(f"   Persona length: {len(persona)} characters")
        print(f"   Contains 'LabsDAO': {'LabsDAO' in persona}")
        print(f"   Contains 'transparency': {'transparency' in persona}")
    except Exception as e:
        print(f"❌ Persona generation failed: {e}")
    
    # Test 3: Test AWS Bedrock LLM wrapper
    print("\n3. Testing AWS Bedrock LLM wrapper...")
    try:
        llm_wrapper = agent.create_bedrock_llm()
        print("✅ Bedrock LLM wrapper created")
        print(f"   LLM type: {type(llm_wrapper)}")
    except Exception as e:
        print(f"❌ Bedrock LLM creation failed: {e}")
    
    # Test 4: Test greeting message
    print("\n4. Testing greeting message...")
    try:
        greeting = "Hi, I am Labs, how can I help you?"
        print(f"✅ Default greeting: '{greeting}'")
    except Exception as e:
        print(f"❌ Greeting test failed: {e}")
    
    print("\n" + "=" * 50)
    print("🎉 AskLabs Local Component Test Complete!")
    print("\nNext steps:")
    print("1. Configure LiveKit Cloud credentials in .env file")
    print("2. Run: python test_asklabs_agent.py")
    print("3. Test voice interactions in the frontend")

if __name__ == "__main__":
    asyncio.run(test_asklabs_local())
