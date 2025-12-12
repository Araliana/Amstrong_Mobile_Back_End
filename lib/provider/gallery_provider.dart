import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/db/db_helper.dart';
import 'package:flutter_application_1/model/gallery.dart';
import 'package:uuid/uuid.dart';

class GalleryProvider with ChangeNotifier {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final List<Memo> memos = [];
  final DBHelper db = DBHelper();
  final Tables galleryTable = Tables.gallery;
  final uuid = const Uuid();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> loadMemos() async {
    _setLoading(true);
    final res = await db.get(
      galleryTable,
      orderBy: "created_at",
      orderType: OrderType.desc,
    );

    memos
      ..clear()
      ..addAll(res.map((e) => Memo.fromMap(e)).toList());
    _setLoading(false);

    await analytics.logEvent(
      name: 'load_gallery',
      parameters: {'count': memos.length},
    );
  }

  Future<Memo?> getMemoById(String id) async {
    _setLoading(true);
    final res = (await db.get(
      galleryTable,
      where: "id = ?",
      whereArgs: [id],
    ))[0];
    _setLoading(false);
    await analytics.logEvent(
      name: 'get_memo_detail',
      parameters: {'memo_id': id},
    );
    return Memo.fromMap(res);
  }

  Future<void> addMemo({
    required String name,
    required String quote,
    required String img,
    required String category,
  }) async {
    _setLoading(true);
    final id = uuid.v4();
    await db.insert(galleryTable, {
      'id': id,
      'name': name,
      'category': category,
      'quote': quote,
      'img': img,
    });

    memos.add(
      Memo(
        id: id,
        name: name,
        quote: quote,
        img: img,
        category: category,
        isActive: true,
      ),
    );

    _setLoading(false);

    await analytics.logEvent(
      name: 'add_gallery_memo',
      parameters: {'name': name, 'quote': quote},
    );
  }

  Future<void> editMemo({
    required String name,
    required String quote,
    required String img,
    required String category,
    required bool isActive,
    required String id,
  }) async {
    _setLoading(true);

    await db.update(
      galleryTable,
      id: id,
      data: {
        'name': name,
        'category': category,
        'quote': quote,
        'img': img,
        'is_active': isActive ? 1 : 0,
      },
    );
    final index = memos.indexWhere((item) => item.id == id);
    memos[index] = Memo(
      id: id,
      name: name,
      quote: quote,
      img: img,
      category: category,
      isActive: isActive,
    );

    _setLoading(false);

    await analytics.logEvent(
      name: 'edit_gallery_memo',
      parameters: {'id': id, 'name': name, 'quote': quote},
    );
  }

  Future<void> deleteMemo(String id) async {
    _setLoading(true);
    await db.delete(galleryTable, id: id);

    memos.removeWhere((c) => c.id == id);

    _setLoading(false);

    await analytics.logEvent(
      name: 'delete_gallery_memo',
      parameters: {'id': id},
    );
  }
}
