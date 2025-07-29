class Drill {
  final String name;
  final String level;
  final String materials;
  final String duration;
  final String description;
  final String videoUrl;

  Drill({
    required this.name,
    required this.level,
    required this.materials,
    required this.duration,
    required this.description,
    required this.videoUrl,
  });

  factory Drill.fromCsvRow(List<dynamic> row) {
    return Drill(
      name: row[1].toString(),
      level: row[2].toString(),
      materials: row[6].toString(),
      duration: row[4].toString(),
      description: row[5].toString(),
      videoUrl: row[7].toString(),
    );
  }
}
