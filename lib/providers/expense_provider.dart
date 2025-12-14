import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../services/api_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final ApiService _apiService;

  ExpenseProvider(this._apiService);

  // 账单列表
  List<Expense> _expenses = [];
  List<Expense> get expenses => _expenses;

  // 统计信息
  ExpenseStats? _stats;
  ExpenseStats? get stats => _stats;

  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 错误信息
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // 分页信息
  int _currentPage = 1;
  int get currentPage => _currentPage;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // 筛选条件
  String _period = 'all';
  String get period => _period;
  String? _startDate;
  String? get startDate => _startDate;
  String? _endDate;
  String? get endDate => _endDate;
  String? _selectedCategory;
  String? get selectedCategory => _selectedCategory;
  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  /// 加载账单列表
  Future<void> loadExpenses({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _expenses = [];
      _hasMore = true;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newExpenses = await _apiService.getExpenses(
        page: _currentPage,
        limit: 20,
        period: _period == 'all' ? null : _period,
        startDate: _startDate,
        endDate: _endDate,
        category: _selectedCategory,
        search: _searchQuery,
      );

      if (refresh) {
        _expenses = newExpenses;
      } else {
        _expenses.addAll(newExpenses);
      }

      _hasMore = newExpenses.length >= 20;
      _currentPage++;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载统计信息
  Future<void> loadStats() async {
    try {
      final stats = await _apiService.getExpenseStats(
        period: _period == 'all' ? null : _period,
        startDate: _startDate,
        endDate: _endDate,
      );

      // 加载预算设置
      final prefs = await SharedPreferences.getInstance();
      final budget = prefs.getDouble('monthly_budget') ?? 0.0;

      // 创建带预算的统计对象
      _stats = ExpenseStats(
        totalExpense: stats.totalExpense,
        totalIncome: stats.totalIncome,
        totalCount: stats.totalCount,
        categoryStats: stats.categoryStats,
        dailyTrend: stats.dailyTrend,
        dailyAverage: stats.dailyAverage,
        monthlyBudget: budget,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// 设置时间周期
  void setPeriod(String period) {
    _period = period;
    _startDate = null;
    _endDate = null;
    loadExpenses(refresh: true);
    loadStats();
  }

  /// 设置自定义日期范围
  void setDateRange(String? startDate, String? endDate) {
    _period = 'custom';
    _startDate = startDate;
    _endDate = endDate;
    loadExpenses(refresh: true);
    loadStats();
  }

  /// 设置分类筛选
  void setCategory(String? category) {
    _selectedCategory = category;
    loadExpenses(refresh: true);
  }

  /// 设置搜索关键词
  void setSearch(String? search) {
    _searchQuery = search;
    loadExpenses(refresh: true);
  }

  /// 清除筛选条件
  void clearFilters() {
    _period = 'all';
    _startDate = null;
    _endDate = null;
    _selectedCategory = null;
    _searchQuery = null;
    loadExpenses(refresh: true);
    loadStats();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await Future.wait([
      loadExpenses(refresh: true),
      loadStats(),
    ]);
  }

  /// 获取分类列表
  Future<List<String>> getCategories() async {
    return await _apiService.getCategories();
  }

  /// 更新账单分类
  Future<void> updateExpenseCategory(int expenseId, String category) async {
    try {
      await _apiService.updateExpenseCategory(expenseId, category);

      // 更新本地数据
      final index = _expenses.indexWhere((e) => e.id == expenseId);
      if (index != -1) {
        // 创建新的 Expense 对象，更新分类
        final oldExpense = _expenses[index];
        _expenses[index] = Expense(
          id: oldExpense.id,
          transactionTime: oldExpense.transactionTime,
          type: oldExpense.type,
          counterparty: oldExpense.counterparty,
          productName: oldExpense.productName,
          amount: oldExpense.amount,
          paymentMethod: oldExpense.paymentMethod,
          status: oldExpense.status,
          category: category,
          source: oldExpense.source,
        );
        notifyListeners();
      }

      // 刷新统计数据
      await loadStats();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
