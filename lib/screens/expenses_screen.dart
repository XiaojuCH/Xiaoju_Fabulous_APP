import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 初始加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ExpenseProvider>();
      provider.refresh();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的账单'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: '统计'),
            Tab(icon: Icon(Icons.list), text: '明细'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(),
          _buildDetailsTab(),
        ],
      ),
    );
  }

  // 统计页面
  Widget _buildStatsTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                // 筛选条件显示
                if (provider.period != 'all' ||
                    provider.selectedCategory != null ||
                    provider.searchQuery != null)
                  _buildFilterChips(provider),

                // 统计卡片
                if (provider.stats != null)
                  _buildStatsCard(provider.stats!),

                // 图表区域
                if (provider.stats != null)
                  _buildChartsSection(provider.stats!),

                // 错误提示
                if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 空状态
                if (provider.stats == null && !provider.isLoading)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.bar_chart_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暂无统计数据',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 明细页面
  Widget _buildDetailsTab() {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final scrollController = ScrollController();

        // 监听滚动，实现分页加载
        scrollController.addListener(() {
          if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200) {
            if (!provider.isLoading && provider.hasMore) {
              provider.loadExpenses();
            }
          }
        });

        return RefreshIndicator(
          onRefresh: () => provider.refresh(),
          child: provider.expenses.isEmpty && !provider.isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '暂无账单记录',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: scrollController,
                  itemCount: provider.expenses.length + 1,
                  itemBuilder: (context, index) {
                    if (index < provider.expenses.length) {
                      return _buildExpenseItem(provider.expenses[index]);
                    } else if (provider.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (!provider.hasMore) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: Text(
                            '没有更多数据了',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
        );
      },
    );
  }

  Widget _buildStatsCard(ExpenseStats stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 预算（如果设置了）
            if (stats.monthlyBudget > 0) ...[
              _buildStatItem(
                '每月预算',
                '¥${stats.monthlyBudget.toStringAsFixed(2)}',
                Colors.blue,
                Icons.account_balance_wallet,
              ),
              const Divider(height: 24),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '总支出',
                  '¥${stats.totalExpense.toStringAsFixed(2)}',
                  Colors.red,
                  Icons.arrow_upward,
                ),
                _buildStatItem(
                  '总收入',
                  '¥${stats.totalIncome.toStringAsFixed(2)}',
                  Colors.green,
                  Icons.arrow_downward,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '结余',
                  '¥${stats.balance.toStringAsFixed(2)}',
                  stats.balance >= 0 ? Colors.green : Colors.red,
                  stats.balance >= 0 ? Icons.trending_up : Icons.trending_down,
                ),
                _buildStatItem(
                  '日均消费',
                  '¥${stats.dailyAverage.toStringAsFixed(2)}',
                  Colors.orange,
                  Icons.calendar_today,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '记录数',
                  stats.totalCount.toString(),
                  Colors.blue,
                  Icons.receipt,
                ),
                _buildStatItem(
                  '消费天数',
                  stats.dailyTrend.where((d) => d.total > 0).length.toString(),
                  Colors.purple,
                  Icons.event,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          if (provider.period != 'all')
            Chip(
              label: Text(_getPeriodLabel(provider.period)),
              onDeleted: () => provider.setPeriod('all'),
              deleteIcon: const Icon(Icons.close, size: 18),
            ),
          if (provider.selectedCategory != null)
            Chip(
              label: Text(provider.selectedCategory!),
              onDeleted: () => provider.setCategory(null),
              deleteIcon: const Icon(Icons.close, size: 18),
            ),
          if (provider.searchQuery != null)
            Chip(
              label: Text('搜索: ${provider.searchQuery}'),
              onDeleted: () => provider.setSearch(null),
              deleteIcon: const Icon(Icons.close, size: 18),
            ),
          if (provider.period != 'all' ||
              provider.selectedCategory != null ||
              provider.searchQuery != null)
            ActionChip(
              label: const Text('清除筛选'),
              onPressed: () => provider.clearFilters(),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: expense.isExpense ? Colors.red[100] : Colors.green[100],
          child: Icon(
            expense.isExpense ? Icons.remove : Icons.add,
            color: expense.isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(
          expense.productName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.counterparty,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    expense.category,
                    style: TextStyle(fontSize: 10, color: Colors.blue[700]),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  expense.transactionTime.substring(0, 16),
                  style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          expense.displayAmount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: expense.isExpense ? Colors.red : Colors.green,
          ),
        ),
        isThreeLine: true,
        onTap: () => _showCategoryEditDialog(context, expense),
      ),
    );
  }

  void _showCategoryEditDialog(BuildContext context, Expense expense) async {
    final provider = context.read<ExpenseProvider>();

    // 获取分类列表
    List<String> categories = [];
    try {
      categories = await provider.getCategories();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('获取分类失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改分类'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              expense.productName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '当前分类: ${expense.category}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            const Text('选择新分类:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              width: double.maxFinite,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((category) {
                  final isSelected = category == expense.category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) async {
                      if (selected && category != expense.category) {
                        Navigator.pop(context);
                        await _updateCategory(expense.id, category);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCategory(int expenseId, String newCategory) async {
    final provider = context.read<ExpenseProvider>();

    try {
      await provider.updateExpenseCategory(expenseId, newCategory);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('分类已更新'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('更新失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showFilterDialog(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '筛选条件',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('时间周期', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('全部'),
                  selected: provider.period == 'all',
                  onSelected: (_) {
                    provider.setPeriod('all');
                    Navigator.pop(context);
                  },
                ),
                ChoiceChip(
                  label: const Text('本月'),
                  selected: provider.period == 'month',
                  onSelected: (_) {
                    provider.setPeriod('month');
                    Navigator.pop(context);
                  },
                ),
                ChoiceChip(
                  label: const Text('本年'),
                  selected: provider.period == 'year',
                  onSelected: (_) {
                    provider.setPeriod('year');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                provider.clearFilters();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.clear),
              label: const Text('清除所有筛选'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection(ExpenseStats stats) {
    return Column(
      children: [
        // 分类饼图
        if (stats.categoryStats.isNotEmpty) _buildCategoryPieChart(stats),
        // 趋势折线图
        if (stats.dailyTrend.isNotEmpty) _buildTrendLineChart(stats),
      ],
    );
  }

  Widget _buildCategoryPieChart(ExpenseStats stats) {
    // 使用柔和的论文配图风格配色，从深到浅排列
    final colors = [
      const Color(0xFFFB8072), // 淡红色（较深）
      const Color(0xFF80B1D3), // 淡蓝色（较深）
      const Color(0xFF8DD3C7), // 淡青色（较深）
      const Color(0xFFBEBADA), // 淡紫色（较深）
      const Color(0xFFBC80BD), // 淡紫红色（较深）
      const Color(0xFFFDB462), // 淡橙色（中等）
      const Color(0xFFB3DE69), // 淡绿色（中等）
      const Color(0xFFCCEBC5), // 淡青绿色（较浅）
      const Color(0xFFFCCDE5), // 淡粉色（较浅）
      const Color(0xFFFFED6F), // 淡黄色（较浅）
      const Color(0xFFFFFF99), // 淡黄绿色（较浅）
      const Color(0xFFD9D9D9), // 淡灰色（最浅）
    ];

    final sortedCategories = stats.categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '支出分类',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // 显示当前触摸的分类信息
            if (_touchedPieIndex >= 0 && _touchedPieIndex < sortedCategories.length)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: colors[_touchedPieIndex % colors.length].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colors[_touchedPieIndex % colors.length],
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[_touchedPieIndex % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${sortedCategories[_touchedPieIndex].key}: ¥${sortedCategories[_touchedPieIndex].value.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors[_touchedPieIndex % colors.length],
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 32),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sortedCategories.asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    final isTouched = index == _touchedPieIndex;
                    return PieChartSectionData(
                      value: category.value,
                      title: '',
                      color: colors[index % colors.length],
                      radius: isTouched ? 90 : 80,  // 触摸时放大
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          _touchedPieIndex = -1;
                          return;
                        }
                        _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: sortedCategories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors[index % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${category.key} ¥${category.value.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendLineChart(ExpenseStats stats) {
    if (stats.dailyTrend.isEmpty) return const SizedBox.shrink();

    final maxY = stats.dailyTrend.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final spots = stats.dailyTrend.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.total);
    }).toList();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '消费趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '¥${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: stats.dailyTrend.length > 10 ? 5 : 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < stats.dailyTrend.length) {
                            final date = stats.dailyTrend[index].date;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                date.substring(5),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  minY: 0,
                  maxY: maxY * 1.2,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'month':
        return '本月';
      case 'year':
        return '本年';
      case 'custom':
        return '自定义';
      default:
        return '全部';
    }
  }
}
