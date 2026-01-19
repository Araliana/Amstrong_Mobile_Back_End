import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/product.dart';
import 'package:uuid/uuid.dart';

class ProductProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Product> products = [];
  final DBHelper db = DBHelper();
  final Tables productTables = Tables.product;
  final uuid = const Uuid();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      final res = await db.get(
        productTables,
        orderBy: "created_at",
        orderType: OrderType.asc,
      );
      products
        ..clear()
        ..addAll(res.map((e) => Product.fromMap(e)).toList());
    } catch (e) {
      debugPrint("Error loading products: $e");
    } finally {
      _setLoading(false);
    }

    await analytics.logEvent(
      name: 'load_product',
      parameters: {'count': products.length},
    );
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required String description,
    required String? img,
    double? discountPrice, // Parameter ini sudah benar
    int stock = 0, // Default stock 0 jika tidak diisi
  }) async {
    _setLoading(true);
    try {
      final id = uuid.v4();
      final now = DateTime.now(); // Simpan waktu pembuatan

      // 1. Simpan ke Database Lokal
      await db.insert(productTables, {
        'id': id,
        'name': name,
        'price': price,
        'discount_price': discountPrice,
        'stock': stock,
        'description': description,
        'img': img,
        'created_at': now.toIso8601String(),
      });

      // 2. Update List di Memory (Agar UI langsung berubah)
      products.add(
        Product(
          id: id,
          name: name,
          price: price,
          discountPrice: discountPrice, // [FIX] Tambahkan ini
          stock: stock, // [FIX] Tambahkan ini
          description: description,
          img: img,
          createdAt: now, // [FIX] Tambahkan ini
        ),
      );

      await analytics.logEvent(
        name: 'add_product',
        parameters: {'name': name, 'price': price, 'description': description},
      );
    } catch (e) {
      debugPrint("Error add product: $e");
      rethrow;
    } finally {
      _setLoading(false); // Pastikan loading berhenti
    }
  }

  Future<void> editProduct({
    required String name,
    required double price,
    required int stock,
    required String description,
    required String? img,
    required String id,
    double? discountPrice,
  }) async {
    _setLoading(true);
    try {
      // Ambil data lama untuk jaga-jaga jika gambar/tanggal null
      final oldDataList = await db.get(
        productTables,
        where: "id = ?",
        whereArgs: [id],
      );
      Product? oldProduct;
      if (oldDataList.isNotEmpty) {
        oldProduct = Product.fromMap(oldDataList.first);
      }

      // 1. Update Database
      await db.update(
        productTables,
        id: id,
        data: {
          'name': name,
          'price': price,
          'discount_price': discountPrice,
          'stock': stock,
          'description': description,
          'img':
              img ??
              oldProduct?.img, // Pakai gambar lama jika tidak ada gambar baru
        },
      );

      // 2. Update List di Memory
      final index = products.indexWhere((item) => item.id == id);
      if (index != -1) {
        products[index] = Product(
          id: id,
          name: name,
          price: price,
          discountPrice: discountPrice, // [FIX] Tambahkan ini
          stock: stock, // [FIX] Tambahkan ini
          description: description,
          img: img ?? oldProduct?.img, // [FIX] Pakai gambar lama jika null
          createdAt:
              oldProduct?.createdAt, // [FIX] Jangan hilangkan tanggal buat
        );
      }

      await analytics.logEvent(
        name: 'edit_product',
        parameters: {
          'name': name,
          'price': price,
          'stock': stock,
          'description': description,
        },
      );
    } catch (e) {
      debugPrint("Error edit product: $e");
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteProduct(String id) async {
    _setLoading(true);
    try {
      await db.delete(productTables, id: id);
      products.removeWhere((item) => item.id == id);

      await analytics.logEvent(name: 'delete_product', parameters: {'id': id});
    } catch (e) {
      debugPrint("Error delete product: $e");
    } finally {
      _setLoading(false);
    }
  }
}
