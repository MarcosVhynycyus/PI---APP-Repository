import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

typedef TestRequestHandler = FutureOr<void> Function(TestRequest request);

class TestApiServer {
  TestApiServer._(this._server)
      : baseUrl = 'http://${_server.address.host}:${_server.port}' {
    _subscription = _server.listen(_handleRequest);
  }

  final HttpServer _server;
  final String baseUrl;
  final Queue<TestRequestHandler> _handlers = Queue<TestRequestHandler>();
  late final StreamSubscription<HttpRequest> _subscription;

  static Future<TestApiServer> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    return TestApiServer._(server);
  }

  void enqueue(TestRequestHandler handler) {
    _handlers.add(handler);
  }

  Future<void> close() async {
    await _subscription.cancel();
    await _server.close(force: true);
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (_handlers.isEmpty) {
      await _respondWithError(
        request,
        'Unexpected ${request.method} ${request.uri.path}',
      );
      return;
    }

    final handler = _handlers.removeFirst();

    try {
      await handler(TestRequest._(request));
    } catch (error) {
      await _respondWithError(request, 'Test handler failed: $error');
    }
  }

  Future<void> _respondWithError(HttpRequest request, String message) async {
    try {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'message': message}));
      await request.response.close();
    } catch (_) {
      // The response may already have been closed by the test handler.
    }
  }
}

class TestRequest {
  TestRequest._(this._request);

  final HttpRequest _request;

  String get method => _request.method;

  Uri get uri => _request.uri;

  HttpHeaders get headers => _request.headers;

  Future<Map<String, dynamic>> jsonBody() async {
    final rawBody = await utf8.decoder.bind(_request).join();
    if (rawBody.trim().isEmpty) return <String, dynamic>{};

    final decodedBody = jsonDecode(rawBody);
    if (decodedBody is Map<String, dynamic>) return decodedBody;
    if (decodedBody is Map) return Map<String, dynamic>.from(decodedBody);

    throw FormatException('Request body is not a JSON object: $rawBody');
  }

  Future<void> respondJson(
    int statusCode,
    Map<String, dynamic> body,
  ) async {
    _request.response.statusCode = statusCode;
    _request.response.headers.contentType = ContentType.json;
    _request.response.write(jsonEncode(body));
    await _request.response.close();
  }
}
