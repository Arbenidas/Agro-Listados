import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_product_dialog.dart';
import 'transport_info_screen.dart';
import 'pdf_preview_screen.dart';

class SupervisorListDetailScreen extends StatefulWidget {
  final String listId;

  const SupervisorListDetailScreen({
    Key? key,
    required this.listId,
  }) : super(key: key);

  @override
  State<SupervisorListDetailScreen> createState() => _SupervisorListDetailScreenState();
}

class _SupervisorListDetailScreenState extends State<SupervisorListDetailScreen> {
  late Map<String, dynamic> _listDetails;
  List<Map<String, dynamic>> _productsList = [];
  bool _isEditing = false;

  // Datos de ejemplo para los detalles de la lista
  final Map<String, Map<String, dynamic>> _listsData = {
    '001': {
      'id': '001',
      'provider': 'Agrícola El Salvador',
      'point': 'Punto Ahuachapán',
      'date': '15 Abril, 2025',
      'items': 8,
      'total': 1245.80,
      'status': 'Pendiente',
      'statusColor': Colors.orange,
      'products': [
        {
          'product': 'Maíz',
          'price': '5.50',
          'unit': 'Quintal',
          'quantity': '50',
        },
        {
          'product': 'Frijol',
          'price': '8.75',
          'unit': 'Quintal',
          'quantity': '30',
        },
        {
          'product': 'Arroz',
          'price': '7.25',
          'unit': 'Quintal',
          'quantity': '40',
        },
        {
          'product': 'Café',
          'price': '12.50',
          'unit': 'Saco',
          'quantity': '25',
        },
      ],
    },
    '002': {
      'id': '002',
      'provider': 'Distribuidora Santa Ana',
      'point': 'Punto El Salvador',
      'date': '15 Abril, 2025',
      'items': 12,
      'total': 2350.50,
      'status': 'En Proceso',
      'statusColor': Colors.blue,
      'products': [
        {
          'product': 'Trigo',
          'price': '6.25',
          'unit': 'Quintal',
          'quantity': '60',
        },
        {
          'product': 'Azúcar',
          'price': '9.50',
          'unit': 'Saco',
          'quantity': '45',
        },
        {
          'product': 'Sorgo',
          'price': '5.75',
          'unit': 'Quintal',
          'quantity': '35',
        },
      ],
    },
    '003': {
      'id': '003',
      'provider': 'Agrícola El Salvador',
      'point': 'Punto Santa Ana',
      'date': '15 Abril, 2025',
      'items': 5,
      'total': 890.30,
      'status': 'Completado',
      'statusColor': Colors.green,
      'products': [
        {
          'product': 'Cebada',
          'price': '7.80',
          'unit': 'Quintal',
          'quantity': '20',
        },
        {
          'product': 'Soya',
          'price': '10.25',
          'unit': 'Quintal',
          'quantity': '15',
        },
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _loadListDetails();
  }

  void _loadListDetails() {
    // En una aplicación real, esto cargaría los datos desde una API o base de datos
    _listDetails = _listsData[widget.listId] ?? {};
    _productsList = List<Map<String, dynamic>>.from(_listDetails['products'] ?? []);

    // Recalcular el total y la cantidad de items
    _updateListSummary();
  }

  void _updateListSummary() {
    double total = 0;
    for (var product in _productsList) {
      final price = double.parse(product['price'].toString());
      final quantity = int.parse(product['quantity'].toString());
      total += price * quantity;
    }

    setState(() {
      _listDetails['total'] = total;
      _listDetails['items'] = _productsList.length;
    });
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => AddProductDialog(
        onProductAdded: (product) {
          setState(() {
            _productsList.add(product);
            _updateListSummary();
          });
        },
      ),
    );
  }

  void _removeProduct(int index) {
    setState(() {
      _productsList.removeAt(index);
      _updateListSummary();
    });
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    // En una aplicación real, esto guardaría los cambios en una API o base de datos
    setState(() {
      _isEditing = false;
      _listDetails['products'] = _productsList;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cambios guardados con éxito'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    });
  }

  void _navigateToTransportInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransportInfoScreen(
          listDetails: _listDetails,
          productsList: _productsList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Lista'),
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _toggleEditMode,
              tooltip: 'Editar lista',
            )
          else
            IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveChanges,
              tooltip: 'Guardar cambios',
            ),
        ],
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: _showAddProductDialog,
              child: Icon(Icons.add),
              backgroundColor: Theme.of(context).colorScheme.primary,
              tooltip: 'Agregar producto',
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildListHeader(),
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
              Expanded(
                child: _buildProductsTable(),
              ),
              SizedBox(height: 16),
              if (!_isEditing)
                ElevatedButton(
                  onPressed: _navigateToTransportInfo,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_shipping),
                      SizedBox(width: 8),
                      Text('AGREGAR INFORMACIÓN DE TRANSPORTE'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
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
                  _listDetails['provider'] ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (_listDetails['statusColor'] as Color?)?.withOpacity(0.2) ?? Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _listDetails['status'] ?? 'Desconocido',
                  style: TextStyle(
                    color: _listDetails['statusColor'] as Color? ?? Colors.grey,
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
              Text(
                _listDetails['point'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
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
                _listDetails['date'] ?? '',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Divider(),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '\$${(_listDetails['total'] as double?)?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Productos:',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${_listDetails['items'] ?? 0}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable() {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _productsList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No hay productos en esta lista',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    if (_isEditing)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Presiona el botón + para agregar productos',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Producto',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Precio',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Unidad',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Cantidad',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_isEditing)
                        DataColumn(
                          label: Text(
                            'Acciones',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                    rows: List.generate(
                      _productsList.length,
                      (index) {
                        final product = _productsList[index];
                        final price = double.parse(product['price'].toString());
                        final quantity = int.parse(product['quantity'].toString());
                        final total = price * quantity;

                        return DataRow(
                          cells: [
                            DataCell(Text(product['product'])),
                            DataCell(Text('\$${price.toStringAsFixed(2)}')),
                            DataCell(Text(product['unit'])),
                            DataCell(Text(quantity.toString())),
                            DataCell(Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            if (_isEditing)
                              DataCell(
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red[400],
                                    size: 20,
                                  ),
                                  onPressed: () => _removeProduct(index),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
