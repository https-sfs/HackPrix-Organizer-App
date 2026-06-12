import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'notification_category.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is! Timestamp) return '';

    final dateTime = timestamp.toDate();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year} • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final listPadding = EdgeInsets.only(
      left: 20,
      right: 20,
      top: 20,
      bottom: MediaQuery.of(context).padding.bottom + 32,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('notifications')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: HackPrixColors.purple),
              );
            }

            if (snapshot.hasError) {
              return const Center(
                child: Text(
                  'Unable to load announcements.',
                  style: TextStyle(color: Color(0xFF5B6B80)),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];

            if (docs.isEmpty) {
              return ListView(
                padding: listPadding,
                children: const [
                  HackPrixRibbon(),
                  SizedBox(height: 24),
                  _EmptyAnnouncementsState(),
                ],
              );
            }

            return ListView.separated(
              padding: listPadding,
              itemCount: docs.length + 1,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) return const HackPrixRibbon();

                final data = docs[index - 1].data();
                final message = data['message'] as String? ?? '';
                final timestamp = _formatTimestamp(data['timestamp']);
                final category = NotificationCategory.fromValue(
                  data['category'] as String?,
                );

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: category.accent.withValues(alpha: 0.18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: category.accent.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(category.icon, size: 16, color: category.accent),
                          const SizedBox(width: 6),
                          Text(
                            category.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: category.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: HackPrixColors.text,
                        ),
                      ),
                      if (timestamp.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          timestamp,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7A90),
                          ),
                        ),
                      ],
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

class _EmptyAnnouncementsState extends StatelessWidget {
  const _EmptyAnnouncementsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: HackPrixColors.purple.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: HackPrixColors.purple.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.campaign_outlined,
              color: HackPrixColors.purple,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No announcements yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: HackPrixColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Live updates from organizers will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF5B6B80)),
          ),
        ],
      ),
    );
  }
}
