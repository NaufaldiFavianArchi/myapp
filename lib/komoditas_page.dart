import 'package:flutter/material.dart';
import 'weather_dashboard.dart';
import 'predict_api.dart';

class KomoditasPage extends StatefulWidget {
  @override
  _KomoditasPageState createState() => _KomoditasPageState();
}

class _KomoditasPageState extends State<KomoditasPage> {
  final List<Map<String, dynamic>> hargaKomoditas = [
    {"tanggal": "24/09/2024", "Aceh": "15350", "Jawa Barat": "15500", "Jawa Timur": "15200"},
    {"tanggal": "25/09/2024", "Aceh": "15300", "Jawa Barat": "15600", "Jawa Timur": "15150"},
    {"tanggal": "26/09/2024", "Aceh": "15400", "Jawa Barat": "15550", "Jawa Timur": "15300"},
  ];

  String selectedKomoditas = 'Beras Kualitas Bawah I';
  String selectedProvinsi1 = 'Aceh';
  String selectedProvinsi2 = 'Jawa Barat';

  final List<String> listKomoditas = ['Beras Kualitas Bawah I', 'Daging Ayam', 'Kentang', 'Cabai', 'Jagung', 'Kedelai', 'Kopi', 'Tebu', 'Bawang Merah', 'Karet'];
  final List<String> listProvinsi = ['Aceh', 'Jawa Barat', 'Jawa Timur', 'Lampung', 'Bali', 'Sumatera Utara', 'Kalimantan Barat', 'Sulawesi Selatan', 'Papua', 'NTB'];

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Perbandingan Harga",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            Text("Antar Provinsi", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            // Filter Komoditas
            _buildDropdownFilter(
              label: 'Pilih Komoditas',
              value: selectedKomoditas,
              items: listKomoditas,
              onChanged: (newValue) {
                setState(() {
                  selectedKomoditas = newValue!;
                });
              },
            ),
            SizedBox(height: 10),
            // Filter Provinsi/Kota 1
            _buildDropdownFilter(
              label: 'Pilih Provinsi/Kota 1',
              value: selectedProvinsi1,
              items: listProvinsi,
              onChanged: (newValue) {
                setState(() {
                  selectedProvinsi1 = newValue!;
                });
              },
            ),
            SizedBox(height: 10),
            // Filter Provinsi/Kota 2
            _buildDropdownFilter(
              label: 'Pilih Provinsi/Kota 2',
              value: selectedProvinsi2,
              items: listProvinsi,
              onChanged: (newValue) {
                setState(() {
                  selectedProvinsi2 = newValue!;
                });
              },
            ),
            SizedBox(height: 20),
            // Tabel Perbandingan Harga Komoditas
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: ListView(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Tanggal",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          selectedProvinsi1,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                        Text(
                          selectedProvinsi2,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ...hargaKomoditas.map((data) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data['tanggal']!,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Rp. ${data[selectedProvinsi1]}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[600]),
                              ),
                              Text(
                                'Rp. ${data[selectedProvinsi2]}',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 14,
        unselectedFontSize: 12,
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
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WeatherDashboard()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => CropPredictionPage()),
              );
              break;
            case 2:
              break;
          }
        },
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
        ),
        SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
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
                child: Text(value, style: TextStyle(fontSize: 16)),
              );
            }).toList(),
            onChanged: onChanged,
            underline: SizedBox(),
            icon: Icon(Icons.arrow_drop_down, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
