import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'history_page.dart';
import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final logger = Logger('CropPredictionPage');

class CropPredictionPage extends StatefulWidget {
  const CropPredictionPage({super.key});

  @override
  State<CropPredictionPage> createState() => _CropPredictionPageState();
}

class _CropPredictionPageState extends State<CropPredictionPage> {
  @override
  void initState() {
    super.initState();
    Logger.root.level = Level.ALL;
    PrintAppender(formatter: const ColorFormatter()).attachToLogger(Logger.root);
  }

  final TextEditingController _nController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  final TextEditingController _kController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _humidityController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final TextEditingController _rainfallController = TextEditingController();

  String _predictionResult = '';
  final List<String> _predictionHistory = [];

  Future<void> _predictCrop() async {
    try {
      logger.info('Starting prediction process');
      final response = await http.post(
        Uri.parse('https://0b5e-103-73-77-2.ngrok-free.app/predict'),
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

      logger.info('Received response with status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictionResult = data['prediction'];
          _predictionHistory.add(_predictionResult);
        });
        logger.info('Prediction successful: $_predictionResult');
        
        // Panggil fungsi untuk menyimpan ke Firebase
        await _saveDataToFirebase();
      } else {
        throw Exception('Failed to get prediction. Status code: ${response.statusCode}');
      }
    } catch (e) {
      logger.severe('Error during prediction process: $e');
      setState(() {
        _predictionResult = 'An error occurred';
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Prediction'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      drawer: _buildDrawer(context), // Add drawer for sidebar navigation
      body: SingleChildScrollView(
        child: Padding(
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
              _buildTextField(
                  _nController, 'N (Nitrogen)', Icons.grass, 'Enter N value'),
              const SizedBox(height: 10),
              _buildTextField(
                  _pController, 'P (Phosphorus)', Icons.grass, 'Enter P value'),
              const SizedBox(height: 10),
              _buildTextField(
                  _kController, 'K (Potassium)', Icons.grass, 'Enter K value'),
              const SizedBox(height: 10),
              _buildTextField(_temperatureController, 'Temperature (°C)',
                  Icons.thermostat_outlined, 'Enter temperature'),
              const SizedBox(height: 10),
              _buildTextField(_humidityController, 'Humidity (%)',
                  Icons.water_drop, 'Enter humidity'),
              const SizedBox(height: 10),
              _buildTextField(_phController, 'pH', Icons.science_outlined,
                  'Enter pH value'),
              const SizedBox(height: 10),
              _buildTextField(_rainfallController, 'Rainfall (mm)', Icons.cloud,
                  'Enter rainfall amount'),
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
                child:
                    const Text('Predict Crop', style: TextStyle(fontSize: 18)),
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
                            offset: Offset(0, 5),
                          ),
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
      ),
    );
  }

  // Build text field
  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, String hint) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: Colors.blue[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  // Build drawer (sidebar)
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Predict Crop'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Prediction History'),
            onTap: () {
              Navigator.pop(context); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    var historyPage2 = HistoryPage(predictionHistory: _predictionHistory);
                    var historyPage = historyPage2;
                    return historyPage;
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
