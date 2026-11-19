# Базовый образ
FROM python:3.11-slim

# Установка рабочей директории
WORKDIR /app

# Копирование файла зависимостей и их установка
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Копирование исходного кода приложения
COPY . .

# Открытие порта (если требуется)
EXPOSE 8080
EXPOSE 8000


CMD ["python", "index-service.py"]
CMD ["python3", "-m", "uvicorn", "search-service:app", "--port", "8000", "--reload"]