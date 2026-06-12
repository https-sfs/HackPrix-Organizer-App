import 'package:cloud_firestore/cloud_firestore.dart';

/// One-time Firestore seat seeding for HackPrix labs.
///
/// Inserts seats into the `seats` collection only when a document
/// with the same ID does not already exist.
///
/// Manual invocation (run once, then remove the temporary call):
/// ```dart
/// await HackPrixSeatSeedService().seedIfMissing();
/// ```
class HackPrixSeatSeedService {
  HackPrixSeatSeedService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const int _batchLimit = 450;

  static const Map<String, int> labs = {
    '222-C': 60,
    '222-A': 60,
    '222-B': 30,
    '222-G': 30,
    '222-E': 30,
    '222-F': 30,
    '201-A': 60,
    '201-B': 30,
    '301-A': 60,
    '301-B': 60,
    '222-D1': 60,
    '222-D2': 60,
  };

  static const List<String> labOrder = [
    '222-C',
    '222-A',
    '222-B',
    '222-G',
    '222-E',
    '222-F',
    '201-A',
    '201-B',
    '301-A',
    '301-B',
    '222-D1',
    '222-D2',
  ];

  static String documentId(String labName, int seatNumber) =>
      '${labName}_$seatNumber';

  static Map<String, dynamic> seatData(String labName, int seatNumber) => {
    'labName': labName,
    'seatNumber': seatNumber,
    'occupied': false,
    'teamName': '',
  };

  /// Creates missing seat documents only. Existing documents are left unchanged.
  Future<SeatSeedResult> seedIfMissing() async {
    final existingSnapshot = await _firestore.collection('seats').get();
    final existingIds = existingSnapshot.docs.map((doc) => doc.id).toSet();

    var batch = _firestore.batch();
    var batchCount = 0;
    var created = 0;
    var skipped = 0;

    for (final labName in labOrder) {
      final capacity = labs[labName]!;

      for (var seatNumber = 1; seatNumber <= capacity; seatNumber++) {
        final id = documentId(labName, seatNumber);

        if (existingIds.contains(id)) {
          skipped++;
          continue;
        }

        batch.set(
          _firestore.collection('seats').doc(id),
          seatData(labName, seatNumber),
        );
        batchCount++;
        created++;

        if (batchCount >= _batchLimit) {
          await batch.commit();
          batch = _firestore.batch();
          batchCount = 0;
        }
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    return SeatSeedResult(created: created, skipped: skipped);
  }
}

class SeatSeedResult {
  const SeatSeedResult({required this.created, required this.skipped});

  final int created;
  final int skipped;

  int get totalExpected => HackPrixSeatSeedService.labOrder.fold(
    0,
    (sum, lab) => sum + HackPrixSeatSeedService.labs[lab]!,
  );

  @override
  String toString() =>
      'SeatSeedResult(created: $created, skipped: $skipped, totalExpected: $totalExpected)';
}
