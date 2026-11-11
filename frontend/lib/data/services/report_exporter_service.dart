import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:emprendedor/data/models/entrepreneur/stats/stats_model.dart';

class ReportExporterService {
  static const _sheetName = 'Estadísticas_Tienda';
  static const _reportTitle = 'Reporte de Estadísticas';
  static const _generatedLabel = 'Generado';

  final Logger _logger = Logger('ReportExporterService');
  final String _locale = 'es_ES';

  Future<String?> exportToExcel(
    StatisticsOverview statsOverview,
    String fileNamePrefix,
  ) async {
    if (_isEmpty(statsOverview)) {
      throw Exception('No hay datos para exportar a Excel.');
    }

    try {
      final excel = Excel.createExcel();
      final Sheet sheet = excel[_sheetName];

      final headerStyle = CellStyle(
        bold: true,
        fontSize: 12,
        backgroundColorHex: ExcelColor.fromHexString('FFEEEEEE'),
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center,
      );

      int currentRow = 0;

      sheet
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        _reportTitle,
      );
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: currentRow),
      );
      currentRow++;

      sheet
          .cell(
            CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
          )
          .value = TextCellValue(
        '$_generatedLabel: ${DateFormat('dd MMM yyyy, hh:mm a', _locale).format(DateTime.now())}',
      );
      currentRow += 2;

      if (statsOverview.dailySales.isNotEmpty) {
        currentRow = _writeDailySales(
          sheet,
          statsOverview,
          currentRow,
          headerStyle,
        );
      }

      if (statsOverview.topProducts.isNotEmpty) {
        currentRow = _writeTopProducts(
          sheet,
          statsOverview,
          currentRow,
          headerStyle,
        );
      }

      if (statsOverview.frequentCustomers.isNotEmpty) {
        _writeFrequentCustomers(sheet, statsOverview, currentRow, headerStyle);
      }

      excel.setDefaultSheet(sheet.sheetName);

      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception('No se pudo generar el archivo Excel.');
      }

      final directory = await getApplicationDocumentsDirectory();
      final path =
          '${directory.path}/${_buildTimestampedFileName(fileNamePrefix, 'xlsx')}';

      final file = File(path);
      await file.writeAsBytes(fileBytes, flush: true);

      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        _logger.warning('No se pudo abrir el archivo Excel: ${result.message}');
      }

      return path;
    } catch (e, st) {
      _logger.severe('Error exportando Excel', e, st);
      rethrow;
    }
  }

  Future<String?> exportToPdf(
    StatisticsOverview statsOverview,
    String fileNamePrefix,
  ) async {
    if (_isEmpty(statsOverview)) {
      throw Exception('No hay datos para exportar a PDF.');
    }

    try {
      final pdf = pw.Document();

      final defaultTextStyle = pw.TextStyle(
        fontSize: 10,
        color: PdfColors.black,
      );

      final headerTextStyle = pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.teal700,
      );

      final tableHeaderStyle = pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          header: (_) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const pw.EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 0.5, color: PdfColors.grey),
              ),
            ),
            child: pw.Text(
              'Reporte de Estadísticas - Tienda Emprendedor',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          ),
          footer: (context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey),
            ),
          ),
          build: (_) {
            final widgets = <pw.Widget>[
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Reporte General de Estadísticas',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.teal900,
                      ),
                    ),
                    pw.PdfLogo(),
                  ],
                ),
              ),
              pw.Paragraph(
                text:
                    'Generado el: ${DateFormat('dd MMMM yyyy, hh:mm a', _locale).format(DateTime.now())}',
                style: defaultTextStyle,
              ),
              pw.SizedBox(height: 20),
            ];

            if (statsOverview.dailySales.isNotEmpty) {
              widgets.add(
                pw.Header(
                  level: 1,
                  child: pw.Text(
                    'Resumen de Ventas Diarias',
                    style: headerTextStyle,
                  ),
                ),
              );
              widgets.add(
                _buildSalesTablePdf(
                  statsOverview.dailySales,
                  'Fecha',
                  defaultTextStyle,
                  tableHeaderStyle,
                ),
              );
              widgets.add(pw.SizedBox(height: 15));
            }

            if (statsOverview.topProducts.isNotEmpty) {
              widgets.add(
                pw.Header(
                  level: 1,
                  child: pw.Text(
                    'Productos Más Vendidos',
                    style: headerTextStyle,
                  ),
                ),
              );
              widgets.add(
                _buildTopProductsTablePdf(
                  statsOverview.topProducts,
                  defaultTextStyle,
                  tableHeaderStyle,
                ),
              );
              widgets.add(pw.SizedBox(height: 15));
            }

            if (statsOverview.frequentCustomers.isNotEmpty) {
              widgets.add(
                pw.Header(
                  level: 1,
                  child: pw.Text('Clientes Frecuentes', style: headerTextStyle),
                ),
              );
              widgets.add(
                _buildFrequentCustomersTablePdf(
                  statsOverview.frequentCustomers,
                  defaultTextStyle,
                  tableHeaderStyle,
                ),
              );
            }

            return widgets;
          },
        ),
      );

      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/${_buildTimestampedFileName(fileNamePrefix, 'pdf')}';

      final file = File(path);
      final pdfBytes = await pdf.save();

      await file.writeAsBytes(pdfBytes, flush: true);

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: file.path.split('/').last,
      );

      return path;
    } catch (e, st) {
      _logger.severe('Error exportando PDF', e, st);
      rethrow;
    }
  }

  bool _isEmpty(StatisticsOverview statsOverview) {
    return statsOverview.dailySales.isEmpty &&
        statsOverview.topProducts.isEmpty &&
        statsOverview.frequentCustomers.isEmpty;
  }

  String _buildTimestampedFileName(String prefix, String extension) {
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${prefix}_$stamp.$extension';
  }

  int _writeExcelSectionTitle(
    Sheet sheet,
    int row,
    String title,
    CellStyle headerStyle,
  ) {
    final cell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
    );
    cell.value = TextCellValue(title);
    cell.cellStyle = headerStyle;
    return row + 1;
  }

  int _writeDailySales(
    Sheet sheet,
    StatisticsOverview statsOverview,
    int currentRow,
    CellStyle headerStyle,
  ) {
    currentRow = _writeExcelSectionTitle(
      sheet,
      currentRow,
      'Ventas Diarias',
      headerStyle,
    );

    _writeExcelHeaderRow(
      sheet: sheet,
      row: currentRow,
      headers: const ['Fecha', 'Monto Ventas', 'Num. Pedidos'],
      headerStyle: headerStyle,
    );

    currentRow++;

    for (final sale in statsOverview.dailySales) {
      _writeExcelRow(
        sheet: sheet,
        row: currentRow,
        values: [
          TextCellValue(DateFormat('dd/MM/yyyy', _locale).format(sale.date)),
          DoubleCellValue(sale.salesAmount),
          IntCellValue(sale.orderCount),
        ],
      );
      currentRow++;
    }

    return currentRow + 2;
  }

  int _writeTopProducts(
    Sheet sheet,
    StatisticsOverview statsOverview,
    int currentRow,
    CellStyle headerStyle,
  ) {
    currentRow = _writeExcelSectionTitle(
      sheet,
      currentRow,
      'Productos Más Vendidos',
      headerStyle,
    );

    _writeExcelHeaderRow(
      sheet: sheet,
      row: currentRow,
      headers: const ['Producto', 'Cantidad Vendida', 'Ingresos Generados'],
      headerStyle: headerStyle,
    );

    currentRow++;

    for (final product in statsOverview.topProducts) {
      _writeExcelRow(
        sheet: sheet,
        row: currentRow,
        values: [
          TextCellValue(product.productName),
          IntCellValue(product.quantitySold),
          DoubleCellValue(product.totalRevenue),
        ],
      );
      currentRow++;
    }

    return currentRow + 2;
  }

  void _writeFrequentCustomers(
    Sheet sheet,
    StatisticsOverview statsOverview,
    int currentRow,
    CellStyle headerStyle,
  ) {
    currentRow = _writeExcelSectionTitle(
      sheet,
      currentRow,
      'Clientes Frecuentes',
      headerStyle,
    );

    _writeExcelHeaderRow(
      sheet: sheet,
      row: currentRow,
      headers: const ['Cliente', 'Total Pedidos', 'Total Gastado'],
      headerStyle: headerStyle,
    );

    currentRow++;

    for (final customer in statsOverview.frequentCustomers) {
      _writeExcelRow(
        sheet: sheet,
        row: currentRow,
        values: [
          TextCellValue(customer.customerName),
          IntCellValue(customer.totalOrders),
          DoubleCellValue(customer.totalSpent),
        ],
      );
      currentRow++;
    }
  }

  void _writeExcelHeaderRow({
    required Sheet sheet,
    required int row,
    required List<String> headers,
    required CellStyle headerStyle,
  }) {
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }
  }

  void _writeExcelRow({
    required Sheet sheet,
    required int row,
    required List<CellValue> values,
  }) {
    for (int i = 0; i < values.length; i++) {
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row))
              .value =
          values[i];
    }
  }

  pw.Widget _buildSalesTablePdf(
    List<SalesDataPoint> sales,
    String dateHeader,
    pw.TextStyle style,
    pw.TextStyle headerStyle,
  ) {
    return _buildPdfTable(
      style: style,
      headerStyle: headerStyle,
      data: [
        [dateHeader, 'Monto Ventas', 'Num. Pedidos'],
        ...sales.map(
          (s) => [
            DateFormat('dd/MM/yy', _locale).format(s.date),
            NumberFormat.currency(
              locale: _locale,
              symbol: '\$',
              decimalDigits: 2,
            ).format(s.salesAmount),
            s.orderCount.toString(),
          ],
        ),
      ],
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
      },
    );
  }

  pw.Widget _buildTopProductsTablePdf(
    List<TopProductStat> products,
    pw.TextStyle style,
    pw.TextStyle headerStyle,
  ) {
    return _buildPdfTable(
      style: style,
      headerStyle: headerStyle,
      data: [
        ['Producto', 'Cant. Vendida', 'Ingresos'],
        ...products.map(
          (p) => [
            p.productName,
            p.quantitySold.toString(),
            NumberFormat.currency(
              locale: _locale,
              symbol: '\$',
              decimalDigits: 2,
            ).format(p.totalRevenue),
          ],
        ),
      ],
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(3),
      },
    );
  }

  pw.Widget _buildFrequentCustomersTablePdf(
    List<FrequentCustomerStat> customers,
    pw.TextStyle style,
    pw.TextStyle headerStyle,
  ) {
    return _buildPdfTable(
      style: style,
      headerStyle: headerStyle,
      data: [
        ['Cliente', 'Total Pedidos', 'Total Gastado'],
        ...customers.map(
          (c) => [
            c.customerName,
            c.totalOrders.toString(),
            NumberFormat.currency(
              locale: _locale,
              symbol: '\$',
              decimalDigits: 2,
            ).format(c.totalSpent),
          ],
        ),
      ],
      columnWidths: {
        0: const pw.FlexColumnWidth(4),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(3),
      },
    );
  }

  pw.Widget _buildPdfTable({
    required pw.TextStyle style,
    required pw.TextStyle headerStyle,
    required List<List<String>> data,
    required Map<int, pw.TableColumnWidth> columnWidths,
  }) {
    return pw.TableHelper.fromTextArray(
      cellPadding: const pw.EdgeInsets.all(5),
      headerStyle: headerStyle,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.teal400),
      cellStyle: style,
      cellAlignment: pw.Alignment.centerLeft,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
      columnWidths: columnWidths,
    );
  }
}








