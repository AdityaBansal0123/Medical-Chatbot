## 1. Upgrade to Python 3.11-slim (Fixes the "Requires-Python >=3.11" error)
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

## 2. Fix the "typing-extensions" metadata conflict
# We install this from the standard PyPI index first so Torch doesn't have to look for it 
# in the problematic PyTorch CPU index.
RUN pip install --no-cache-dir "typing-extensions>=4.10.0"

## 3. Install Torch (Split into its own layer for ECR efficiency)
# Note: If you are using the /cpu index, you do NOT need the nvidia-cublas or nvidia-cudnn 
# packages. Removing them will save you about 1.5GB of space.
RUN pip install --no-cache-dir torch==2.10.0 --index-url https://download.pytorch.org/whl/cpu

## 4. Install the rest of the application
COPY setup.py .
RUN pip install --no-cache-dir -e .

COPY . .

EXPOSE 5000

CMD ["python", "app/application.py"]