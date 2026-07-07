import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/transaction_model.dart';

class ExportService {
  Future<String> exportToCsv({
    required String title,
    required int income,
    required int expense,
    required List<TransactionModel> transactions,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/Laporan');
    if (!await folder.exists()) await folder.create();

    final fileName = 'laporan_${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File('${folder.path}/$fileName');

    final buffer = StringBuffer();
    buffer.writeln(title);
    buffer.writeln('Pemasukan,Rp ${_format(income)}');
    buffer.writeln('Pengeluaran,Rp ${_format(expense)}');
    buffer.writeln('Saldo,Rp ${_format(income - expense)}');
    buffer.writeln('');
    buffer.writeln('Tanggal,Deskripsi,Kategori,Jumlah,Jenis');

    for (final t in transactions) {
      buffer.writeln(
        '${t.date.toIso8601String().split('T')[0]},'
        '"${t.description}",'
        '"${t.categoryName ?? ''}",'
        'Rp ${_format(t.amount.abs())},'
        '${t.isExpense ? 'Pengeluaran' : 'Pemasukan'}',
      );
    }

    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<String> exportToPdf({
    required String title,
    required int income,
    required int expense,
    required List<TransactionModel> transactions,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/Laporan');
    if (!await folder.exists()) await folder.create();

    final fileName = 'laporan_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${folder.path}/$fileName');

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (ctx) => [
          pw.Header(
            level: 0,
            child: pw.Text(title, style: const pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _summaryBox('Pemasukan', income, PdfColors.green),
              _summaryBox('Pengeluaran', expense, PdfColors.red),
              _summaryBox('Saldo', income - expense, (income - expense) >= 0 ? PdfColors.green : PdfColors.red),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text('Detail Transaksi', style: const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headerStyle: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellStyle: const pw.TextStyle(fontSize: 9),
            rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
            headers: ['Tanggal', 'Deskripsi', 'Kategori', 'Jumlah', 'Jenis'],
            data: transactions.map((t) => [
              t.date.toIso8601String().split('T')[0],
              t.description,
              t.categoryName ?? '',
              'Rp ${_format(t.amount.abs())}',
              t.isExpense ? 'Pengeluaran' : 'Pemasukan',
            ]).toList(),
          ),
        ],
      ),
    );

    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  pw.Widget _summaryBox(String label, int amount, PdfColor color) {
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, color: color)),
          pw.SizedBox(height: 4),
          pw.Text('Rp ${_format(amount)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  String _format(int n) => n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}
