FROM python:3.12-slim

RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# requirements.txt must be at: backend/requirements.txt in the repo
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# copy the rest of the app from backend/ into /app
COPY . .

EXPOSE 5000
CMD ["python", "app.py"]


