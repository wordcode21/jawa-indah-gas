import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jawa_indah_gas/models/login_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isloading = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  Future<void> login() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    setState(() {
      _isloading = true;
    });

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isloading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Gagal Login'),
            content: const Text('Semua Field Harus diisi!'),
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
    } else {
      LoginData loginData = LoginData(username, password);
      try {
        final response = await http.post(
          Uri.parse("https://api.masadji.my.id/login"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(loginData.toJson()),
        );
        if (response.statusCode == 200) {
          setState(() {
            _isloading = false;
          });
          final Map<String, dynamic> data = jsonDecode(response.body);
          final String token = data['token'];
          final SharedPreferences sharedPreferences =
              await SharedPreferences.getInstance();
          await sharedPreferences.setString("token", token);
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacementNamed(context, "/home");
          });
        } else {
          setState(() {
            _isloading = false;
          });
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Login Gagal'),
                  content: const Text('Invalid cridentials'),
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
          _isloading = false;
        });
        print(e);
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Login Gagal'),
                content: const Text('Tidak bisa konek ke server'),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextButton(
          onPressed: () => {},
          child: const Text(
            "Jawa Indah Gas",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: _isloading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 32,
                    ),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: 394,
                      height: 42,
                      child: TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 394,
                      height: 42,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah Punya Akun? '),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, "/register");
                          },
                          child: const Text(
                            'Belum',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () {
                        login();
                      }, // Panggil fungsi _login saat tombol ditekan
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.black, // Warna background tombol
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
