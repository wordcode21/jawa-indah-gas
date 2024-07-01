import 'package:flutter/material.dart';
import 'package:jawa_indah_gas/components/navbar2.dart';
import 'package:jawa_indah_gas/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:jawa_indah_gas/page/checkout_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DetailPage extends StatefulWidget {
  final Product product;
  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int count = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> addToCart() async {
    setState(() {
      _isLoading = true;
    });
    String? token = await getToken();
    if (count == 0) {
      setState(() {
        _isLoading = true;
      });
      Future.delayed(
        Duration.zero,
        () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Gagal Menambahkan Ke keranjang'),
                content: const Text('Jumlah Barang tidak boleh 0'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      try {
        final request = await http.post(
          Uri.parse("http://api.masadji.my.id/keranjang"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(
            <String, String>{
              "kode_barang": widget.product.kodeBarang,
              "sebanyak": count.toString(),
            },
          ),
        );

        if (request.statusCode == 201) {
          setState(() {
            _isLoading = true;
          });
          Future.delayed(
            Duration.zero,
            () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Berhasil Menambahkan Ke Keranjang'),
                    content: const Text('Dipindahkan Ke halaman Keranjang'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/keranjang");
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        } else {
          setState(() {
            _isLoading = true;
          });
          Future.delayed(
            Duration.zero,
            () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Gagal Menambahkan Ke Keranjang'),
                    content: const Text('Periksa Koneksi Anda'),
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
            },
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = true;
        });
      }
    }
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar2(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 32,
                  ),
                  const Text(
                    "Detail Barang",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Image.network(widget.product.imageUrl,
                      height: 100, width: 100),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text("Stok: ${widget.product.stok}"),
                  const SizedBox(
                    height: 16,
                  ),
                  Text("Harga: Rp${widget.product.price}"),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            if (count > 1) {
                              count--;
                            }
                          });
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
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(
                        count.toString(),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (widget.product.stok > count) {
                            setState(() {
                              count++;
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
                            fontSize: 10,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          addToCart();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.red, // Warna background tombol
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Column(
                          children: [
                            Text(
                              "Tambahkan",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 8),
                            ),
                            Text(
                              "Ke Keranjang",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 8),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutPage(
                                  kodeBarang: widget.product.kodeBarang,
                                  namaBarang: widget.product.name,
                                  sebanyak: count,
                                  harga: widget.product.price,
                                  stok: widget.product.stok),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // Warna background tombol
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'checkout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
