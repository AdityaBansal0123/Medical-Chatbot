FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

## 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

## 2. Fix metadata conflict for typing-extensions
RUN pip install --no-cache-dir "typing-extensions>=4.10.0"

## 3. Install Torch (CPU version for smaller image size)
RUN pip install --no-cache-dir torch==2.10.0 --index-url https://download.pytorch.org/whl/cpu

## 4. Copy dependency files ONLY (Crucial for caching)
# We copy both because setup.py depends on requirements.txt
COPY setup.py requirements.txt ./

## 5. Install the application dependencies
# This layer will only re-run if setup.py or requirements.txt changes
RUN pip install --no-cache-dir -e .

## 6. Copy the rest of the application code
COPY . .

EXPOSE 5000

CMD ["python", "app/application.py"]