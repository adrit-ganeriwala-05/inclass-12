import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/item.dart';

class FirestoreService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(Item item) async {
    await _collection.add(item.toMap());
  }

  Stream<List<Item>> streamItems() {
    return _collection.orderBy('name').snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Item.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList(),
    );
  }

  Future<void> updateItem(String id, Item item) async {
    await _collection.doc(id).update(item.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _collection.doc(id).delete();
  }
}
