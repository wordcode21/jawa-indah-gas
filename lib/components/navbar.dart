import 'package:flutter/material.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AppBar(
      automaticallyImplyLeading: false,
      title: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, "/home");
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
              Navigator.pushReplacementNamed(context, "/order");
            },
            child: const Text(
              'My Order',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/keranjang");
            },
            child: const Text(
              'Keranjang',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, "/profile");
            },
            child: const Text(
              'My Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ] else ...[
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'order':
                  Navigator.pushReplacementNamed(context, "/order");
                  break;
                case 'keranjang':
                  Navigator.pushReplacementNamed(context, "/keranjang");
                  break;
                case 'profile':
                  Navigator.pushReplacementNamed(context, "/profile");
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'order',
                  child: Text('My Order'),
                ),
                const PopupMenuItem<String>(
                  value: 'keranjang',
                  child: Text('Keranjang'),
                ),
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Text('My Profile'),
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
