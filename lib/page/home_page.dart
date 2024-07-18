import 'package:flutter/material.dart';
import 'package:jawa_indah_gas/components/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawa_indah_gas/models/product.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'package:jawa_indah_gas/components/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    checkLogin();
    futureProducts = fetchProducts();
  }

  Future<void> checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    }
  }

  Future<List<Product>> fetchProducts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
        Uri.parse('https://api.masadji.my.id/products'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List productJson = jsonResponse['data'];
      return productJson.map((data) => Product.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: Center(
        child: FutureBuilder<List<Product>>(
          future: futureProducts,
          builder: (context, snapshot) {
            return Column(
              children: <Widget>[
                const SizedBox(height: 32),
                const Text(
                  "Home",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const CircularProgressIndicator()
                else if (snapshot.hasError)
                  Text('${snapshot.error}')
                else
                  Expanded(child: LayoutBuilder(
                    builder: (context, constraints) {
                      int ukuranLayar = constraints.maxWidth < 731
                          ? 2
                          : constraints.maxWidth < 967
                              ? 3
                              : 4;
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: ukuranLayar,
                            mainAxisSpacing: ukuranLayar * 10,
                            crossAxisSpacing: ukuranLayar * 10,
                            childAspectRatio: ukuranLayar / ukuranLayar,
                          ),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return ProductCard(product: snapshot.data![index]);
                          },
                        ),
                      );
                    },
                  )),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          html.window.open('https://wa.me/089636337709', '_block');
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.chat_rounded),
      ),
    );
  }
}
