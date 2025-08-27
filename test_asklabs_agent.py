#!/usr/bin/env python3
"""
Test script for AskLabs Voice Agent
"""

import asyncio
import requests
import json

# Configuration
BACKEND_URL = "http://localhost:8080"
ROOM_NAME = "asklabs-test-room"

async def test_asklabs_agent():
    """Test the AskLabs voice agent setup"""
    
    print("🧪 Testing AskLabs Voice Agent")
    print("=" * 50)
    
    # Test 1: Check LiveKit status
    print("\n1. Checking LiveKit status...")
    try:
        response = requests.get(f"{BACKEND_URL}/api/v1/audio/livekit/status")
        if response.status_code == 200:
            status = response.json()
            print(f"✅ LiveKit configured: {status.get('livekit_configured')}")
            print(f"✅ WebSocket URL: {status.get('ws_url')}")
            print(f"✅ Whisper available: {status.get('whisper_available')}")
        else:
            print(f"❌ Status check failed: {response.status_code}")
            return
    except Exception as e:
        print(f"❌ Connection error: {e}")
        return
    
    # Test 2: Create voice room
    print(f"\n2. Creating voice room: {ROOM_NAME}")
    try:
        response = requests.post(
            f"{BACKEND_URL}/api/v1/audio/livekit/create-room",
            json={"room_name": ROOM_NAME, "participant_name": "test-user"}
        )
        if response.status_code == 200:
            room_data = response.json()
            print(f"✅ Room created: {room_data.get('room_name')}")
            print(f"✅ Room SID: {room_data.get('room', {}).get('room_sid')}")
        else:
            print(f"❌ Room creation failed: {response.status_code}")
            return
    except Exception as e:
        print(f"❌ Room creation error: {e}")
        return
    
    # Test 3: Start AskLabs agent
    print(f"\n3. Starting AskLabs voice agent...")
    try:
        response = requests.post(
            f"{BACKEND_URL}/api/v1/audio/livekit/start-agent",
            json={"room_name": ROOM_NAME}
        )
        if response.status_code == 200:
            agent_data = response.json()
            print(f"✅ Agent started: {agent_data.get('message')}")
            print(f"✅ Agent type: {agent_data.get('agent_config', {}).get('agent_type')}")
            print(f"✅ Greeting: {agent_data.get('agent_config', {}).get('greeting')}")
            print(f"✅ Bedrock integration: {agent_data.get('agent_config', {}).get('bedrock_integration')}")
        else:
            print(f"❌ Agent start failed: {response.status_code}")
            print(f"Response: {response.text}")
            return
    except Exception as e:
        print(f"❌ Agent start error: {e}")
        return
    
    # Test 4: List active rooms
    print(f"\n4. Checking active rooms...")
    try:
        response = requests.get(f"{BACKEND_URL}/api/v1/audio/livekit/rooms")
        if response.status_code == 200:
            rooms_data = response.json()
            print(f"✅ Active rooms: {len(rooms_data.get('rooms', []))}")
            for room in rooms_data.get('rooms', []):
                print(f"   - {room}")
        else:
            print(f"❌ Rooms check failed: {response.status_code}")
    except Exception as e:
        print(f"❌ Rooms check error: {e}")
    
    print("\n" + "=" * 50)
    print("🎉 AskLabs Voice Agent Test Complete!")
    print("\nTo test the voice agent:")
    print(f"1. Open your frontend at http://localhost:5174")
    print(f"2. Join the voice room: {ROOM_NAME}")
    print("3. Speak to Labs and hear the greeting: 'Hi, I am Labs, how can I help you?'")
    print("4. Ask questions about LabsDAO, research, or science!")

if __name__ == "__main__":
    asyncio.run(test_asklabs_agent())
