import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatefulWidget {
  final List<String> predictionHistory;

  const HistoryPage({super.key, required this.predictionHistory});

  @override
  State<HistoryPage> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Prediksi> _prediksiList = [];

  @override
  void initState() {
    super.initState();
    _loadPrediksi();
  }

  Future<void> _loadPrediksi() async {
    final QuerySnapshot querySnapshot = await firestore
        .collection('prediksi')
        .orderBy('timestamp', descending: true)
        .get();
    
    setState(() {
      _prediksiList = querySnapshot.docs
          .map((doc) => Prediksi.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Prediksi'),
      ),
      body: _prediksiList.isEmpty
          ? const Center(
              child: Text('Tidak ada riwayat prediksi'),
            )
          : ListView.builder(
              itemCount: _prediksiList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_prediksiList[index].prediksi),
                  subtitle: Text(_prediksiList[index].tanggal),
                );
              },
            ),
    );
  }
}

class Prediksi {
  String prediksi;
  String tanggal;

  Prediksi({required this.prediksi, required this.tanggal});

  factory Prediksi.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Prediksi(
      prediksi: data['prediksi'] ?? '',
      tanggal: data['timestamp'] != null 
          ? (data['timestamp'] as Timestamp).toDate().toString()
          : '',
    );
  }
}