# --- Backend Dockerfile ---
FROM python:3.12-slim
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY backend/requirements.txt ./requirements.txt

RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ .

# expose flask port
EXPOSE 5000

# run flask
CMD ["python", "app.py"]

