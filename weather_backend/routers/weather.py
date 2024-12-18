from fastapi import APIRouter
from utils.weather_api import fetch_weather_data, fetch_forecast_data

router = APIRouter(prefix="/weather", tags=["weather"])

@router.get("/{city}")
def get_weather(city: str):
    data = fetch_weather_data(city)
    return data

@router.get("/forecast/{city}")
def get_forecast(city: str):
    data = fetch_forecast_data(city)
    return data
