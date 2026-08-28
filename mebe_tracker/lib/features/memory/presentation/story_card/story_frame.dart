/// Which decorative frame a Story Card is rendered with. Free frames are
/// available to everyone; the rest require Premium (gated in the editor).
enum StoryFrameStyle { blossomGarden, bunnyCute, starryNight, vintagePolaroid }

class StoryFrameInfo {
  const StoryFrameInfo({
    required this.style,
    required this.name,
    required this.isPremium,
  });

  final StoryFrameStyle style;
  final String name;
  final bool isPremium;
}

const storyFrames = [
  StoryFrameInfo(style: StoryFrameStyle.blossomGarden, name: 'Blossom Garden', isPremium: false),
  StoryFrameInfo(style: StoryFrameStyle.bunnyCute, name: 'Bunny Cute', isPremium: false),
  StoryFrameInfo(style: StoryFrameStyle.starryNight, name: 'Starry Night', isPremium: true),
  StoryFrameInfo(style: StoryFrameStyle.vintagePolaroid, name: 'Vintage Polaroid', isPremium: true),
];
