from fastapi import FastAPI
from routers.weather import router as weather_router

app = FastAPI(title="Weather API", version="1.0")

# Einbinden der Wetter-Routen
app.include_router(weather_router)

@app.get("/")
def root():
    return {"message": "Welcome to the Weather API"}

# uvicorn main:app --reload