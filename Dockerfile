# Use official Python image
FROM python:3.9-slim

# Set work directory inside container
WORKDIR /app

# Install system dependencies (optional, useful for some libs)
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Copy only requirements first (for better caching)
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Expose Flask default port
EXPOSE 5000

# Environment variables for Flask (adjust if needed)
ENV FLASK_APP=app.py \
    FLASK_RUN_HOST=0.0.0.0 \
    FLASK_RUN_PORT=5000

# Run the Flask app
CMD ["python", "app.py"]
