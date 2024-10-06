import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harga Komoditas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const KomoditasPage(),
    );
  }
}

class KomoditasPage extends StatefulWidget {
  const KomoditasPage({super.key});

  @override
  State<KomoditasPage> createState() => _KomoditasPageState();
}

class _KomoditasPageState extends State<KomoditasPage> {
  List<Map<String, dynamic>> hargaKomoditas = [];
  List<dynamic> commodities = [];
  List<dynamic> provinces = [];

  String selectedKomoditas = 'Beras';
  String selectedProvinsi1 = 'Aceh';

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    try {
      commodities = await _fetchCommodities();
      provinces = await _fetchProvinces();
      _fetchKomoditasData();
    } catch (e) {
      logger.e('Error fetching initial data: $e');
    }
  }

  Future<List<dynamic>> _fetchCommodities() async {
    final response = await http.get(Uri.parse('https://www.bi.go.id/hargapangan/WebSite/TabelHarga/GetRefCommodityAndCategory?_=1728194958124'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load commodities');
    }
  }

  Future<List<dynamic>> _fetchProvinces() async {
    final response = await http.get(Uri.parse('https://www.bi.go.id/hargapangan/WebSite/TabelHarga/GetRefProvince?_=1728194958125'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load provinces');
    }
  }

  Future<void> _fetchKomoditasData() async {
    const String startDate = '2024-09-28';
    const String endDate = '2024-10-06';

    final selectedCommodity = commodities.firstWhere((element) => element['name'] == selectedKomoditas);
    final selectedCommodityId = selectedCommodity['id'];

    final selectedProvince1 = provinces.firstWhere((element) => element['name'] == selectedProvinsi1);
    final selectedProvinceId1 = selectedProvince1['id'];

    final url =
        'https://www.bi.go.id/hargapangan/WebSite/TabelHarga/GetGridDataDaerah?price_type_id=1&comcat_id=$selectedCommodityId&province_id=$selectedProvinceId1&regency_id=&market_id=&tipe_laporan=1&start_date=$startDate&end_date=$endDate';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        final List<Map<String, dynamic>> hargaKomoditasTemp = [];
        for (var item in jsonResponse['data']) {
          final komoditas = item['name'];
          const tanggal = '04/10/2024'; // Ini contoh, sebaiknya dinamis berdasarkan tanggal dalam respons
          final harga = item[tanggal];

          hargaKomoditasTemp.add({
            'komoditas': komoditas,
            'provinsi': selectedProvinsi1,
            'harga': harga,
            'tanggal': tanggal,
          });
        }

        setState(() {
          hargaKomoditas = hargaKomoditasTemp;
        });
      } else {
        logger.e('Gagal mengambil data, status code: ${response .statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching data: $e');
    }
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start ,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 16)),
              );
            }).toList(),
            onChanged: onChanged,
            underline: const SizedBox(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Harga Komoditas'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdownFilter(
              label: 'Pilih Komoditas',
              value: selectedKomoditas,
              items: commodities.map((e) => e['name'].toString()).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedKomoditas = newValue!;
                  _fetchKomoditasData();
                });
              },
            ),
            const SizedBox(height: 10),
            _buildDropdownFilter(
              label: 'Pilih Provinsi/Kota',
              value: selectedProvinsi1,
              items: provinces.map((e) => e['name'].toString()).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedProvinsi1 = newValue!;
                  _fetchKomoditasData();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: hargaKomoditas.map((data) {
                  return Card(
                    child: ListTile(
                      title: Text('${data['komoditas']} - ${data['provinsi']}'),
                      subtitle: Text('Harga: Rp. ${data['harga']} - Tanggal: ${data['tanggal']}'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}