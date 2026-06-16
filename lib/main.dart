import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_bootstrap.dart';
import 'firebase_initializer.dart';
import 'notification_service.dart';
import 'seat_reset_service.dart';
import 'seat_screen.dart';
import 'organizer_notification_screen.dart';
import 'announcements_screen.dart';
import 'my_seat_page.dart';
import 'schedule_page.dart';
import 'guidelines_page.dart';
import 'admin_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  await bootstrapApp();
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
      navigatorKey: hackPrixNavigatorKey,
      routes: {
        '/announcements': (_) => const ResponsiveAppShell(
          child: AnnouncementsScreen(),
        ),
      },
      home: const ResponsiveAppShell(child: ParticipantShell()),
    );
  }
}

class ResponsiveAppShell extends StatelessWidget {
  final Widget child;

  const ResponsiveAppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final maxContentWidth = width >= 1200
            ? 960.0
            : width >= 900
            ? 820.0
            : width;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: child,
          ),
        );
      },
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

  @override
  void initState() {
    super.initState();
    NotificationService.instance.onViewUpdates = (context) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      setState(() => _index = 3);
    };
  }

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
                if (pinController.text.trim() == '0304') {
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
    final pages = [
      const ParticipantHomePage(),
      const MySeatPage(),
      const SchedulePage(),
      const AnnouncementsScreen(),
      const GuidelinesPage(),
    ];

    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() => _index = 0);
      },
      child: Scaffold(
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
        body: IndexedStack(index: _index, children: pages),
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
              label: 'Guidelines',
            ),
          ],
        ),
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

  void _openFeaturePage(
    BuildContext context, {
    required String title,
    required Widget page,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: SafeArea(child: page),
        ),
      ),
    );
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
              FeatureTile(
                title: 'My Seat',
                subtitle: 'Your lab + seat',
                icon: Icons.event_seat,
                accent: HackPrixColors.orange,
                onTap: () => _openFeaturePage(
                  context,
                  title: 'My Seat',
                  page: const MySeatPage(),
                ),
              ),
              FeatureTile(
                title: 'Schedule',
                subtitle: 'Day-wise flow',
                icon: Icons.schedule,
                accent: HackPrixColors.cyan,
                onTap: () => _openFeaturePage(
                  context,
                  title: 'Schedule',
                  page: const SchedulePage(),
                ),
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
              FeatureTile(
                title: 'Guidelines',
                subtitle: 'Event Guidelines',
                icon: Icons.menu_book,
                accent: HackPrixColors.lime,
                onTap: () => _openFeaturePage(
                  context,
                  title: 'Guidelines',
                  page: const GuidelinesPage(),
                ),
              ),
            ],
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
    final borderRadius = BorderRadius.circular(26);
    final content = Column(
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
    );

    final shadow = BoxShadow(
      color: accent.withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, 10),
    );

    if (onTap == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
          boxShadow: [shadow],
        ),
        child: content,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [shadow],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          splashColor: accent.withValues(alpha: 0.16),
          highlightColor: accent.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ),
      ),
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

  static const _resetOrganizerPin = '9016';

  void _confirmResetSeats(BuildContext context) {
    final pinController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Organizer PIN Required'),
          content: TextField(
            controller: pinController,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Enter Organizer PIN',
            ),
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
                if (pinController.text.trim() != _resetOrganizerPin) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Incorrect Organizer PIN')),
                  );
                  return;
                }

                Navigator.pop(dialogContext);
                _showFinalResetConfirmation(context);
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  void _showFinalResetConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('⚠️ Final Confirmation'),
          content: const Text(
            'This will permanently remove ALL seat allocations from HackPrix.\nThis action cannot be undone.',
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
              child: const Text('Yes, Reset'),
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
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).padding.bottom + 32,
          ),
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
          const _OrganizerLiveStatsDashboard(),
          const SizedBox(height: 24),
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
        ],
        ),
      ),
    );
  }
}

class _OrganizerSeatStats {
  final int totalSeats;
  final int occupiedSeats;
  final int availableSeats;
  final int teamsAssigned;
  final int labsFilled;

  const _OrganizerSeatStats({
    required this.totalSeats,
    required this.occupiedSeats,
    required this.availableSeats,
    required this.teamsAssigned,
    required this.labsFilled,
  });

  factory _OrganizerSeatStats.fromDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    var occupiedSeats = 0;
    final teams = <String>{};
    final occupiedByLab = <String, int>{};

    for (final doc in docs) {
      final data = doc.data();
      final occupied =
          data['occupied'] == true || data['status'] == 'occupied';

      if (occupied) {
        occupiedSeats++;
        final labName = data['labName'] as String?;
        if (labName != null && labName.isNotEmpty) {
          occupiedByLab[labName] = (occupiedByLab[labName] ?? 0) + 1;
        }
      }

      final teamName =
          (data['teamName'] as String? ?? data['team'] as String? ?? '')
              .trim();
      if (teamName.isNotEmpty) {
        teams.add(teamName);
      }
    }

    final totalSeats = SeatAllotmentLabs.labs.fold<int>(
      0,
      (sum, lab) => sum + lab.value,
    );

    var labsFilled = 0;
    for (final lab in SeatAllotmentLabs.labs) {
      if ((occupiedByLab[lab.key] ?? 0) > 0) {
        labsFilled++;
      }
    }

    return _OrganizerSeatStats(
      totalSeats: totalSeats,
      occupiedSeats: occupiedSeats,
      availableSeats: totalSeats - occupiedSeats,
      teamsAssigned: teams.length,
      labsFilled: labsFilled,
    );
  }
}

class _OrganizerLiveStatsDashboard extends StatelessWidget {
  const _OrganizerLiveStatsDashboard();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('seats').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final stats = _OrganizerSeatStats.fromDocs(snapshot.data?.docs ?? []);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Stats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: HackPrixColors.text,
              ),
            ),
            const SizedBox(height: 12),
            _OrganizerSummaryCards(stats: stats),
          ],
        );
      },
    );
  }
}

class _OrganizerSummaryCards extends StatelessWidget {
  final _OrganizerSeatStats stats;

  const _OrganizerSummaryCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 720
            ? (constraints.maxWidth - 24) / 3
            : (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _OrganizerStatCard(
              width: cardWidth,
              label: 'Total Seats',
              value: '${stats.totalSeats}',
              accent: HackPrixColors.blue,
            ),
            _OrganizerStatCard(
              width: cardWidth,
              label: 'Occupied Seats',
              value: '${stats.occupiedSeats}',
              accent: const Color(0xFFE53935),
            ),
            _OrganizerStatCard(
              width: cardWidth,
              label: 'Available Seats',
              value: '${stats.availableSeats}',
              accent: const Color(0xFF43A047),
            ),
            _OrganizerStatCard(
              width: cardWidth,
              label: 'Teams Assigned',
              value: '${stats.teamsAssigned}',
              accent: HackPrixColors.purple,
            ),
            _OrganizerStatCard(
              width: cardWidth,
              label: 'Labs Filled',
              value: '${stats.labsFilled}',
              accent: HackPrixColors.orange,
            ),
          ],
        );
      },
    );
  }
}

class _OrganizerStatCard extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final Color accent;

  const _OrganizerStatCard({
    required this.width,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5B6B80),
            ),
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
