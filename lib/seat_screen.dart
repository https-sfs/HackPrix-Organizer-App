import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamAssignmentResult {
  final String teamName;
  final String labName;
  final String seatRange;

  const TeamAssignmentResult({
    required this.teamName,
    required this.labName,
    required this.seatRange,
  });
}

class _HackPrixDialogColors {
  static const blue = Color(0xFF2D6BFF);
  static const text = Color(0xFF10203A);
  static const lime = Color(0xFFB7E200);
  static const muted = Color(0xFF5B6B80);
}

class SeatAllotmentLabs {
  SeatAllotmentLabs._();

  static const List<MapEntry<String, int>> labs = [
    MapEntry('222-A', 60),
    MapEntry('222-B', 30),
    MapEntry('222-C', 60),
    MapEntry('222-D1', 60),
    MapEntry('222-D2', 60),
    MapEntry('222-E', 30),
    MapEntry('222-F', 30),
    MapEntry('222-G', 30),
    MapEntry('201-A', 60),
    MapEntry('201-B', 30),
    MapEntry('301-A', 60),
    MapEntry('301-B', 60),
  ];

  static const List<String> allocationOrder = [
    '222-A',
    '222-B',
    '222-C',
    '222-D1',
    '222-D2',
    '222-E',
    '222-F',
    '222-G',
    '201-A',
    '201-B',
    '301-A',
    '301-B',
  ];

  static String displayLabel(String labName, int seatNumber) {
    switch (labName) {
      case '222-A':
      case '201-A':
      case '301-A':
        return 'A$seatNumber';
      case '222-B':
      case '201-B':
      case '301-B':
        return 'B$seatNumber';
      case '222-C':
        return 'C$seatNumber';
      case '222-D1':
        return 'D1-$seatNumber';
      case '222-D2':
        return 'D2-$seatNumber';
      case '222-E':
        return 'E$seatNumber';
      case '222-F':
        return 'F$seatNumber';
      case '222-G':
        return 'G$seatNumber';
      default:
        return '$labName-$seatNumber';
    }
  }
}

class SeatScreen extends StatelessWidget {
  const SeatScreen({super.key});

  void assignTeam(BuildContext context) {
    TextEditingController teamController = TextEditingController();
    TextEditingController sizeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Assign Team"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: teamController,
                decoration: InputDecoration(labelText: "Team Name"),
              ),
              TextField(
                controller: sizeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Team Size"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String teamName = teamController.text;

                if (teamName.isEmpty || sizeController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields")),
                  );
                  return;
                }

                int? size = int.tryParse(sizeController.text);

                if (size == null || size <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Enter valid team size")),
                  );
                  return;
                }

                final result = await assignSeats(context, teamName, size);

                if (!context.mounted) return;

                Navigator.pop(context);

                if (result != null) {
                  _showAssignmentSuccessDialog(context, result);
                }
              },
              child: Text("Assign"),
            ),
          ],
        );
      },
    );
  }

  void _showAssignmentSuccessDialog(
    BuildContext context,
    TeamAssignmentResult result,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _HackPrixDialogColors.lime.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: _HackPrixDialogColors.lime,
                  size: 40,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                '✅ Team Assigned Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _HackPrixDialogColors.text,
                ),
              ),
              const SizedBox(height: 20),
              _SuccessDetailRow(label: 'Team', value: result.teamName),
              const SizedBox(height: 10),
              _SuccessDetailRow(label: 'Lab', value: result.labName),
              const SizedBox(height: 10),
              _SuccessDetailRow(label: 'Seats', value: result.seatRange),
            ],
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _HackPrixDialogColors.blue,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  String _formatSeatRange(
    String labName,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> selectedSeats,
  ) {
    final firstData = selectedSeats.first.data();
    final lastData = selectedSeats.last.data();
    final firstNumber = firstData['seatNumber'] as int? ?? 0;
    final lastNumber = lastData['seatNumber'] as int? ?? 0;
    final firstLabel = SeatAllotmentLabs.displayLabel(labName, firstNumber);
    final lastLabel = SeatAllotmentLabs.displayLabel(labName, lastNumber);

    if (firstNumber == lastNumber) {
      return firstLabel;
    }

    return '$firstLabel-$lastLabel';
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _findConsecutiveSeats(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> availableSeats,
    int size,
  ) {
    for (var i = 0; i <= availableSeats.length - size; i++) {
      var isConsecutive = true;

      for (var j = 1; j < size; j++) {
        final current = availableSeats[i + j].data()['seatNumber'] as int? ?? 0;
        final previous =
            availableSeats[i + j - 1].data()['seatNumber'] as int? ?? 0;

        if (current != previous + 1) {
          isConsecutive = false;
          break;
        }
      }

      if (isConsecutive) {
        return availableSeats.sublist(i, i + size);
      }
    }

    return null;
  }

  Future<TeamAssignmentResult?> assignSeats(
    BuildContext context,
    String teamName,
    int size,
  ) async {
    var snapshot = await FirebaseFirestore.instance
        .collection('seats')
        .where('occupied', isEqualTo: false)
        .get();

    final seatsByLab =
        <String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>{};

    for (final seat in snapshot.docs) {
      final labName = seat.data()['labName'] as String?;
      if (labName == null || labName.isEmpty) continue;

      seatsByLab.putIfAbsent(labName, () => []).add(seat);
    }

    List<QueryDocumentSnapshot<Map<String, dynamic>>>? selectedSeats;

    for (final labName in SeatAllotmentLabs.allocationOrder) {
      final availableSeats = seatsByLab[labName];
      if (availableSeats == null || availableSeats.isEmpty) continue;

      availableSeats.sort(
        (a, b) => (a.data()['seatNumber'] as int? ?? 0).compareTo(
          b.data()['seatNumber'] as int? ?? 0,
        ),
      );

      selectedSeats = _findConsecutiveSeats(availableSeats, size);
      if (selectedSeats != null) break;
    }

    if (selectedSeats == null || selectedSeats.length < size) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No adjacent seats available")),
      );
      return null;
    }

    for (var seat in selectedSeats) {
      await FirebaseFirestore.instance.collection('seats').doc(seat.id).update({
        "occupied": true,
        "teamName": teamName,
      });
    }

    final labName = selectedSeats.first.data()['labName'] as String? ?? '';

    return TeamAssignmentResult(
      teamName: teamName,
      labName: labName,
      seatRange: _formatSeatRange(labName, selectedSeats),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Seat Allotment")),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () => assignTeam(context),
                child: Text("Assign Team"),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('seats').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final occupiedByLab = _occupiedCountByLab(snapshot.data?.docs ?? []);

                  return ListView.separated(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 32,
                    ),
                    itemCount: SeatAllotmentLabs.labs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final lab = SeatAllotmentLabs.labs[index];
                      return _LabCard(
                        labName: lab.key,
                        seatCount: lab.value,
                        occupiedCount: occupiedByLab[lab.key] ?? 0,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LabSeatScreen(labName: lab.key),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Map<String, int> _occupiedCountByLab(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final occupiedByLab = <String, int>{};

    for (final doc in docs) {
      final data = doc.data();
      final labName = data['labName'] as String?;
      if (labName == null || labName.isEmpty) continue;

      final occupied =
          data['occupied'] == true || data['status'] == 'occupied';
      if (occupied) {
        occupiedByLab[labName] = (occupiedByLab[labName] ?? 0) + 1;
      }
    }

    return occupiedByLab;
  }
}

class _SuccessDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _SuccessDetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _HackPrixDialogColors.blue.withValues(alpha: 0.12)),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: _HackPrixDialogColors.text,
          ),
          children: [
            TextSpan(
              text: '$label:\n',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _HackPrixDialogColors.muted,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LabCard extends StatelessWidget {
  final String labName;
  final int seatCount;
  final int occupiedCount;
  final VoidCallback onTap;

  const _LabCard({
    required this.labName,
    required this.seatCount,
    required this.occupiedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = seatCount == 0 ? 0.0 : occupiedCount / seatCount;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: _HackPrixDialogColors.blue.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: _HackPrixDialogColors.blue.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _HackPrixDialogColors.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$seatCount Seats',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _HackPrixDialogColors.muted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '$occupiedCount / $seatCount Occupied',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _HackPrixDialogColors.text,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE8EEF8),
                          color: _HackPrixDialogColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: _HackPrixDialogColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LabSeatScreen extends StatelessWidget {
  final String labName;

  const LabSeatScreen({super.key, required this.labName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(labName)),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('seats')
              .where('labName', isEqualTo: labName)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final seats = snapshot.data!.docs.toList()
              ..sort(
                (a, b) => (a.data()['seatNumber'] as int? ?? 0).compareTo(
                  b.data()['seatNumber'] as int? ?? 0,
                ),
              );

            return GridView.builder(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 32,
              ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: seats.length,
            itemBuilder: (context, index) {
              final seat = seats[index];
              final data = seat.data();
              final occupied = data['occupied'] == true;
              final teamName = data['teamName'] as String? ?? '';
              final seatNumber = data['seatNumber'] as int? ?? 0;
              final color = occupied ? Colors.red : Colors.green;

              return Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      SeatAllotmentLabs.displayLabel(labName, seatNumber),
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    if (teamName.isNotEmpty)
                      Text(
                        teamName,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}
