import 'package:flutter/material.dart';
import 'main.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  static const _days = [
    _ScheduleDay(
      label: 'DAY 1',
      date: '13 June',
      events: [
        _ScheduleEvent(
          time: '08:00 AM',
          title: 'Registration & Check-in',
          accent: HackPrixColors.blue,
        ),
        _ScheduleEvent(
          time: '09:30 AM',
          title: 'Opening Ceremony',
          accent: HackPrixColors.orange,
        ),
        _ScheduleEvent(
          time: '11:00 AM',
          title: 'Hacking Starts',
          accent: HackPrixColors.lime,
        ),
        _ScheduleEvent(
          time: '12:00 PM',
          title: 'Mentoring Round 1',
          accent: HackPrixColors.purple,
        ),
        _ScheduleEvent(
          time: '01:30 PM',
          title: 'Lunch',
          accent: HackPrixColors.lime,
        ),
        _ScheduleEvent(
          time: '03:00 PM',
          title: 'Group Photo',
          accent: HackPrixColors.cyan,
        ),
        _ScheduleEvent(
          time: '04:00 PM',
          title: 'MLH Workshop',
          accent: HackPrixColors.purple,
        ),
        _ScheduleEvent(
          time: '06:00 PM',
          title: 'Mentoring Round 2',
          accent: HackPrixColors.purple,
        ),
        _ScheduleEvent(
          time: '09:00 PM',
          title: 'Dinner',
          accent: HackPrixColors.lime,
        ),
        _ScheduleEvent(
          time: '10:00 PM',
          title: 'Campfire & Chill',
          accent: HackPrixColors.orange,
        ),
        _ScheduleEvent(
          time: '11:30 PM',
          title: 'Mini-Events',
          accent: HackPrixColors.purple,
        ),
      ],
    ),
    _ScheduleDay(
      label: 'DAY 2',
      date: '14 June',
      events: [
        _ScheduleEvent(
          time: '07:30 AM',
          title: 'Breakfast',
          accent: HackPrixColors.lime,
        ),
        _ScheduleEvent(
          time: '11:00 AM',
          title: 'Mentoring Round 3',
          accent: HackPrixColors.purple,
        ),
        _ScheduleEvent(
          time: '01:30 PM',
          title: 'Lunch',
          accent: HackPrixColors.lime,
        ),
        _ScheduleEvent(
          time: '03:00 PM',
          title: 'Submission Starts',
          accent: HackPrixColors.cyan,
        ),
        _ScheduleEvent(
          time: '04:15 PM',
          title: 'Judging Starts',
          accent: HackPrixColors.blue,
        ),
        _ScheduleEvent(
          time: '06:00 PM',
          title: 'Hacking Ends / Judging Ends',
          accent: HackPrixColors.lime,
        ),
        _ScheduleEvent(
          time: '06:00 PM',
          title: 'Wrap-up & Chill',
          accent: HackPrixColors.cyan,
        ),
        _ScheduleEvent(
          time: '06:30 PM',
          title: 'Fireside Chat Session & Closing Ceremony',
          accent: HackPrixColors.purple,
        ),
        _ScheduleEvent(
          time: '08:30 PM',
          title: 'Hackathon Ends / Closing Ceremony',
          accent: HackPrixColors.orange,
        ),
        _ScheduleEvent(
          time: '09:30 PM',
          title: 'Buses Leave',
          accent: HackPrixColors.blue,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HackPrixColors.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HackPrixRibbon(),
            const SizedBox(height: 22),
            const Text(
              'HackPrix Schedule',
              style: TextStyle(
                fontSize: 32,
                height: 1.05,
                fontWeight: FontWeight.w800,
                color: HackPrixColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '36 Hours of Hacking',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: HackPrixColors.blue.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 28),
            for (var i = 0; i < _days.length; i++) ...[
              _DaySection(day: _days[i]),
              if (i != _days.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduleDay {
  final String label;
  final String date;
  final List<_ScheduleEvent> events;

  const _ScheduleDay({
    required this.label,
    required this.date,
    required this.events,
  });
}

class _ScheduleEvent {
  final String time;
  final String title;
  final Color? accent;
  final bool highlight;

  const _ScheduleEvent({
    required this.time,
    required this.title,
    this.accent,
    this.highlight = false,
  });
}

class _DaySection extends StatelessWidget {
  final _ScheduleDay day;

  const _DaySection({required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                HackPrixColors.blue.withValues(alpha: 0.12),
                HackPrixColors.cyan.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: HackPrixColors.blue.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            children: [
              Text(
                day.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: HackPrixColors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: HackPrixColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                day.date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: HackPrixColors.text,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Stack(
          children: [
            Positioned(
              left: 17,
              top: 12,
              bottom: 12,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      HackPrixColors.blue.withValues(alpha: 0.45),
                      HackPrixColors.cyan.withValues(alpha: 0.35),
                      HackPrixColors.purple.withValues(alpha: 0.30),
                    ],
                  ),
                ),
              ),
            ),
            Column(
              children: [
                for (var i = 0; i < day.events.length; i++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: i == day.events.length - 1 ? 0 : 16,
                    ),
                    child: _TimelineEventCard(event: day.events[i]),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineEventCard extends StatelessWidget {
  final _ScheduleEvent event;

  const _TimelineEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final accent = event.accent ?? HackPrixColors.blue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(top: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: accent, width: 3),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accent.withValues(alpha: 0.20),
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.time,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: HackPrixColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
