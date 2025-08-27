# LiveKit Cloud Integration Setup

## 🔑 Environment Configuration

Create a `.env` file in your Open WebUI backend directory with your LiveKit API credentials:

```bash
# Navigate to backend directory
cd /Users/shadmanhossain/Desktop/AI\ Projects/aws-bedrock-chatbot/terraform/assets/open-webui/backend

# Create .env file with your LiveKit credentials
cat > .env << 'EOF'
# LiveKit Cloud Configuration
LIVEKIT_API_KEY=your_api_key_here
LIVEKIT_API_SECRET=your_secret_here
LIVEKIT_WS_URL=wss://your-project.livekit.cloud

# Optional: OpenAI API Key for enhanced TTS/LLM
OPENAI_API_KEY=your_openai_key_here
EOF
```

## 🚀 Testing LiveKit Integration

### 1. Restart Backend with LiveKit
```bash
# Stop current backend (Ctrl+C)
# Then restart with environment variables
cd /Users/shadmanhossain/Desktop/AI\ Projects/aws-bedrock-chatbot/terraform/assets/open-webui/backend
uvicorn open_webui.main:app --host 0.0.0.0 --port 8080 --reload
```

### 2. Test LiveKit Status
```bash
curl http://localhost:8080/api/v1/audio/livekit/status
```

Expected response:
```json
{
  "livekit_configured": true,
  "ws_url": "wss://your-project.livekit.cloud",
  "whisper_available": true,
  "active_rooms": 0,
  "rooms": []
}
```

### 3. Create Voice Room
```bash
curl -X POST http://localhost:8080/api/v1/audio/livekit/create-room \
  -H "Content-Type: application/json" \
  -d '{"room_name": "test-voice-room", "participant_name": "user1"}'
```

## 🎯 LiveKit Features

### Real-Time Voice Rooms
- **Multi-participant** voice chat
- **Cloud infrastructure** with global edge servers
- **Automatic scaling** and load balancing
- **Advanced audio processing** (echo cancellation, noise suppression)

### Voice Agent Integration
- **Local Whisper STT** for privacy
- **OpenAI integration** for enhanced LLM responses
- **Real-time transcription** streaming
- **Voice activity detection**

### API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/livekit/status` | GET | Check integration status |
| `/livekit/create-room` | POST | Create new voice room |
| `/livekit/join-room` | POST | Join existing room |
| `/livekit/start-agent` | POST | Start voice agent |
| `/livekit/rooms` | GET | List active rooms |

## 🔧 Frontend Integration

The LiveKit frontend component (`LiveKitVoiceInput.svelte`) provides:

- **Room connection** management
- **Real-time audio** streaming
- **Visual feedback** for connection status
- **Automatic reconnection** handling
- **Voice agent** communication

## 🏗️ Architecture

```
Browser → LiveKit Client → LiveKit Cloud → Voice Agent → Local Whisper → Transcription
```

### Benefits over Basic WebSocket:
- ✅ **Multi-user support**
- ✅ **Global edge network**
- ✅ **Advanced audio processing**
- ✅ **Automatic scaling**
- ✅ **Production-ready infrastructure**

## 🔐 Security

- **JWT tokens** for room access
- **Participant permissions** control
- **Room-level isolation**
- **API key rotation** support

## 📊 Monitoring

LiveKit provides built-in monitoring for:
- **Connection quality**
- **Audio/video metrics**
- **Participant analytics**
- **Usage statistics**

## 🚨 Troubleshooting

### Common Issues:

1. **"livekit_configured": false**
   - Check API keys in `.env` file
   - Verify LIVEKIT_WS_URL format

2. **Connection timeout**
   - Verify LiveKit project is active
   - Check firewall/network settings

3. **Agent not responding**
   - Ensure Whisper model is loaded
   - Check agent logs for errors

### Debug Commands:
```bash
# Check environment variables
env | grep LIVEKIT

# Test API connectivity
curl -H "Authorization: Bearer $LIVEKIT_API_KEY" $LIVEKIT_WS_URL/health

# View backend logs
tail -f logs/app.log | grep -i livekit
```
