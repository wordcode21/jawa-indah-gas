import 'package:flutter/material.dart';

class Navbar2 extends StatelessWidget implements PreferredSizeWidget {
  const Navbar2({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      automaticallyImplyLeading: false,
      title: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, "/home");
        },
        child: const Text(
          "Jawa Indah Gas",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.black,
      actions: [
        if (screenWidth > 600) ...[
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, "/home");
            },
            child: const Text(
              'Home',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ] else ...[
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'home':
                  Navigator.pushNamed(context, "/home");
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'home',
                  child: Text('Home'),
                ),
              ];
            },
            icon: Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ],
    );
  }
}
