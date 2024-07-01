import 'package:flutter/material.dart';
import 'package:jawa_indah_gas/models/product.dart';
import 'package:jawa_indah_gas/page/detail_page.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPage(
              product: product,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (screenWidth > 600) ...[
              const SizedBox(height: 16),
              Image.network(
                product.imageUrl,
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 16),
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'RP. ${product.price}',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Stok: ${product.stok}',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(height: 10),
            ] else ...[
              const SizedBox(height: 16),
              Image.network(
                product.imageUrl,
                height: 50,
                width: 50,
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'RP. ${product.price}',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Stok: ${product.stok}',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              const SizedBox(height: 8),
            ]
          ],
        ),
      ),
    );
  }
}
