import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class ProviderListDetailScreen extends StatefulWidget {
  final int listId;

  const ProviderListDetailScreen({
    Key? key,
    required this.listId,
  }) : super(key: key);

  @override
  State<ProviderListDetailScreen> createState() =>
      _ProviderListDetailScreenState();
}

class _ProviderListDetailScreenState extends State<ProviderListDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();

  Map<String, dynamic>? _listDetails;
  List<Map<String, dynamic>> _productsList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadListDetails();
  }

  Future<void> _loadListDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Cargar detalles de la lista
      final lists = await _databaseService.getAllShippingListsWithDetails();
      final listDetail = lists.firstWhere(
        (list) => list['id'] == widget.listId,
        orElse: () => {},
      );

      if (listDetail.isNotEmpty) {
        // Cargar productos de la lista
        final products = await _databaseService
            .getListItemsWithProductDetails(widget.listId);

        setState(() {
          _listDetails = listDetail;
          _productsList = products;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lista no encontrada'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error loading list details: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar detalles: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'en_proceso':
        return Colors.blue;
      case 'completado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_proceso':
        return 'En Proceso';
      case 'completado':
        return 'Completado';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de Lista #${widget.listId}'),
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _listDetails == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Lista no encontrada',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildListHeader(),
                        SizedBox(height: 24),
                        _buildTransportInfo(),
                        SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Productos',
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                            Text(
                              '${_productsList.length} productos',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        _buildProductsList(),
                        SizedBox(height: 24),
                        _buildTotalSection(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildListHeader() {
    if (_listDetails == null) return Container();

    final shippingDate = DateTime.parse(_listDetails!['shipping_date']);
    final createdAt = DateTime.parse(_listDetails!['created_at']);
    final statusColor = _getStatusColor(_listDetails!['status']);
    final statusText = _getStatusText(_listDetails!['status']);

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _listDetails!['point_name'] ?? 'Punto desconocido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  _listDetails!['point_address'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4),
              Text(
                'Envío: ${DateFormat('dd/MM/yyyy').format(shippingDate)}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: Colors.grey[600],
              ),
              SizedBox(width: 4),
              Text(
                'Creada: ${DateFormat('dd/MM/yyyy HH:mm').format(createdAt)}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportInfo() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getTransportInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Container();
        }

        final transportInfo = snapshot.data!;

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: Colors.blue.shade700,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Información de Transporte',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildInfoRow(
                  'Conductor:', transportInfo['driver_name'] ?? 'No asignado'),
              _buildInfoRow(
                  'Camión:', transportInfo['truck_info'] ?? 'No asignado'),
              if (transportInfo['entry_time'] != null &&
                  transportInfo['entry_time'].isNotEmpty)
                _buildInfoRow('Hora de entrada:', transportInfo['entry_time']),
              if (transportInfo['exit_time'] != null &&
                  transportInfo['exit_time'].isNotEmpty)
                _buildInfoRow('Hora de salida:', transportInfo['exit_time']),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getTransportInfo() async {
    try {
      final transportInfo =
          await _databaseService.getTransportInfoByListId(widget.listId);
      if (transportInfo != null) {
        return {
          'driver_name': transportInfo.driverName,
          'truck_info':
              '${transportInfo.truckPlate} - ${transportInfo.truckModel}',
          'entry_time': transportInfo.entryTime,
          'exit_time': transportInfo.exitTime,
        };
      }
    } catch (e) {
      print('Error getting transport info: $e');
    }
    return null;
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (_productsList.isEmpty) {
      return Container(
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              SizedBox(height: 8),
              Text(
                'No hay productos en esta lista',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
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
        children: _productsList.map((product) {
          final price = product['price'] ?? 0.0;
          final quantity = product['quantity'] ?? 0;
          final subtotal = product['subtotal'] ?? 0.0;

          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['product_name'] ?? 'Producto desconocido',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${quantity} ${product['product_unit'] ?? ''} x \$${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalSection() {
    final total = _listDetails?['total'] ?? 0.0;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total:',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
