import 'package:flutter_application_1/model/product.dart';

import 'db_helper.dart';

class ProductDB {
  final DBHelper _helper = DBHelper();

  Future<int> insert(Product product) async {
    return await _helper.insert(Tables.product, product.toMap());
  }

  Future<List<Product>> getAll({
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final rows = await _helper.get(
      Tables.product,
      where: where,
      whereArgs: whereArgs,
    );

    return rows.map((r) => Product.fromMap(r)).toList();
  }

  Future<Product?> getById(int id) async {
    final rows = await _helper.get(
      Tables.product,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (rows.isEmpty) return null;
    return Product.fromMap(rows.first);
  }

  Future<int> update(Product product) async {
    if (product.id == null) throw ArgumentError('Product id is required');
    return await _helper.update(Tables.product, product.id!, product.toMap());
  }

  Future<int> delete(int id) async {
    return await _helper.delete(Tables.product, id: id);
  }
}
