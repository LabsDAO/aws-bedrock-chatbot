# Testing Voice Integration

## Quick Test (No API Keys Required)

The current implementation works **locally** without LiveKit Cloud API keys.

### 1. Test Backend Dependencies

```bash
cd /path/to/open-webui/backend
python -c "
import whisper
import fastapi
import numpy as np
print('✓ All dependencies available')
whisper_model = whisper.load_model('base')
print('✓ Whisper model loaded successfully')
"
```

### 2. Start Open WebUI Backend

```bash
cd /path/to/open-webui/backend
python -m open_webui.main
```

### 3. Test Voice API Endpoints

```bash
# Test voice status endpoint
curl http://localhost:8080/api/v1/audio/voice/status

# Expected response:
# {
#   "whisper_available": true,
#   "active_connections": 0,
#   "model_loaded": "base"
# }
```

### 4. Start Frontend

```bash
cd /path/to/open-webui
npm run dev
```

### 5. Test Voice Input in Browser

1. Open `http://localhost:5173`
2. Look for microphone button in chat interface
3. Click to start recording
4. Speak into microphone
5. Check browser console for WebSocket messages

## For Full LiveKit Cloud Integration (Optional)

If you want **real-time rooms** and **cloud infrastructure**, you'll need LiveKit API keys:

### Get LiveKit API Keys

1. Sign up at [LiveKit Cloud](https://cloud.livekit.io)
2. Create a new project
3. Get your API Key and Secret

### Environment Variables

```bash
# Add to your .env file
LIVEKIT_API_KEY=your_api_key_here
LIVEKIT_API_SECRET=your_secret_here
LIVEKIT_WS_URL=wss://your-project.livekit.cloud
```

### Enhanced LiveKit Integration

```python
# Enhanced version with LiveKit Cloud
import os
from livekit import api

# Initialize LiveKit client
livekit_api = api.LiveKitAPI(
    url=os.getenv('LIVEKIT_WS_URL'),
    api_key=os.getenv('LIVEKIT_API_KEY'),
    api_secret=os.getenv('LIVEKIT_API_SECRET')
)
```

## Debugging Steps

### Check WebSocket Connection

```javascript
// Open browser console and run:
const ws = new WebSocket('ws://localhost:8080/api/v1/audio/ws/voice');
ws.onopen = () => console.log('✓ WebSocket connected');
ws.onerror = (e) => console.log('✗ WebSocket error:', e);
```

### Test Audio Recording

```javascript
// Test microphone access:
navigator.mediaDevices.getUserMedia({ audio: true })
  .then(stream => {
    console.log('✓ Microphone access granted');
    stream.getTracks().forEach(track => track.stop());
  })
  .catch(err => console.log('✗ Microphone error:', err));
```

### Backend Logs

```bash
# Check backend logs for voice integration
tail -f /path/to/open-webui/backend/logs/app.log | grep -i voice
```

## Expected Behavior

### Working Integration:
- ✓ Microphone button appears in chat
- ✓ Click starts recording (button turns red)
- ✓ Speaking generates real-time transcription
- ✓ Transcribed text appears in chat input
- ✓ WebSocket shows connected status

### Common Issues:

1. **No microphone button**: Frontend component not integrated
2. **WebSocket connection failed**: Backend not running or port conflict
3. **No transcription**: Whisper model not loaded or audio format issue
4. **Permission denied**: Browser microphone permissions

## Performance Testing

```bash
# Test with different Whisper models
python -c "
import whisper
import time

models = ['tiny', 'base', 'small']
for model_name in models:
    start = time.time()
    model = whisper.load_model(model_name)
    load_time = time.time() - start
    print(f'{model_name}: {load_time:.2f}s load time')
"
```

## Next Steps After Testing

1. **If basic version works**: You're ready to use voice input!
2. **If you want LiveKit Cloud**: Get API keys and upgrade integration
3. **For production**: Consider GPU acceleration for larger Whisper models
4. **Add TTS**: Implement text-to-speech for complete voice experience
