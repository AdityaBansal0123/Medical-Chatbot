## Use a slim but stable base
FROM python:3.10-slim

## Essential environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

## 1. Install system dependencies (Cached)
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

## 2. Install heavy dependencies FIRST (Layer Caching)
# This creates a separate layer for the 2GB+ AI libraries. 
# It won't be re-uploaded unless you change this line.
RUN pip install --no-cache-dir \
    torch==2.10.0 \
    nvidia-cublas-cu12 \
    nvidia-cudnn-cu12 \
    --index-url https://download.pytorch.org/whl/cpu 
    # Note: Use /whl/cu121 if you strictly need GPU support on ECR

## 3. Copy requirements or setup.py separately
# This ensures that changing your code doesn't trigger a re-install of all libraries
COPY setup.py .
RUN pip install --no-cache-dir -e .

## 4. Copy the rest of the application
COPY . .

EXPOSE 5000

CMD ["python", "app/application.py"]