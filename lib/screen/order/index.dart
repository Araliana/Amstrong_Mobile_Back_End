import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // Pastikan package intl sudah ada, atau gunakan helper di bawah
import 'package:provider/provider.dart';
import 'package:flutter_application_1/provider/order_provider.dart';
import 'package:flutter_application_1/provider/theme_provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    // Memanggil fungsi fetchOrders dari Provider saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  /// Helper format currency (jika belum instal intl, bisa pakai logika string manual)
  String _formatCurrency(double amount) {
    try {
      final format = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return format.format(amount);
    } catch (e) {
      return "Rp ${amount.toStringAsFixed(0)}";
    }
  }

  /// Helper format tanggal
  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return isoString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'PRE_ORDER':
        return Colors.orange;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).getTheme();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Pesanan"),
        centerTitle: false,
        actions: [
          // Tombol refresh manual
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<OrderProvider>(context, listen: false).fetchOrders();
            },
          ),
        ],
      ),
      // Tombol Tambah Pesanan
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigasi ke form create, lalu refresh saat kembali
          context.push('/order/create').then((_) {
            Provider.of<OrderProvider>(context, listen: false).fetchOrders();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text("Buat Pesanan"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      // Menggunakan Consumer untuk mendengarkan perubahan data dari Provider
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          // 1. Kondisi Loading
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Kondisi Data Kosong (Ini yang memperbaiki kotak X)
          // Kita gunakan Icon biasa, bukan Image.asset untuk menghindari error
          if (orderProvider.orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada riwayat pesanan",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tekan tombol + untuk membuat pesanan baru",
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            );
          }

          // 3. Kondisi Ada Data
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    // Logic ke detail order
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(order.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  order.customerName.isNotEmpty
                                      ? order.customerName
                                      : "Pelangga Umum",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  order.status,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getStatusColor(
                                    order.status,
                                  ).withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(order.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Tagihan",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatCurrency(order.totalPrice),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
