import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../entities/shift_retrospective.dart';

/// Exporta retrospectiva de turno em PDF e compartilha via share sheet.
abstract final class ShiftRetrospectiveExporter {
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  static Future<void> sharePdf(ShiftRetrospective retrospective) async {
    final bytes = await buildPdfBytes(retrospective);
    final started = retrospective.entry.startedAt;
    final file = await _writeTempFile(
      bytes: bytes,
      name:
          'driveflow-turno-${started.year}${started.month.toString().padLeft(2, '0')}${started.day.toString().padLeft(2, '0')}.pdf',
    );
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Retrospectiva de turno DriveFlow',
    );
  }

  @visibleForTesting
  static Future<List<int>> buildPdfBytes(ShiftRetrospective retrospective) =>
      _buildPdf(retrospective);

  static Future<List<int>> _buildPdf(ShiftRetrospective retrospective) async {
    final entry = retrospective.entry;
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              kAppName,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#00E5B8'),
              ),
            ),
            pw.Text('Retrospectiva de turno'),
            pw.Text(
              '${_dateFormat.format(entry.startedAt)} — '
              '${_dateFormat.format(entry.endedAt)}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) => [
          _pdfSection('Resumo', [
            _pdfRow('Ganhos', CurrencyFormatter.format(entry.revenue)),
            _pdfRow('Corridas', '${entry.rides}'),
            _pdfRow('Duração', _formatDuration(entry.elapsed)),
            if (entry.revenuePerHour != null)
              _pdfRow(
                'R\$/h',
                CurrencyFormatter.format(entry.revenuePerHour!),
              ),
            if (entry.totalPlanBlocks > 0)
              _pdfRow(
                'Aderência ao plano',
                '${entry.adherenceScore.round()}% '
                    '(${entry.matchedPlanBlocks}/${entry.totalPlanBlocks} blocos)',
              ),
          ]),
          pw.SizedBox(height: 12),
          _pdfSection('Insight', [
            pw.Text(retrospective.insight),
          ]),
          if (retrospective.platformBreakdown.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _pdfSection('Mix por app', [
              for (final slice in retrospective.platformBreakdown)
                ..._pdfPlatformSliceRow(slice),
            ]),
          ],
          if (retrospective.blockOutcomes.isNotEmpty) ...[
            pw.SizedBox(height: 12),
            _pdfSection('Plano vs realizado', [
              for (final outcome in retrospective.blockOutcomes)
                _pdfRow(
                  '${outcome.block.timeRange} · ${outcome.block.platform.label}',
                  outcome.actualPlatform == null
                      ? 'Sem ganhos'
                      : '${outcome.actualPlatform!.label} · '
                          '${CurrencyFormatter.format(outcome.revenue)}'
                          '${outcome.matched ? ' ✓' : ''}',
                ),
            ]),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _pdfSection(String title, List<pw.Widget> children) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        ...children,
      ],
    );
  }

  static pw.Widget _pdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(child: pw.Text(label)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static List<pw.Widget> _pdfPlatformSliceRow(ShiftPlatformSlice slice) {
    final share = slice.share.clamp(0.0, 1.0);
    return [
      pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(slice.platform.label),
                pw.Text(
                  '${CurrencyFormatter.format(slice.revenue)} · '
                  '${(share * 100).round()}%',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
              ],
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              height: 8,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#1A2233'),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: (share * 1000).round().clamp(1, 1000),
                    child: pw.Container(
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#5BA4F5'),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: ((1 - share) * 1000).round().clamp(1, 1000),
                    child: pw.SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  static Future<File> _writeTempFile({
    required List<int> bytes,
    required String name,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }
}
