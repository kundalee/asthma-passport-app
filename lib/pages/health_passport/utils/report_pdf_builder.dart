import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../models/passport_models.dart';

const Map<int, PdfColor> _statusBgColors = {
  1: PdfColor.fromInt(0xFFD9F4E5),
  2: PdfColor.fromInt(0xFFFEFCE8),
  3: PdfColor.fromInt(0xFFF5DED6),
  4: PdfColor.fromInt(0xFFFFF4F5),
};

const Map<int, PdfColor> _statusTextColors = {
  1: PdfColor.fromInt(0xFF006D37),
  2: PdfColor.fromInt(0xFFBF8915),
  3: PdfColor.fromInt(0xFFDA4F1E),
  4: PdfColor.fromInt(0xFFE7000B),
};

const PdfColor _sweetGrey = PdfColor.fromInt(0xFFD9D9D9);
const PdfColor _hydrocarbon = PdfColor.fromInt(0xFF4A5565);

Future<pw.Document> buildActionPlanReportPdf({
  required PassportInfo info,
  required PassportPlan plan,
}) async {
  final regular = await PdfGoogleFonts.notoSansTCRegular();
  final medium = await PdfGoogleFonts.notoSansTCMedium();
  final bold = await PdfGoogleFonts.notoSansTCBold();

  final statusTitle = passportStatusTitles[plan.statusLevel] ?? '尚未填寫';
  final statusBg = _statusBgColors[plan.statusLevel] ?? PdfColors.grey200;
  final statusColor = _statusTextColors[plan.statusLevel] ?? PdfColors.black;

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Center(
          child: pw.Text(
            '行動計畫指派報告',
            style: pw.TextStyle(font: bold, fontSize: 22),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 3, color: PdfColors.black),
        pw.SizedBox(height: 8),
        pw.Text('基本資料', style: pw.TextStyle(font: medium, fontSize: 14)),
        pw.SizedBox(height: 6),
        _row(medium, '病患姓名', info.name),
        _row(medium, '填寫日期', plan.recordDate?.replaceAll('-', '/') ?? '-'),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 3, color: _sweetGrey),
        pw.SizedBox(height: 8),
        pw.Text('氣喘控制狀況', style: pw.TextStyle(font: medium, fontSize: 14)),
        pw.SizedBox(height: 6),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: pw.BoxDecoration(
            color: statusBg,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(
            statusTitle,
            style: pw.TextStyle(font: medium, fontSize: 14, color: statusColor),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 3, color: _sweetGrey),
        pw.SizedBox(height: 8),
        if (plan.statusLevel == 4) ...[
          pw.Text('緊急措施', style: pw.TextStyle(font: medium, fontSize: 14)),
          pw.SizedBox(height: 6),
          pw.Text(
            '請立即依醫師指示採取緊急措施，並儘速就醫。',
            style: pw.TextStyle(font: regular, fontSize: 12, color: _hydrocarbon),
          ),
        ] else ...[
          pw.Text('控制藥物', style: pw.TextStyle(font: medium, fontSize: 14)),
          pw.SizedBox(height: 6),
          ..._medicationBlocks(medium, regular, plan.controlMeds),
          pw.SizedBox(height: 8),
          pw.Text('緩解藥物', style: pw.TextStyle(font: medium, fontSize: 14)),
          pw.SizedBox(height: 6),
          ..._medicationBlocks(medium, regular, plan.reliefMeds),
        ],
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 3, color: _sweetGrey),
        pw.SizedBox(height: 8),
        pw.Text('備註事項', style: pw.TextStyle(font: medium, fontSize: 14)),
        pw.SizedBox(height: 6),
        pw.Text(
          plan.notes.isNotEmpty ? plan.notes : '無',
          style: pw.TextStyle(font: regular, fontSize: 12),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(thickness: 3, color: PdfColors.black),
        pw.SizedBox(height: 8),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text('醫師確認：', style: pw.TextStyle(font: medium, fontSize: 12)),
            pw.Text(
              plan.doctorName.isNotEmpty ? plan.doctorName : '未確認',
              style: pw.TextStyle(font: medium, fontSize: 18),
            ),
          ],
        ),
      ],
    ),
  );

  return doc;
}

List<pw.Widget> _medicationBlocks(
  pw.Font medium,
  pw.Font regular,
  List<PassportMedication> meds,
) {
  if (meds.isEmpty) {
    return [
      pw.Text('藥物 1', style: pw.TextStyle(font: medium, fontSize: 13)),
      _row(medium, '藥物名稱', '未指派'),
      pw.SizedBox(height: 8),
    ];
  }

  final blocks = <pw.Widget>[];
  for (var i = 0; i < meds.length; i++) {
    final med = meds[i];
    blocks.add(pw.Text('藥物 ${i + 1}', style: pw.TextStyle(font: medium, fontSize: 13)));
    blocks.add(_row(medium, '藥物名稱', med.name.isNotEmpty ? med.name : '未指派'));
    if (med.name.isNotEmpty) {
      blocks.add(_row(medium, '- 使用劑量：白天', med.dose.isNotEmpty ? med.dose : '未指派'));
      blocks.add(_row(medium, '- 使用劑量：夜晚', med.freq.isNotEmpty ? med.freq : '未指派'));
    }
    if (med.note.isNotEmpty) {
      blocks.add(pw.SizedBox(height: 4));
      blocks.add(pw.Text('備註', style: pw.TextStyle(font: medium, fontSize: 12)));
      blocks.add(pw.Text(med.note, style: pw.TextStyle(font: regular, fontSize: 12)));
    }
    blocks.add(pw.SizedBox(height: 8));
  }
  return blocks;
}

pw.Widget _row(pw.Font font, String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 12)),
        pw.Text(value, style: pw.TextStyle(font: font, fontSize: 12)),
      ],
    ),
  );
}
