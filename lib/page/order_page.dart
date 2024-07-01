import 'package:flutter/material.dart';
import 'package:jawa_indah_gas/components/navbar2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> checkLogin() async {
    String? token = await getToken();
    if (token == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, "/login");
      });
    } else {
      fetchItems();
    }
  }

  Future<void> fetchItems() async {
    String? token = await getToken();
    try {
      final response = await http.get(
        Uri.parse("http://api.masadji.my.id/order"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _items = jsonResponse['data'];
        });
      } else {
        print("gagal mengambil data");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screeWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: const Navbar2(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : screeWidth > 600
              ? Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 32,
                        ),
                        const Text(
                          'Pesanan Saya',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            border: TableBorder.all(),
                            columns: const [
                              DataColumn(label: Text('Kode Transaksi')),
                              DataColumn(label: Text('Nama Barang')),
                              DataColumn(label: Text('Sebanyak')),
                              DataColumn(label: Text('Harga')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: _items
                                .map(
                                  (item) => DataRow(cells: [
                                    DataCell(Text(item['kode_transaksi'])),
                                    DataCell(Text(item['nama_barang'])),
                                    DataCell(Text(item['sebanyak'].toString())),
                                    DataCell(Text(item['harga'].toString())),
                                    DataCell(
                                        Text(item['total_tagihan'].toString())),
                                    DataCell(Text(item['status'].toString())),
                                  ]),
                                )
                                .toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 32,
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Pesanan Saya',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            border: TableBorder.all(),
                            columns: const [
                              DataColumn(label: Text('Kode Transaksi')),
                              DataColumn(label: Text('Nama Barang')),
                              DataColumn(label: Text('Sebanyak')),
                              DataColumn(label: Text('Harga')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: _items
                                .map(
                                  (item) => DataRow(cells: [
                                    DataCell(Text(item['kode_transaksi'])),
                                    DataCell(Text(item['nama_barang'])),
                                    DataCell(Text(item['sebanyak'].toString())),
                                    DataCell(Text(item['harga'].toString())),
                                    DataCell(
                                        Text(item['total_tagihan'].toString())),
                                    DataCell(Text(item['status'].toString())),
                                  ]),
                                )
                                .toList(),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
