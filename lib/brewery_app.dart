import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Helpers / data
// ---------------------------------------------------------------------------
String money(double value) => '\$${value.toStringAsFixed(2)}';

class Beer {
  final String name;
  final String style;
  final double abv;
  final double price;
  final IconData icon;

  const Beer({
    required this.name,
    required this.style,
    required this.abv,
    required this.price,
    required this.icon,
  });
}

const List<Beer> menu = [
  Beer(
    name: 'Hopstone IPA',
    style: 'West Coast IPA',
    abv: 6.8,
    price: 7.00,
    icon: Icons.sports_bar,
  ),
  Beer(
    name: 'Golden Hour',
    style: 'Czech Pilsner',
    abv: 4.9,
    price: 6.00,
    icon: Icons.local_drink,
  ),
  Beer(
    name: 'Midnight Oak',
    style: 'Oatmeal Stout',
    abv: 5.8,
    price: 7.50,
    icon: Icons.liquor,
  ),
  Beer(
    name: 'Orchard Tart',
    style: 'Fruited Sour',
    abv: 4.5,
    price: 7.25,
    icon: Icons.wine_bar,
  ),
];

// ---------------------------------------------------------------------------
// App + theme
// ---------------------------------------------------------------------------
class BreweryApp extends StatelessWidget {
  const BreweryApp({super.key});

  @override
  Widget build(BuildContext context) {
    const stout = Color(0xFF3E2723);
    const amber = Color(0xFFF2A900);
    const foam = Color(0xFFFFF9E8);

    return MaterialApp(
      title: 'Hopstone Brewing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: amber,
          primary: stout,
          secondary: amber,
        ),
        scaffoldBackgroundColor: foam,
        appBarTheme: const AppBarTheme(
          backgroundColor: stout,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: amber,
            foregroundColor: stout,
            disabledBackgroundColor: Colors.black12,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const OrderPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Main screen (holds all the state)
// ---------------------------------------------------------------------------
class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<int> quantities = List.filled(menu.length, 0);
  bool addTip = false;
  double tipPercent = 15;
  bool ageConfirmed = false;

  double get subtotal {
    double sum = 0;
    for (int i = 0; i < menu.length; i++) {
      sum += menu[i].price * quantities[i];
    }
    return sum;
  }

  double get tipAmount => addTip ? subtotal * tipPercent / 100 : 0;
  double get total => subtotal + tipAmount;
  int get itemCount => quantities.fold(0, (a, b) => a + b);
  bool get canOrder => itemCount > 0 && ageConfirmed;

  void _changeQuantity(int index, int delta) {
    setState(() {
      quantities[index] = (quantities[index] + delta).clamp(0, 99);
    });
  }

  void _resetOrder() {
    setState(() {
      quantities = List.filled(menu.length, 0);
      addTip = false;
      tipPercent = 15;
      ageConfirmed = false;
    });
  }

  Future<void> _confirmOrder() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Order Confirmed'),
          content: Text(
            'Cheers! Your $itemCount pour${itemCount == 1 ? '' : 's'} '
            'will be ready at the taproom.\n\nTotal: ${money(total)}\n\n'
            'Please bring a valid ID.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
    if (mounted) _resetOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hopstone Brewing')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const BreweryHeader(),
          const SizedBox(height: 20),
          const SectionTitle('On Tap'),
          Card(
            child: Column(
              children: [
                for (int i = 0; i < menu.length; i++) ...[
                  BeerTile(
                    beer: menu[i],
                    quantity: quantities[i],
                    onAdd: () => _changeQuantity(i, 1),
                    onRemove: () => _changeQuantity(i, -1),
                  ),
                  if (i < menu.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Extras'),
          TipCard(
            addTip: addTip,
            tipPercent: tipPercent,
            onToggle: (value) => setState(() => addTip = value),
            onPercentChanged: (value) => setState(() => tipPercent = value),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Summary'),
          OrderSummary(
            subtotal: subtotal,
            tipAmount: tipAmount,
            total: total,
            showTip: addTip,
          ),
          const SizedBox(height: 12),
          Card(
            child: CheckboxListTile(
              title: const Text('I confirm I am 21 or older'),
              value: ageConfirmed,
              onChanged: (value) =>
                  setState(() => ageConfirmed = value ?? false),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            // Disabled until there is at least one pour AND age is confirmed
            onPressed: canOrder ? _confirmOrder : null,
            child: const Text('Place Order'),
          ),
          // Conditional UI: hint changes depending on what is missing
          if (!canOrder)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                itemCount == 0
                    ? 'Add at least one pour to place your order.'
                    : 'Please confirm your age to place your order.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable widgets
// ---------------------------------------------------------------------------
class BreweryHeader extends StatelessWidget {
  const BreweryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5D4037), Color(0xFF2E1B16)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.sports_bar, size: 64, color: Color(0xFFF2A900)),
          SizedBox(height: 8),
          Text(
            'HOPSTONE',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
          Text(
            'Craft Brewing Co.',
            style: TextStyle(color: Color(0xFFF2A900), letterSpacing: 1.5),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF3E2723),
        ),
      ),
    );
  }
}

class BeerTile extends StatelessWidget {
  final Beer beer;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const BeerTile({
    super.key,
    required this.beer,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFFFE9A8),
        child: Icon(beer.icon, color: const Color(0xFF3E2723)),
      ),
      title: Text(
        beer.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      // Two clean lines: style on the first, ABV and price on the second
      subtitle: Text(
        '${beer.style}\n${beer.abv}% ABV · ${money(beer.price)} / pint',
      ),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: quantity == 0 ? null : onRemove,
          ),
          Text(
            '$quantity',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class TipCard extends StatelessWidget {
  final bool addTip;
  final double tipPercent;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onPercentChanged;

  const TipCard({
    super.key,
    required this.addTip,
    required this.tipPercent,
    required this.onToggle,
    required this.onPercentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Tip your bartender'),
            secondary: const Icon(Icons.volunteer_activism),
            value: addTip,
            onChanged: onToggle,
          ),
          // Conditional UI: slider only appears when the switch is on
          if (addTip)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  // NEW UI ELEMENT EXPLORED: Slider (with divisions + label)
                  Slider(
                    value: tipPercent,
                    min: 0,
                    max: 30,
                    divisions: 6,
                    label: '${tipPercent.round()}%',
                    onChanged: onPercentChanged,
                  ),
                  Text(
                    'Tip: ${tipPercent.round()}%',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class OrderSummary extends StatelessWidget {
  final double subtotal;
  final double tipAmount;
  final double total;
  final bool showTip;

  const OrderSummary({
    super.key,
    required this.subtotal,
    required this.tipAmount,
    required this.total,
    required this.showTip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SummaryRow(label: 'Subtotal', value: money(subtotal)),
            if (showTip) SummaryRow(label: 'Tip', value: money(tipAmount)),
            const Divider(height: 24),
            SummaryRow(label: 'Total', value: money(total), bold: true),
          ],
        ),
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const SummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 20 : 16,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          // Spacer pushes the value to the far right edge
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}
