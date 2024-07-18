import 'package:flutter/material.dart';
import 'package:jawa_indah_gas/components/navbar2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'dart:convert';

class CheckoutPage extends StatefulWidget {
  final String kodeBarang;
  final String namaBarang;
  final int sebanyak;
  final int harga;
  final int stok;
  final String? kodeKeranjang;
  const CheckoutPage(
      {super.key,
      required this.kodeBarang,
      required this.namaBarang,
      required this.sebanyak,
      required this.harga,
      required this.stok,
      this.kodeKeranjang});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _alamatController = TextEditingController();
  int sebanyak = 0;
  int harga = 0;
  String kotaPilihan = '205';
  int ongkir = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    sebanyak = widget.sebanyak;
    harga = widget.harga;
    getOngkir();
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<void> getPayment() async {
    setState(() {
      _isLoading = true;
    });
    String? token = await getToken();
    final String alamat = _alamatController.text;
    String namaKota = getNamaKotaByKode(kotaPilihan);
    if (token != null) {
      final request = await http.post(
        Uri.parse("https://api.masadji.my.id/order"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(
          <String, dynamic>{
            'kode_barang': widget.kodeBarang,
            'sebanyak': sebanyak,
            'alamat': alamat,
            'kota': namaKota,
            'ongkir': ongkir
          },
        ),
      );
      if (request.statusCode == 201) {
        setState(() {
          _isLoading = false;
        });
        final data = json.decode(request.body);
        final redirectUrl = data['payment_url'];

        html.window.open(redirectUrl, '_self');
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Failed to create transaction');
      }
    }
  }

  Future<void> getOngkir() async {
    setState(() {
      _isLoading = true;
    });
    String? token = await getToken();
    if (token != null) {
      try {
        final request =
            await http.post(Uri.parse("https://api.masadji.my.id/cek-ongkir"),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode(<String, String>{"destination": kotaPilihan}));
        if (request.statusCode == 200) {
          Map<String, dynamic> jsonResponse = jsonDecode(request.body);
          List<dynamic> dataResponse = jsonResponse['data'];
          Map<String, dynamic> data = dataResponse[0];
          List<dynamic> services = data['services'];
          Map<String, dynamic> firstService = services[0];
          setState(() {
            _isLoading = false;
            ongkir = firstService['cost'];
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> deleteItem(String? kodeKeranjang) async {
    String? token = await getToken();
    if (kodeKeranjang != null) {
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
        } else {}
      } catch (e) {
        print(e);
      }
    }
  }

  String getNamaKotaByKode(String kode) {
    String? namaKota;
    kotaKalimantanTengah.forEach((kota) {
      if (kota['code'] == kode) {
        namaKota = kota['name'];
      }
    });
    return namaKota ?? 'Kode tidak ditemukan';
  }

  List<Map<String, String>> kotaKalimantanTengah = [
    {'name': 'Barito Selatan', 'code': '44'},
    {'name': 'Barito Timur', 'code': '45'},
    {'name': 'Barito Utara', 'code': '46'},
    {'name': 'Gunung Mas', 'code': '136'},
    {'name': 'Kapuas', 'code': '167'},
    {'name': 'Katingan', 'code': '174'},
    {'name': 'Kotawaringin Barat', 'code': '205'},
    {'name': 'Kotawaringin Timur', 'code': '206'},
    {'name': 'Lamandau', 'code': '221'},
    {'name': 'Murung Raya', 'code': '296'},
    {'name': 'Palangka Raya', 'code': '326'},
    {'name': 'Pulang Pisau', 'code': '371'},
    {'name': 'Seruyan', 'code': '405'},
    {'name': 'Sukamara', 'code': '432'},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar2(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 32,
                    ),
                    const Text(
                      "Checkout",
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Text(
                      widget.namaBarang,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      "harga: Rp.${widget.harga.toString()}",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (sebanyak > 1) {
                              setState(() {
                                sebanyak--;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.yellow, // Warna background tombol
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            '-',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Text(
                          sebanyak.toString(),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (sebanyak < widget.stok) {
                              setState(() {
                                sebanyak++;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.green, // Warna background tombol
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            '+',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      "Alamat",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: 300,
                      height: 60,
                      child: TextField(
                        controller: _alamatController,
                        maxLines: 2,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 12),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Masukan Alamat',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      "Kabupaten/Kota:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 42,
                      width: 200,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: kotaPilihan,
                        items: kotaKalimantanTengah
                            .map<DropdownMenuItem<String>>(
                                (Map<String, String> city) {
                          return DropdownMenuItem<String>(
                            value: city['code']!,
                            child: Text(city['name']!),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              kotaPilihan = newValue;
                            });
                            getOngkir();
                          }
                        },
                        underline: SizedBox(),
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      "Ongkir:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      "Rp.${ongkir}",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      "Total:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Text(
                      "Rp.${(harga * sebanyak) + ongkir}",
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (widget.kodeKeranjang != null) {
                          deleteItem(widget.kodeKeranjang);
                        }
                        getPayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green, // Warna background tombol
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Beli',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
