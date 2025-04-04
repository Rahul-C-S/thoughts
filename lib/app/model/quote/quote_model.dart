class QuoteModel {
  final String author;
  final String quote;

  QuoteModel({required this.author, required this.quote});

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      author: json['author'] as String,
      quote: json['quote'] as String,
    );
  }

  @override
  String toString() {
    return '"$quote" - $author';
  }
}
