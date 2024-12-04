class FavoriteVideo {
  final int id;
  final String title;
  final String videoKey;
  final String thumbnail;

  FavoriteVideo({
    required this.id,
    required this.title,
    required this.videoKey,
    required this.thumbnail,
  });

  factory FavoriteVideo.fromMap(Map<String, dynamic> map) {
    return FavoriteVideo(
      id: map['id'],
      title: map['title'],
      videoKey: map['videoKey'],
      thumbnail: map['thumbnail'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'videoKey': videoKey,
      'thumbnail': thumbnail,
    };
  }
}