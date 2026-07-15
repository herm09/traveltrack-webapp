import 'api_client.dart';

class TripsService {
  TripsService({ApiClient? client}) : _apiClient = client ?? apiClient;

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> getTrips() async {
    final data = await _apiClient.get('/api/trips');
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>> getTrip(String id) async {
    return await _apiClient.get('/api/trips/$id') as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createTrip(Map<String, dynamic> trip) async {
    return await _apiClient.post('/api/trips', body: trip) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateTrip(String id, Map<String, dynamic> trip) async {
    return await _apiClient.patch('/api/trips/$id', body: trip) as Map<String, dynamic>;
  }

  Future<void> deleteTrip(String id) => _apiClient.delete('/api/trips/$id');
}
