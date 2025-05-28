import 'package:flutter/material.dart';
import 'package:logitruck_app/model/driver.dart';
import 'package:logitruck_app/model/transport_info.dart';
import 'package:logitruck_app/model/truck.dart';
import '../services/database_service.dart';

class AssignTransportDialog extends StatefulWidget {
  final int listId;
  final VoidCallback onTransportAssigned;

  const AssignTransportDialog({
    Key? key,
    required this.listId,
    required this.onTransportAssigned,
  }) : super(key: key);

  @override
  State<AssignTransportDialog> createState() => _AssignTransportDialogState();
}

class _AssignTransportDialogState extends State<AssignTransportDialog> {
  final DatabaseService _databaseService = DatabaseService();

  List<Driver> _drivers = [];
  List<Truck> _trucks = [];
  Driver? _selectedDriver;
  Truck? _selectedTruck;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final drivers = await _databaseService.getAllDrivers();
      final trucks = await _databaseService.getAllTrucks();

      // Cargar información de transporte existente si la hay
      final existingTransport =
          await _databaseService.getTransportInfoByListId(widget.listId);

      if (mounted) {
        setState(() {
          _drivers = drivers.where((driver) => driver.isActive).toList();
          _trucks = trucks.where((truck) => truck.isActive).toList();

          // Pre-seleccionar conductor y camión si ya están asignados
          if (existingTransport != null) {
            _selectedDriver = _drivers.firstWhere(
              (d) => d.id == existingTransport.driverDbId,
              orElse: () => _drivers.firstWhere(
                (d) => d.name == existingTransport.driverName,
                orElse: () => _drivers.first,
              ),
            );
            _selectedTruck = _trucks.firstWhere(
              (t) => t.id == existingTransport.truckDbId,
              orElse: () => _trucks.firstWhere(
                (t) => t.plate == existingTransport.truckPlate,
                orElse: () => _trucks.first,
              ),
            );
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignTransport() async {
    if (_selectedDriver == null || _selectedTruck == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona un conductor y un camión'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Verificar si ya existe información de transporte para esta lista
      final existingTransport =
          await _databaseService.getTransportInfoByListId(widget.listId);

      if (existingTransport != null) {
        // Actualizar la información existente
        final updatedTransport = existingTransport.copyWith(
          driverName: _selectedDriver!.name,
          driverIdText: _selectedDriver!.driverId,
          truckPlate: _selectedTruck!.plate,
          truckModel: '${_selectedTruck!.brand} ${_selectedTruck!.model}',
          driverDbId: _selectedDriver!.id,
          truckDbId: _selectedTruck!.id,
        );

        await _databaseService.updateTransportInfo(updatedTransport);
      } else {
        // Crear nueva información de transporte
        final transportInfo = TransportInfo(
          listId: widget.listId,
          driverName: _selectedDriver!.name,
          driverIdText: _selectedDriver!.driverId,
          truckPlate: _selectedTruck!.plate,
          truckModel: '${_selectedTruck!.brand} ${_selectedTruck!.model}',
          entryTime: '',
          createdAt: DateTime.now(),
          driverDbId: _selectedDriver!.id,
          truckDbId: _selectedTruck!.id,
        );

        await _databaseService.insertTransportInfo(transportInfo);
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onTransportAssigned();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al asignar transporte: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Asignar Transporte'),
      content: _isLoading
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Seleccionar Conductor:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Driver>(
                        value: _selectedDriver,
                        hint: const Text('Seleccionar conductor'),
                        isExpanded: true,
                        items: _drivers.map((driver) {
                          return DropdownMenuItem<Driver>(
                            value: driver,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'ID: ${driver.driverId} | Licencia: ${driver.licenseType}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDriver = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Seleccionar Camión:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.maxFinite,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Truck>(
                        value: _selectedTruck,
                        hint: const Text('Seleccionar camión'),
                        isExpanded: true,
                        items: _trucks.map((truck) {
                          return DropdownMenuItem<Truck>(
                            value: truck,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${truck.plate} - ${truck.brand} ${truck.model}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Año: ${truck.year} | Capacidad: ${truck.capacity} ton',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedTruck = value;
                          });
                        },
                      ),
                    ),
                  ),
                  if (_selectedDriver != null && _selectedTruck != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Resumen de Asignación:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Conductor: ${_selectedDriver!.name}'),
                          Text('Camión: ${_selectedTruck!.plate}'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _assignTransport,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Asignar'),
        ),
      ],
    );
  }
}
