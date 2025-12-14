import 'dart:io';
import 'package:dio/dio.dart';
import '../models/expense.dart';

class ApiService {
  final String apiKey;
  late final Dio _dio;

  ApiService(this.apiKey) {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://www.xiaojuch.com',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'X-API-Key': apiKey,
      },
    ));
  }

  /// 上传账单文件
  Future<UploadResult> uploadBill(File file, String billType) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'bill_type': billType,
        'bill_file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/api/bill-import.php',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return UploadResult(
          success: data['success'] ?? false,
          message: data['message'] ?? '未知错误',
          total: data['data']?['total'] ?? 0,
          imported: data['data']?['imported'] ?? 0,
          skipped: data['data']?['skipped'] ?? 0,
          errors: List<String>.from(data['data']?['errors'] ?? []),
        );
      } else {
        return UploadResult(
          success: false,
          message: '上传失败: HTTP ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = '上传失败';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = '连接超时，请检查网络';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = '接收超时，请稍后重试';
      } else if (e.response != null) {
        errorMessage = '服务器错误: ${e.response?.statusCode}';
      } else {
        errorMessage = '网络错误: ${e.message}';
      }
      return UploadResult(success: false, message: errorMessage);
    } catch (e) {
      return UploadResult(success: false, message: '未知错误: $e');
    }
  }

  /// 更新 API 密钥
  void updateApiKey(String newApiKey) {
    _dio.options.headers['X-API-Key'] = newApiKey;
  }

  /// 获取账单列表
  Future<List<Expense>> getExpenses({
    int page = 1,
    int limit = 20,
    String? period,
    String? startDate,
    String? endDate,
    String? category,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'action': 'list',
        'page': page,
        'limit': limit,
      };

      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      if (category != null) queryParams['category'] = category;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/expenses-data.php',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Expense.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? '获取账单失败');
      }
    } catch (e) {
      throw Exception('获取账单失败: $e');
    }
  }

  /// 获取账单统计信息
  Future<ExpenseStats> getExpenseStats({
    String? period,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'action': 'stats',
      };

      if (period != null) queryParams['period'] = period;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await _dio.get(
        '/api/expenses-data.php',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return ExpenseStats.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? '获取统计信息失败');
      }
    } catch (e) {
      throw Exception('获取统计信息失败: $e');
    }
  }

  /// 获取分类列表
  Future<List<String>> getCategories() async {
    try {
      final response = await _dio.get(
        '/api/expenses-data.php',
        queryParameters: {'action': 'categories'},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => item['name'] as String).toList();
      } else {
        throw Exception(response.data['message'] ?? '获取分类失败');
      }
    } catch (e) {
      throw Exception('获取分类失败: $e');
    }
  }

  /// 更新账单分类
  Future<bool> updateExpenseCategory(int expenseId, String category) async {
    try {
      final response = await _dio.post(
        '/api/expenses-data.php?action=update_category',
        data: {
          'expense_id': expenseId,
          'category': category,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? '更新分类失败');
      }
    } catch (e) {
      throw Exception('更新分类失败: $e');
    }
  }
}

class UploadResult {
  final bool success;
  final String message;
  final int total;
  final int imported;
  final int skipped;
  final List<String> errors;

  UploadResult({
    required this.success,
    required this.message,
    this.total = 0,
    this.imported = 0,
    this.skipped = 0,
    this.errors = const [],
  });

  @override
  String toString() {
    if (!success) return message;
    return '总计: $total, 导入: $imported, 跳过: $skipped';
  }
}
