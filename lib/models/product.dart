class Product {
  final String name;
  final String imageUrl;
  final int price;
  final int stok;
  final String kodeBarang;
  final String tanggal;

  Product({
    required this.kodeBarang,
    required this.name,
    required this.stok,
    required this.price,
    required this.tanggal,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['nama_barang'],
      imageUrl: json['foto'],
      price: json['harga'],
      stok: json['stok'],
      tanggal: json['diupdate_tanggal'],
      kodeBarang: json['kode_barang'],
    );
  }
}
