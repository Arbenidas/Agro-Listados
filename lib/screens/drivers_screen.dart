import 'package:flutter/material.dart';
import 'package:logitruck_app/model/driver.dart';
import '../services/database_service.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({Key? key}) : super(key: key);

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Driver> _drivers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  Future<void> _loadDrivers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final drivers = await _databaseService.getAllDrivers();
      setState(() {
        _drivers = drivers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar conductores: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddDriverDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddDriverDialog(
        onDriverAdded: () {
          _loadDrivers();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conductores'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDrivers,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDriverDialog,
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _drivers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.drive_eta,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No hay conductores registrados',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDrivers,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _drivers.length,
                    itemBuilder: (context, index) {
                      final driver = _drivers[index];
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
                              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                              child: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              driver.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text('ID: ${driver.driverId}'),
                                Text('Teléfono: ${driver.phone}'),
                                Text('Licencia: ${driver.licenseType}'),
                              ],
                            ),
                            trailing: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: driver.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                driver.isActive ? 'Activo' : 'Inactivo',
                                style: TextStyle(
                                  color: driver.isActive ? Colors.green : Colors.red,
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

class _AddDriverDialog extends StatefulWidget {
  final VoidCallback onDriverAdded;

  const _AddDriverDialog({required this.onDriverAdded});

  @override
  State<_AddDriverDialog> createState() => _AddDriverDialogState();
}

class _AddDriverDialogState extends State<_AddDriverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _driverIdController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedLicenseType = 'A';
  bool _isLoading = false;

  final List<String> _licenseTypes = ['A', 'B', 'C', 'D', 'E'];

  Future<void> _saveDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final driver = Driver(
          name: _nameController.text.trim(),
          driverId: _driverIdController.text.trim(),
          phone: _phoneController.text.trim(),
          licenseType: _selectedLicenseType,
          isActive: true,
          createdAt: DateTime.now(),
        );

        await DatabaseService().insertDriver(driver);

        Navigator.pop(context);
        widget.onDriverAdded();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conductor agregado con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar conductor: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _driverIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Agregar Conductor'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _driverIdController,
                decoration: InputDecoration(
                  labelText: 'Identificación',
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la identificación';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el teléfono';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLicenseType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Licencia',
                  prefixIcon: Icon(Icons.credit_card),
                ),
                items: _licenseTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text('Licencia $type'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLicenseType = value!;
                  });
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
          onPressed: _isLoading ? null : _saveDriver,
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
