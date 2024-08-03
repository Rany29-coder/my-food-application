import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StoreDashboard extends StatefulWidget {
  const StoreDashboard({Key? key}) : super(key: key);

  @override
  _StoreDashboardState createState() => _StoreDashboardState();
}

class _StoreDashboardState extends State<StoreDashboard> {
  final _firestore = FirebaseFirestore.instance;
  double _totalSales = 0.0;
  int _activeListings = 0;
  int _customerSavings = 0;
  List<Sales> _salesData = [];
  List<ProductSales> _popularProducts = [];
  String _confirmationStatus = 'Checking...';

  @override
  void initState() {
    super.initState();
    _fetchStoreData();
    _fetchSalesData();
    _fetchPopularProductsData();
  }

  Future<void> _fetchStoreData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final storeDoc = await _firestore.collection('sellers').doc(user.uid).get();
        if (storeDoc.exists) {
          final storeData = storeDoc.data();
          setState(() {
            _totalSales = (storeData?['totalSales'] ?? 0).toDouble();
            _activeListings = storeData?['activeListings'] ?? 0;
            _customerSavings = storeData?['customerSavings'] ?? 0;
            _confirmationStatus = storeData?['confirmationStatus'] ?? 'Unknown';
          });
        }
      }
    } catch (e) {
      print("Error fetching store data: $e");
    }
  }

  Future<void> _fetchSalesData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ordersSnapshot = await _firestore
            .collection('orders')
            .where('ownerId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: false)
            .get();

        Map<DateTime, int> salesMap = {};
        for (var doc in ordersSnapshot.docs) {
          Timestamp timestamp = doc.data()['timestamp'];
          DateTime date = DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day);

          if (salesMap.containsKey(date)) {
            salesMap[date] = salesMap[date]! + 1;
          } else {
            salesMap[date] = 1;
          }
        }

        List<Sales> salesData = salesMap.entries.map((entry) {
          return Sales(entry.key, entry.value);
        }).toList();

        setState(() {
          _salesData = salesData;
        });
      }
    } catch (e) {
      print("Error fetching sales data: $e");
    }
  }

  Future<void> _fetchPopularProductsData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final ordersSnapshot = await _firestore
            .collection('orders')
            .where('ownerId', isEqualTo: user.uid)
            .get();

        Map<String, int> productsMap = {};
        for (var doc in ordersSnapshot.docs) {
          String productId = doc.data()['productId'];
          if (productsMap.containsKey(productId)) {
            productsMap[productId] = productsMap[productId]! + 1;
          } else {
            productsMap[productId] = 1;
          }
        }

        List<ProductSales> popularProducts = [];
        for (var entry in productsMap.entries) {
          final productDoc = await _firestore.collection('products').doc(entry.key).get();
          String productName = productDoc.data()?['productName'] ?? 'Unknown';
          popularProducts.add(ProductSales(productName, entry.value));
        }

        setState(() {
          _popularProducts = popularProducts;
        });
      }
    } catch (e) {
      print("Error fetching popular products data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_confirmationStatus == 'Awaiting Confirmation') ...[
              Center(
                child: Text(
                  'Your account is awaiting confirmation.',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Add functionality to contact support
                },
                child: Text('Contact Support'),
              ),
            ] else if (_confirmationStatus == 'Confirmed') ...[
              Center(
                child: Text(
                  'Your account is confirmed.',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
              // Add buttons or widgets for actions available to confirmed sellers
              ElevatedButton(
                onPressed: () {
                  // Navigate to add product page
                },
                child: Text('Post a Product'),
              ),
            ] else ...[
              Center(
                child: Text(
                  'Checking confirmation status...',
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
              ),
              SizedBox(height: 16),
            ],
            Text(
              'Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryCard('Total Sales', _totalSales),
                  _buildSummaryCard('Active Listings', _activeListings.toDouble()),
                  _buildSummaryCard('Customer Savings', _customerSavings.toDouble()),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Sales Trends',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildSalesChart(),
            SizedBox(height: 24),
            Text(
              'Popular Products',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildPopularProductsChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesChart() {
    var series = [
      charts.Series<Sales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (Sales sales, _) => sales.day,
        measureFn: (Sales sales, _) => sales.sales,
        data: _salesData,
      ),
    ];

    return Container(
      height: 200,
      child: charts.TimeSeriesChart(
        series,
        animate: true,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
      ),
    );
  }

  Widget _buildPopularProductsChart() {
    var series = [
      charts.Series<ProductSales, String>(
        id: 'Products',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (ProductSales sales, _) => sales.product,
        measureFn: (ProductSales sales, _) => sales.sales,
        data: _popularProducts,
      ),
    ];

    return Container(
      height: 200,
      child: charts.BarChart(
        series,
        animate: true,
      ),
    );
  }
}

class Sales {
  final DateTime day;
  final int sales;

  Sales(this.day, this.sales);

  @override
  String toString() {
    return '{ day: $day, sales: $sales }';
  }
}

class ProductSales {
  final String product;
  final int sales;

  ProductSales(this.product, this.sales);
}
