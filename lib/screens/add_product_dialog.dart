import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddProductDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onProductAdded;

  const AddProductDialog({
    Key? key,
    required this.onProductAdded,
  }) : super(key: key);

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  String? _selectedProduct;
  final TextEditingController _priceController = TextEditingController();
  String? _selectedUnit;
  final TextEditingController _quantityController = TextEditingController();

  // Datos de ejemplo para los productos disponibles
  final List<String> _availableProducts = [
    'Maíz',
    'Frijol',
    'Arroz',
    'Café',
    'Azúcar',
    'Trigo',
    'Sorgo',
    'Cebada',
    'Soya',
    'Algodón',
  ];

  // Datos de ejemplo para las unidades disponibles
  final List<String> _availableUnits = [
    'Saco',
    'Bolsa',
    'Quintal',
    'Kilogramo',
    'Tonelada',
    'Caja',
  ];

  // Modificar el método _isFormValid() para que sea menos estricto y muestre mensajes de depuración
  bool _isFormValid() {
    final isValid = _selectedProduct != null &&
        _priceController.text.isNotEmpty &&
        _selectedUnit != null &&
        _quantityController.text.isNotEmpty;

    print('Validación del formulario: $isValid');
    print('Producto: $_selectedProduct');
    print('Precio: ${_priceController.text}');
    print('Unidad: $_selectedUnit');
    print('Cantidad: ${_quantityController.text}');

    return isValid;
  }

  // Modificar el método _addProduct() para asegurar que se llame correctamente
  void _addProduct() {
    if (_isFormValid()) {
      final productData = {
        'product': _selectedProduct!,
        'price': _priceController.text,
        'unit': _selectedUnit!,
        'quantity': _quantityController.text,
      };

      print('Agregando producto: $productData');
      widget.onProductAdded(productData);
      Navigator.pop(context);
    } else {
      // Mostrar un mensaje de error si el formulario no es válido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  // Modificar el botón de AGREGAR para que siempre esté habilitado y maneje la validación internamente
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar Producto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Producto:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Seleccionar producto',
                prefixIcon: Icon(Icons.inventory_2_outlined),
              ),
              value: _selectedProduct,
              items: _availableProducts.map((product) {
                return DropdownMenuItem<String>(
                  value: product,
                  child: Text(product),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProduct = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Precio:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                hintText: 'Precio por unidad',
                prefixIcon: Icon(Icons.attach_money),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Unidad:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                hintText: 'Seleccionar unidad',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              value: _selectedUnit,
              items: _availableUnits.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Cantidad:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                hintText: 'Cantidad',
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCELAR'),
        ),
        ElevatedButton(
          onPressed: () => _addProduct(),
          child: const Text('AGREGAR'),
        ),
      ],
    );
  }
}
