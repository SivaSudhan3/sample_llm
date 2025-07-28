# syntax=docker/dockerfile:1

# ---------- Base stage ----------
FROM python:3.11-slim as base

# Environment settings
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Poetry
ENV POETRY_VERSION=2.1.3
RUN pip install "poetry==$POETRY_VERSION"

# Copy dependency files
COPY pyproject.toml poetry.lock ./

# Install only main dependencies (no dev)
RUN poetry config virtualenvs.create false \
  && poetry install --no-root --no-interaction --no-ansi --only main

# Copy the rest of the application
COPY . .

# ---------- Final image stage ----------
FROM python:3.11-slim as final

# Working directory
WORKDIR /app

# Copy installed packages and app from base
COPY --from=base /usr/local /usr/local
COPY --from=base /app /app

# Set environment variables (override in docker run -e or docker-compose)
ENV TAVILY_API_KEY=${TAVILY_API_KEY}
ENV GROQ_API_KEY=${GROQ_API_KEY}
# Expose port
EXPOSE 8000

# Start the app with Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
