import 'package:flutter/material.dart';
import 'package:logitruck_app/services/database_service.dart';
import 'package:logitruck_app/screens/pdf_preview_screen.dart';
import 'package:logitruck_app/model/transport_info.dart';

class TransportInfoScreen extends StatefulWidget {
  final Map<String, dynamic> listDetails;
  final List<Map<String, dynamic>> productsList;

  const TransportInfoScreen({
    Key? key,
    required this.listDetails,
    required this.productsList,
  }) : super(key: key);

  @override
  State<TransportInfoScreen> createState() => _TransportInfoScreenState();
}

class _TransportInfoScreenState extends State<TransportInfoScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final _formKey = GlobalKey<FormState>();
  final _exitTimeController = TextEditingController();
  final _notesController = TextEditingController();

  TransportInfo? _transportInfo;
  bool _isLoading = true;
  bool _isGeneratingPDF = false;
  TimeOfDay? _selectedExitTime;

  @override
  void initState() {
    super.initState();
    // Establecer la hora actual como hora de salida por defecto
    _selectedExitTime = TimeOfDay.now();
    _exitTimeController.text = _formatTimeOfDay(_selectedExitTime!);
    _loadTransportInfo();
  }

  @override
  void dispose() {
    _exitTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectExitTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedExitTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedExitTime = picked;
        _exitTimeController.text = _formatTimeOfDay(picked);
      });
    }
  }

  Future<void> _loadTransportInfo() async {
    try {
      final transportInfo = await _databaseService
          .getTransportInfoByListId(widget.listDetails['id']);

      if (mounted) {
        setState(() {
          _transportInfo = transportInfo;
          _isLoading = false;

          // Pre-llenar las notas si ya hay información
          if (transportInfo != null) {
            _notesController.text = transportInfo.notes ?? '';

            // Si ya hay hora de salida, usarla en lugar de la hora actual
            if (transportInfo.exitTime != null &&
                transportInfo.exitTime!.isNotEmpty) {
              _exitTimeController.text = transportInfo.exitTime!;
              // Intentar parsear la hora existente
              try {
                final parts = transportInfo.exitTime!.split(':');
                if (parts.length == 2) {
                  _selectedExitTime = TimeOfDay(
                    hour: int.parse(parts[0]),
                    minute: int.parse(parts[1]),
                  );
                }
              } catch (e) {
                // Si no se puede parsear, mantener la hora actual
              }
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar información de transporte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generatePDF() async {
    if (_transportInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay información de transporte asignada'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      // Actualizar la información de transporte con hora de salida y notas
      final updatedTransportInfo = TransportInfo(
        id: _transportInfo!.id,
        listId: _transportInfo!.listId,
        driverName: _transportInfo!.driverName,
        driverIdText: _transportInfo!.driverIdText,
        truckPlate: _transportInfo!.truckPlate,
        truckModel: _transportInfo!.truckModel,
        entryTime: _transportInfo!.entryTime,
        exitTime: _exitTimeController.text.trim(),
        notes: _notesController.text.trim(),
        createdAt: _transportInfo!.createdAt,
      );

      // Actualizar en la base de datos
      await _databaseService.updateTransportInfo(updatedTransportInfo);

      // Marcar la lista como completada
      await _databaseService.updateShippingListStatus(
          widget.listDetails['id'], 'completado');

      // Preparar datos para el PDF
      final transportData = {
        'driverName': updatedTransportInfo.driverName,
        'driverIdText': updatedTransportInfo.driverIdText,
        'truckPlate': updatedTransportInfo.truckPlate,
        'truckModel': updatedTransportInfo.truckModel,
        'entryTime': updatedTransportInfo.entryTime,
        'exitTime': updatedTransportInfo.exitTime ?? '',
        'notes': updatedTransportInfo.notes ?? '',
      };

      if (mounted) {
        // Navegar a la vista previa del PDF
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PDFPreviewScreen(
              listDetails: widget.listDetails,
              productsList: widget.productsList,
              transportData: transportData,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Información de Transporte'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transportInfo == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        size: 64,
                        color: Colors.orange[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay transporte asignado a esta lista',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Debe asignar un conductor y camión antes de generar el PDF',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Volver'),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTransportInfoCard(),
                          const SizedBox(height: 24),
                          _buildAdditionalInfoCard(),
                          const SizedBox(height: 32),
                          _buildGeneratePDFButton(),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildTransportInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping,
                  color: Colors.green[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'Información del Transporte',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Conductor:', _transportInfo!.driverName),
            _buildInfoRow('ID Conductor:', _transportInfo!.driverIdText),
            _buildInfoRow('Placa del Camión:', _transportInfo!.truckPlate),
            _buildInfoRow('Modelo del Camión:', _transportInfo!.truckModel),
            _buildInfoRow('Hora de Entrada:', _transportInfo!.entryTime),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: Colors.blue[700],
                ),
                const SizedBox(width: 8),
                Text(
                  'Información Adicional',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _exitTimeController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Hora de Salida',
                hintText: 'Seleccionar hora',
                prefixIcon: const Icon(Icons.access_time),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.schedule),
                  onPressed: _selectExitTime,
                ),
                border: const OutlineInputBorder(),
              ),
              onTap: _selectExitTime,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor seleccione la hora de salida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (Opcional)',
                hintText: 'Ingrese cualquier observación adicional...',
                prefixIcon: Icon(Icons.note_add),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratePDFButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isGeneratingPDF ? null : _generatePDF,
        icon: _isGeneratingPDF
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.picture_as_pdf),
        label: Text(
          _isGeneratingPDF
              ? 'Generando PDF...'
              : 'Generar PDF y Completar Lista',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
