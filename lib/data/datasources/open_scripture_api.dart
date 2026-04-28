import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/scripture.dart';

/// Client for https://openscriptureapi.org
/// Base URL: /api/scriptures/v1/lds/en
class OpenScriptureApi {
  static const _baseUrl =
      'https://openscriptureapi.org/api/scriptures/v1/lds/en';

  final http.Client _client;

  OpenScriptureApi({http.Client? client}) : _client = client ?? http.Client();

  /// GET /volume/{volumeId} -> { books: [{ _id, title }] }
  Future<List<ScriptureBook>> fetchBooks(StandardWork volume) async {
    final url = Uri.parse('$_baseUrl/volume/${volume.apiVolumeId}');
    final response = await _client.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch books: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final books = data['books'] as List<dynamic>;

    return books.map((b) {
      final map = b as Map<String, dynamic>;
      return ScriptureBook(
        apiId: map['_id'] as String,
        title: map['title'] as String,
        volume: volume,
      );
    }).toList();
  }

  /// GET /volume/{volumeId}/{bookId}/{chapter}
  /// Returns full chapter with verses, footnotes, summary, and nav links.
  Future<ScriptureChapter> fetchChapter(
    StandardWork volume,
    String bookApiId,
    int chapterNumber,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/volume/${volume.apiVolumeId}/$bookApiId/$chapterNumber',
    );
    final response = await _client.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ApiException('Failed to fetch chapter: ${response.statusCode}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    return _parseChapterResponse(data, bookApiId);
  }

  ScriptureChapter _parseChapterResponse(
    Map<String, dynamic> data,
    String bookApiId,
  ) {
    final book = data['book'] as Map<String, dynamic>;
    final chapter = data['chapter'] as Map<String, dynamic>;
    final versesJson = chapter['verses'] as List<dynamic>;

    final verses = <ScriptureVerse>[];
    for (var i = 0; i < versesJson.length; i++) {
      final v = versesJson[i] as Map<String, dynamic>;
      final footNotesJson = v['footNotes'] as List<dynamic>? ?? [];

      verses.add(ScriptureVerse(
        number: i + 1,
        text: v['text'] as String,
        footNotes: footNotesJson.map((fn) {
          final fnMap = fn as Map<String, dynamic>;
          return FootNote(
            start: fnMap['start'] as int,
            end: fnMap['end'] as int,
            text: fnMap['text'] as String,
          );
        }).toList(),
      ));
    }

    return ScriptureChapter(
      bookApiId: bookApiId,
      bookTitle: book['title'] as String? ?? bookApiId,
      number: chapter['number'] as int,
      summary: chapter['summary'] as String?,
      verses: verses,
      nextChapterId: data['nextChapterId'] as String?,
      prevChapterId: data['prevChapterId'] as String?,
    );
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
