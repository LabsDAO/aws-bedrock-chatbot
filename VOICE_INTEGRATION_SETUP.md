# Voice Integration Setup Guide

This guide explains how to set up and use the LiveKit + OpenAI Whisper voice integration with your Open WebUI instance.

## Prerequisites

- **Node.js 20.16.0+** or **22.3.0+** (current version 18.20.5 needs upgrade)
- **Python 3.11+**
- **Open WebUI** cloned and set up locally

## Installation Steps

### 1. Upgrade Node.js (Required)

Your current Node.js version (18.20.5) is incompatible. Upgrade to 20.16.0+ or 22.3.0+:

```bash
# Using nvm (recommended)
nvm install 22
nvm use 22

# Or using Homebrew
brew install node@22
```

### 2. Install Backend Dependencies

```bash
cd /path/to/open-webui/backend
pip install whisper openai livekit fastapi websockets numpy
```

### 3. Install Frontend Dependencies (after Node.js upgrade)

```bash
cd /path/to/open-webui
npm install livekit-client --legacy-peer-deps
```

## Configuration

### Backend Configuration

The voice integration is automatically enabled when dependencies are available. Key files:

- `backend/open_webui/apps/audio/livekit_voice.py` - Voice processing endpoints
- `backend/open_webui/main.py` - Router integration (already configured)

### Frontend Configuration

Add the voice input component to your chat interface:

```javascript
// In your chat component
import VoiceInput from '$lib/components/chat/VoiceInput.svelte';

// Use in template
<VoiceInput 
  onTranscription={(text) => handleVoiceInput(text)}
  disabled={false}
/>
```

## API Endpoints

### WebSocket Endpoint
- **URL**: `ws://localhost:8080/api/v1/audio/ws/voice`
- **Purpose**: Real-time voice streaming and transcription

### HTTP Endpoints
- **POST** `/api/v1/audio/voice/transcribe` - Upload audio file for transcription
- **GET** `/api/v1/audio/voice/status` - Check voice integration status

## Usage

### Real-time Voice Input

1. Click the microphone button in the chat interface
2. Speak into your microphone
3. Real-time transcription appears as you speak
4. Click again to stop recording

### Keyboard Shortcut

- **Ctrl+Space** - Toggle voice recording

## Features

- **Real-time transcription** using OpenAI Whisper
- **WebSocket streaming** for low-latency audio processing
- **Voice activity detection** with visual feedback
- **Automatic audio optimization** (echo cancellation, noise suppression)
- **Fallback support** - gracefully handles missing dependencies

## Troubleshooting

### Common Issues

1. **Node.js Version Error**
   ```
   Error: Not compatible with your version of node/npm
   ```
   **Solution**: Upgrade to Node.js 20.16.0+ or 22.3.0+

2. **Whisper Model Loading**
   ```
   Failed to load Whisper model
   ```
   **Solution**: Ensure sufficient disk space and internet connection for model download

3. **WebSocket Connection Failed**
   ```
   Voice connection failed
   ```
   **Solution**: Check backend is running and firewall settings

### Debug Commands

```bash
# Check voice integration status
curl http://localhost:8080/api/v1/audio/voice/status

# Test backend dependencies
python -c "import whisper; print('Whisper OK')"

# Check Node.js version
node --version
```

## Development Notes

### Whisper Model Options

Change model size in `livekit_voice.py`:
```python
whisper_model = whisper.load_model("base")  # tiny, base, small, medium, large
```

### Audio Configuration

Modify audio settings in `VoiceInput.svelte`:
```javascript
audio: {
    sampleRate: 16000,      // Whisper optimal rate
    channelCount: 1,        // Mono audio
    echoCancellation: true, // Noise reduction
    noiseSuppression: true  // Background noise filtering
}
```

## Integration with Your AWS Bedrock Setup

The voice integration works seamlessly with your existing AWS Bedrock chatbot:

1. Voice input → Whisper transcription → Chat input
2. Bedrock model processes the text
3. Response displayed in chat interface
4. Optional: Add TTS for voice responses

## Next Steps

1. **Upgrade Node.js** to compatible version
2. **Install dependencies** as outlined above
3. **Test voice functionality** with the provided endpoints
4. **Customize UI** to match your existing design
5. **Add TTS integration** for complete voice experience

## Performance Tips

- Use `tiny` or `base` Whisper models for faster transcription
- Implement audio chunking for long recordings
- Consider GPU acceleration for larger Whisper models
- Monitor WebSocket connection health

The integration is designed to be lightweight and non-intrusive - it won't affect your existing Open WebUI functionality if dependencies are missing.
