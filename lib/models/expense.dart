class Expense {
  final int id;
  final String transactionTime;
  final String type;
  final String counterparty;
  final String productName;
  final double amount;
  final String paymentMethod;
  final String status;
  final String category;
  final String source;

  Expense({
    required this.id,
    required this.transactionTime,
    required this.type,
    required this.counterparty,
    required this.productName,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.category,
    required this.source,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    // 安全地转换金额，支持字符串和数字类型
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return Expense(
      id: json['id'] ?? 0,
      transactionTime: json['transaction_time'] ?? '',
      type: json['type'] ?? '',
      counterparty: json['counterparty'] ?? '',
      productName: json['product_name'] ?? '',
      amount: parseAmount(json['amount']),
      paymentMethod: json['payment_method'] ?? '',
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      source: json['source'] ?? '',
    );
  }

  bool get isExpense => type == '支出' || type == '/' || type == 'expense';
  bool get isIncome => type == '收入' || type == '入账' || type == 'income';

  String get displayAmount {
    if (isExpense) {
      return '-¥${amount.abs().toStringAsFixed(2)}';
    } else {
      return '+¥${amount.abs().toStringAsFixed(2)}';
    }
  }
}

class DailyTrend {
  final String date;
  final double total;
  final int count;

  DailyTrend({
    required this.date,
    required this.total,
    required this.count,
  });

  factory DailyTrend.fromJson(Map<String, dynamic> json) {
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return DailyTrend(
      date: json['date'] ?? '',
      total: parseAmount(json['total']),
      count: json['count'] ?? 0,
    );
  }
}

class ExpenseStats {
  final double totalExpense;
  final double totalIncome;
  final int totalCount;
  final Map<String, double> categoryStats;
  final List<DailyTrend> dailyTrend;
  final double dailyAverage;
  final double monthlyBudget;

  ExpenseStats({
    required this.totalExpense,
    required this.totalIncome,
    required this.totalCount,
    required this.categoryStats,
    required this.dailyTrend,
    required this.dailyAverage,
    this.monthlyBudget = 0.0,
  });

  factory ExpenseStats.fromJson(Map<String, dynamic> json) {
    // 安全地转换金额，支持字符串和数字类型
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final categoryData = json['category_stats'] as List<dynamic>? ?? [];
    final categoryStats = <String, double>{};

    for (var item in categoryData) {
      categoryStats[item['category'] ?? 'Other'] = parseAmount(item['total']);
    }

    // 解析每日趋势数据
    final trendData = json['daily_trend'] as List<dynamic>? ?? [];
    final dailyTrend = trendData.map((item) => DailyTrend.fromJson(item)).toList();

    // 计算日均消费（基于有消费的天数）
    final daysWithExpense = dailyTrend.where((d) => d.total > 0).length;
    final totalExpense = parseAmount(json['total_expense']);
    final dailyAverage = daysWithExpense > 0 ? totalExpense / daysWithExpense : 0.0;

    return ExpenseStats(
      totalExpense: totalExpense,
      totalIncome: parseAmount(json['total_income']),
      totalCount: json['total_count'] ?? 0,
      categoryStats: categoryStats,
      dailyTrend: dailyTrend,
      dailyAverage: dailyAverage,
    );
  }

  // 如果设置了预算，结余 = 预算 - 支出；否则 = 收入 - 支出
  double get balance => monthlyBudget > 0
      ? monthlyBudget - totalExpense
      : totalIncome - totalExpense;
}
