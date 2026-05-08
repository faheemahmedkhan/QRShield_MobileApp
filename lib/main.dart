import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as xl;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:device_preview/device_preview.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

// ─── Design Tokens ─────────────────────────────────────────────────────────────
// Following 4-base rule: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double massive = 48.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double round = 40.0;
}

class AppFontSize {
  static const double xs = 10.0;
  static const double sm = 11.0;
  static const double md = 12.0;
  static const double lg = 14.0;
  static const double xl = 16.0;
  static const double xxl = 18.0;
  static const double title = 22.0;
}

class AppColors {
  // Light Theme Color
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color lightSurfaceBorder = Color(0xFFE2E8F0);
  static const Color lightSurfaceBorderBright = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightamber = Color(0xFF94A3B8);

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF0A0E12);
  static const Color darkSurface = Color(0xFF181F28);
  static const Color darkSurfaceElevated = Color(0xFF1E2733);
  static const Color darkSurfaceBorder = Color(0xFF2A3440);
  static const Color darkSurfaceBorderBright = Color(0xFF4A5A6E);
  static const Color darkTextPrimary = Color(0xFFF0F4FA);
  static const Color darkTextSecondary = Color(0xFFB8C4D4);
  static const Color darkamber = Color(0xFF4A5A6E);

  // Accent colors (same for both themes)
  static const Color blue = Color(0xFF2D7AFF);
  static const Color blueDim = Color(0xFF1A4DCC);
  static const Color blueFaint = Color(0x142D7AFF);
  static const Color blueGlow = Color(0x332D7AFF);

  static const Color green = Color(0xFF10B981);
  static const Color greenFaint = Color(0x1410B981);

  static const Color red = Color(0xFFEF4444);
  static const Color redFaint = Color(0x14EF4444);

  static const Color yellow = Color(0xFFF59E0B);
  static const Color yellowFaint = Color(0x14F59E0B);

  static const Color amber = yellow;
  static const Color amberFaint = yellowFaint;
}

class AppTextStyles {
  static const String fontFamily = 'monospace';

  static TextStyle labelXs(BuildContext context) => TextStyle(
    fontSize: AppFontSize.xs,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: Theme.of(context).hintColor,
    fontFamily: fontFamily,
  );

  static TextStyle labelSm(BuildContext context) => TextStyle(
    fontSize: AppFontSize.sm,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: Theme.of(context).hintColor,
    fontFamily: fontFamily,
  );

  static TextStyle mono(BuildContext context) => TextStyle(
    fontSize: AppFontSize.md,
    fontFamily: fontFamily,
    color: Theme.of(context).textTheme.bodyLarge?.color,
    letterSpacing: 0.3,
  );

  static TextStyle monoSm(BuildContext context) => TextStyle(
    fontSize: AppFontSize.sm,
    fontFamily: fontFamily,
    color: Theme.of(context).hintColor,
    letterSpacing: 0.2,
  );

  static TextStyle heading(BuildContext context) => TextStyle(
    fontSize: AppFontSize.title,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
    letterSpacing: -0.5,
    color: Theme.of(context).textTheme.titleLarge?.color,
  );

  static TextStyle subtitle(BuildContext context) => TextStyle(
    fontSize: AppFontSize.lg,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: Theme.of(context).hintColor,
  );
}

void main() {
  runApp(
    DevicePreview(
      enabled: true,
      builder: (context) => const QRShieldTesterApp(),
    ),
  );
}

class QRShieldTesterApp extends StatefulWidget {
  const QRShieldTesterApp({super.key});

  @override
  State<QRShieldTesterApp> createState() => _QRShieldTesterAppState();
}

class _QRShieldTesterAppState extends State<QRShieldTesterApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QRShield',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBg,
        primaryColor: AppColors.blue,
        hintColor: AppColors.lightamber,
        colorScheme: const ColorScheme.light(
          primary: AppColors.blue,
          secondary: AppColors.green,
          surface: AppColors.lightSurface,
          error: AppColors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.lightTextPrimary,
          onError: Colors.white,
        ),
        cardColor: AppColors.lightSurface,
        dividerColor: AppColors.lightSurfaceBorder,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: AppColors.lightTextPrimary,
            fontFamily: 'monospace',
          ),
          bodyMedium: TextStyle(
            color: AppColors.lightTextSecondary,
            fontFamily: 'monospace',
          ),
          titleLarge: TextStyle(
            color: AppColors.lightTextPrimary,
            fontFamily: 'monospace',
          ),
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightSurface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        primaryColor: AppColors.blue,
        hintColor: AppColors.darkamber,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.blue,
          secondary: AppColors.green,
          surface: AppColors.darkSurface,
          error: AppColors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: AppColors.darkTextPrimary,
          onError: Colors.white,
        ),
        cardColor: AppColors.darkSurface,
        dividerColor: AppColors.darkSurfaceBorder,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'monospace',
          ),
          bodyMedium: TextStyle(
            color: AppColors.darkTextSecondary,
            fontFamily: 'monospace',
          ),
          titleLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'monospace',
          ),
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkSurface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      ),

      home: MainShell(toggleTheme: toggleTheme, themeMode: _themeMode),
    );
  }
}

// ─── Data Model ────────────────────────────────────────────────────────────────
class ScanRecord {
  final String id;
  final DateTime timestamp;
  final String status;
  final String? decodedUrl;
  final double? fusionScore;
  final double? dlProbability;
  final double? mlProbability;
  final String? fusionMode;
  final String? note;
  final String? error;
  final List<Map<String, dynamic>>? shapExplanation; // Added

  ScanRecord({
    required this.id,
    required this.timestamp,
    required this.status,
    this.decodedUrl,
    this.fusionScore,
    this.dlProbability,
    this.mlProbability,
    this.fusionMode,
    this.note,
    this.error,
    this.shapExplanation,
  });

  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
    id: json['id'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    status: json['status'] as String? ?? 'UNKNOWN',
    decodedUrl: json['decoded_url'] as String?,
    fusionScore: (json['fusion_score'] as num?)?.toDouble(),
    dlProbability: (json['dl_probability'] as num?)?.toDouble(),
    mlProbability: (json['ml_probability'] as num?)?.toDouble(),
    fusionMode: json['fusion_mode'] as String?,
    note: json['note'] as String?,
    error: json['error'] as String?,
    shapExplanation: json['shap_explanation'] != null
        ? List<Map<String, dynamic>>.from(json['shap_explanation'] as List)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'status': status,
    'decoded_url': decodedUrl,
    'fusion_score': fusionScore,
    'dl_probability': dlProbability,
    'ml_probability': mlProbability,
    'fusion_mode': fusionMode,
    'note': note,
    'error': error,
    if (shapExplanation != null) 'shap_explanation': shapExplanation,
  };
}

// ─── History Service ───────────────────────────────────────────────────────────
class HistoryService {
  static const _key = 'qr_scan_history';

  static Future<List<ScanRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final now = DateTime.now();
    final records =
        raw
            .map(
              (e) =>
                  ScanRecord.fromJson(json.decode(e) as Map<String, dynamic>),
            )
            .where((r) => now.difference(r.timestamp).inDays < 3)
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    await _save(records, prefs);
    return records;
  }

  static Future<void> add(ScanRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await load();
    existing.insert(0, record);
    await _save(existing, prefs);
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await load();
    records.removeWhere((r) => r.id == id);
    await _save(records, prefs);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _save(
    List<ScanRecord> records,
    SharedPreferences prefs,
  ) async {
    await prefs.setStringList(
      _key,
      records.map((r) => json.encode(r.toJson())).toList(),
    );
  }
}

// ─── Export Service ────────────────────────────────────────────────────────────
class ExportService {
  static String _fmt(double? v) => v != null ? v.toStringAsFixed(4) : 'N/A';
  static String _fmtDate(DateTime dt) =>
      DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);

  static Future<File> exportPdf(List<ScanRecord> records) async {
    final pdf = pw.Document();
    final dateHeader = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'QRShield Scan History',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Exported: $dateHeader',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
            pw.SizedBox(height: AppSpacing.sm),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: AppSpacing.xs),
          ],
        ),
        build: (_) => [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(3),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(1.2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey800,
                ),
                children:
                    [
                          'Timestamp',
                          'Status',
                          'URL',
                          'Fusion',
                          'DL Prob',
                          'ML Prob',
                        ]
                        .map(
                          (h) => pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              h,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              ...records.asMap().entries.map((entry) {
                final r = entry.value;
                final isEven = entry.key % 2 == 0;
                PdfColor statusColor = PdfColors.orange;
                if (r.status == 'SAFE') statusColor = PdfColors.green700;
                if (r.status == 'MALICIOUS' || r.status == 'DISTORTED_QR') {
                  statusColor = PdfColors.red700;
                }
                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.grey100 : PdfColors.white,
                  ),
                  children: [
                    _cell(_fmtDate(r.timestamp)),
                    _cell(r.status, color: statusColor),
                    _cell(r.decodedUrl ?? 'N/A'),
                    _cell(_fmt(r.fusionScore)),
                    _cell(_fmt(r.dlProbability)),
                    _cell(_fmt(r.mlProbability)),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/qrshield_history_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _cell(String text, {PdfColor? color}) => pw.Padding(
    padding: const pw.EdgeInsets.all(5),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 8, color: color ?? PdfColors.black),
    ),
  );

  static Future<File> exportExcel(List<ScanRecord> records) async {
    final excel = xl.Excel.createExcel();
    final sheet = excel['Scan History'];
    final headers = [
      'ID',
      'Timestamp',
      'Status',
      'Decoded URL',
      'Fusion Score',
      'DL Probability',
      'ML Probability',
      'Fusion Mode',
      'Note',
      'Error',
    ];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = xl.TextCellValue(headers[i]);
      cell.cellStyle = xl.CellStyle(
        bold: true,
        backgroundColorHex: xl.ExcelColor.fromHexString('#1E3A5F'),
        fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
      );
    }
    for (var i = 0; i < records.length; i++) {
      final r = records[i];
      final values = [
        r.id,
        _fmtDate(r.timestamp),
        r.status,
        r.decodedUrl ?? '',
        r.fusionScore?.toStringAsFixed(4) ?? '',
        r.dlProbability?.toStringAsFixed(4) ?? '',
        r.mlProbability?.toStringAsFixed(4) ?? '',
        r.fusionMode ?? '',
        r.note ?? '',
        r.error ?? '',
      ];
      for (var j = 0; j < values.length; j++) {
        sheet
            .cell(
              xl.CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1),
            )
            .value = xl.TextCellValue(
          values[j],
        );
      }
    }
    for (var i = 0; i < headers.length; i++) sheet.setColumnWidth(i, 20);
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/qrshield_history_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    final bytes = excel.encode();
    if (bytes != null) await file.writeAsBytes(bytes);
    return file;
  }
}

// ─── Shared Widgets ────────────────────────────────────────────────────────────

class _TacticalCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final EdgeInsetsGeometry padding;
  final Color? bgColor;

  const _TacticalCard({
    required this.child,
    this.accentColor = AppColors.blue,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.04),
            blurRadius: AppSpacing.xl,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Stack(
          children: [
            Padding(padding: padding, child: child),
            Positioned(
              top: 0,
              left: 0,
              child: _Corner(color: accentColor, flip: false),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _Corner(color: accentColor, flip: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Color color;
  final bool flip;
  const _Corner({required this.color, required this.flip});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: flip ? 3.14159 : 0,
      child: SizedBox(
        width: 16,
        height: 16,
        child: CustomPaint(painter: _CornerPainter(color: color)),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(Offset(0, size.height * 0.65), Offset.zero, paint);
    canvas.drawLine(Offset.zero, Offset(size.width * 0.65, 0), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

class _ScanDivider extends StatelessWidget {
  final Color color;
  const _ScanDivider({this.color = AppColors.blue});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            color.withValues(alpha: 0.4),
            color,
            color.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSafe = status == 'SAFE';
    final isBad = status == 'MALICIOUS' || status == 'DISTORTED_QR';
    final color = isSafe
        ? AppColors.green
        : (isBad ? AppColors.red : AppColors.amber);
    final icon = isSafe
        ? Icons.verified_rounded
        : (isBad ? Icons.gpp_bad_rounded : Icons.warning_amber_rounded);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.md, color: color),
          SizedBox(width: AppSpacing.xs),
          Text(
            status,
            style: TextStyle(
              fontSize: AppFontSize.xs,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DataRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label.toUpperCase(),
              style: AppTextStyles.labelXs(context),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.mono(context).copyWith(
                color:
                    valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: AppFontSize.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Main Shell ────────────────────────────────────────────────────────────────
class MainShell extends StatefulWidget {
  final VoidCallback toggleTheme;
  final ThemeMode themeMode;

  const MainShell({
    super.key,
    required this.toggleTheme,
    required this.themeMode,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  final GlobalKey<HistoryScreenState> _historyKey =
      GlobalKey<HistoryScreenState>();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [TestingScreen(), HistoryScreen(key: _historyKey)];
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) _historyKey.currentState?.reload();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          width: 80,
          height: 80,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.shield_rounded, color: AppColors.blue, size: 24),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: AppSpacing.md),
            child: IconButton(
              onPressed: widget.toggleTheme,
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                size: 22,
              ),
              tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.lightSurfaceElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _navItem(0, Icons.qr_code_scanner_rounded, 'SCANNER'),
              Container(
                width: 1,
                height: 32,
                color: Theme.of(context).dividerColor,
              ),
              _navItem(1, Icons.storage_rounded, 'HISTORY'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isActive ? AppColors.blueFaint : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: isActive
                      ? AppColors.blue.withValues(alpha: 0.25)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isActive
                        ? AppColors.blue
                        : Theme.of(context).hintColor,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: AppFontSize.xs,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: isActive
                          ? AppColors.blue
                          : Theme.of(context).hintColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isActive ? 32 : 0,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(AppRadius.xs),
                boxShadow: isActive
                    ? [
                        const BoxShadow(
                          color: AppColors.blueGlow,
                          blurRadius: AppSpacing.sm,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add these classes before the TestingScreen class

// SHAP Analysis Models
class ShapFeature {
  final String name;
  final double value;
  final double shapValue;

  ShapFeature({
    required this.name,
    required this.value,
    required this.shapValue,
  });

  factory ShapFeature.fromJson(Map<String, dynamic> json) => ShapFeature(
    name: json['feature'] as String,
    value: (json['value'] as num).toDouble(),
    shapValue: (json['shap_value'] as num).toDouble(),
  );
}

// SHAP Waterfall Plot Widget - shows feature contributions similar to your image
class ShapWaterfallPlot extends StatelessWidget {
  final List<ShapFeature> features;

  const ShapWaterfallPlot({super.key, required this.features});

  @override
  Widget build(BuildContext context) {
    // Sort by absolute SHAP value (most important first)
    final sortedFeatures = List<ShapFeature>.from(features)
      ..sort((a, b) => b.shapValue.abs().compareTo(a.shapValue.abs()));

    // Take top 8 features for display
    final topFeatures = sortedFeatures.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.analytics_rounded, size: 14, color: AppColors.blue),
            SizedBox(width: AppSpacing.sm),
            Text(
              'FEATURE CONTRIBUTIONS (SHAP)',
              style: AppTextStyles.labelXs(
                context,
              ).copyWith(color: AppColors.blue, fontSize: AppFontSize.sm),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        // Feature list
        ...topFeatures.map((feature) => _ShapFeatureRow(feature: feature)),

        SizedBox(height: AppSpacing.md),

        // Legend
        _buildLegend(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem('Increases risk', AppColors.red, context),
          SizedBox(width: AppSpacing.md),
          _legendItem('Reduces risk', AppColors.green, context),
        ],
      ),
    );
  }

  Widget _legendItem(String text, Color color, BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.xs),
            border: Border.all(color: color),
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          text,
          style: AppTextStyles.monoSm(
            context,
          ).copyWith(fontSize: AppFontSize.xs),
        ),
      ],
    );
  }
}

class _ShapFeatureRow extends StatelessWidget {
  final ShapFeature feature;

  const _ShapFeatureRow({required this.feature});

  @override
  Widget build(BuildContext context) {
    final isIncrease = feature.shapValue > 0;
    final color = isIncrease ? AppColors.red : AppColors.green;
    final barWidth = (feature.shapValue.abs() / 0.3).clamp(
      0.0,
      1.0,
    ); // Normalize to max 0.3

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  _formatFeatureName(feature.name),
                  style: AppTextStyles.monoSm(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.sm,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: Text(
                  _formatValue(feature.value),
                  style: AppTextStyles.monoSm(context),
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 65,
                child: Text(
                  _formatContribution(feature.shapValue),
                  style: TextStyle(
                    fontSize: AppFontSize.sm,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: barWidth,
              backgroundColor: Theme.of(context).dividerColor,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 3,
            ),
          ),
          // Description text (like in the image)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              _getFeatureDescription(feature.name, feature.value),
              style: AppTextStyles.monoSm(context).copyWith(
                fontSize: AppFontSize.xs - 1,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFeatureName(String name) {
    return name.replaceAll('_', ' ').toUpperCase();
  }

  String _formatValue(double value) {
    // Handle boolean-like values (0/1)
    if (value == 0 || value == 1) {
      return value == 1 ? 'Yes' : 'No';
    }
    if (value.toString().contains('.')) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  String _formatContribution(double value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(4)}';
  }

  String _getFeatureDescription(String featureName, double value) {
    final descriptions = {
      'hostname_length': 'Abnormally long hostnames can mask phishing domains',
      'whois_available': 'Public WHOIS is a legitimate transparency signal',
      'tld_length': 'Common, recognised TLD reduces risk',
      'uses_https': 'Encrypted connection reduces risk',
      'checking_ip_address': 'Domain name used (not raw IP) reduces risk',
      'abnormal_url': 'Normal URL structure reduces risk',
      'count_dot': 'Normal number of dots in URL',
      'count_at': 'No @ symbol abuse detected',
      'find_dir': 'Normal path depth',
      'no_of_embed': 'No embedded URL tricks detected',
      'shortening_service': 'No URL shortener used',
      'count_per': 'Minimal percent-encoding, normal',
      'count_ques': 'Number of query parameters',
      'count_dash': 'Number of hyphens in URL',
      'count_equal': 'Number of equals signs',
      'url_length': 'Total URL length',
      'suspicious_words': 'Contains suspicious keywords',
      'digit_count': 'Number of digits in URL',
      'count_special_chars': 'Number of special characters',
      'fd_length': 'Length of first directory',
      'domain_age_days': 'Domain age in days',
      'dns_resolves': 'DNS resolves to IP address',
      'num_ip_addresses': 'Number of IP addresses',
      'has_mx_record': 'Has mail exchange record',
      'http_status_code': 'HTTP response status',
      'redirect_count': 'Number of redirects',
      'ssl_valid': 'SSL certificate valid',
    };

    String desc =
        descriptions[featureName] ?? 'Feature contribution to risk assessment';

    // Add specific context based on value for certain features
    if (featureName == 'hostname_length' && value > 15) {
      desc =
          'Hostname is ${value.toInt()} chars — abnormally long hostnames can mask phishing domains';
    } else if (featureName == 'tld_length') {
      desc = 'TLD is ${value.toInt()} chars — a common, recognised TLD';
    } else if (featureName == 'count_dot') {
      desc = '${value.toInt()} dot(s) in URL — a normal number of dots';
    } else if (featureName == 'find_dir') {
      desc = '${value.toInt()} slash(es) (path depth) — normal path depth';
    } else if (featureName == 'count_per') {
      desc =
          '${value.toInt()} percent-encoded char(s) — minimal encoding, normal';
    } else if (featureName == 'domain_age_days') {
      if (value < 30)
        desc =
            'Domain is ${value.toInt()} days old — very new domains are suspicious';
      else if (value > 365)
        desc =
            'Domain is ${value.toInt()} days old — established domain reduces risk';
    }

    return desc;
  }
}

// ─── Testing Screen ────────────────────────────────────────────────────────────
class TestingScreen extends StatefulWidget {
  const TestingScreen({super.key});

  @override
  State<TestingScreen> createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _urlController = TextEditingController(
    text: 'http://72.62.246.243:8080/scan',
  );
  File? _image;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String _backendUrl = 'http://72.62.246.243:8080/scan';
  final BarcodeScanner _qrScanner = BarcodeScanner(
    formats: [BarcodeFormat.qrCode],
  );

  @override
  void dispose() {
    _qrScanner.close();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = null;
        _isLoading = true;
      });
      try {
        final cropped = await _cropToQrIfPossible(_image!);
        setState(() => _image = cropped);
        await _analyzeImage();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<File> _cropToQrIfPossible(File input) async {
    try {
      final inputImage = InputImage.fromFilePath(input.path);
      final barcodes = await _qrScanner.processImage(inputImage);
      if (barcodes.isEmpty) return input;

      final rect = barcodes.first.boundingBox;
      if (rect == null) return input;

      final bytes = await input.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final decoded = frame.image;

      final pad = math.max(
        16,
        (math.max(rect.width, rect.height) * 0.18).round(),
      );
      final x1 = (rect.left.round() - pad).clamp(0, decoded.width - 1);
      final y1 = (rect.top.round() - pad).clamp(0, decoded.height - 1);
      final x2 = (rect.right.round() + pad).clamp(1, decoded.width);
      final y2 = (rect.bottom.round() + pad).clamp(1, decoded.height);
      final w = math.max(1, x2 - x1);
      final h = math.max(1, y2 - y1);

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      final src = ui.Rect.fromLTWH(
        x1.toDouble(),
        y1.toDouble(),
        w.toDouble(),
        h.toDouble(),
      );
      final dst = ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble());
      final paint = ui.Paint()..filterQuality = ui.FilterQuality.high;
      canvas.drawImageRect(decoded, src, dst, paint);
      final picture = recorder.endRecording();
      final cropped = await picture.toImage(w, h);
      final png = await cropped.toByteData(format: ui.ImageByteFormat.png);
      if (png == null) return input;

      final dir = await getTemporaryDirectory();
      final out = File(
        '${dir.path}/qr_crop_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await out.writeAsBytes(png.buffer.asUint8List());
      return out;
    } catch (_) {
      return input;
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;
    setState(() {
      _isLoading = true;
      _result = null;
    });
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_backendUrl));
      request.files.add(
        await http.MultipartFile.fromPath('file', _image!.path),
      );
      final response = await http.Response.fromStream(await request.send());
      if (response.statusCode == 200) {
        final resultData = json.decode(response.body) as Map<String, dynamic>;
        setState(() => _result = resultData);
        await HistoryService.add(
          ScanRecord(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            status: resultData['status'] as String? ?? 'UNKNOWN',
            decodedUrl: resultData['decoded_url'] as String?,
            fusionScore: (resultData['fusion_score'] as num?)?.toDouble(),
            dlProbability: (resultData['dl_probability'] as num?)?.toDouble(),
            mlProbability: (resultData['ml_probability'] as num?)?.toDouble(),
            fusionMode: resultData['fusion_mode'] as String?,
            note: resultData['note'] as String?,
            shapExplanation: resultData['shap_explanation'] != null
                ? List<Map<String, dynamic>>.from(
                    resultData['shap_explanation'] as List,
                  )
                : null,
          ),
        );
      } else {
        setState(
          () => _result = {
            'error': 'Server error: ${response.statusCode}',
            'body': response.body,
          },
        );
      }
    } catch (e) {
      setState(() => _result = {'error': 'Connection failed: $e'});
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final target = uri.hasScheme ? uri : Uri.parse('https://$url');
    if (await canLaunchUrl(target)) {
      await launchUrl(target, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
          SliverPadding(
            padding: EdgeInsets.all(AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDropZone(),
                SizedBox(height: AppSpacing.md),
                _buildScanActions(),
                SizedBox(height: AppSpacing.xxl),
                if (_isLoading) _buildLoader(),
                if (!_isLoading && _result != null) _buildResultCard(),
              ]),
            ),
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: AppSpacing.xxxl)),
        ],
      ),
    );
  }

  Widget _buildDropZone() {
    final hasImage = _image != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _TacticalCard(
      accentColor: hasImage ? AppColors.blue : Theme.of(context).dividerColor,
      padding: EdgeInsets.zero,
      bgColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          height: 240,
          width: double.infinity,
          child: hasImage
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(_image!, fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Theme.of(
                              context,
                            ).scaffoldBackgroundColor.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.md,
                      left: AppSpacing.md,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).scaffoldBackgroundColor.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(
                            color: AppColors.blue.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppColors.green,
                            ),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              'IMAGE LOADED',
                              style: AppTextStyles.labelXs(
                                context,
                              ).copyWith(color: AppColors.green),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_2_rounded,
                        size: 32,
                        color: AppColors.amber,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'NO IMAGE SELECTED',
                      style: AppTextStyles.labelSm(
                        context,
                      ).copyWith(color: Theme.of(context).hintColor),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'capture or import a QR code image',
                      style: AppTextStyles.monoSm(
                        context,
                      ).copyWith(fontSize: AppFontSize.xs),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildScanActions() {
    return Row(
      children: [
        Expanded(
          child: _scanBtn(
            icon: Icons.camera_alt_rounded,
            label: 'CAMERA',
            onTap: () => _pickImage(ImageSource.camera),
            primary: true,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _scanBtn(
            icon: Icons.photo_library_rounded,
            label: 'GALLERY',
            onTap: () => _pickImage(ImageSource.gallery),
            primary: false,
          ),
        ),
      ],
    );
  }

  Widget _scanBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool primary,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(
                  colors: [AppColors.blueDim, AppColors.blue],
                )
              : null,
          color: primary
              ? null
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: primary
                ? Colors.transparent
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: primary ? Colors.white : Theme.of(context).hintColor,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                fontSize: AppFontSize.sm,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: primary ? Colors.white : Theme.of(context).hintColor,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return _TacticalCard(
      accentColor: AppColors.blue,
      child: Column(
        children: [
          SizedBox(height: AppSpacing.xxl),
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              color: AppColors.blue,
              strokeWidth: 2,
            ),
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'ANALYZING QR CODE',
            style: AppTextStyles.labelSm(
              context,
            ).copyWith(color: AppColors.blue),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'scanning for threat vectors…',
            style: AppTextStyles.monoSm(
              context,
            ).copyWith(fontSize: AppFontSize.xs),
          ),
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final status = _result!['status'] as String? ?? 'UNKNOWN';
    final isSafe = status == 'SAFE';
    final isBad = status == 'MALICIOUS' || status == 'DISTORTED_QR';
    final accentColor = isSafe
        ? AppColors.green
        : (isBad ? AppColors.red : AppColors.amber);
    final url = _result!['decoded_url'] as String?;

    // Parse SHAP explanations from backend
    List<ShapFeature> shapFeatures = [];
    if (_result!.containsKey('shap_explanation') &&
        _result!['shap_explanation'] != null) {
      final shapList = _result!['shap_explanation'] as List;
      shapFeatures = shapList
          .map((item) => ShapFeature.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    Color? bgTint;
    if (isBad) bgTint = AppColors.red.withValues(alpha: 0.04);
    if (isSafe) bgTint = AppColors.green.withValues(alpha: 0.04);

    return _TacticalCard(
      accentColor: accentColor,
      bgColor: bgTint ?? Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status and score
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SCAN RESULT',
                      style: AppTextStyles.labelXs(
                        context,
                      ).copyWith(color: Theme.of(context).hintColor),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _StatusBadge(status: status),
                  ],
                ),
              ),
              if (_result!['fusion_score'] != null)
                _ScoreMeter(
                  score: (_result!['fusion_score'] as num).toDouble(),
                  color: accentColor,
                ),
            ],
          ),
          _ScanDivider(color: accentColor),

          // Basic metrics
          _DataRow(
            label: 'Fusion Score',
            value: _result!['fusion_score']?.toString() ?? 'N/A',
          ),
          _DataRow(
            label: 'DL Prob',
            value: _result!['dl_probability']?.toString() ?? 'N/A',
          ),
          _DataRow(
            label: 'ML Prob',
            value: _result!['ml_probability']?.toString() ?? 'N/A',
          ),
          _DataRow(label: 'Mode', value: _result!['fusion_mode'] ?? 'N/A'),

          // SHAP Analysis Section - ALWAYS SHOW (even if empty)
          SizedBox(height: AppSpacing.md),
          _ScanDivider(color: accentColor),

          // Show either actual SHAP data or a placeholder card
          shapFeatures.isNotEmpty
              ? ShapWaterfallPlot(features: shapFeatures)
              : _buildShapPlaceholder(),

          if (_result!['note'] != null)
            _DataRow(label: 'Note', value: _result!['note']!),
          if (_result!['error'] != null)
            _DataRow(
              label: 'Error',
              value: _result!['error']!,
              valueColor: AppColors.red,
            ),
          _ScanDivider(color: accentColor),
          if (url != null && url.isNotEmpty)
            _UrlBlock(url: url, onVisit: () => _launchUrl(url))
          else
            _DataRow(label: 'URL', value: 'Not decoded'),
        ],
      ),
    );
  }

  // Add this new method to show placeholder when SHAP data is not available
  Widget _buildShapPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_rounded, size: 14, color: AppColors.blue),
            SizedBox(width: AppSpacing.sm),
            Text(
              'FEATURE CONTRIBUTIONS (SHAP)',
              style: AppTextStyles.labelXs(
                context,
              ).copyWith(color: AppColors.blue, fontSize: AppFontSize.sm),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.data_usage_rounded,
                size: 32,
                color: Theme.of(context).hintColor.withValues(alpha: 0.5),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'SHAP ANALYSIS UNAVAILABLE',
                style: AppTextStyles.labelSm(context).copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: AppFontSize.sm,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Feature importance data not returned from server\nfor this QR code scan',
                style: AppTextStyles.monoSm(context).copyWith(
                  fontSize: AppFontSize.xs,
                  color: Theme.of(context).hintColor.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Score Meter ───────────────────────────────────────────────────────────────
class _ScoreMeter extends StatelessWidget {
  final double score;
  final Color color;
  const _ScoreMeter({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        color: color.withValues(alpha: 0.08),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toStringAsFixed(2),
            style: TextStyle(
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.w800,
              color: color,
              fontFamily: 'monospace',
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'SCORE',
            style: AppTextStyles.labelXs(context).copyWith(
              fontSize: AppFontSize.xs - 2,
              color: color.withValues(alpha: 0.7),
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── URL Block ─────────────────────────────────────────────────────────────────
class _UrlBlock extends StatelessWidget {
  final String url;
  final VoidCallback onVisit;
  const _UrlBlock({required this.url, required this.onVisit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.link_rounded, size: 12, color: AppColors.amber),
            SizedBox(width: AppSpacing.xs),
            Text(
              'DECODED URL',
              style: AppTextStyles.labelXs(
                context,
              ).copyWith(color: Theme.of(context).hintColor),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBg : AppColors.lightBg,
            borderRadius: BorderRadius.circular(AppRadius.xs),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Text(
            url,
            style: AppTextStyles.mono(
              context,
            ).copyWith(color: AppColors.blue, fontSize: AppFontSize.sm),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: onVisit,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.blueDim, AppColors.blue],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.open_in_browser_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        'VISIT LINK',
                        style: TextStyle(
                          fontSize: AppFontSize.sm,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppColors.green,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'URL copied to clipboard',
                          style: AppTextStyles.mono(
                            context,
                          ).copyWith(fontSize: AppFontSize.md),
                        ),
                      ],
                    ),
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceElevated
                        : AppColors.lightSurfaceElevated,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: const Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: AppColors.blue,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── History Screen ────────────────────────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  List<ScanRecord> _records = [];
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void reload() => _load();

  Future<void> _load() async {
    if (mounted) setState(() => _loading = true);
    final records = await HistoryService.load();
    if (mounted)
      setState(() {
        _records = records;
        _loading = false;
      });
  }

  Future<void> _delete(String id) async {
    await HistoryService.delete(id);
    await _load();
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        titlePadding: EdgeInsets.all(AppSpacing.lg),
        contentPadding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, size: 18, color: AppColors.red),
            SizedBox(width: AppSpacing.sm),
            Text(
              'CLEAR ALL RECORDS',
              style: AppTextStyles.labelSm(context).copyWith(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: AppFontSize.md,
              ),
            ),
          ],
        ),
        content: Text(
          'All scan records will be permanently deleted. This cannot be undone.',
          style: AppTextStyles.mono(context).copyWith(
            color: Theme.of(context).hintColor,
            fontSize: AppFontSize.sm,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'CANCEL',
              style: AppTextStyles.labelXs(
                context,
              ).copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'DELETE ALL',
              style: AppTextStyles.labelXs(
                context,
              ).copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await HistoryService.clearAll();
      await _load();
    }
  }

  Future<void> _exportPdf() async {
    if (_records.isEmpty) return;
    setState(() => _exporting = true);
    try {
      final file = await ExportService.exportPdf(_records);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'QRShield Scan History PDF',
        ),
      );
    } catch (e) {
      _showError('PDF export failed: $e');
    } finally {
      setState(() => _exporting = false);
    }
  }

  Future<void> _exportExcel() async {
    if (_records.isEmpty) return;
    setState(() => _exporting = true);
    try {
      final file = await ExportService.exportExcel(_records);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          subject: 'QRShield Scan History Excel',
        ),
      );
    } catch (e) {
      _showError('Excel export failed: $e');
    } finally {
      setState(() => _exporting = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTextStyles.mono(context).copyWith(fontSize: AppFontSize.md),
        ),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final target = uri.hasScheme ? uri : Uri.parse('https://$url');
    if (await canLaunchUrl(target)) {
      await launchUrl(target, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          if (_loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.blue,
                  strokeWidth: 2,
                ),
              ),
            )
          else ...[
            if (_records.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: _buildToolbar(),
                ),
              ),
            SliverToBoxAdapter(child: _buildStatsBanner()),
            if (_records.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _buildHistoryTile(_records[i]),
                    childCount: _records.length,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        Expanded(
          child: _exportBtn(
            Icons.picture_as_pdf_rounded,
            'PDF',
            const Color(0xFFFF6B35),
            _exportPdf,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _exportBtn(
            Icons.table_chart_rounded,
            'EXCEL',
            const Color(0xFF00C853),
            _exportExcel,
          ),
        ),
      ],
    );
  }

  Widget _exportBtn(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: _exporting ? null : onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _exporting
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: color,
                      strokeWidth: 1.5,
                    ),
                  )
                : Icon(icon, size: 16, color: color),
            SizedBox(width: AppSpacing.sm),
            Text(
              'EXPORT $label',
              style: TextStyle(
                fontSize: AppFontSize.xs,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBanner() {
    final total = _records.length;
    final safe = _records.where((r) => r.status == 'SAFE').length;
    final threat = _records
        .where((r) => r.status == 'MALICIOUS' || r.status == 'DISTORTED_QR')
        .length;
    final unknown = total - safe - threat;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            _statBlock('$total', 'TOTAL', AppColors.blue),
            _vDivider(),
            _statBlock('$safe', 'SAFE', AppColors.green),
            _vDivider(),
            _statBlock('$threat', 'THREAT', AppColors.red),
            _vDivider(),
            _statBlock('$unknown', 'UNKN', AppColors.amber),
            const Spacer(),
            const Icon(
              Icons.schedule_rounded,
              size: 12,
              color: AppColors.amber,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              '3-day retention',
              style: AppTextStyles.monoSm(
                context,
              ).copyWith(fontSize: AppFontSize.xs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBlock(String count, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
            fontFamily: 'monospace',
            height: 1,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelXs(context).copyWith(
            color: color.withValues(alpha: 0.7),
            fontSize: AppFontSize.xs - 1,
          ),
        ),
      ],
    );
  }

  Widget _vDivider() => Container(
    width: 1,
    height: 32,
    margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
    color: Theme.of(context).dividerColor,
  );

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: const Icon(
              Icons.storage_rounded,
              size: 32,
              color: AppColors.amber,
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          Text(
            'NO RECORDS FOUND',
            style: AppTextStyles.labelSm(
              context,
            ).copyWith(color: Theme.of(context).hintColor),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'scan a QR code to populate this log',
            style: AppTextStyles.monoSm(
              context,
            ).copyWith(fontSize: AppFontSize.xs),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(ScanRecord r) {
    final isSafe = r.status == 'SAFE';
    final isBad = r.status == 'MALICIOUS' || r.status == 'DISTORTED_QR';
    final statusColor = isSafe
        ? AppColors.green
        : (isBad ? AppColors.red : AppColors.amber);
    final ageHours = DateTime.now().difference(r.timestamp).inHours;
    final ageLabel = ageHours < 1
        ? 'Just now'
        : ageHours < 24
        ? '${ageHours}h ago'
        : '${DateTime.now().difference(r.timestamp).inDays}d ago';
    final timeStr = DateFormat('dd MMM · HH:mm').format(r.timestamp);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(r.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: AppSpacing.xl),
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.redFaint,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DELETE',
              style: AppTextStyles.labelXs(
                context,
              ).copyWith(color: AppColors.red),
            ),
            SizedBox(width: AppSpacing.sm),
            const Icon(Icons.delete_rounded, color: AppColors.red, size: 18),
          ],
        ),
      ),
      onDismissed: (_) => _delete(r.id),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: statusColor.withValues(alpha: 0.22)),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.sm),
                    bottomLeft: Radius.circular(AppRadius.sm),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.35),
                      blurRadius: AppSpacing.sm,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusBadge(status: r.status),
                      const Spacer(),
                      Text(
                        timeStr,
                        style: AppTextStyles.monoSm(
                          context,
                        ).copyWith(fontSize: AppFontSize.xs),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          ageLabel,
                          style: AppTextStyles.labelXs(context).copyWith(
                            fontSize: AppFontSize.xs - 1,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (r.fusionScore != null ||
                      r.dlProbability != null ||
                      r.mlProbability != null) ...[
                    SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (r.fusionScore != null)
                          _scorePill('FSN', r.fusionScore!, statusColor),
                        if (r.dlProbability != null)
                          _scorePill('DL', r.dlProbability!, AppColors.blue),
                        if (r.mlProbability != null)
                          _scorePill(
                            'ML',
                            r.mlProbability!,
                            const Color(0xFF9D6FFF),
                          ),
                      ],
                    ),
                  ],
                  if (r.decodedUrl != null && r.decodedUrl!.isNotEmpty) ...[
                    SizedBox(height: AppSpacing.md),
                    Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBg : AppColors.lightBg,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.link_rounded,
                            size: 14,
                            color: AppColors.amber,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              r.decodedUrl!,
                              style: AppTextStyles.mono(context).copyWith(
                                color: AppColors.blue,
                                fontSize: AppFontSize.sm,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: () => _launchUrl(r.decodedUrl!),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.blueFaint,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                                border: Border.all(
                                  color: AppColors.blue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.open_in_browser_rounded,
                                    size: 13,
                                    color: AppColors.blue,
                                  ),
                                  SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'VISIT',
                                    style: AppTextStyles.labelXs(context)
                                        .copyWith(
                                          color: AppColors.blue,
                                          fontSize: AppFontSize.xs,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                ClipboardData(text: r.decodedUrl!),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 14,
                                        color: AppColors.green,
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Text(
                                        'URL copied',
                                        style: AppTextStyles.mono(
                                          context,
                                        ).copyWith(fontSize: AppFontSize.sm),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: isDark
                                      ? AppColors.darkSurfaceElevated
                                      : AppColors.lightSurfaceElevated,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.xs,
                                    ),
                                    side: BorderSide(
                                      color: Theme.of(context).dividerColor,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                              ),
                              child: const Icon(
                                Icons.copy_rounded,
                                size: 13,
                                color: AppColors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scorePill(String label, double value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelXs(context).copyWith(
              color: color.withValues(alpha: 0.8),
              fontSize: AppFontSize.xs,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            value.toStringAsFixed(3),
            style: TextStyle(
              fontSize: AppFontSize.sm,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
