import 'constants.dart';

String getBackgroundImage(String? description) {
  if (description == null || description.isEmpty) {
    return AssetPaths.defaultWeather;
  }

  final lowerCaseDescription = description.toLowerCase();
  if (lowerCaseDescription.contains("cloud")) {
    return AssetPaths.cloudy;
  } else if (lowerCaseDescription.contains("rain")) {
    return AssetPaths.rainy;
  } else if (lowerCaseDescription.contains("snow")) {
    return AssetPaths.snowy;
  } else if (lowerCaseDescription.contains("clear")) {
    return AssetPaths.sunny;
  } else if (lowerCaseDescription.contains("mist") ||
      lowerCaseDescription.contains("fog")) {
    return AssetPaths.foggy;
  } else {
    return AssetPaths.defaultWeather;
  }
}

String getWeatherIcon(String? main) {
  if (main == null || main.isEmpty) {
    return AssetPaths.defaultWeather;
  }

  switch (main.toLowerCase()) {
    case "clouds":
      return "assets/icons/cloudy.png";
    case "rain":
      return "assets/icons/rainy.png";
    case "snow":
      return "assets/icons/snowy.png";
    case "clear":
      return "assets/icons/sunny.png";
    case "mist":
    case "fog":
      return "assets/icons/misty.png";
    default:
      return "assets/icons/default.png";
  }
}
