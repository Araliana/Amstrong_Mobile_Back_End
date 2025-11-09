import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/ad_banner.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  final String selectedPeriod;
  const DashboardScreen({super.key, required this.selectedPeriod});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedPeriod = 'Hari Ini';

  // Dummy data
  final Map<String, dynamic> salesData = {
    'totalOmset': 15750000,
    'totalTransaksi': 127,
    'totalProdukTerjual': 342,
    'avgTransaksi': 124016,
  };

  final List<Map<String, dynamic>> topProducts = [
    {
      'name': 'Espresso Machine Pro',
      'qty': 8,
      'revenue': 4800000,
      'category': 'Mesin Kopi',
    },
    {
      'name': 'Arabica Premium 1kg',
      'qty': 45,
      'revenue': 2250000,
      'category': 'Biji Kopi',
    },
    {
      'name': 'French Press Deluxe',
      'qty': 23,
      'revenue': 1840000,
      'category': 'Alat Kopi',
    },
    {
      'name': 'Chocolate Macaron Box',
      'qty': 67,
      'revenue': 1675000,
      'category': 'Snack',
    },
    {
      'name': 'Coffee Grinder Manual',
      'qty': 18,
      'revenue': 1260000,
      'category': 'Alat Kopi',
    },
  ];

  final Map<String, int> categorySales = {
    'Mesin Kopi': 4800000,
    'Biji Kopi': 3850000,
    'Alat Kopi': 3600000,
    'Snack': 3500000,
  };

  final List<Map<String, dynamic>> recentTransactions = [
    {'id': 'TRX-2701', 'time': '14:35', 'items': 5, 'total': 1250000},
    {'id': 'TRX-2700', 'time': '14:12', 'items': 3, 'total': 485000},
    {'id': 'TRX-2699', 'time': '13:48', 'items': 2, 'total': 150000},
    {'id': 'TRX-2698', 'time': '13:25', 'items': 7, 'total': 875000},
    {'id': 'TRX-2697', 'time': '12:55', 'items': 4, 'total': 620000},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.getTheme();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () async {},
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary Cards
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildSummaryCard(
                          'Total Omset',
                          'Rp ${_formatNumber(salesData['totalOmset'])}',
                          Icons.attach_money,
                          Colors.green,
                          isDark,
                        ),
                        _buildSummaryCard(
                          'Transaksi',
                          '${salesData['totalTransaksi']}',
                          Icons.shopping_cart,
                          Colors.blue,
                          isDark,
                        ),
                        _buildSummaryCard(
                          'Produk Terjual',
                          '${salesData['totalProdukTerjual']}',
                          Icons.inventory,
                          Colors.orange,
                          isDark,
                        ),
                        _buildSummaryCard(
                          'Rata-rata',
                          'Rp ${_formatNumber(salesData['avgTransaksi'])}',
                          Icons.trending_up,
                          Colors.purple,
                          isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Produk Terlaris', isDark),
                    const SizedBox(height: 12),
                    _buildTopProductsList(isDark),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Penjualan per Kategori', isDark),
                    const SizedBox(height: 12),
                    _buildCategoryChart(isDark),
                    const SizedBox(height: 24),

                    _buildSectionTitle('Transaksi Terbaru', isDark),
                    const SizedBox(height: 12),
                    _buildRecentTransactions(isDark),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Container(
                alignment: Alignment.bottomCenter,
                color: Colors.transparent,
                child: IgnorePointer(
                  ignoring: false,
                  child: CollapsibleBannerAd(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme == true ? Colors.grey[900] : Colors.white, //Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: theme == true ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme == true ? Colors.white : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: theme == true ? Colors.white : Colors.black87,
      ),
    );
  }

  Widget _buildTopProductsList(bool theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme == true ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topProducts.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final product = topProducts[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.brown[100],
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.brown[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              product['name'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${product['category']} • ${product['qty']} terjual',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Text(
              'Rp ${_formatNumber(product['revenue'])}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChart(bool theme) {
    // final maxValue = categorySales.values.reduce((a, b) => a > b ? a : b);
    final totalSales = categorySales.values.reduce((a, b) => a + b);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme == true ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: categorySales.entries.map((entry) {
          final percentage = (entry.value / totalSales);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Rp ${_formatNumber(entry.value)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme == true
                            ? Colors.brown[100]
                            : Colors.brown[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: theme == true
                        ? Colors.grey[500]
                        : Colors.grey[200],
                    color: theme == true
                        ? Colors.brown[600]
                        : Colors.brown[400],
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentTransactions(bool theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme == true ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentTransactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final trx = recentTransactions[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_long,
                color: Colors.blue[700],
                size: 20,
              ),
            ),
            title: Text(
              trx['id'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${trx['time']} • ${trx['items']} item',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Text(
              'Rp ${_formatNumber(trx['total'])}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          );
        },
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
