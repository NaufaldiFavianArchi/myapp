import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'history_page.dart'; // Import halaman history
import 'weather_dashboard.dart'; // Import halaman weather
import 'komoditas_page.dart'; // Import halaman komoditas
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan import ini
import 'package:logging/logging.dart'; // Tambahkan import ini
import 'package:logging_appenders/logging_appenders.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CropPredictionPage(),
    );
  }
}

class CropPredictionPage extends StatefulWidget {
  const CropPredictionPage({super.key});

  @override
  State<CropPredictionPage> createState() => _CropPredictionPageState();
}

class _CropPredictionPageState extends State<CropPredictionPage> {
  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();

  final FocusNode _nFocus = FocusNode();
  final FocusNode _pFocus = FocusNode();
  final FocusNode _kFocus = FocusNode();
  final FocusNode _temperatureFocus = FocusNode();
  final FocusNode _humidityFocus = FocusNode();
  final FocusNode _phFocus = FocusNode();
  final FocusNode _rainfallFocus = FocusNode();

  String _predictionResult = '';
  List<Map<String, dynamic>> _history =
      []; // List untuk menyimpan riwayat dengan input

  final logger = Logger('CropPredictionPage');

  @override
  void initState() {
    super.initState();
    _loadHistory(); // Muat riwayat dari SharedPreferences saat aplikasi mulai
    Logger.root.level = Level.ALL;
    PrintAppender(formatter: const ColorFormatter()).attachToLogger(Logger.root);
  }

  Future<void> _saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> encodedHistory = _history.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('history', encodedHistory);
  }

  Future<void> _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? encodedHistory = prefs.getStringList('history');
    if (encodedHistory != null) {
      setState(() {
        _history = encodedHistory
            .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
            .toList();
      });
    }
  }

  Future<void> _predictCrop() async {
    String url;
    if (kIsWeb) {
      url = 'https://3fdf-103-73-77-2.ngrok-free.app/predict';
    } else if (Platform.isAndroid) {
      url = 'https://3fdf-103-73-77-2.ngrok-free.app/predict';
    } else {
      url = 'http://127.0.0.1:5000/predict';
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'N': double.parse(_nController.text),
        'P': double.parse(_pController.text),
        'K': double.parse(_kController.text),
        'temperature': double.parse(_temperatureController.text),
        'humidity': double.parse(_humidityController.text),
        'pH': double.parse(_phController.text),
        'rainfall': double.parse(_rainfallController.text),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _predictionResult = data['prediction'];
        _history.add({
          'N': _nController.text,
          'P': _pController.text,
          'K': _kController.text,
          'Temperature': _temperatureController.text,
          'Humidity': _humidityController.text,
          'pH': _phController.text,
          'Rainfall': _rainfallController.text,
          'Prediction': _predictionResult
        });
      });
      _saveHistory();
      await _saveDataToFirebase(); 
    } else {
      setState(() {
        _predictionResult = 'Prediction failed';
      });
    }
  }

 Future<void> _saveDataToFirebase() async {
    try {
      logger.info('Starting to save data to Firestore');
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      final data = {
        'N': _nController.text,
        'P': _pController.text,
        'K': _kController.text,
        'temperature': _temperatureController.text,
        'humidity': _humidityController.text,
        'pH': _phController.text,
        'rainfall': _rainfallController.text,
        'prediksi': _predictionResult,
        'timestamp': FieldValue.serverTimestamp(),
      };

      logger.info('Preparing to add document: $data');
      await firestore.collection('prediksi').add(data);
      logger.info('Data successfully saved to Firestore');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil disimpan')),
        );
      }
    } catch (e) {
      logger.severe('Error saving data to Firestore: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      }
    }
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(history: _history),
      ),
    );
  }

  void _nextFocus(FocusNode currentFocus, FocusNode nextFocus,
      TextEditingController controller) {
    if (controller.text.isNotEmpty) {
      FocusScope.of(context).requestFocus(nextFocus);
    } else {
      FocusScope.of(context).requestFocus(currentFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Prediction'),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Enter Crop Details',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 20),
            _buildTextField(_nController, 'N (Nitrogen)', Icons.grass,
                'Enter N value', _nFocus, _pFocus),
            const SizedBox(height: 10),
            _buildTextField(_pController, 'P (Phosphorus)', Icons.grass,
                'Enter P value', _pFocus, _kFocus),
            const SizedBox(height: 10),
            _buildTextField(_kController, 'K (Potassium)', Icons.grass,
                'Enter K value', _kFocus, _temperatureFocus),
            const SizedBox(height: 10),
            _buildTextField(
                _temperatureController,
                'Temperature (°C)',
                Icons.thermostat_outlined,
                'Enter temperature',
                _temperatureFocus,
                _humidityFocus),
            const SizedBox(height: 10),
            _buildTextField(_humidityController, 'Humidity (%)',
                Icons.water_drop, 'Enter humidity', _humidityFocus, _phFocus),
            const SizedBox(height: 10),
            _buildTextField(_phController, 'pH', Icons.science_outlined,
                'Enter pH value', _phFocus, _rainfallFocus),
            const SizedBox(height: 10),
            _buildTextField(_rainfallController, 'Rainfall (mm)', Icons.cloud,
                'Enter rainfall amount', _rainfallFocus, null),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _predictCrop,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Predict Crop', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
            _predictionResult.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5)),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Prediction Result',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _predictionResult,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black87),
                        ),
                      ],
                    ),
                  )
                : const Text('No prediction yet',
                    style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white, // Latar belakang putih
        selectedItemColor: Colors.blueAccent, // Warna untuk item yang dipilih
        unselectedItemColor: Colors.grey, // Warna untuk item yang tidak dipilih
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: 'Cuaca',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Prediksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grass),
            label: 'Komoditas',
          ),
        ],
        currentIndex: 1, // Index untuk menandakan halaman aktif
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigasi ke halaman Cuaca
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WeatherDashboard()),
              );
              break;
            case 1:
              // Sudah di halaman Prediksi
              break;
            case 2:
              // Navigasi ke halaman Komoditas
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      String hint,
      FocusNode currentFocus,
      FocusNode? nextFocus) {
    return TextField(
      controller: controller,
      focusNode: currentFocus,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      onSubmitted: (value) {
        _nextFocus(currentFocus, nextFocus!, controller);
      },
    );
  }
}
