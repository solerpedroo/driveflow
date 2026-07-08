import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../earnings/domain/entities/earning_entity.dart';
import '../../../expenses/domain/entities/expense_entity.dart';
import '../entities/report_snapshot.dart';
import '../../analytics/domain/entities/period_comparison_result.dart';

/// Exporta relatórios em PDF e CSV e compartilha via share sheet.
abstract final class ReportExporter {
  static final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  static Future<void> sharePdf({
    required ReportSnapshot snapshot,
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    PeriodComparisonResult? comparison,
  }) async {
    final bytes = await _buildPdf(
      snapshot: snapshot,
      earnings: earnings,
      expenses: expenses,
      comparison: comparison,
    );
    final file = await _writeTempFile(
      bytes: bytes,
      name: 'driveflow-relatorio-${snapshot.period.name}.pdf',
    );
    await Share.shareXFiles([XFile(file.path)], text: 'Relatório DriveFlow');
  }

  static Future<void> shareCsv({
    required ReportSnapshot snapshot,
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    PeriodComparisonResult? comparison,
  }) async {
    final csv = _buildCsv(
      snapshot: snapshot,
      earnings: earnings,
      expenses: expenses,
      comparison: comparison,
    );
    final file = await _writeTempFile(
      bytes: utf8.encode(csv),
      name: 'driveflow-relatorio-${snapshot.period.name}.csv',
    );
    await Share.shareXFiles([XFile(file.path)], text: 'Relatório DriveFlow');
  }

  static Future<List<int>> _buildPdf({
    required ReportSnapshot snapshot,
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    PeriodComparisonResult? comparison,
  }) async {
    final doc = pw.Document();
    final summary = snapshot.summary;

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
            pw.Text('Relatório ${snapshot.periodLabel}'),
            pw.Text(
              'Gerado em ${_dateFormat.format(snapshot.generatedAt)}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 12),
          ],
        ),
        build: (context) => [
          _pdfSection('Indicadores', [
            _pdfRow('Receita', CurrencyFormatter.format(summary.revenue)),
            _pdfRow('Despesas', CurrencyFormatter.format(summary.expenses)),
            _pdfRow('Lucro', CurrencyFormatter.formatSigned(summary.profit)),
            _pdfRow(
              'Horas trabalhadas',
              DurationFormatter.formatWorkedHours(summary.workedHours),
            ),
            _pdfRow('Corridas', '${summary.rides}'),
            _pdfRow('Km estimados', summary.kmDriven.toStringAsFixed(0)),
            _pdfRow('Combustível', CurrencyFormatter.format(summary.fuelExpense)),
            if (summary.profitPerHour != null)
              _pdfRow(
                'Lucro / hora',
                CurrencyFormatter.format(summary.profitPerHour!),
              ),
            if (summary.profitPerKm != null)
              _pdfRow(
                'Lucro / km',
                CurrencyFormatter.format(summary.profitPerKm!),
              ),
          ]),
          if (comparison != null) ...[
            pw.SizedBox(height: 16),
            _pdfSection(
              'Comparativo (${comparison.reference.label})',
              [
                for (final metric in comparison.metrics)
                  _pdfRow(
                    metric.label,
                    '${CurrencyFormatter.format(metric.current)} '
                    '(${metric.delta >= 0 ? '+' : ''}${CurrencyFormatter.format(metric.delta)})',
                  ),
              ],
            ),
          ],
          pw.SizedBox(height: 16),
          _pdfSection('Ganhos (${earnings.length})', [
            for (final earning in earnings)
              pw.Text(
                '${DateFormat('dd/MM').format(earning.date)} · '
                '${earning.platform.label} · '
                '${CurrencyFormatter.format(earning.amount)}',
              ),
          ]),
          pw.SizedBox(height: 16),
          _pdfSection('Despesas (${expenses.length})', [
            for (final expense in expenses)
              pw.Text(
                '${DateFormat('dd/MM').format(expense.date)} · '
                '${expense.category.label} · '
                '${CurrencyFormatter.format(expense.amount)}',
              ),
          ]),
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
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static String _buildCsv({
    required ReportSnapshot snapshot,
    required List<EarningEntity> earnings,
    required List<ExpenseEntity> expenses,
    PeriodComparisonResult? comparison,
  }) {
    final buffer = StringBuffer();
    final summary = snapshot.summary;

    buffer.writeln('secao,campo,valor');
    buffer.writeln('resumo,periodo,${snapshot.periodLabel}');
    buffer.writeln('resumo,receita,${summary.revenue.toStringAsFixed(2)}');
    buffer.writeln('resumo,despesas,${summary.expenses.toStringAsFixed(2)}');
    buffer.writeln('resumo,lucro,${summary.profit.toStringAsFixed(2)}');
    buffer.writeln('resumo,horas,${summary.workedHours.toStringAsFixed(2)}');
    buffer.writeln('resumo,corridas,${summary.rides}');
    buffer.writeln('resumo,km,${summary.kmDriven.toStringAsFixed(0)}');
    buffer.writeln(
      'resumo,combustivel,${summary.fuelExpense.toStringAsFixed(2)}',
    );

    if (comparison != null) {
      buffer.writeln();
      buffer.writeln('comparativo,indicador,atual,delta,delta_pct');
      for (final metric in comparison.metrics) {
        buffer.writeln(
          'comparativo,${metric.label},${metric.current.toStringAsFixed(2)},'
          '${metric.delta.toStringAsFixed(2)},'
          '${metric.deltaPercent?.toStringAsFixed(1) ?? ''}',
        );
      }
    }

    buffer.writeln();
    buffer.writeln('tipo,data,descricao,valor');
    for (final earning in earnings) {
      buffer.writeln(
        'ganho,${DateFormat('yyyy-MM-dd').format(earning.date)},'
        '${earning.platform.label},${earning.amount.toStringAsFixed(2)}',
      );
    }
    for (final expense in expenses) {
      buffer.writeln(
        'despesa,${DateFormat('yyyy-MM-dd').format(expense.date)},'
        '${expense.category.label},${expense.amount.toStringAsFixed(2)}',
      );
    }

    return buffer.toString();
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
