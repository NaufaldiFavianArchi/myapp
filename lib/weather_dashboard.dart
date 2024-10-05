import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'predict_api.dart'; 
import 'komoditas_page.dart';

class WeatherDashboard extends StatefulWidget {
  const WeatherDashboard({super.key});

  @override
  State<WeatherDashboard> createState() => _WeatherDashboardState();
}

class _WeatherDashboardState extends State<WeatherDashboard> {
  final String apiKey = '2b488ec308e6a4b9c9b9d7d2d8ccc4f9'; // Ganti dengan API key OpenWeather Anda
  final String city = 'Bandar Lampung';
  double temperature = 0.0;
  double humidity = 0.0;
  double rainfall = 0.0;
  double windSpeed = 0.0;
  String weatherStatus = 'Loading...';
  List<dynamic> hourlyForecast = [];

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  Future<void> _fetchWeatherData() async {
    // URL untuk mendapatkan data cuaca saat ini dan perkiraan cuaca
    final currentWeatherUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric',
    );
    final forecastUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric',
    );

    try {
      // Fetch cuaca saat ini
      final currentWeatherResponse = await http.get(currentWeatherUrl);
      if (currentWeatherResponse.statusCode == 200) {
        final currentWeatherData = jsonDecode(currentWeatherResponse.body);
        setState(() {
          temperature = currentWeatherData['main']['temp']?. toDouble() ?? 0.0;
          humidity = currentWeatherData['main']['humidity']?. toDouble() ?? 0.0;
          rainfall = currentWeatherData['rain']?['1h']?. toDouble() ??
                     currentWeatherData['rain']?['3h']?. toDouble() ??
                     0.0;
          windSpeed = currentWeatherData['wind']['speed']?. toDouble() ?? 0.0;
// Suggested code may be subject to a license. Learn more: ~LicenseLog:2377620614.
          weatherStatus = currentWeatherData['weather'][0]['description'] ?? 'Unknown';
        });
      }

      // Fetch data perkiraan cuaca per jam
      final forecastResponse = await http.get(forecastUrl);
      if (forecastResponse.statusCode == 200) {
        final forecastData = jsonDecode(forecastResponse.body);
        setState(() {
          hourlyForecast = forecastData['list'].take(5).toList(); // Ambil 5 jam ke depan
        });
      }
    } catch (e) {
      setState(() {
        weatherStatus = 'Error fetching data: $e';
      });
    }
  }

  String getDroughtStatus(double humidity, double temperature) {
    if (humidity < 30 && temperature > 30) {
      return "Drought Risk";
    } else {
      return "No Drought Risk";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather Dashboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Container(
          color: Colors.lightBlue,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                _buildCurrentWeatherSection(),
                const SizedBox(height: 20),
                _buildHourlyUpdateSection(),
                const SizedBox(height: 20),
                _buildDroughtStatusSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud, size: 30),
            label: 'Cuaca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up, size: 30),
            label: 'Prediksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grass, size: 30),
            label: 'Komoditas',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CropPredictionPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const KomoditasPage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildCurrentWeatherSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${temperature.toStringAsFixed(1)}°C",
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const Icon(Icons.wb_sunny, size: 50, color: Colors.orange),
            ],
          ),
          Text(
            weatherStatus,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherDetailItem("Rainfall", rainfall > 0 ? "${rainfall.toStringAsFixed(1)} mm" : "N/A"),
              _buildWeatherDetailItem("Humidity", "${humidity.toStringAsFixed(0)}%"),
              _buildWeatherDetailItem("Wind", "${windSpeed.toStringAsFixed(1)} m/s"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyUpdateSection() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyForecast.length,
        itemBuilder: (context, index) {
          final forecast = hourlyForecast[index];
          final time = forecast['dt_txt']?.substring(11, 16) ?? 'N/A'; // Ambil waktu dari dt_txt
          final temp = forecast['main']?['temp']?.toString() ?? 'N/A';
          final humidity = forecast['main']?['humidity']?.toString() ?? 'N/A';

          return _buildHourlyItem(time, "$temp°C", "$humidity%");
        },
      ),
    );
  }

  Widget _buildDroughtStatusSection() {
    String droughtStatus = getDroughtStatus(humidity, temperature);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Drought Status",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            droughtStatus,
            style: TextStyle(
              fontSize: 18,
              color: droughtStatus == "Drought Risk" ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyItem(String time, String temp, String humidity) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Text(
            temp,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Text(
            "Humidity: $humidity",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
