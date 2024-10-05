import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryPage({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.blue,
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'No history available',
                style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 0, 255, 234)),
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('N: ${item['N']}'),
                        Text('P: ${item['P']}'),
                        Text('K: ${item['K']}'),
                        Text('Temperature: ${item['Temperature']} °C'),
                        Text('Humidity: ${item['Humidity']} %'),
                        Text('pH: ${item['pH']}'),
                        Text('Rainfall: ${item['Rainfall']} mm'),
                        const SizedBox(height: 10),
                        Text('Prediction: ${item['Prediction']}', 
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}