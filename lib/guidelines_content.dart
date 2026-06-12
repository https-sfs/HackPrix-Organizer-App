class GuidelineSection {
  final String heading;
  final String body;

  const GuidelineSection({required this.heading, required this.body});
}

class GuidelinesContent {
  GuidelinesContent._();

  static const sections = [
    GuidelineSection(
      heading: 'Before You Participate',
      body:
          'Welcome to HackPrix!\n\nHackPrix is committed to providing a safe, inclusive, and respectful environment for everyone.\n\nBefore participating, please take a few minutes to read these participation guidelines carefully.\n\nBy joining HackPrix 2026, you agree to follow this Code of Conduct and help create a positive experience for every participant, mentor, volunteer, organizer, and sponsor.',
    ),
    GuidelineSection(
      heading: 'Introduction',
      body:
          'At HackPrix, we are dedicated to providing a safe, welcoming, and inclusive space for all participants regardless of gender, sexual orientation, disability, physical appearance, body size, race, ethnicity, religion, or technology choices. We do not tolerate harassment of participants in any form.\n\nThis Code of Conduct applies to all HackPrix events including hackathons, meetups, community gatherings, and online spaces. By participating, you agree to follow this Code of Conduct.',
    ),
    GuidelineSection(
      heading: 'Expected Behavior',
      body:
          'Be Respectful: Treat all participants with respect and consideration. Communicate openly and thoughtfully and be mindful of differing viewpoints and experiences.\n\nBe Inclusive: Create a welcoming environment where everyone feels included. Avoid language or behavior that excludes or discriminates.\n\nBe Considerate: Remember that event spaces are shared. Be aware of your surroundings and considerate of your fellow participants.\n\nBe Collaborative: Support a community where everyone feels comfortable sharing ideas and working together.\n\nBe Mindful: Understand how your words and actions may affect others. Offer and receive constructive feedback with kindness.',
    ),
    GuidelineSection(
      heading: 'Unacceptable Behavior',
      body:
          'Unacceptable behaviors include but are not limited to:\n\n• Harassment, intimidation, or discrimination of any kind\n\n• Verbal or written abuse including offensive comments or jokes related to gender, sexual orientation, disability, physical appearance, body size, race, ethnicity, religion, or technology choices\n\n• Unwelcome sexual attention including inappropriate physical contact or sexual remarks\n\n• Sustained disruption of talks, workshops, sessions, or activities\n\n• Sharing others private information without explicit permission\n\n• Encouraging or advocating any of the above behaviors',
    ),
    GuidelineSection(
      heading: 'Reporting Incidents',
      body:
          'If you experience or witness any form of unacceptable behavior or have other concerns, please report it as soon as possible. You can report by:\n\n• Contacting an event organizer\n\n• Emailing us at contact@hackprix.tech\n\nAll reports will be handled with discretion and confidentiality. We will take appropriate action which may include removal of the participant from the event.',
    ),
    GuidelineSection(
      heading: 'Consequences of Unacceptable Behavior',
      body:
          'Participants asked to stop inappropriate behavior are expected to comply immediately. If a participant continues or engages in unacceptable behavior, organizers may take any action they find appropriate including warnings or expulsion from the event.',
    ),
    GuidelineSection(
      heading: 'Acknowledgement',
      body:
          'By participating in HackPrix events, you agree to abide by this Code of Conduct. We appreciate your participation and aim to create a positive, safe, and meaningful experience for everyone.',
    ),
    GuidelineSection(
      heading: 'Contact Information',
      body:
          'For any questions or concerns about this Code of Conduct, email us at contact@hackprix.tech.',
    ),
  ];
}
