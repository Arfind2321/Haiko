# --- Этап 1: Общий фундамент (собирается и хранится на диске 1 раз) ---
FROM python:3.12-slim AS base
WORKDIR /app
COPY requirements.txt .
COPY ./multilingual-e5-small .
RUN pip install --no-cache-dir -r requirements.txt

# --- Этап 2: Сборка для первого сервиса ---
FROM base AS grpc_server
COPY requirements-grpc.txt .
RUN pip install --no-cache-dir -r requirements-grpc.txt
COPY ./grpc-server .
EXPOSE 50051
CMD ["python3", "index-service.py"]

# --- Этап 3: Сборка для второго сервиса ---
FROM base AS http_api
COPY requirements-api.txt .
RUN pip install --no-cache-dir -r requirements-api.txt
COPY ./http-api .
EXPOSE 8080
CMD ["uvicorn", "search-service:app", "--host", "0.0.0.0", "--port", "8080"]