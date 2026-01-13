import 'package:pdf_render_plus/pdf_render.dart';

class PDFViewerService {
  Future<PdfDocument> loadPdf(String filePath) async {
    try {
      final document = await PdfDocument.openFile(filePath);
      return document;
    } catch (e) {
      throw Exception('Failed to load PDF: $e');
    }
  }

  Future<PdfPage> getPage(PdfDocument document, int pageNumber) async {
    try {
      return await document.getPage(pageNumber);
    } catch (e) {
      throw Exception('Failed to load page: $e');
    }
  }

  int getTotalPages(PdfDocument document) {
    return document.pageCount;
  }

  Future<void> closePdf(PdfDocument document) async {
    await document.dispose(); // <- use dispose(), not close()
  }
}
