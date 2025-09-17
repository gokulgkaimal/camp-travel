# --- Backend Dockerfile ---
FROM python:3.12-slim
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# set working directory
WORKDIR /app

# copy requirements first (better caching)
COPY requirements.txt .

# install deps
RUN pip install --no-cache-dir -r requirements.txt

# copy app code
COPY . .

# expose flask port
EXPOSE 5000

# run flask
CMD ["python", "app.py"]

