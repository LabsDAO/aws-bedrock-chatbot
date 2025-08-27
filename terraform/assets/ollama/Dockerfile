FROM ollama/ollama:latest

# Set environment variables
ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_ORIGINS=*

# Expose the Ollama API port
EXPOSE 11434

# Create a non-root user for security (using standard Linux commands)
RUN groupadd -r ollama && \
    useradd -r -g ollama ollama

# Create the .ollama directory and change ownership
RUN mkdir -p /root/.ollama && \
    chown -R ollama:ollama /root/.ollama

# Switch to the ollama user
USER ollama

# Set the working directory
WORKDIR /root

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:11434/api/tags || exit 1

# Default command
CMD ["ollama", "serve"] 