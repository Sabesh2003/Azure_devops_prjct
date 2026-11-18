FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY templates/ ./templates/

EXPOSE 5000

# Intentionally uses Flask's built-in development server for this practice project.
# Do not use this single-process setup as a production serving configuration.
CMD ["python", "app.py"]
