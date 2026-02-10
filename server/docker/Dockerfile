FROM python:3.10

# Set working directory inside the container
WORKDIR /app

# Copy and install dependencies
COPY ../requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Copy the entire project
COPY .. .

# Run the FastAPI app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]