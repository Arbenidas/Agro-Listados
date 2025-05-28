import 'package:flutter/material.dart';
import 'package:logitruck_app/model/driver.dart';
import 'package:logitruck_app/model/truck.dart';
import '../utils/page_transition.dart';
import 'supervisor_lists_screen.dart';
import 'drivers_screen.dart';
import 'trucks_screen.dart';

import '../services/database_service.dart';
import '../services/statistics_service.dart';
import '../widgets/logout_button.dart';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({Key? key}) : super(key: key);

  @override
  State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final StatisticsService _statisticsService = StatisticsService();
  Map<String, int> _statistics = {
    'total': 0,
    'pending': 0,
    'completed': 0,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.35), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
    _loadStatistics();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final stats = await _statisticsService.getListStatistics();
    if (mounted) {
      setState(() {
        _statistics = stats;
      });
    }
  }

  void _showAddDriverDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddDriverDialog(
        onDriverAdded: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Conductor agregado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _showAddTruckDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddTruckDialog(
        onTruckAdded: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camión agregado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel de Supervisor'),
        elevation: 0,
        actions: [
          LogoutButton(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    '¡Bienvenido, Supervisor!',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
              SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Text(
                    'Gestiona las listas de todos los proveedores',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildMenuCard(
                          title: 'Listas de Proveedores',
                          icon: Icons.list_alt,
                          onTap: () {
                            Navigator.push(
                              context,
                              SlideRightRoute(page: const SupervisorListsScreen()),
                            );
                          },
                        ),
                        _buildMenuCard(
                          title: 'Conductores',
                          icon: Icons.drive_eta,
                          onTap: () {
                            Navigator.push(
                              context,
                              SlideRightRoute(page: const DriversScreen()),
                            );
                          },
                        ),
                        _buildMenuCard(
                          title: 'Camiones',
                          icon: Icons.local_shipping,
                          onTap: () {
                            Navigator.push(
                              context,
                              SlideRightRoute(page: const TrucksScreen()),
                            );
                          },
                        ),
                        _buildMenuCard(
                          title: 'Agregar Conductor',
                          icon: Icons.person_add,
                          backgroundColor: Colors.blue,
                          onTap: _showAddDriverDialog,
                        ),
                        _buildMenuCard(
                          title: 'Agregar Camión',
                          icon: Icons.add_road,
                          backgroundColor: Colors.green,
                          onTap: _showAddTruckDialog,
                        ),
                        _buildMenuCard(
                          title: 'Reportes',
                          icon: Icons.bar_chart,
                          onTap: () {
                            // Navegar a la pantalla de reportes
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
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
                      children: [
                        Text(
                          'Resumen',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard(
                              title: 'Listas',
                              value: _statistics['total'].toString(),
                              icon: Icons.list,
                              color: Colors.blue,
                            ),
                            _buildStatCard(
                              title: 'Pendientes',
                              value: _statistics['pending'].toString(),
                              icon: Icons.pending_actions,
                              color: Colors.orange,
                            ),
                            _buildStatCard(
                              title: 'Completadas',
                              value: _statistics['completed'].toString(),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              splashColor: (backgroundColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.2),
              highlightColor: (backgroundColor ?? Theme.of(context).colorScheme.primary).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 48,
                      color: backgroundColor != null ? Colors.white : Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: backgroundColor != null ? Colors.white : Theme.of(context).colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// Diálogo para agregar conductor
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

// Diálogo para agregar camión
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
                  if (year == null || year < 1990 || year > DateTime.now().year + 1) {
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
