/// Photo-collage layouts for a printable Baby Book page. Scoped to the two
/// most distinct looks — a bright album spread and a dark, circular-photo
/// spread — rather than every layout in the original spec, to keep the
/// hand-painted Canvas work maintainable.
enum BookLayout { monthlyAlbum, moonlightDark }

class BookLayoutInfo {
  const BookLayoutInfo({required this.layout, required this.name, required this.isPremium});
  final BookLayout layout;
  final String name;
  final bool isPremium;
}

const bookLayouts = [
  BookLayoutInfo(layout: BookLayout.monthlyAlbum, name: 'Monthly Album', isPremium: true),
  BookLayoutInfo(layout: BookLayout.moonlightDark, name: 'Moonlight Dark', isPremium: true),
];

class BabyBookPageData {
  const BabyBookPageData({
    required this.title,
    required this.babyName,
    required this.dateRange,
    this.weight,
    this.height,
    this.milestones,
    this.tagline,
  });

  final String title;
  final String babyName;
  final String dateRange;
  final String? weight;
  final String? height;
  final String? milestones;
  final String? tagline;
}

/// Poster themes for the printable A4 Growth Poster.
enum PosterTheme { blossom, starryNight }

class PosterThemeInfo {
  const PosterThemeInfo({required this.theme, required this.name, required this.isPremium});
  final PosterTheme theme;
  final String name;
  final bool isPremium;
}

const posterThemes = [
  PosterThemeInfo(theme: PosterTheme.blossom, name: 'Poster Blossom', isPremium: true),
  PosterThemeInfo(theme: PosterTheme.starryNight, name: 'Poster Night', isPremium: true),
];

class GrowthPosterData {
  const GrowthPosterData({
    required this.babyName,
    required this.ageText,
    required this.dateText,
    this.weight,
    this.height,
    this.milestones,
    this.quote,
  });

  final String babyName;
  final String ageText;
  final String dateText;
  final String? weight;
  final String? height;
  final String? milestones;
  final String? quote;
}
