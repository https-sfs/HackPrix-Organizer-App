import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'seat_screen.dart';

class MySeatPage extends StatefulWidget {
  const MySeatPage({super.key});

  @override
  State<MySeatPage> createState() => _MySeatPageState();
}

class _MySeatPageState extends State<MySeatPage> {
  final _teamController = TextEditingController();
  bool _loading = false;
  String? _labName;
  String? _seatRange;
  bool _notFound = false;

  @override
  void dispose() {
    _teamController.dispose();
    super.dispose();
  }

  String _formatSeatRanges(String labName, List<int> seatNumbers) {
    if (seatNumbers.isEmpty) return '';

    final sorted = [...seatNumbers]..sort();
    final ranges = <String>[];
    var rangeStart = sorted.first;
    var rangeEnd = sorted.first;

    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i] == rangeEnd + 1) {
        rangeEnd = sorted[i];
      } else {
        ranges.add(_formatRange(labName, rangeStart, rangeEnd));
        rangeStart = sorted[i];
        rangeEnd = sorted[i];
      }
    }

    ranges.add(_formatRange(labName, rangeStart, rangeEnd));
    return ranges.join(', ');
  }

  String _formatRange(String labName, int start, int end) {
    final firstLabel = SeatAllotmentLabs.displayLabel(labName, start);
    if (start == end) return firstLabel;

    final lastLabel = SeatAllotmentLabs.displayLabel(labName, end);
    return '$firstLabel-$lastLabel';
  }

  Future<void> _findMySeat() async {
    final teamName = _teamController.text.trim();

    if (teamName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your team name')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _notFound = false;
      _labName = null;
      _seatRange = null;
    });

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('seats')
          .where('teamName', isEqualTo: teamName)
          .get();

      if (!mounted) return;

      if (snapshot.docs.isEmpty) {
        setState(() {
          _loading = false;
          _notFound = true;
        });
        return;
      }

      final labName = snapshot.docs.first.data()['labName'] as String? ?? '';
      final seatNumbers = snapshot.docs
          .map((doc) => doc.data()['seatNumber'] as int? ?? 0)
          .where((number) => number > 0)
          .toList();

      setState(() {
        _loading = false;
        _labName = labName;
        _seatRange = _formatSeatRanges(labName, seatNumbers);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _notFound = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HackPrixRibbon(),
          const SizedBox(height: 20),
          const Text(
            'My Seat',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: HackPrixColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your team name to find your allocated lab and seats.',
            style: TextStyle(fontSize: 14, color: Color(0xFF5B6B80)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: HackPrixColors.orange.withValues(alpha: 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: HackPrixColors.orange.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _teamController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    hintText: 'Enter your team name',
                  ),
                  onSubmitted: (_) => _findMySeat(),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _findMySeat,
                  style: FilledButton.styleFrom(
                    backgroundColor: HackPrixColors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Find My Seat'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_notFound)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: HackPrixColors.purple.withValues(alpha: 0.18),
                ),
              ),
              child: const Text(
                'No seat allocation found for this team.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF5B6B80),
                ),
              ),
            ),
          if (_labName != null && _seatRange != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D6BFF), Color(0xFF18C7F2)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: HackPrixColors.blue.withValues(alpha: 0.20),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Welcome to HackPrix!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '📍 Your Lab: $_labName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your Seats: $_seatRange',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Best of Luck for HackPrix!\nHappy Hacking!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
