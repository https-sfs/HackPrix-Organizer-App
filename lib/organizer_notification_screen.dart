import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class OrganizerNotificationScreen extends StatefulWidget {
  const OrganizerNotificationScreen({super.key});

  @override
  State<OrganizerNotificationScreen> createState() =>
      _OrganizerNotificationScreenState();
}

class _OrganizerNotificationScreenState
    extends State<OrganizerNotificationScreen> {
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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

  Future<void> _confirmDeleteNotification(String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Notification?'),
          content: const Text(
            'This announcement will be permanently deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(docId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification deleted')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete notification')),
      );
    }
  }

  Future<void> _sendNotification() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    setState(() => _sending = true);

    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification Sent')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send notification')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notification')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const HackPrixRibbon(),
          const SizedBox(height: 18),
          const Text(
            'Broadcast Update',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: HackPrixColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Send a message to all participants in real time.',
            style: TextStyle(fontSize: 14, color: Color(0xFF5B6B80)),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: HackPrixColors.cyan.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _messageController,
                  maxLines: 5,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Notification message',
                    hintText: 'Type your announcement here...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _sending ? null : _sendNotification,
                  style: FilledButton.styleFrom(
                    backgroundColor: HackPrixColors.cyan,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  icon: _sending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_sending ? 'Sending...' : 'Send'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Recent Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: HackPrixColors.text,
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: HackPrixColors.cyan,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Unable to load notifications.',
                    style: TextStyle(color: Color(0xFF5B6B80)),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: HackPrixColors.cyan.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Text(
                    'No notifications sent yet.',
                    style: TextStyle(color: Color(0xFF5B6B80)),
                  ),
                );
              }

              return Column(
                children: [
                  for (final doc in docs) ...[
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: HackPrixColors.cyan.withValues(alpha: 0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: HackPrixColors.cyan.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.data()['message'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    height: 1.45,
                                    fontWeight: FontWeight.w600,
                                    color: HackPrixColors.text,
                                  ),
                                ),
                                if (_formatTimestamp(
                                  doc.data()['timestamp'],
                                ).isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    _formatTimestamp(doc.data()['timestamp']),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7A90),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _confirmDeleteNotification(doc.id),
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.red,
                            tooltip: 'Delete notification',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
