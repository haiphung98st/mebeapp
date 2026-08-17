enum FoodCategory {
  vegetable,
  fruit,
  grain,
  protein,
  dairy,
  legume,
  fish,
}

class BabyFood {
  const BabyFood({
    required this.id,
    required this.name,
    required this.category,
    required this.minAgeWeeks,
    this.emoji = '🍽️',
    this.isCommonAllergen = false,
    this.prepNote,
  });

  final String id;
  final String name;
  final FoodCategory category;
  final int minAgeWeeks; // minimum age in weeks (24 = 6 months)
  final String emoji;
  final bool isCommonAllergen;
  final String? prepNote;

  String get categoryLabel => switch (category) {
        FoodCategory.vegetable => 'Rau củ',
        FoodCategory.fruit => 'Trái cây',
        FoodCategory.grain => 'Ngũ cốc',
        FoodCategory.protein => 'Đạm',
        FoodCategory.dairy => 'Sữa/Trứng',
        FoodCategory.legume => 'Đậu',
        FoodCategory.fish => 'Cá/Hải sản',
      };
}

const List<BabyFood> babyFoodDatabase = [
  // ── Vegetables (24-32 weeks) ─────────────────────────────
  BabyFood(id: 'carrot', name: 'Cà rốt', category: FoodCategory.vegetable, minAgeWeeks: 24, emoji: '🥕', prepNote: 'Hấp chín, nghiền nhuyễn'),
  BabyFood(id: 'sweet_potato', name: 'Khoai lang', category: FoodCategory.vegetable, minAgeWeeks: 24, emoji: '🍠', prepNote: 'Nướng hoặc hấp, nghiền'),
  BabyFood(id: 'potato', name: 'Khoai tây', category: FoodCategory.vegetable, minAgeWeeks: 24, emoji: '🥔', prepNote: 'Luộc, nghiền'),
  BabyFood(id: 'pumpkin', name: 'Bí đỏ', category: FoodCategory.vegetable, minAgeWeeks: 24, emoji: '🎃', prepNote: 'Hấp chín, nghiền'),
  BabyFood(id: 'zucchini', name: 'Bí xanh', category: FoodCategory.vegetable, minAgeWeeks: 24, emoji: '🥬'),
  BabyFood(id: 'peas', name: 'Đậu hà lan', category: FoodCategory.vegetable, minAgeWeeks: 24, emoji: '🫛', prepNote: 'Nghiền qua rây'),
  BabyFood(id: 'broccoli', name: 'Súp lơ xanh', category: FoodCategory.vegetable, minAgeWeeks: 26, emoji: '🥦'),
  BabyFood(id: 'cauliflower', name: 'Súp lơ trắng', category: FoodCategory.vegetable, minAgeWeeks: 26, emoji: '🥬'),
  BabyFood(id: 'spinach', name: 'Rau chân vịt', category: FoodCategory.vegetable, minAgeWeeks: 26, emoji: '🌿'),
  BabyFood(id: 'corn', name: 'Ngô', category: FoodCategory.vegetable, minAgeWeeks: 28, emoji: '🌽', prepNote: 'Xay nhuyễn, lọc vỏ'),
  BabyFood(id: 'green_bean', name: 'Đậu que', category: FoodCategory.vegetable, minAgeWeeks: 26, emoji: '🫘'),
  BabyFood(id: 'beetroot', name: 'Củ dền', category: FoodCategory.vegetable, minAgeWeeks: 28, emoji: '🫀'),
  BabyFood(id: 'asparagus', name: 'Măng tây', category: FoodCategory.vegetable, minAgeWeeks: 28, emoji: '🌿'),
  BabyFood(id: 'celery', name: 'Cần tây', category: FoodCategory.vegetable, minAgeWeeks: 30, emoji: '🌿'),
  BabyFood(id: 'cucumber', name: 'Dưa leo', category: FoodCategory.vegetable, minAgeWeeks: 28, emoji: '🥒'),
  BabyFood(id: 'tomato', name: 'Cà chua', category: FoodCategory.vegetable, minAgeWeeks: 32, emoji: '🍅', prepNote: 'Bỏ hạt và vỏ'),
  BabyFood(id: 'cabbage', name: 'Bắp cải', category: FoodCategory.vegetable, minAgeWeeks: 28, emoji: '🥬'),
  BabyFood(id: 'bok_choy', name: 'Cải thìa', category: FoodCategory.vegetable, minAgeWeeks: 26, emoji: '🥬'),
  BabyFood(id: 'morning_glory', name: 'Rau muống', category: FoodCategory.vegetable, minAgeWeeks: 28, emoji: '🌿'),
  BabyFood(id: 'mushroom', name: 'Nấm', category: FoodCategory.vegetable, minAgeWeeks: 36, emoji: '🍄'),

  // ── Fruits (24-32 weeks) ─────────────────────────────────
  BabyFood(id: 'apple', name: 'Táo', category: FoodCategory.fruit, minAgeWeeks: 24, emoji: '🍎', prepNote: 'Bỏ vỏ, hấp mềm hoặc nghiền'),
  BabyFood(id: 'pear', name: 'Lê', category: FoodCategory.fruit, minAgeWeeks: 24, emoji: '🍐', prepNote: 'Bỏ vỏ, nghiền'),
  BabyFood(id: 'banana', name: 'Chuối', category: FoodCategory.fruit, minAgeWeeks: 24, emoji: '🍌', prepNote: 'Nghiền, cho ăn ngay'),
  BabyFood(id: 'avocado', name: 'Bơ', category: FoodCategory.fruit, minAgeWeeks: 24, emoji: '🥑', prepNote: 'Nghiền với sữa'),
  BabyFood(id: 'mango', name: 'Xoài', category: FoodCategory.fruit, minAgeWeeks: 28, emoji: '🥭', prepNote: 'Bỏ vỏ, nghiền'),
  BabyFood(id: 'papaya', name: 'Đu đủ', category: FoodCategory.fruit, minAgeWeeks: 24, emoji: '🍈', prepNote: 'Bỏ hạt, nghiền'),
  BabyFood(id: 'watermelon', name: 'Dưa hấu', category: FoodCategory.fruit, minAgeWeeks: 26, emoji: '🍉', prepNote: 'Bỏ hạt, nghiền'),
  BabyFood(id: 'peach', name: 'Đào', category: FoodCategory.fruit, minAgeWeeks: 28, emoji: '🍑', prepNote: 'Bỏ vỏ, nghiền'),
  BabyFood(id: 'plum', name: 'Mận', category: FoodCategory.fruit, minAgeWeeks: 28, emoji: '🍑'),
  BabyFood(id: 'prune', name: 'Mận khô', category: FoodCategory.fruit, minAgeWeeks: 28, emoji: '🫐', prepNote: 'Nấu mềm, nghiền'),
  BabyFood(id: 'blueberry', name: 'Việt quất', category: FoodCategory.fruit, minAgeWeeks: 32, emoji: '🫐', prepNote: 'Nghiền hoặc cắt đôi'),
  BabyFood(id: 'strawberry', name: 'Dâu tây', category: FoodCategory.fruit, minAgeWeeks: 36, emoji: '🍓', prepNote: 'Cắt nhỏ'),
  BabyFood(id: 'kiwi', name: 'Kiwi', category: FoodCategory.fruit, minAgeWeeks: 36, emoji: '🥝'),
  BabyFood(id: 'orange', name: 'Cam', category: FoodCategory.fruit, minAgeWeeks: 36, emoji: '🍊', prepNote: 'Ép lấy nước, pha loãng'),
  BabyFood(id: 'grape', name: 'Nho', category: FoodCategory.fruit, minAgeWeeks: 36, emoji: '🍇', prepNote: 'Bỏ vỏ và hạt, cắt nhỏ'),
  BabyFood(id: 'pineapple', name: 'Dứa', category: FoodCategory.fruit, minAgeWeeks: 40, emoji: '🍍', prepNote: 'Bỏ lõi, cắt nhỏ'),
  BabyFood(id: 'longan', name: 'Nhãn', category: FoodCategory.fruit, minAgeWeeks: 40, emoji: '🍈'),
  BabyFood(id: 'dragon_fruit', name: 'Thanh long', category: FoodCategory.fruit, minAgeWeeks: 32, emoji: '🍈'),
  BabyFood(id: 'lychee', name: 'Vải', category: FoodCategory.fruit, minAgeWeeks: 40, emoji: '🍈'),
  BabyFood(id: 'guava', name: 'Ổi', category: FoodCategory.fruit, minAgeWeeks: 36, emoji: '🍈'),

  // ── Grains (24+ weeks) ───────────────────────────────────
  BabyFood(id: 'rice', name: 'Cơm/Cháo gạo', category: FoodCategory.grain, minAgeWeeks: 24, emoji: '🍚', prepNote: 'Nấu loãng dạng cháo'),
  BabyFood(id: 'oat', name: 'Yến mạch', category: FoodCategory.grain, minAgeWeeks: 24, emoji: '🌾', prepNote: 'Nấu loãng'),
  BabyFood(id: 'barley', name: 'Đại mạch', category: FoodCategory.grain, minAgeWeeks: 28, emoji: '🌾'),
  BabyFood(id: 'quinoa', name: 'Hạt quinoa', category: FoodCategory.grain, minAgeWeeks: 28, emoji: '🌾'),
  BabyFood(id: 'bread', name: 'Bánh mì', category: FoodCategory.grain, minAgeWeeks: 36, emoji: '🍞', prepNote: 'Bánh mì mềm, bẻ nhỏ', isCommonAllergen: true),
  BabyFood(id: 'pasta', name: 'Mì ống', category: FoodCategory.grain, minAgeWeeks: 36, emoji: '🍝', prepNote: 'Nấu mềm, cắt nhỏ', isCommonAllergen: true),
  BabyFood(id: 'noodle', name: 'Bún/Phở', category: FoodCategory.grain, minAgeWeeks: 36, emoji: '🍜', prepNote: 'Cắt ngắn'),
  BabyFood(id: 'corn_flour', name: 'Bột ngô', category: FoodCategory.grain, minAgeWeeks: 24, emoji: '🌽'),
  BabyFood(id: 'rice_cake', name: 'Bánh gạo', category: FoodCategory.grain, minAgeWeeks: 40, emoji: '🍘'),

  // ── Proteins (28+ weeks) ─────────────────────────────────
  BabyFood(id: 'chicken', name: 'Thịt gà', category: FoodCategory.protein, minAgeWeeks: 28, emoji: '🍗', prepNote: 'Nấu chín, xay nhuyễn'),
  BabyFood(id: 'pork', name: 'Thịt heo', category: FoodCategory.protein, minAgeWeeks: 28, emoji: '🥩', prepNote: 'Nấu chín, xay'),
  BabyFood(id: 'beef', name: 'Thịt bò', category: FoodCategory.protein, minAgeWeeks: 28, emoji: '🥩', prepNote: 'Nấu chín kỹ, xay'),
  BabyFood(id: 'tofu', name: 'Đậu hũ', category: FoodCategory.protein, minAgeWeeks: 26, emoji: '⬜', prepNote: 'Hấp hoặc luộc'),
  BabyFood(id: 'egg_yolk', name: 'Lòng đỏ trứng', category: FoodCategory.dairy, minAgeWeeks: 28, emoji: '🥚', isCommonAllergen: true, prepNote: 'Luộc chín kỹ'),
  BabyFood(id: 'egg_white', name: 'Lòng trắng trứng', category: FoodCategory.dairy, minAgeWeeks: 52, emoji: '🥚', isCommonAllergen: true),
  BabyFood(id: 'liver', name: 'Gan gà', category: FoodCategory.protein, minAgeWeeks: 32, emoji: '🍖', prepNote: 'Nấu chín kỹ, xay'),

  // ── Fish & Seafood (28+ weeks) ───────────────────────────
  BabyFood(id: 'white_fish', name: 'Cá trắng (cá rô)', category: FoodCategory.fish, minAgeWeeks: 28, emoji: '🐟', prepNote: 'Bỏ xương kỹ, hấp', isCommonAllergen: true),
  BabyFood(id: 'salmon', name: 'Cá hồi', category: FoodCategory.fish, minAgeWeeks: 28, emoji: '🐟', isCommonAllergen: true),
  BabyFood(id: 'tilapia', name: 'Cá rô phi', category: FoodCategory.fish, minAgeWeeks: 28, emoji: '🐟', prepNote: 'Bỏ xương'),
  BabyFood(id: 'catfish', name: 'Cá basa', category: FoodCategory.fish, minAgeWeeks: 28, emoji: '🐟'),
  BabyFood(id: 'shrimp', name: 'Tôm', category: FoodCategory.fish, minAgeWeeks: 32, emoji: '🦐', isCommonAllergen: true, prepNote: 'Bỏ vỏ, nấu chín, xay'),
  BabyFood(id: 'crab', name: 'Cua', category: FoodCategory.fish, minAgeWeeks: 40, emoji: '🦀', isCommonAllergen: true),

  // ── Dairy (28+ weeks) ────────────────────────────────────
  BabyFood(id: 'yogurt', name: 'Sữa chua', category: FoodCategory.dairy, minAgeWeeks: 28, emoji: '🥛', isCommonAllergen: true),
  BabyFood(id: 'cheese', name: 'Phô mai', category: FoodCategory.dairy, minAgeWeeks: 36, emoji: '🧀', isCommonAllergen: true, prepNote: 'Chọn loại ít muối'),
  BabyFood(id: 'butter', name: 'Bơ động vật', category: FoodCategory.dairy, minAgeWeeks: 32, emoji: '🧈', isCommonAllergen: true),

  // ── Legumes (28+ weeks) ──────────────────────────────────
  BabyFood(id: 'lentil', name: 'Đậu lăng', category: FoodCategory.legume, minAgeWeeks: 28, emoji: '🫘', prepNote: 'Nấu mềm, nghiền'),
  BabyFood(id: 'black_bean', name: 'Đậu đen', category: FoodCategory.legume, minAgeWeeks: 32, emoji: '🫘', prepNote: 'Nấu mềm'),
  BabyFood(id: 'chickpea', name: 'Đậu gà', category: FoodCategory.legume, minAgeWeeks: 32, emoji: '🫘'),
  BabyFood(id: 'mung_bean', name: 'Đậu xanh', category: FoodCategory.legume, minAgeWeeks: 28, emoji: '🫘', prepNote: 'Nấu cháo đậu xanh'),
  BabyFood(id: 'edamame', name: 'Đậu nành non', category: FoodCategory.legume, minAgeWeeks: 32, emoji: '🫛'),
  BabyFood(id: 'peanut', name: 'Đậu phộng', category: FoodCategory.legume, minAgeWeeks: 28, emoji: '🥜', isCommonAllergen: true, prepNote: 'Dạng bơ đậu phộng mỏng, không dùng hạt nguyên'),
  BabyFood(id: 'sesame', name: 'Mè', category: FoodCategory.legume, minAgeWeeks: 36, emoji: '🌾', isCommonAllergen: true),
];

List<BabyFood> foodsForAge(int ageWeeks) =>
    babyFoodDatabase.where((f) => f.minAgeWeeks <= ageWeeks).toList();
