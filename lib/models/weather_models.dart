class WeatherInfo {
  final String siteName;
  final String county;
  final String weather;
  final double temperature;
  final int humidity;
  final int aqi;
  final double pm25;

  const WeatherInfo({
    required this.siteName,
    required this.county,
    required this.weather,
    required this.temperature,
    required this.humidity,
    required this.aqi,
    required this.pm25,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      siteName: json['sitename'] ?? '',
      county: json['county'] ?? '',
      weather: json['weather'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      aqi: (json['aqi'] as num?)?.toInt() ?? 0,
      pm25: (json['pm25'] as num?)?.toDouble() ?? 0,
    );
  }
}
