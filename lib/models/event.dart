class Event {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime timestamp;
  final String? imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}
