import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/stock.dart';
import 'package:flutter_application_1/provider/stock_provider.dart';
import 'package:flutter_application_1/components/index.dart';
import 'package:flutter_application_1/screen/inventory/addEdit.dart';
import 'package:flutter_application_1/screen/inventory/detail.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<StockProvider>(context, listen: false);
    _loadFuture = provider.loadStocks();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<StockProvider>(context);

    return Scaffold(
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildLoadingState("Fetching Stock History...");
          }

          final items = provider.stocks;

          return items.isEmpty
              ? buildEmptyState("Stock History", Icons.inventory_2_rounded)
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return buildHeader(
                        "Stock History",
                        Icons.inventory_rounded,
                      );
                    }

                    final stock = items[index - 1];
                    final isActive = stock.isActiveStock(items);

                    return _buildStockCard(
                      stock: stock,
                      isActive: isActive,
                      onEdit: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AddEditStockScreen(editStock: stock),
                          ),
                        );
                        if (result == true) {
                          provider.loadStocks();
                        }
                      },
                      onDelete: () async {
                        showDeleteConfirmation(
                          context,
                          title: "Stock",
                          label: stock.productName,
                          isLoading: provider.isLoading,
                          onDelete: () async {
                            await provider.deleteStock(
                              stock.id,
                              productId: stock.productId,
                            );
                          },
                        );
                      },
                      onTap: () {
                        showStockDetail(context, stock, items);
                      },
                    );
                  },
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditStockScreen()),
          );
          if (result == true) {
            provider.loadStocks();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStockCard({
    required Stock stock,
    required bool isActive,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: Colors.green[400]!, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? Colors.green.withAlpha(20)
                  : Colors.brown.withAlpha(10),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with product name and actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [Colors.green[50]!, Colors.green[100]!]
                      : [Colors.brown[50]!, Colors.brown[100]!],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: isActive ? Colors.green[700] : Colors.brown[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                stock.productName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isActive
                                      ? Colors.green[900]
                                      : Colors.brown[900],
                                ),
                              ),
                            ),
                            if (isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(stock.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive
                                ? Colors.green[600]
                                : Colors.brown[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildIconButton(
                          icon: Icons.edit_outlined,
                          color: Colors.orange[700]!,
                          onPressed: onEdit,
                        ),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                        _buildIconButton(
                          icon: Icons.delete_outline_rounded,
                          color: Colors.red[700]!,
                          onPressed: onDelete,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stock details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Quantity',
                          '${stock.quantity} pcs',
                          Icons.inventory,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'HPP',
                          'IDR ${_formatPrice(stock.hpp)}',
                          Icons.attach_money,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Profit',
                          'IDR ${_formatPrice(stock.trueProfit)}',
                          Icons.trending_up,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Final Price',
                          'IDR ${_formatPrice(stock.finalPrice)}',
                          Icons.sell,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Total value info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.brown[700]!, Colors.brown[900]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Value',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'IDR ${_formatPrice(stock.totalValue)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      color: color,
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
      splashRadius: 20,
    );
  }

  String _formatPrice(double price) {
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(price.toInt());
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(date);
  }
}
