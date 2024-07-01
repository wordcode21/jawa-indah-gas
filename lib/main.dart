import 'package:flutter/material.dart';
import 'package:jawa_indah_gas/page/cart_page.dart';
import 'package:jawa_indah_gas/page/home_page.dart';
import 'package:jawa_indah_gas/page/login_page.dart';
import 'package:jawa_indah_gas/page/order_page.dart';
import 'package:jawa_indah_gas/page/profile_page.dart';
import 'package:jawa_indah_gas/page/register_page.dart';
import 'package:jawa_indah_gas/page/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: "Jawa Indah Gas",
    initialRoute: "/",
    routes: {
      "/": (context) => WelcomePage(),
      "/login": (context) => LoginPage(),
      "/register": (context) => RegisterPage(),
      "/home": (context) => HomePage(),
      "/profile": (context) => ProfilePage(),
      "/keranjang": (context) => CartPage(),
      "/order": (context) => OrderPage(),
    },
  ));
}
