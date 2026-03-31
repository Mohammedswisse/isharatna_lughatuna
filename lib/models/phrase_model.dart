class PhraseModel {
  final int id;
  final String text;
  final String gender;
  final String skinColor;
  final String? type;
  final String? imagePath;

  PhraseModel({
    required this.id,
    required this.text,
    required this.gender,
    required this.skinColor,
    this.type,
    this.imagePath,
  });

  factory PhraseModel.fromJson(Map<String, dynamic> json) {
    return PhraseModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      text: (json['text'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString(),
      skinColor: (json['skin_color'] ?? '').toString(),
      type: json['type']?.toString(),
      imagePath: json['image_path']?.toString(),
    );
  }
}