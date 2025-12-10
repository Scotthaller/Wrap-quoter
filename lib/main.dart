import 'package:flutter/material.dart';

void main() {
  runApp(const WrapQuoteApp());
}

class WrapQuoteApp extends StatelessWidget {
  const WrapQuoteApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pro Vinyl Wrap Quoter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const QuoteScreen(),
    );
  }
}

class VehicleData {
  final String make;
  final String model;
  final String year;
  final double fullWrapSqFt; // average exterior surface area

  VehicleData(this.make, this.model, this.year, this.fullWrapSqFt);
}

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});
  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  // User selections
  String? _selectedMake;
  String? _selectedModel;
  String? _selectedYear;
  String _materialType = 'Standard Cast (3-5 yr)';
  double _coveragePercent = 100.0;
  double _laborRate = 85.0;
  double _profitMargin = 30.0;

  // Current calculated vehicle
  VehicleData? _currentVehicle;

  // Pricing per sq ft (update these anytime in Settings later)
  final Map<String, double> materialPrices = {
    'Standard Cast (3-5 yr)': 3.50,
    'Premium Cast (7+ yr)': 5.50,
    'Chrome / Specialty': 9.00,
    'Color Flip / Matte': 7.00,
  };

  // ─────────────────────────────────────────────────────────────
  // Huge but lightweight database (you can add 1000+ cars, still tiny)
  // ─────────────────────────────────────────────────────────────
  final List<VehicleData> vehicles = [
    // Toyota
    VehicleData('Toyota', 'Camry', '2020-2025', 195),
    VehicleData('Toyota', 'Camry', '2015-2019', 190),
    VehicleData('Toyota', 'Corolla', '2020-2025', 170),
    VehicleData('Toyota', 'RAV4', '2019-2025', 245),
    VehicleData('Toyota', 'Tacoma', '2016-2025', 310),
    VehicleData('Toyota', 'Tundra', '2022-2025', 380),

    // Honda
    VehicleData('Honda', 'Civic', '2022-2025', 175),
    VehicleData('Honda', 'Civic', '2016-2021', 172),
    VehicleData('Honda', 'Accord', '2018-2025', 198),
    VehicleData('Honda', 'CR-V', '2017-2025', 240),
    VehicleData('Honda', 'Pilot', '2016-2025', 280),

    // Ford
    VehicleData('Ford', 'F-150', '2021-2025', 360),
    VehicleData('Ford', 'F-150', '2015-2020', 355),
    VehicleData('Ford', 'Mustang', '2024-2025', 210),
    VehicleData('Ford', 'Explorer', '2020-2025', 275),

    // Tesla
    VehicleData('Tesla', 'Model 3', '2017-2025', 185),
    VehicleData('Tesla', 'Model Y', '2020-2025', 225),
    VehicleData('Tesla', 'Model S', '2021-2025', 215),
    VehicleData('Tesla', 'Cybertruck', '2024-2025', 420),

    // Add 100s more whenever you want…
  ];
  // end of database

  List<String> get makes => vehicles.map((v) => v.make).toSet().toList()..sort();
  List<String> get models {
    if (_selectedMake == null) return [];
    return vehicles
        .where((v) => v.make == _selectedMake)
        .map((v) => v.model)
        .toSet()
        .toList()..sort();
  }
  List<String> get years {
    if (_selectedMake == null || _selectedModel == null) return [];
    return vehicles
        .where((v) => v.make == _selectedMake && v.model == _selectedModel)
        .map((v) => v.year)
        .toSet()
        .toList()..sort((a, b) => b.compareTo(a)); // newest first
  }

  void _updateVehicle() {
    if (_selectedMake != null && _selectedModel != null && _selectedYear != null) {
      _currentVehicle = vehicles.firstWhere(
        (v) =>
            v.make == _selectedMake &&
            v.model == _selectedModel &&
            v.year == _selectedYear,
      );
    } else {
      _currentVehicle = null;
    }
    setState(() {}); // refresh quote if needed
  }

  Map<String, double> calculateQuote() {
    if (_currentVehicle == null) {
      return {'material': 0, 'labor': 0, 'total': 0};
    }

    double area = _currentVehicle!.fullWrapSqFt * (_coveragePercent / 100);
    double materialPrice = materialPrices[_materialType]!;
    double materialCost = area * materialPrice;

    // Rough labor estimate: 0.10–0.14 hours per sq ft (average 0.12)
    double laborHours = area * 0.12;
    double laborCost = laborHours * _laborRate;

    double subtotal = materialCost + laborCost;
    double total = subtotal * (1 + _profitMargin / 100);

    return {
      'material': materialCost,
      'labor': laborCost,
      'hours': laborHours,
      'total': total,
    };
  }

  @override
  Widget build(BuildContext context) {
    final quote = calculateQuote();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Wrap Quoter'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Make → Model → Year
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Make'),
              value: _selectedMake,
              items: makes.map((make) => DropdownMenuItem(value: make, child: Text(make))).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedMake = val;
                  _selectedModel = null;
                  _selectedYear = null;
                  _currentVehicle = null;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Model'),
              value: _selectedModel,
              items: models.map((model) => DropdownMenuItem(value: model, child: Text(model))).toList(),
              onChanged: _selectedMake == null
                  ? null
                  : (val) {
                      setState(() {
                        _selectedModel = val;
                        _selectedYear = null;
                        _currentVehicle = null;
                      });
                    },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Year / Generation'),
              value: _selectedYear,
              items: years.map((year) => DropdownMenuItem(value: year, child: Text(year))).toList(),
              onChanged: _selectedModel == null
                  ? null
                  : (val) {
                      setState(() => _selectedYear = val);
                      _updateVehicle();
                    },
            ),

            const Divider(height: 40),

            // Material & Coverage
            DropdownButtonFormField<String>(
              value: _materialType,
              decoration: const InputDecoration(labelText: 'Material Type'),
              items: materialPrices.keys
                  .map((m) => DropdownMenuItem(value: m, child: Text('$m  (\$${materialPrices[m]}/sqft)')))
                  .toList(),
              onChanged: (val) => setState(() => _materialType = val!),
            ),
            const SizedBox(height: 16),
            Text('Coverage: ${_coveragePercent.toStringAsFixed(0)}%', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              min: 10,
              max: 100,
              divisions: 9,
              value: _coveragePercent,
              onChanged: (v) => setState(() => _coveragePercent = v),
            ),

            // Rates
            TextField(
              decoration: const InputDecoration(labelText: 'Labor Rate ($/hour)', prefixText: '\$'),
              keyboardType: TextInputType.number,
              onChanged: (v) => _laborRate = double.tryParse(v) ?? 85,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Profit Margin (%)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => _profitMargin = double.tryParse(v) ?? 30,
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _currentVehicle == null ? null : () => setState(() {}),
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Quote'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
            ),

            if (quote['total']! > 0) ...[
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vehicle: ${_currentVehicle!.year} ${_currentVehicle!.make} ${_currentVehicle!.model}',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Surface area used: ${( _currentVehicle!.fullWrapSqFt * _coveragePercent / 100).toStringAsFixed(1)} sqft'),
                      const Divider(),
                      Text('Material: \$${quote['material']!.toStringAsFixed(0)}'),
                      Text('Labor (${quote['hours']!.toStringAsFixed(1)} hrs @ \$${ _laborRate}): \$${quote['labor']!.toStringAsFixed(0)}'),
                      Text('Total Quote: \$${quote['total']!.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
