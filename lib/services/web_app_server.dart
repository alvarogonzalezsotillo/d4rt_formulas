import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as path;

/// HTTP server that serves webapp.zip contents at /static path
class WebAppServer {
  HttpServer? _server;
  final int port;
  final Map<String, List<int>> _extractedFiles = {};

  WebAppServer({this.port = 8080});

  /// Start the HTTP server
  Future<void> start() async {
    if (_server != null) {
      print('WebAppServer already running on port $_server!.port');
      return;
    }

    await _extractWebAppZip();

    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    print('WebAppServer started on http://localhost:${_server!.port}');

    _server!.listen(_handleRequest);
  }

  /// Stop the HTTP server
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    print('WebAppServer stopped');
  }

  /// Extract webapp.zip from assets into memory
  Future<void> _extractWebAppZip() async {
    try {
      // Load the zip file from assets
      final zipData = await rootBundle.load('assets/generated/webapp.zip');
      final bytes = zipData.buffer.asUint8List(zipData.offsetInBytes, zipData.lengthInBytes);

      // Decode the ZIP archive
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extract all files into memory
      _extractedFiles.clear();
      for (final file in archive) {
        if (file.isFile && file.size > 0) {
          _extractedFiles[file.name] = file.content as List<int>;
        }
      }

      print('Extracted ${_extractedFiles.length} files from webapp.zip');
    } catch (e, st) {
      print('Error extracting webapp.zip: $e');
      print(st);
      rethrow;
    }
  }

  /// Handle incoming HTTP requests
  void _handleRequest(HttpRequest request) {
    try {
      String uriPath = request.uri.path;

      // Only handle /static/* paths
      if (uriPath.startsWith('/static')) {
        String filePath = uriPath.substring('/static'.length);
        if (filePath.startsWith('/')) {
          filePath = filePath.substring(1);
        }

        // Default to index.html if no file specified or path is /static/
        if (filePath.isEmpty) {
          filePath = 'index.html';
        }

        _serveFile(request, filePath);
      } else {
        _sendNotFound(request, 'Not found');
      }
    } catch (e, st) {
      print('Error handling request: $e');
      print(st);
      _sendError(request, 'Internal server error: $e');
    }
  }

  /// Serve a file from the extracted zip
  void _serveFile(HttpRequest request, String filePath) {
    if (!_extractedFiles.containsKey(filePath)) {
      _sendNotFound(request, 'File not found: $filePath');
      return;
    }

    List<int> fileData = _extractedFiles[filePath]!;
    String contentType = _getContentType(filePath);

    request.response.headers.set('Content-Type', contentType);
    request.response.headers.set('Content-Length', fileData.length.toString());
    request.response.add(fileData);
    request.response.close();
  }

  /// Get MIME type based on file extension
  String _getContentType(String filePath) {
    // TODO: CHANGE TO A Map<String,String>
    String ext = path.extension(filePath).toLowerCase();
    switch (ext) {
      case '.html':
        return 'text/html; charset=utf-8';
      case '.js':
        return 'application/javascript; charset=utf-8';
      case '.css':
        return 'text/css; charset=utf-8';
      case '.json':
        return 'application/json; charset=utf-8';
      case '.wasm':
        return 'application/wasm';
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.gif':
        return 'image/gif';
      case '.svg':
        return 'image/svg+xml';
      case '.ico':
        return 'image/x-icon';
      case '.txt':
        return 'text/plain; charset=utf-8';
      default:
        return 'application/octet-stream';
    }
  }

  void _sendNotFound(HttpRequest request, String message) {
    request.response.statusCode = HttpStatus.notFound;
    request.response.headers.set('Content-Type', 'text/plain');
    request.response.write(message);
    request.response.close();
  }

  void _sendError(HttpRequest request, String message) {
    request.response.statusCode = HttpStatus.internalServerError;
    request.response.headers.set('Content-Type', 'text/plain');
    request.response.write(message);
    request.response.close();
  }

  /// Check if server is running
  bool get isRunning => _server != null;

  /// Get server URL
  String get url => _server != null ? 'http://localhost:${_server!.port}' : '';
}
