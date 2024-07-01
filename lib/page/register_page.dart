import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:jawa_indah_gas/models/register_data.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameContorller = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordContorller = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> register(BuildContext context) async {
    String password = _passwordContorller.text;
    String confirmPassword = _confirmPasswordController.text;
    String username = _usernameContorller.text;
    String name = _nameController.text;
    String email = _emailController.text;
    setState(() {
      _isLoading = true;
    });

    if (username.isEmpty ||
        name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Gagal Register'),
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
    } else if (!EmailValidator.validate(email)) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Gagal Register'),
            content: const Text('Format email tidak sesuai'),
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
    } else if (password != confirmPassword) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Gagal Register'),
            content: const Text('Password dan Confirm Password tidak cocok.'),
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
    } else if (password.length < 8) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Gagal Register'),
            content: const Text('Panjang Password minimal 8'),
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
      //kode untuk post request register
      RegisterData registerData = RegisterData(
        email: email,
        name: name,
        username: username,
        password: password,
      );
      try {
        final response = await http.post(
          Uri.parse("http://api.masadji.my.id/register"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(registerData.toJson()),
        );
        if (response.statusCode == 201) {
          setState(() {
            _isLoading = false;
          });
          Future.delayed(Duration.zero, () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Register Berhasil'),
                  content: const Text('Kembali Ke Halaman Login'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.pushNamed(context, "/login");
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
                  title: const Text('Register Gagal'),
                  content: const Text('Username Sudah Digunakan'),
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
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Gagal Register'),
                content: const Text('Periksa Kembali Koneksi Anda.'),
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
          onPressed: () {},
          child: const Text(
            "Jawa Indah Gas",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 32,
                    ),
                    const Text(
                      "Register",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: 394,
                      height: 42,
                      child: TextField(
                        controller: _usernameContorller,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: 394,
                      height: 42,
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'email',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: 394,
                      height: 42,
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nama',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: 394,
                      height: 42,
                      child: TextField(
                        controller: _passwordContorller,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: 394,
                      height: 42,
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Konfirmasi Password',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Sudah Punya Akun? '),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, "/login");
                          },
                          child: const Text(
                            'Sudah',
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
                        register(context);
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
                        'Register',
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
