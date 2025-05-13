import 'package:flutter/material.dart';
import '../utils/page_transition.dart';
import 'supervisor_list_detail_screen.dart';

class SupervisorListsScreen extends StatefulWidget {
  const SupervisorListsScreen({Key? key}) : super(key: key);

  @override
  State<SupervisorListsScreen> createState() => _SupervisorListsScreenState();
}

class _SupervisorListsScreenState extends State<SupervisorListsScreen> {
  String _selectedFilter = 'Todos';
  final List<String> _filterOptions = [
    'Todos',
    'Pendientes',
    'En Proceso',
    'Completados'
  ];

  // Datos de ejemplo para las listas de proveedores
  final List<Map<String, dynamic>> _providerLists = [
    {
      'id': '001',
      'provider': 'Agrícola El Salvador',
      'point': 'Punto Ahuachapán',
      'date': '15 Abril, 2025',
      'items': 8,
      'total': '\$1,245.80',
      'status': 'Pendiente',
      'statusColor': Colors.orange,
    },
    {
      'id': '002',
      'provider': 'Distribuidora Santa Ana',
      'point': 'Punto El Salvador',
      'date': '15 Abril, 2025',
      'items': 12,
      'total': '\$2,350.50',
      'status': 'En Proceso',
      'statusColor': Colors.blue,
    },
    {
      'id': '003',
      'provider': 'Agrícola El Salvador',
      'point': 'Punto Santa Ana',
      'date': '15 Abril, 2025',
      'items': 5,
      'total': '\$890.30',
      'status': 'Completado',
      'statusColor': Colors.green,
    },
    {
      'id': '004',
      'provider': 'Distribuidora Santa Ana',
      'point': 'Punto Ahuachapán',
      'date': '10 Abril, 2025',
      'items': 10,
      'total': '\$1,780.00',
      'status': 'Completado',
      'statusColor': Colors.green,
    },
    {
      'id': '005',
      'provider': 'Agrícola El Salvador',
      'point': 'Punto El Salvador',
      'date': '10 Abril, 2025',
      'items': 7,
      'total': '\$1,120.75',
      'status': 'Completado',
      'statusColor': Colors.green,
    },
    {
      'id': '006',
      'provider': 'Distribuidora Santa Ana',
      'point': 'Punto Santa Ana',
      'date': '5 Abril, 2025',
      'items': 9,
      'total': '\$1,560.40',
      'status': 'Pendiente',
      'statusColor': Colors.orange,
    },
  ];

  List<Map<String, dynamic>> get filteredLists {
    if (_selectedFilter == 'Todos') {
      return _providerLists;
    } else {
      return _providerLists
          .where((list) =>
              list['status'] ==
              (_selectedFilter == 'Pendientes'
                  ? 'Pendiente'
                  : _selectedFilter == 'En Proceso'
                      ? 'En Proceso'
                      : 'Completado'))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listas de Proveedores'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterSection(),
              SizedBox(height: 16),
              Expanded(
                child: _buildListsView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            'Filtrar por estado:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    checkmarkColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListsView() {
    return filteredLists.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'No se encontraron listas',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: filteredLists.length,
            itemBuilder: (context, index) {
              final list = filteredLists[index];
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
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                list['provider'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: list['statusColor'].withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                list['status'],
                                style: TextStyle(
                                  color: list['statusColor'],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          list['point'],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              list['date'],
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
                              Icons.shopping_cart,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${list['items']} productos',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(
                              Icons.attach_money,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            SizedBox(width: 4),
                            Text(
                              list['total'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          SlideRightRoute(
                            page:
                                SupervisorListDetailScreen(listId: list['id']),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        SlideRightRoute(
                          page: SupervisorListDetailScreen(listId: list['id']),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
  }
}
