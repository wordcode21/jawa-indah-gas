import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jawa_indah_gas/components/navbar2.dart';
import 'package:jawa_indah_gas/page/checkout_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> _items = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
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
        Uri.parse("https://api.masadji.my.id/keranjang"),
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

  Future<void> deleteItem(String kodeKeranjang) async {
    setState(() {
      _isLoading = true;
    });
    String? token = await getToken();
    try {
      final request = await http.delete(
        Uri.parse("https://api.masadji.my.id/keranjang"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          <String, String>{'kode_keranjang': kodeKeranjang},
        ),
      );
      if (request.statusCode == 200) {
        setState(() {
          _isLoading = false;
        });
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Item Berhasil dihapus'),
                content: const Text('Item telah dihapus'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      fetchItems();
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Item gagal dihapus'),
                content: const Text('Item gagal dihapus'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
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
    final screeWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: Navbar2(),
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
                          'Keranjang',
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
                              DataColumn(label: Text('Kode Keranjang')),
                              DataColumn(label: Text('Nama Barang')),
                              DataColumn(label: Text('Sebanyak')),
                              DataColumn(label: Text('Harga')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Delete')),
                              DataColumn(label: Text('Checkout')),
                            ],
                            rows: _items
                                .map(
                                  (item) => DataRow(cells: [
                                    DataCell(Text(item['kode_keranjang'])),
                                    DataCell(Text(item['nama_barang'])),
                                    DataCell(Text(item['sebanyak'].toString())),
                                    DataCell(Text(item['harga'].toString())),
                                    DataCell(Text(item['total'].toString())),
                                    DataCell(ElevatedButton(
                                      onPressed: () {
                                        deleteItem(
                                            item['kode_keranjang'].toString());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .red, // Warna background tombol
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    )),
                                    DataCell(ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CheckoutPage(
                                              kodeBarang: item['kode_barang']
                                                  .toString(),
                                              namaBarang: item['nama_barang']
                                                  .toString(),
                                              sebanyak: item['sebanyak'],
                                              harga: item['harga'],
                                              stok: item['stok'],
                                              kodeKeranjang:
                                                  item['kode_keranjang'],
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .green, // Warna background tombol
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        'checkout',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    )),
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
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const SizedBox(
                          height: 32,
                        ),
                        const Text(
                          'Keranjang',
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
                              DataColumn(label: Text('Kode Keranjang')),
                              DataColumn(label: Text('Kode Barang')),
                              DataColumn(label: Text('Nama Barang')),
                              DataColumn(label: Text('Sebanyak')),
                              DataColumn(label: Text('Harga')),
                              DataColumn(label: Text('Total')),
                              DataColumn(label: Text('Delete')),
                              DataColumn(label: Text('Checkout')),
                            ],
                            rows: _items
                                .map(
                                  (item) => DataRow(cells: [
                                    DataCell(Text(item['kode_keranjang'])),
                                    DataCell(Text(item['kode_barang'])),
                                    DataCell(Text(item['nama_barang'])),
                                    DataCell(Text(item['sebanyak'].toString())),
                                    DataCell(Text(item['harga'].toString())),
                                    DataCell(Text(item['total'].toString())),
                                    DataCell(ElevatedButton(
                                      onPressed: () {
                                        deleteItem(
                                            item['kode_keranjang'].toString());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .red, // Warna background tombol
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    )),
                                    DataCell(ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CheckoutPage(
                                              kodeBarang: item['kode_barang']
                                                  .toString(),
                                              namaBarang: item['nama_barang']
                                                  .toString(),
                                              sebanyak: item['sebanyak'],
                                              harga: item['harga'],
                                              stok: item['stok'],
                                              kodeKeranjang:
                                                  item['kode_keranjang'],
                                            ),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .green, // Warna background tombol
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                      child: const Text(
                                        'checkout',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    )),
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
