String translateDescription(String description, String language) {
  const translations = {
    'clear sky': {'de': 'Klarer Himmel', 'es': 'Cielo despejado'},
    'few clouds': {'de': 'Wenige Wolken', 'es': 'Pocas nubes'},
    'scattered clouds': {'de': 'Aufgelockerte Wolken', 'es': 'Nubes dispersas'},
    'rain': {'de': 'Regen', 'es': 'Lluvia'},
    'thunderstorm': {'de': 'Gewitter', 'es': 'Tormenta'},
    'snow': {'de': 'Schnee', 'es': 'Nieve'},
    'mist': {'de': 'Nebel', 'es': 'Niebla'},
    // Weitere Übersetzungen hinzufügen...
  };

  // Prüfe, ob die Beschreibung in der Übersetzungskarte existiert
  final translationMap = translations[description.toLowerCase()];
  if (translationMap != null) {
    return translationMap[language] ?? description;
  }

  // Rückgabe der ursprünglichen Beschreibung, falls keine Übersetzung verfügbar ist
  return description;
}





