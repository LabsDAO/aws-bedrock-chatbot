"""
LiveKit Voice Agent for Open WebUI Integration
Handles real-time audio processing with OpenAI Whisper STT
"""

import asyncio
import logging
import os
from typing import Optional

import whisper
from livekit import rtc
from livekit.agents import AutoSubscribe, JobContext, WorkerOptions, cli, llm
from livekit.agents.voice_assistant import VoiceAssistant
from livekit.plugins import openai, silero

logger = logging.getLogger("voice-assistant")

class OpenWebUIVoiceAgent:
    def __init__(self, whisper_model: str = "base"):
        """Initialize the voice agent with Whisper model"""
        self.whisper_model = whisper.load_model(whisper_model)
        self.is_processing = False
        
    async def entrypoint(self, ctx: JobContext):
        """Main entry point for the LiveKit agent"""
        initial_ctx = llm.ChatContext().append(
            role="system",
            text=(
                "You are a voice assistant integrated with Open WebUI. "
                "Your role is to help users interact with their AI models through voice. "
                "Be concise and helpful in your responses."
            ),
        )

        logger.info(f"Connecting to room {ctx.room.name}")
        await ctx.connect(auto_subscribe=AutoSubscribe.AUDIO_ONLY)

        # Wait for the first participant to connect
        participant = await ctx.wait_for_participant()
        logger.info(f"Starting voice assistant for participant {participant.identity}")

        # Initialize voice assistant with Whisper STT
        assistant = VoiceAssistant(
            vad=silero.VAD.load(),
            stt=self._create_whisper_stt(),
            llm=openai.LLM(),
            tts=openai.TTS(),
            chat_ctx=initial_ctx,
        )

        # Start the voice assistant
        assistant.start(ctx.room, participant)

        # Keep the agent running
        await assistant.aclose()

    def _create_whisper_stt(self):
        """Create a custom Whisper STT implementation"""
        class WhisperSTT:
            def __init__(self, model):
                self.model = model
                
            async def recognize(self, audio_data):
                """Transcribe audio using Whisper"""
                try:
                    # Convert audio data to format expected by Whisper
                    result = self.model.transcribe(audio_data)
                    return result["text"].strip()
                except Exception as e:
                    logger.error(f"Whisper transcription error: {e}")
                    return ""
                    
        return WhisperSTT(self.whisper_model)

async def request_fnc(req: llm.ChatRequest) -> None:
    """Handle chat requests from the voice assistant"""
    await req.aclose()

if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    )
    
    # Initialize and run the agent
    agent = OpenWebUIVoiceAgent()
    cli.run_app(
        WorkerOptions(
            entrypoint_fnc=agent.entrypoint,
            request_fnc=request_fnc,
        )
    )
