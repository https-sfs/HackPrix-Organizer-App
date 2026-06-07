import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';
import 'seat_reset_service.dart';
import 'seat_screen.dart';
import 'organizer_notification_screen.dart';
import 'announcements_screen.dart';
import 'admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.instance.initialize();
  runApp(const HackPrixApp());
}

class HackPrixColors {
  static const blue = Color(0xFF2D6BFF);
  static const background = Color(0xFFF7FAFF);
  static const card = Colors.white;
  static const text = Color(0xFF10203A);

  
  static const orange = Color(0xFFFF9B2F);
  static const lime = Color(0xFFB7E200);
  static const cyan = Color(0xFF18C7F2);
  static const purple = Color(0xFF9E45E8);
  static const yellow = Color(0xFFFFC61A);
}

ThemeData buildHackPrixTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: HackPrixColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: HackPrixColors.blue,
      brightness: Brightness.light,
      primary: HackPrixColors.blue,
      secondary: HackPrixColors.purple,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: HackPrixColors.background,
      foregroundColor: HackPrixColors.text,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: HackPrixColors.text,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: HackPrixColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.blue.shade100),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.blue.shade100),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: HackPrixColors.blue, width: 2),
      ),
    ),
  );
}

class HackPrixApp extends StatelessWidget {
  const HackPrixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HackPrix',
      theme: buildHackPrixTheme(),
      home: const ParticipantShell(),
    );
  }
}

class ParticipantShell extends StatefulWidget {
  const ParticipantShell({super.key});

  @override
  State<ParticipantShell> createState() => _ParticipantShellState();
}

class _ParticipantShellState extends State<ParticipantShell> {
  int _index = 0;

  final List<Widget> _pages = const [
    ParticipantHomePage(),
    MySeatPage(),
    SchedulePage(),
    AnnouncementsPage(),
    HelpPage(),
  ];

  void _openOrganizerGate() {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Organizer Access'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Enter PIN',
              hintText: 'Hidden admin access',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (pinController.text.trim() == '19090304') {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrganizerPanelPage(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Wrong PIN')));
                }
              },
              child: const Text('Unlock'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _openOrganizerGate,
          child: const Text('HackPrix'),
        ),
        actions: [
          IconButton(
            onPressed: _openOrganizerGate,
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Organizer access',
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        backgroundColor: Colors.white,
        indicatorColor: HackPrixColors.blue.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_seat_outlined),
            selectedIcon: Icon(Icons.event_seat),
            label: 'My Seat',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: 'Updates',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline),
            selectedIcon: Icon(Icons.help),
            label: 'Help',
          ),
        ],
      ),
    );
  }
}

class HackPrixRibbon extends StatelessWidget {
  const HackPrixRibbon({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = [
      HackPrixColors.orange,
      HackPrixColors.lime,
      HackPrixColors.cyan,
      HackPrixColors.purple,
      HackPrixColors.yellow,
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Row(
        children: List.generate(colors.length, (index) {
          return Expanded(child: Container(height: 12, color: colors[index]));
        }),
      ),
    );
  }
}

class ParticipantHomePage extends StatelessWidget {
  const ParticipantHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HackPrixRibbon(),
          const SizedBox(height: 16),
          const Text(
            'Build For Better',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: HackPrixColors.blue,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Welcome to HackPrix',
            style: TextStyle(
              fontSize: 32,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: HackPrixColors.text,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your event companion for seat info, announcements, schedule, and live updates.',
            style: TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color(0xFF5B6B80),
            ),
          ),
          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D6BFF), Color(0xFF18C7F2)],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HackPrix 2026',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Participant-first event access • live updates • clean info flow',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.2,
            children: [
              const FeatureTile(
                title: 'My Seat',
                subtitle: 'Your lab + seat',
                icon: Icons.event_seat,
                accent: HackPrixColors.orange,
              ),
              const FeatureTile(
                title: 'Schedule',
                subtitle: 'Day-wise flow',
                icon: Icons.schedule,
                accent: HackPrixColors.cyan,
              ),
              FeatureTile(
                title: 'Announcements',
                subtitle: 'Live updates',
                icon: Icons.campaign,
                accent: HackPrixColors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnnouncementsScreen(),
                    ),
                  );
                },
              ),
              const FeatureTile(
                title: 'Guidelines',
                subtitle: 'Rules & help',
                icon: Icons.menu_book,
                accent: HackPrixColors.lime,
              ),
            ],
          ),

          const SizedBox(height: 18),

          _SectionTitle(title: 'Quick Notes', accent: HackPrixColors.yellow),
          const SizedBox(height: 10),
          const _NoteCard(
            title: 'Entry flow',
            body:
                'Check-in should be quick, no confusion, and usable during event pressure.',
            accent: HackPrixColors.blue,
          ),
          const SizedBox(height: 12),
          const _NoteCard(
            title: 'Organizer tools',
            body:
                'Hidden inside the same app, protected by PIN, so participants do not see control tools.',
            accent: HackPrixColors.purple,
          ),
        ],
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;

  const FeatureTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: HackPrixColors.text,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7A90)),
          ),
        ],
      ),
    );

    if (onTap == null) return tile;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: tile,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color accent;

  const _SectionTitle({required this.title, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: HackPrixColors.text,
          ),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String title;
  final String body;
  final Color accent;

  const _NoteCard({
    required this.title,
    required this.body,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: HackPrixColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: Color(0xFF5B6B80),
            ),
          ),
        ],
      ),
    );
  }
}

class MySeatPage extends StatelessWidget {
  const MySeatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      title: 'My Seat',
      subtitle: 'Your seat details will appear here after check-in.',
      icon: Icons.event_seat,
      accent: HackPrixColors.orange,
    );
  }
}

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      title: 'Schedule',
      subtitle: 'Day-wise event flow will go here.',
      icon: Icons.schedule,
      accent: HackPrixColors.cyan,
    );
  }
}

class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      title: 'Announcements',
      subtitle: 'Organizer updates will show here in real time.',
      icon: Icons.campaign,
      accent: HackPrixColors.purple,
    );
  }
}

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderPage(
      title: 'Help',
      subtitle: 'Support contacts, guidelines, and event help.',
      icon: Icons.help,
      accent: HackPrixColors.lime,
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _PlaceholderPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: HackPrixColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF5B6B80),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrganizerPanelPage extends StatelessWidget {
  const OrganizerPanelPage({super.key});

  void _confirmResetSeats(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset All Seats?'),
          content: const Text(
            'This will clear all seat assignments in Firestore. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: HackPrixColors.purple,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetSeats(context);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetSeats(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const PopScope(
          canPop: false,
          child: Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: HackPrixColors.purple),
                    SizedBox(height: 16),
                    Text(
                      'Resetting seats...',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: HackPrixColors.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    try {
      await SeatResetService().resetAll();

      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All seats reset successfully')),
      );
    } catch (_) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to reset seats. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Panel')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const HackPrixRibbon(),
          const SizedBox(height: 18),
          const Text(
            'Organizer Control',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: HackPrixColors.text,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hidden tools for seat allocation, live stats, and event control.',
            style: TextStyle(fontSize: 14, color: Color(0xFF5B6B80)),
          ),
          const SizedBox(height: 18),
          _OrganizerActionTile(
            title: 'Seat Allotment',
            subtitle: 'Assign adjacent seats to teams',
            accent: HackPrixColors.orange,
            icon: Icons.event_seat,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SeatScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _OrganizerActionTile(
            title: 'Reset Seats',
            subtitle: 'Clear current seat occupancy',
            accent: HackPrixColors.purple,
            icon: Icons.restart_alt,
            onTap: () => _confirmResetSeats(context),
          ),
          const SizedBox(height: 12),
          _OrganizerActionTile(
            title: 'Send Notification',
            subtitle: 'Broadcast an update to participants',
            accent: HackPrixColors.cyan,
            icon: Icons.notifications_active,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OrganizerNotificationScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _OrganizerActionTile(
            title: 'Live Stats',
            subtitle: 'View occupancy and team counts',
            accent: HackPrixColors.lime,
            icon: Icons.insights,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Live stats page will come next')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OrganizerActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  const _OrganizerActionTile({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: HackPrixColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5B6B80),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
