import 'database_service.dart';

class StatisticsService {
  final DatabaseService _databaseService = DatabaseService();

  Future<Map<String, int>> getListStatistics() async {
    try {
      final lists = await _databaseService.getAllShippingListsWithDetails();

      int total = lists.length;
      int pending = lists.where((list) => list['status'] == 'pendiente').length;
      int completed = lists.where((list) => list['status'] == 'completado').length;

      return {
        'total': total,
        'pending': pending,
        'completed': completed,
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {
        'total': 0,
        'pending': 0,
        'completed': 0,
      };
    }
  }
}
