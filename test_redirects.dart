import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final scriptUrl =
      'https://script.google.com/macros/s/AKfycbzwh9kbZT5HhP3Bm3dFONCJ4fHK_xV01mdtOLFPwZCRBurP9SiRB2ol6pOF16y2mnVJ/exec';
  final url = Uri.parse(scriptUrl);
  final body = json.encode({'action': 'list', 'secret': 'maxemos123'});

  final client = http.Client();
  try {
    // 1. Initial POST request, NO following redirects automatically
    final request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..body = body
      ..followRedirects = false;

    var response = await client.send(request);
    print('Initial Response Status: ${response.statusCode}');

    // 2. If it's a redirect, let's look at the location header
    if (response.statusCode == 302 || response.statusCode == 303) {
      final location = response.headers['location'];
      print('Redirect Location: $location');

      if (location != null) {
        // Apps Script requires the redirect to be followed.
        // Let's do a GET on the redirect URL, which is what browsers do.
        final redirectUrl = Uri.parse(location);
        final redirectRequest = http.Request('GET', redirectUrl)
          // NEVER send the Content-Type header on a GET request after a redirect
          // to script.googleusercontent.com, as it causes 401s in some clients.
          ..followRedirects = true;

        final finalResponse = await client.send(redirectRequest);
        final responseBody = await finalResponse.stream.bytesToString();

        print('Final Response Status: ${finalResponse.statusCode}');
        if (responseBody.length > 200) {
          print('Final Body: ${responseBody.substring(0, 200)}...');
        } else {
          print('Final Body: $responseBody');
        }
      }
    } else {
      final responseBody = await response.stream.bytesToString();
      print('Body: $responseBody');
    }
  } catch (e) {
    print('Error: $e');
  } finally {
    client.close();
  }
}
