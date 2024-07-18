import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jawa_indah_gas/components/navbar2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = " ";
  String username = "";
  String foto = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    String? token = await getToken();
    if (token == null) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/login');
      });
    } else {
      getProfile();
    }
  }

  Future<void> logOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    Future.delayed(Duration.zero, () {
      Navigator.pushReplacementNamed(context, "/login");
    });
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> getProfile() async {
    setState(() {
      _isLoading = true;
    });
    String? token = await getToken();
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse("https://api.masadji.my.id/profile"),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
        );
        setState(() {
          _isLoading = false;
        });
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          final Map<String, dynamic> user = data['data'][0];
          setState(() {
            username = user['username'];
            foto = user['foto'];
            name = user['name'];
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print(e);
      }
    }
  }

  Future<void> changePhoto() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      String? token = await getToken();
      if (result != null && result.files.single.bytes != null) {
        var file = result.files.single;
        if (file.extension != null &&
            (file.extension == 'jpg' ||
                file.extension == 'jpeg' ||
                file.extension == 'png')) {
          var request = http.MultipartRequest(
            'PATCH',
            Uri.parse('https://api.masadji.my.id/profile'),
          );
          request.headers['Authorization'] = 'Bearer $token';
          request.files.add(http.MultipartFile.fromBytes(
            'foto',
            file.bytes!,
            filename: '${file.name}.${file.extension}',
            contentType: MediaType('image', file.extension!),
          ));
          var response = await request.send();
          if (response.statusCode == 200) {
            getProfile();
          } else {
            print('Failed to change photo');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar2(),
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
                      "Profile",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    if (foto.isNotEmpty)
                      ClipOval(
                        child: Image.network(
                          foto,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 100,
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            changePhoto();
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
                            'Ganti Foto',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            logOut();
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
                          child: const Text(
                            'Log Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
