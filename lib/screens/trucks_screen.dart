import 'package:flutter/material.dart';
import 'package:logitruck_app/model/truck.dart';
import '../services/database_service.dart';

class TrucksScreen extends StatefulWidget {
  const TrucksScreen({Key? key}) : super(key: key);

  @override
  State<TrucksScreen> createState() => _TrucksScreenState();
}

class _TrucksScreenState extends State<TrucksScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Truck> _trucks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrucks();
  }

  Future<void> _loadTrucks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final trucks = await _databaseService.getAllTrucks();
      setState(() {
        _trucks = trucks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar camiones: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddTruckDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddTruckDialog(
        onTruckAdded: () {
          _loadTrucks();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camiones'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTrucks,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTruckDialog,
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _trucks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay camiones registrados',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTrucks,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _trucks.length,
                    itemBuilder: (context, index) {
                      final truck = _trucks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Container(
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
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              child: Icon(
                                Icons.local_shipping,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              truck.plate,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text('${truck.brand} ${truck.model}'),
                                Text('Año: ${truck.year}'),
                                Text('Capacidad: ${truck.capacity} ton'),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: truck.isActive
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                truck.isActive ? 'Activo' : 'Inactivo',
                                style: TextStyle(
                                  color: truck.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _AddTruckDialog extends StatefulWidget {
  final VoidCallback onTruckAdded;

  const _AddTruckDialog({required this.onTruckAdded});

  @override
  State<_AddTruckDialog> createState() => _AddTruckDialogState();
}

class _AddTruckDialogState extends State<_AddTruckDialog> {
  final _formKey = GlobalKey<FormState>();
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _brandController = TextEditingController();
  final _yearController = TextEditingController();
  final _capacityController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveTruck() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final truck = Truck(
          plate: _plateController.text.trim().toUpperCase(),
          model: _modelController.text.trim(),
          brand: _brandController.text.trim(),
          year: int.parse(_yearController.text.trim()),
          capacity: double.parse(_capacityController.text.trim()),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await DatabaseService().insertTruck(truck);

        Navigator.pop(context);
        widget.onTruckAdded();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camión agregado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar camión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _brandController.dispose();
    _yearController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Camión'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _plateController,
                decoration: InputDecoration(
                  labelText: 'Placa',
                  prefixIcon: Icon(Icons.confirmation_number),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la placa';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Marca',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la marca';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: InputDecoration(
                  labelText: 'Modelo',
                  prefixIcon: Icon(Icons.local_shipping),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el modelo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(
                  labelText: 'Año',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el año';
                  }
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 1990 ||
                      year > DateTime.now().year + 1) {
                    return 'Ingresa un año válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: InputDecoration(
                  labelText: 'Capacidad (toneladas)',
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la capacidad';
                  }
                  final capacity = double.tryParse(value);
                  if (capacity == null || capacity <= 0) {
                    return 'Ingresa una capacidad válida';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveTruck,
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Guardar'),
        ),
      ],
    );
  }
}
