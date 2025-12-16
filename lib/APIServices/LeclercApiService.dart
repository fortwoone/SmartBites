import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiService.dart';

class LeclercApiService implements ApiService {
  static const String _baseUrl =
      'https://foodsparkfastapiframework.xbyte.io/search';
  static const String _apiKey = 'iczbisjz4iff016p';

  @override
  Future<List<Map<String, dynamic>>> searchProducts(String searchTerm) async {
    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'api_key': _apiKey,
      'domain': 'leclerc',
      'country': 'fra',
      'platform': 'web',
      'endpoint_type': 'gt7344_search',
      'search_term': searchTerm,
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }

    final decodedJson = jsonDecode(utf8.decode(response.bodyBytes));
    print('STATUS: ${response.statusCode}');
    print('BODY: ${utf8.decode(response.bodyBytes)}');

    if (decodedJson['response']?['results'] is List) {
      final rawResults =
      List<Map<String, dynamic>>.from(decodedJson['response']['results']);
      return rawResults.map((item) => _fixMapEncoding(item)).toList();
    }

    return [];
  }

  Map<String, dynamic> _fixMapEncoding(Map<String, dynamic> map) {
    final fixedMap = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is String) {
        fixedMap[key] = _fixEncoding(value);
      } else if (value is Map<String, dynamic>) {
        fixedMap[key] = _fixMapEncoding(value);
      } else if (value is List) {
        fixedMap[key] = _fixListEncoding(value);
      } else {
        fixedMap[key] = value;
      }
    });
    return fixedMap;
  }

  List _fixListEncoding(List list) =>
      list.map((item) => item is String
          ? _fixEncoding(item)
          : item is Map<String, dynamic>
          ? _fixMapEncoding(item)
          : item is List
          ? _fixListEncoding(item)
          : item).toList();

  String _fixEncoding(String text) {
    try {
      return utf8.decode(text.codeUnits);
    } catch (_) {
      return text;
    }
  }
}
