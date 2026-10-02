import '../../../shared/models/bedtime_story.dart';

class BedtimeAccess {
  const BedtimeAccess({required this.isPremium});

  final bool isPremium;

  bool canPlayStory(BedtimeStory story) {
    if (!story.isPremium) return true;
    return isPremium;
  }
}
