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
        final data = doc.data();
        final updates = <String, dynamic>{
          'occupied': false,
          'teamName': '',
        };

        if (data.containsKey('timestamp')) {
          updates['timestamp'] = FieldValue.delete();
        }
        if (data.containsKey('status')) {
          updates['status'] = 'available';
        }
        if (data.containsKey('team')) {
          updates['team'] = '';
        }

        batch.update(doc.reference, updates);
      }

      await batch.commit();
    }
  }
}
