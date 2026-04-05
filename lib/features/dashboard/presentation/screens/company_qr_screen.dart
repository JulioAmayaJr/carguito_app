import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:carguito_app/core/utils/app_bottom_menu.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class CompanyQrScreen extends StatefulWidget {
  const CompanyQrScreen({super.key});

  @override
  State<CompanyQrScreen> createState() => _CompanyQrScreenState();
}

class _CompanyQrScreenState extends State<CompanyQrScreen> {
  final GlobalKey _sellerQrKey = GlobalKey();
  final GlobalKey _recipientQrKey = GlobalKey();

  bool _isGeneratingSellerPdf = false;
  bool _isGeneratingRecipientPdf = false;

  Future<Uint8List> _captureQr(GlobalKey key) async {
    final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado'),
      ),
    );
  }

  Future<void> _downloadSinglePdf({
    required GlobalKey qrKey,
    required String title,
    required String subtitle,
    required String code,
    required bool isSeller,
  }) async {
    try {
      setState(() {
        if (isSeller) {
          _isGeneratingSellerPdf = true;
        } else {
          _isGeneratingRecipientPdf = true;
        }
      });

      final qrBytes = await _captureQr(qrKey);
      final doc = pw.Document();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (context) {
            return pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(18),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'Carguito',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    title,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    subtitle,
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 28),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(18),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(16),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Image(
                      pw.MemoryImage(qrBytes),
                      width: 220,
                      height: 220,
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'Código manual',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(14),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F8F6F9'),
                      borderRadius: pw.BorderRadius.circular(14),
                      border: pw.Border.all(color: PdfColor.fromHex('#E4DFE6')),
                    ),
                    child: pw.Text(
                      code,
                      textAlign: pw.TextAlign.center,
                      style: const pw.TextStyle(
                        fontSize: 13,
                        color: PdfColors.blueGrey800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final bytes = await doc.save();

      if (!mounted) {
        return;
      }

      await Printing.sharePdf(
        bytes: bytes,
        filename: isSeller ? 'qr_vendedores.pdf' : 'qr_clientes_destinatarios.pdf',
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo generar el PDF: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          if (isSeller) {
            _isGeneratingSellerPdf = false;
          } else {
            _isGeneratingRecipientPdf = false;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final companyId = auth.user?.companyId;
    final role = auth.user?.role;

    if (companyId == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F4F7),
        body: Center(
          child: Text(
            'Company ID no encontrado en perfil actual.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      );
    }

    final sellerCode = 'carguito::seller::$companyId';
    final recipientCode = 'carguito::recipient::$companyId';
    final showSeller = role == 'company_admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F7),
      bottomNavigationBar: const AppBottomMenu(currentIndex: 4),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.go('/settings'),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(right: 42),
                      child: Text(
                        'Códigos QR',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF20212A),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4DD),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.qr_code_2_rounded,
                      color: Color(0xFFF4A91F),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comparte tus códigos QR',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Permite registrar vendedores y clientes de forma rápida.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (showSeller) ...[
              _QrSectionCard(
                title: 'Vendedores',
                subtitle: 'Haz que los vendedores escaneen este QR para enlazarse a tu red.',
                code: sellerCode,
                qrKey: _sellerQrKey,
                isLoadingPdf: _isGeneratingSellerPdf,
                onCopy: () => _copyCode(sellerCode),
                onDownloadPdf: () => _downloadSinglePdf(
                  qrKey: _sellerQrKey,
                  title: 'Vendedores',
                  subtitle: 'Haz que los vendedores escaneen este QR para enlazarse a tu red.',
                  code: sellerCode,
                  isSeller: true,
                ),
              ),
              const SizedBox(height: 16),
            ],
            _QrSectionCard(
              title: 'Clientes / Destinatarios',
              subtitle: role == 'seller'
                  ? 'Muestra este QR a tus clientes para que se registren fácilmente.'
                  : 'Haz que tus usuarios escaneen este QR para darse de alta en tu lista de clientes.',
              code: recipientCode,
              qrKey: _recipientQrKey,
              isLoadingPdf: _isGeneratingRecipientPdf,
              onCopy: () => _copyCode(recipientCode),
              onDownloadPdf: () => _downloadSinglePdf(
                qrKey: _recipientQrKey,
                title: 'Clientes / Destinatarios',
                subtitle: role == 'seller'
                    ? 'Muestra este QR a tus clientes para que se registren fácilmente.'
                    : 'Haz que tus usuarios escaneen este QR para darse de alta en tu lista de clientes.',
                code: recipientCode,
                isSeller: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QrSectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String code;
  final GlobalKey qrKey;
  final bool isLoadingPdf;
  final VoidCallback onCopy;
  final VoidCallback onDownloadPdf;

  const _QrSectionCard({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.qrKey,
    required this.isLoadingPdf,
    required this.onCopy,
    required this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8E5EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF20212A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6F717C),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          RepaintBoundary(
            key: qrKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7FA),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE6E1E8)),
              ),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: QrImageView(
                  data: code,
                  version: QrVersions.auto,
                  size: 210,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Código manual',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3A3B45),
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onCopy,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F6F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE4DFE6)),
              ),
              child: Column(
                children: [
                  SelectableText(
                    code,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF52607A),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE4DFE6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: Color(0xFF6B7280),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Copiar ID',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: isLoadingPdf ? null : onDownloadPdf,
              icon: isLoadingPdf
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded),
              label: Text(
                isLoadingPdf ? 'Generando PDF...' : 'Descargar PDF',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4A91F),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}