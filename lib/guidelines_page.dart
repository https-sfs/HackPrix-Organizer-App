import 'package:flutter/material.dart';
import 'guidelines_content.dart';
import 'main.dart';

class _SectionUi {
  final String icon;
  final Color accent;

  const _SectionUi({required this.icon, required this.accent});
}

class GuidelinesPage extends StatefulWidget {
  const GuidelinesPage({super.key});

  @override
  State<GuidelinesPage> createState() => _GuidelinesPageState();
}

class _GuidelinesPageState extends State<GuidelinesPage> {
  int? _expandedIndex;

  static const _sectionUi = [
    _SectionUi(icon: '📖', accent: HackPrixColors.blue),
    _SectionUi(icon: '👋', accent: HackPrixColors.orange),
    _SectionUi(icon: '🤝', accent: HackPrixColors.lime),
    _SectionUi(icon: '❌', accent: HackPrixColors.purple),
    _SectionUi(icon: '🚨', accent: HackPrixColors.cyan),
    _SectionUi(icon: '⚖️', accent: HackPrixColors.yellow),
    _SectionUi(icon: '🎉', accent: HackPrixColors.orange),
    _SectionUi(icon: '📧', accent: HackPrixColors.blue),
  ];

  void _onCardTap(int index) {
    setState(() {
      _expandedIndex = _expandedIndex == index ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HackPrixColors.background,
      child: ListView(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 32,
        ),
        children: [
          const HackPrixRibbon(),
          const SizedBox(height: 24),
          const _GuidelinesHero(),
          const SizedBox(height: 32),
          for (var i = 0; i < GuidelinesContent.sections.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == GuidelinesContent.sections.length - 1 ? 24 : 20,
              ),
              child: _GuidelineExpansionCard(
                section: GuidelinesContent.sections[i],
                ui: _sectionUi[i],
                expanded: _expandedIndex == i,
                onTap: () => _onCardTap(i),
              ),
            ),
          const _GuidelinesClosingCard(),
        ],
      ),
    );
  }
}

class _GuidelinesHero extends StatelessWidget {
  const _GuidelinesHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            HackPrixColors.blue.withValues(alpha: 0.06),
            HackPrixColors.cyan.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: HackPrixColors.blue.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: HackPrixColors.blue.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Participation Guidelines',
            style: TextStyle(
              fontSize: 32,
              height: 1.05,
              fontWeight: FontWeight.w800,
              color: HackPrixColors.text,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Build respectfully.\nCollaborate ethically.\nEnjoy HackPrix 2026.',
            style: TextStyle(
              fontSize: 16,
              height: 1.65,
              fontWeight: FontWeight.w600,
              color: HackPrixColors.text.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidelinesClosingCard extends StatelessWidget {
  const _GuidelinesClosingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HackPrixColors.blue.withValues(alpha: 0.10),
            HackPrixColors.cyan.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: HackPrixColors.blue.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: HackPrixColors.blue.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💙 Build For Better',
            style: TextStyle(
              fontSize: 20,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: HackPrixColors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Let's make HackPrix a safe, inclusive, respectful and unforgettable experience for everyone.",
            style: TextStyle(
              fontSize: 15,
              height: 1.7,
              fontWeight: FontWeight.w500,
              color: HackPrixColors.text.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidelineExpansionCard extends StatelessWidget {
  final GuidelineSection section;
  final _SectionUi ui;
  final bool expanded;
  final VoidCallback onTap;

  static const _animationDuration = Duration(milliseconds: 280);

  const _GuidelineExpansionCard({
    required this.section,
    required this.ui,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = ui.accent;
    final expandedFill = accent.withValues(alpha: 0.07);

    return AnimatedContainer(
      duration: _animationDuration,
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: expanded ? expandedFill : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withValues(alpha: expanded ? 0.24 : 0.14),
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: expanded ? 0.14 : 0.08),
            blurRadius: expanded ? 26 : 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 22, 18, 22),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.22),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ui.icon,
                        style: const TextStyle(fontSize: 22, height: 1),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        section.heading,
                        style: TextStyle(
                          fontSize: 17,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: expanded
                              ? HackPrixColors.text
                              : HackPrixColors.text.withValues(alpha: 0.92),
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: _animationDuration,
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 28,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              heightFactor: expanded ? 1 : 0,
              duration: _animationDuration,
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
                opacity: expanded ? 1 : 0,
                duration: _animationDuration,
                curve: Curves.easeOutCubic,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _GuidelineBodyText(text: section.body),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidelineBodyText extends StatelessWidget {
  final String text;

  const _GuidelineBodyText({required this.text});

  @override
  Widget build(BuildContext context) {
    final blocks = text.split('\n\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          Text(
            blocks[i],
            style: TextStyle(
              fontSize: 15,
              height: 1.78,
              fontWeight: FontWeight.w500,
              color: HackPrixColors.text.withValues(alpha: 0.88),
            ),
          ),
        ],
      ],
    );
  }
}
