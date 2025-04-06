import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // Test login
  await testLogin();
}

Future<void> testLogin() async {
  print('Testing login...');
  
  final response = await http.post(
    Uri.parse('http://localhost:3000/api/auth/syndic/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': 'admin@syndic.com',
      'password': 'admin123',
    }),
  );
  
  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');
  
  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    final token = data['token'];
    print('Token: $token');
    
    // Test getting proprietaires with token
    await testGetProprietaires(token);
  }
}

Future<void> testGetProprietaires(String token) async {
  print('\nTesting get proprietaires...');
  
  // Try different token formats
  await testWithFormat(token, 'No prefix');
  await testWithFormat(token, 'Bearer prefix');
  await testWithFormat(token, 'Query parameter');
}

Future<void> testWithFormat(String token, String format) async {
  print('\nTesting with $format...');
  
  Uri uri;
  Map<String, String> headers = {'Content-Type': 'application/json'};
  
  if (format == 'Query parameter') {
    uri = Uri.parse('http://localhost:3000/api/proprietaires/my-proprietaires?token=$token');
  } else {
    uri = Uri.parse('http://localhost:3000/api/proprietaires/my-proprietaires');
    if (format == 'Bearer prefix') {
      headers['Authorization'] = 'Bearer $token';
    } else {
      headers['Authorization'] = token;
    }
  }
  
  print('URI: $uri');
  print('Headers: $headers');
  
  final response = await http.get(uri, headers: headers);
  
  print('Response status code: ${response.statusCode}');
  print('Response body: ${response.body}');
}
