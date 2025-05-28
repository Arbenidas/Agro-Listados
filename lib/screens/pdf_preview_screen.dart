import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../services/auth_service.dart';
import '../screens/home_screen.dart';
import '../screens/supervisor_home_screen.dart';

class PDFPreviewScreen extends StatelessWidget {
  final Map<String, dynamic> listDetails;
  final List<Map<String, dynamic>> productsList;
  final Map<String, dynamic> transportData;

  const PDFPreviewScreen({
    Key? key,
    required this.listDetails,
    required this.productsList,
    required this.transportData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Generado'),
        elevation: 0,
        automaticallyImplyLeading: false, // Quitar el botón de back automático
        actions: [
          IconButton(
            onPressed: () => _goToListsView(context),
            icon: const Icon(Icons.home),
            tooltip: 'Ir al Inicio',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de éxito
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Lista Completada!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'La lista #${listDetails['id']} ha sido marcada como completada y el PDF ha sido generado exitosamente.',
                        style: TextStyle(
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Vista previa del PDF
          Expanded(
            child: FutureBuilder<Uint8List>(
              future: _generatePdfDocument(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Generando PDF...'),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al generar el PDF: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _goToListsView(context),
                          child: const Text('Ir al Inicio'),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasData) {
                  return PdfPreview(
                    build: (format) => snapshot.data!,
                    allowPrinting: true,
                    allowSharing: true,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    pdfFileName: 'lista_${listDetails['id'] ?? "0"}.pdf',
                  );
                } else {
                  return const Center(
                    child: Text('No se pudo generar el PDF'),
                  );
                }
              },
            ),
          ),
          // Botón para regresar a las listas
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _goToListsView(context),
              icon: const Icon(Icons.list_alt),
              label: const Text(
                'Continuar con Otras Listas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToListsView(BuildContext context) {
    final authService = AuthService();
    final userRole = authService.currentUserRole;

    // Navegar a la pantalla correcta según el rol del usuario
    if (userRole == 'supervisor') {
      // Para supervisores, ir a la pantalla de supervisor
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SupervisorHomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      // Para proveedores, ir a la pantalla de proveedor
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<Uint8List> _generatePdfDocument() async {
    final pdf = pw.Document();

    // Cargar fuentes
    final font = await PdfGoogleFonts.nunitoRegular();
    final fontBold = await PdfGoogleFonts.nunitoBold();

    // Calcular el total y la cantidad total de productos
    double total = 0;
    int totalQuantity = 0;
    for (var product in productsList) {
      final price = double.parse(product['price'].toString());
      final quantity = int.parse(product['quantity'].toString());
      total += price * quantity;
      totalQuantity += quantity; // Sumar las cantidades
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        header: (context) => _buildHeader(context, font, fontBold),
        footer: (context) => _buildFooter(context, font),
        build: (context) => [
          _buildTitle(font, fontBold),
          pw.SizedBox(height: 20),
          _buildInfoSection(font, fontBold),
          pw.SizedBox(height: 20),
          _buildTransportSection(font, fontBold),
          pw.SizedBox(height: 20),
          _buildProductsTable(font, fontBold),
          pw.SizedBox(height: 20),
          _buildTotalSection(font, fontBold, total, totalQuantity),
          pw.SizedBox(height: 40),
          _buildSignatureSection(font, fontBold),
        ],
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(pw.Context context, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            'LOGITRUCK',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 24,
              color: PdfColors.green800,
            ),
          ),
          pw.Text(
            'Sistema de Gestión Logística',
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter(pw.Context context, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Página ${context.pageNumber} de ${context.pagesCount}',
        style: pw.TextStyle(
          font: font,
          fontSize: 12,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  pw.Widget _buildTitle(pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: pw.EdgeInsets.symmetric(vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.green800,
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'LISTA DE CARGA',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 20,
              color: PdfColors.green800,
            ),
          ),
          pw.Text(
            'ID: ${listDetails['id'] ?? ""}',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 16,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoSection(pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN GENERAL',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow(
              'Proveedor:', listDetails['user_name'] ?? '', font, fontBold),
          _buildInfoRow('Punto de Distribución:',
              listDetails['point_name'] ?? '', font, fontBold),
          _buildInfoRow(
              'Fecha:',
              listDetails['shipping_date'] != null
                  ? listDetails['shipping_date'].toString().substring(0, 10)
                  : '',
              font,
              fontBold),
          _buildInfoRow('Estado:', 'Completado', font, fontBold),
        ],
      ),
    );
  }

  pw.Widget _buildTransportSection(pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DE TRANSPORTE',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow(
              'Conductor:', transportData['driverName'] ?? '', font, fontBold),
          _buildInfoRow('ID Conductor:', transportData['driverIdText'] ?? '',
              font, fontBold),
          _buildInfoRow('Placa del Camión:', transportData['truckPlate'] ?? '',
              font, fontBold),
          _buildInfoRow('Modelo del Camión:', transportData['truckModel'] ?? '',
              font, fontBold),
          _buildInfoRow('Hora de Entrada:', transportData['entryTime'] ?? '',
              font, fontBold),
          _buildInfoRow('Hora de Salida:', transportData['exitTime'] ?? '',
              font, fontBold),
          if (transportData['notes'] != null &&
              transportData['notes'].isNotEmpty)
            _buildInfoRow(
                'Observaciones:', transportData['notes'], font, fontBold),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(
      String label, String value, pw.Font font, pw.Font fontBold) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 12,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildProductsTable(pw.Font font, pw.Font fontBold) {
    if (productsList.isEmpty) {
      return pw.Container(
        padding: pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(5),
        ),
        child: pw.Center(
          child: pw.Text(
            'No hay productos en esta lista',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
              color: PdfColors.grey700,
            ),
          ),
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey400,
        width: 0.5,
      ),
      columnWidths: {
        0: pw.FlexColumnWidth(3),
        1: pw.FlexColumnWidth(2),
        2: pw.FlexColumnWidth(2),
        3: pw.FlexColumnWidth(2),
        4: pw.FlexColumnWidth(2),
      },
      children: [
        // Encabezado de la tabla
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.green100,
          ),
          children: [
            _buildTableCell('Producto', font, fontBold, isHeader: true),
            _buildTableCell('Precio', font, fontBold, isHeader: true),
            _buildTableCell('Unidad', font, fontBold, isHeader: true),
            _buildTableCell('Cantidad', font, fontBold, isHeader: true),
            _buildTableCell('Total', font, fontBold, isHeader: true),
          ],
        ),
        // Filas de productos
        ...productsList.map((product) {
          final price = double.parse(product['price'].toString());
          final quantity = int.parse(product['quantity'].toString());
          final total = price * quantity;

          return pw.TableRow(
            children: [
              _buildTableCell(
                  product['product_name'] ?? product['product'] ?? '',
                  font,
                  fontBold),
              _buildTableCell('\$${price.toStringAsFixed(2)}', font, fontBold),
              _buildTableCell(product['product_unit'] ?? product['unit'] ?? '',
                  font, fontBold),
              _buildTableCell(quantity.toString(), font, fontBold),
              _buildTableCell('\$${total.toStringAsFixed(2)}', font, fontBold),
            ],
          );
        }).toList(),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, pw.Font font, pw.Font fontBold,
      {bool isHeader = false}) {
    return pw.Padding(
      padding: pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: isHeader ? fontBold : font,
          fontSize: 12,
        ),
        textAlign: text.contains('\$') ? pw.TextAlign.right : pw.TextAlign.left,
      ),
    );
  }

  pw.Widget _buildTotalSection(
      pw.Font font, pw.Font fontBold, double total, int totalQuantity) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'Total de Productos:',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Container(
                width: 100,
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(
                    color: PdfColors.green800,
                    width: 0.5,
                  ),
                ),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '$totalQuantity',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                'TOTAL:',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(width: 10),
              pw.Container(
                width: 100,
                padding: pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green100,
                  border: pw.Border.all(
                    color: PdfColors.green800,
                    width: 0.5,
                  ),
                ),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    font: fontBold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSignatureSection(pw.Font font, pw.Font fontBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _buildSignatureLine('Firma del Conductor', font, fontBold),
        _buildSignatureLine('Firma del Supervisor', font, fontBold),
      ],
    );
  }

  pw.Widget _buildSignatureLine(String title, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Container(
          width: 200,
          height: 1,
          color: PdfColors.black,
          margin: pw.EdgeInsets.only(bottom: 5),
        ),
        pw.Text(
          title,
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
