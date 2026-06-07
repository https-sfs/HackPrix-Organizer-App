import 'package:cloud_firestore/cloud_firestore.dart';

class SeatResetService {
  SeatResetService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const int _batchLimit = 450;

  Future<void> resetAll() async {
    final snapshot = await _firestore.collection('seats').get();

    for (var i = 0; i < snapshot.docs.length; i += _batchLimit) {
      final batch = _firestore.batch();
      final chunk = snapshot.docs.skip(i).take(_batchLimit);

      for (final doc in chunk) {
        batch.update(doc.reference, {
          'status': 'available',
          'team': '',
          'timestamp': FieldValue.delete(),
        });
      }

      await batch.commit();
    }
  }
}
