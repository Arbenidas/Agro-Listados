import 'package:flutter/material.dart';

class ListHistoryScreen extends StatefulWidget {
  const ListHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ListHistoryScreen> createState() => _ListHistoryScreenState();
}

class _ListHistoryScreenState extends State<ListHistoryScreen> {
  // Datos de ejemplo para el historial agrupado por fechas
  final Map<String, List<Map<String, dynamic>>> _historyByDate = {
    '15 Abril, 2025': [
      {
        'point': 'Punto Ahuachapán',
        'items': 8,
        'total': '\$1,245.80',
        'status': 'Completado',
      },
      {
        'point': 'Punto El Salvador',
        'items': 12,
        'total': '\$2,350.50',
        'status': 'Completado',
      },
      {
        'point': 'Punto Santa Ana',
        'items': 5,
        'total': '\$890.30',
        'status': 'Completado',
      },
    ],
    '10 Abril, 2025': [
      {
        'point': 'Punto Ahuachapán',
        'items': 10,
        'total': '\$1,780.00',
        'status': 'Completado',
      },
      {
        'point': 'Punto El Salvador',
        'items': 7,
        'total': '\$1,120.75',
        'status': 'Completado',
      },
    ],
    '5 Abril, 2025': [
      {
        'point': 'Punto Santa Ana',
        'items': 9,
        'total': '\$1,560.40',
        'status': 'Completado',
      },
      {
        'point': 'Punto Ahuachapán',
        'items': 6,
        'total': '\$950.20',
        'status': 'Completado',
      },
    ],
    '1 Abril, 2025': [
      {
        'point': 'Punto El Salvador',
        'items': 14,
        'total': '\$2,780.90',
        'status': 'Completado',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Listas'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historial por Fecha y Punto',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildHistoryList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      itemCount: _historyByDate.length,
      itemBuilder: (context, dateIndex) {
        final date = _historyByDate.keys.elementAt(dateIndex);
        final pointsForDate = _historyByDate[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(
                      indent: 12,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
            ),
            ...pointsForDate.map((point) => _buildPointCard(point)).toList(),
            if (dateIndex < _historyByDate.length - 1) const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildPointCard(Map<String, dynamic> point) {
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            point['point'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Estado: ${point['status']}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${point['items']} productos • ${point['total']}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
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
              // Acción para ver detalles de la lista
            },
          ),
          onTap: () {
            // Navegar a los detalles de la lista
          },
        ),
      ),
    );
  }
}
