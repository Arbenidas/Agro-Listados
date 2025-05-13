import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pdf_preview_screen.dart';

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
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _driverNameController = TextEditingController();
  final _driverIdController = TextEditingController();
  final _truckPlateController = TextEditingController();
  final _truckModelController = TextEditingController();
  final _entryTimeController = TextEditingController();
  final _exitTimeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _entryTime;
  DateTime? _exitTime;

  @override
  void initState() {
    super.initState();
    _entryTime = DateTime.now();
    _entryTimeController.text = _formatTime(_entryTime!);
  }

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverIdController.dispose();
    _truckPlateController.dispose();
    _truckModelController.dispose();
    _entryTimeController.dispose();
    _exitTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, bool isEntry) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
        if (isEntry) {
          _entryTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            picked.hour,
            picked.minute,
          );
          _entryTimeController.text = _formatTime(_entryTime!);
        } else {
          _exitTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            picked.hour,
            picked.minute,
          );
          _exitTimeController.text = _formatTime(_exitTime!);
        }
      });
    }
  }

  void _generatePDF() {
    if (_formKey.currentState!.validate()) {
      // Recopilar todos los datos para el PDF
      final transportData = {
        'driverName': _driverNameController.text,
        'driverId': _driverIdController.text,
        'truckPlate': _truckPlateController.text,
        'truckModel': _truckModelController.text,
        'entryTime': _entryTimeController.text,
        'exitTime': _exitTimeController.text,
        'notes': _notesController.text,
      };

      // Navegar a la pantalla de vista previa del PDF
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFPreviewScreen(
            listDetails: widget.listDetails,
            productsList: widget.productsList,
            transportData: transportData,
          ),
        ),
      );
    } else {
      // Mostrar mensaje de error si el formulario no es válido
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información de Transporte'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datos del Conductor',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: 16),
                  _buildFormSection(
                    children: [
                      TextFormField(
                        controller: _driverNameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre del Conductor',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el nombre del conductor';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _driverIdController,
                        decoration: InputDecoration(
                          labelText: 'Identificación del Conductor',
                          prefixIcon: Icon(Icons.badge),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa la identificación';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Datos del Camión',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: 16),
                  _buildFormSection(
                    children: [
                      TextFormField(
                        controller: _truckPlateController,
                        decoration: InputDecoration(
                          labelText: 'Placa del Camión',
                          prefixIcon: Icon(Icons.local_shipping),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa la placa del camión';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _truckModelController,
                        decoration: InputDecoration(
                          labelText: 'Modelo del Camión',
                          prefixIcon: Icon(Icons.directions_car),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el modelo del camión';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Horarios',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: 16),
                  _buildFormSection(
                    children: [
                      TextFormField(
                        controller: _entryTimeController,
                        decoration: InputDecoration(
                          labelText: 'Hora de Entrada',
                          prefixIcon: Icon(Icons.access_time),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _selectTime(context, true),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor selecciona la hora de entrada';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _exitTimeController,
                        decoration: InputDecoration(
                          labelText: 'Hora de Salida',
                          prefixIcon: Icon(Icons.access_time),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _selectTime(context, false),
                          ),
                        ),
                        readOnly: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Notas Adicionales',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  SizedBox(height: 16),
                  _buildFormSection(
                    children: [
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Observaciones',
                          prefixIcon: Icon(Icons.note),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _generatePDF,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf),
                        SizedBox(width: 8),
                        Text('GENERAR PDF'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSection({required List<Widget> children}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
