import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logitruck_app/services/database_service.dart';
import 'package:logitruck_app/model/transport_info.dart';
import 'package:logitruck_app/widgets/assign_transport_dialog.dart';
import 'package:logitruck_app/screens/transport_info_screen.dart';
import 'package:logitruck_app/model/product.dart';
import 'package:logitruck_app/screens/add_product_dialog.dart';
import 'package:logitruck_app/model/list_item.dart';

class SupervisorListDetailScreen extends StatefulWidget {
  final int listId;

  const SupervisorListDetailScreen({
    Key? key,
    required this.listId,
  }) : super(key: key);

  @override
  State<SupervisorListDetailScreen> createState() => _SupervisorListDetailScreenState();
}

class _SupervisorListDetailScreenState extends State<SupervisorListDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();

  Map<String, dynamic>? _listDetails;
  List<Map<String, dynamic>> _productsList = [];
  TransportInfo? _transportInfo;
  bool _isLoading = true;
  List<Product> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    _loadListDetails();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _databaseService.getAllProducts();
      if (mounted) {
        setState(() {
          _availableProducts = products;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  Future<void> _loadListDetails() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      // Cargar detalles de la lista
      final lists = await _databaseService.getAllShippingListsWithDetails();
      final listDetail = lists.firstWhere(
        (list) => list['id'] == widget.listId,
        orElse: () => <String, dynamic>{},
      );

      if (listDetail.isNotEmpty) {
        // Cargar productos de la lista
        final products = await _databaseService.getListItemsWithProductDetails(widget.listId);

        // Cargar información de transporte
        final transport = await _databaseService.getTransportInfoByListId(widget.listId);

        if (mounted) {
          setState(() {
            _listDetails = listDetail;
            _productsList = products;
            _transportInfo = transport;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lista no encontrada'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print('Error loading list details: $e');
      if (mounted) {
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
  }

  void _showAssignTransportDialog() {
    showDialog(
      context: context,
      builder: (context) => AssignTransportDialog(
        listId: widget.listId,
        onTransportAssigned: () {
          if (mounted) {
            _loadListDetails(); // Recargar datos
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transporte asignado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        availableProducts: _availableProducts,
        onProductAdded: _handleProductAdded,
      ),
    );
  }

  Future<void> _handleProductAdded(Map<String, dynamic> productData) async {
    try {
      // Obtener el producto por nombre
      final product = await _databaseService.getProductByName(productData['product']);
      if (product != null) {
        final price = double.parse(productData['price'].toString());
        final quantity = int.parse(productData['quantity'].toString());
        final subtotal = price * quantity;

        final listItem = ListItem(
          listId: widget.listId,
          productId: product.id!,
          price: price,
          quantity: quantity,
          subtotal: subtotal,
        );

        await _databaseService.insertListItem(listItem);

        // Recalcular el total de la lista
        await _databaseService.recalculateListTotal(widget.listId);

        // Recargar datos
        await _loadListDetails();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto agregado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar producto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateListStatus(String newStatus) async {
    try {
      await _databaseService.updateShippingListStatus(widget.listId, newStatus);
      await _loadListDetails();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado a: ${_getStatusText(newStatus)}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar estado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _generatePDF() {
    if (_listDetails != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransportInfoScreen(
            listDetails: _listDetails!,
            productsList: _productsList,
          ),
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
        title: Text('Lista #${widget.listId}'),
        elevation: 0,
        actions: [
          if (_listDetails != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'assign_transport':
                    _showAssignTransportDialog();
                    break;
                  case 'add_product':
                    _showAddProductDialog();
                    break;
                  case 'generate_pdf':
                    _generatePDF();
                    break;
                  case 'mark_pending':
                    _updateListStatus('pendiente');
                    break;
                  case 'mark_in_process':
                    _updateListStatus('en_proceso');
                    break;
                  case 'mark_completed':
                    _updateListStatus('completado');
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'assign_transport',
                  child: Row(
                    children: [
                      Icon(Icons.local_shipping),
                      SizedBox(width: 8),
                      Text('Asignar Transporte'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'add_product',
                  child: Row(
                    children: [
                      Icon(Icons.add_shopping_cart),
                      SizedBox(width: 8),
                      Text('Agregar Producto'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'generate_pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf),
                      SizedBox(width: 8),
                      Text('Generar PDF'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'mark_pending',
                  child: Row(
                    children: [
                      Icon(Icons.pending_actions, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Marcar Pendiente'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'mark_in_process',
                  child: Row(
                    children: [
                      Icon(Icons.hourglass_empty, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Marcar En Proceso'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'mark_completed',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Marcar Completado'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      const SizedBox(height: 16),
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
                        const SizedBox(height: 24),
                        _buildTransportInfo(),
                        const SizedBox(height: 24),
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
                        const SizedBox(height: 16),
                        _buildProductsList(),
                        const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _listDetails!['user_name'] ?? 'Usuario desconocido',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _listDetails!['user_email'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          const SizedBox(height: 12),
          Text(
            _listDetails!['point_name'] ?? 'Punto desconocido',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Envío: ${DateFormat('dd/MM/yyyy').format(shippingDate)}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _transportInfo != null ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _transportInfo != null ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                color: _transportInfo != null ? Colors.green.shade700 : Colors.orange.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                'Información de Transporte',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _transportInfo != null ? Colors.green.shade700 : Colors.orange.shade700,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAssignTransportDialog,
                icon: Icon(_transportInfo != null ? Icons.edit : Icons.add),
                label: Text(_transportInfo != null ? 'Editar' : 'Asignar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _transportInfo != null ? Colors.blue : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_transportInfo != null) ...[
            _buildInfoRow('Conductor:', _transportInfo!.driverName),
            _buildInfoRow('ID Conductor:', _transportInfo!.driverIdText),
            _buildInfoRow('Camión:', _transportInfo!.truckPlate),
            _buildInfoRow('Modelo:', _transportInfo!.truckModel),
            if (_transportInfo!.entryTime.isNotEmpty)
              _buildInfoRow('Hora de entrada:', _transportInfo!.entryTime),
            if (_transportInfo!.exitTime != null && _transportInfo!.exitTime!.isNotEmpty)
              _buildInfoRow('Hora de salida:', _transportInfo!.exitTime!),
            if (_transportInfo!.notes != null && _transportInfo!.notes!.isNotEmpty)
              _buildInfoRow('Notas:', _transportInfo!.notes!),
          ] else ...[
            Text(
              'No se ha asignado transporte a esta lista',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
        padding: const EdgeInsets.all(32),
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
              const SizedBox(height: 8),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _productsList.map((product) {
          final price = product['price'] ?? 0.0;
          final quantity = product['quantity'] ?? 0;
          final subtotal = product['subtotal'] ?? 0.0;

          return Container(
            padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
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
