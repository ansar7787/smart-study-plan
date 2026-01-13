import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/file_resource.dart';
import 'pdf_viewer_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceViewerPage extends StatelessWidget {
  final FileResource resource;

  const ResourceViewerPage({super.key, required this.resource});

  @override
  Widget build(BuildContext context) {
    final type = resource.type.toLowerCase();

    if (_isImage(type)) {
      return _ImageViewer(resource);
    }

    if (type == 'pdf') {
      return PdfViewerPage(pdfUrl: resource.url, title: resource.name);
    }

    return _UnsupportedFileView(resource);
  }

  bool _isImage(String type) {
    return ['jpg', 'jpeg', 'png', 'webp'].contains(type);
  }
}

class _ImageViewer extends StatelessWidget {
  final FileResource resource;

  const _ImageViewer(this.resource);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(resource.name)),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: CachedNetworkImage(
            imageUrl: resource.url,
            placeholder: (_, _) => const CircularProgressIndicator(),
            errorWidget: (_, _, _) => const Icon(Icons.error, size: 48),
          ),
        ),
      ),
    );
  }
}

class _UnsupportedFileView extends StatelessWidget {
  final FileResource resource;

  const _UnsupportedFileView(this.resource);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(resource.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insert_drive_file, size: 64),
            const SizedBox(height: 16),
            Text(resource.name),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open File'),
              onPressed: () async {
                final uri = Uri.parse(resource.url);
                if (await canLaunchUrl(uri)) {
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
