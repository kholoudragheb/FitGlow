import 'package:dio/dio.dart';
import 'package:fit_app/utils/token_storage.dart';
import '../models/rate_coach_request_model.dart';

abstract class RateCoachRemoteDataSource {
  Future<void> rateCoach(String coachId, RateCoachRequestModel request);
}

class RateCoachRemoteDataSourceImpl implements RateCoachRemoteDataSource {
  final Dio dio;
  final String baseUrl = 'https://exact-gwenette-fitglow-38dc47eb.koyeb.app';

  RateCoachRemoteDataSourceImpl(this.dio);

  @override
  Future<void> rateCoach(String coachId, RateCoachRequestModel request) async {
    final token = await TokenStorage.getAccessToken();
    
    try {
      final response = await dio.post(
        '$baseUrl/coach-profile/$coachId/rate',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to rate coach. Server returned: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw Exception('Network error: $message');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
