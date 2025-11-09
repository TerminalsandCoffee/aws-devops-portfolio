# ---- Build stage ----
FROM python:3.12-slim AS builder
WORKDIR /app

# Copy and install dependencies first for better build caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ---- Runtime stage ----
FROM python:3.12-slim
WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages

# Copy app source
COPY app.py .
COPY templates ./templates

# Optional: set unprivileged user for security
RUN useradd -m appuser
USER appuser

# Expose Flask/Gunicorn port
EXPOSE 5000
ENV PORT=5000

# Health check for ECS (uses Python stdlib to avoid extra packages)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import os, urllib.request; urllib.request.urlopen(f'http://localhost:{os.environ.get(\"PORT\", \"5000\")}/health')" || exit 1

# Use Gunicorn for production-grade serving
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
  