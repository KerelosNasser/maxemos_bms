import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  try {
    // 1. Get a File ID
    final scriptUrl =
        'https://script.google.com/macros/s/AKfycbzx-Hb66bL_7n0qnIMzLZTMfq2GIBnkavFeBxhFRuwsAV9YLYFMVzcqlGSoV9JAflEU/exec';

    // Manual redirect follow for post
    var response = await http.post(
      Uri.parse(scriptUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'action': 'list', 'secret': 'maxemos123'}),
    );

    if (response.statusCode == 302 || response.statusCode == 303) {
      final loc = response.headers['location'];
      if (loc != null) {
        response = await http.get(Uri.parse(loc));
      }
    }

    final data = json.decode(response.body);
    final files = data['files'] as List<dynamic>;
    if (files.isEmpty) {
      print('No files found.');
      return;
    }

    final fileId = files.first['id'];
    print('Found file ID: $fileId');

    // 2. Try downloading it
    final downloadUrl =
        'https://drive.google.com/uc?export=download&id=$fileId';
    print('Downloading from: $downloadUrl');

    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(downloadUrl));
    final dlResponse = await request.close();

    print('Status Code: ${dlResponse.statusCode}');
    print('Content-Type: ${dlResponse.headers.contentType}');

    if (dlResponse.headers.contentType?.mimeType == 'text/html') {
      final html = await utf8.decodeStream(dlResponse);
      print('HTML Length: ${html.length}');

      File('download_test.html').writeAsStringSync(html);
      print('Saved HTML to download_test.html');

      // Try to parse confirm
      // 1. href="/uc?export=download&amp;confirm=t&amp;id=1P_...&amp;uuid=..."
      // 2. confirm=([a-zA-Z0-9_\-]+)
      final matches = RegExp(r'confirm=([a-zA-Z0-9_\-]+)').allMatches(html);
      for (var m in matches) {
        print('Found confirm match: ${m.group(0)}');
      }
    } else {
      print('Downloaded actual PDF.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
