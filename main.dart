// POS Retail Pro - Flutter demo app (no external packages needed).
// Flow: Splash -> Login -> Home (Dashboard) -> Products -> New Sale -> Payment
//       Home tabs: Inventory, Customers, Reports; More -> Settings -> Offline / Business Profile
import 'package:flutter/material.dart';

void main() => runApp(const PosApp());

// ------------------------------------------------------------------ DATA
final ValueNotifier<Color> themeColor = ValueNotifier(const Color(0xFF1F6FEB));

String money(num v) =>
    'UGX ${v.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',')}';

class Product {
  final String name, category;
  final int price, reorder;
  int stock;
  Product(this.name, this.category, this.price, this.stock, this.reorder);
}

final List<Product> products = [
  Product('Coca Cola 500ml', 'Beverages', 2500, 50, 20),
  Product('Sprite 500ml', 'Beverages', 2500, 40, 20),
  Product('Water 500ml', 'Beverages', 1500, 100, 30),
  Product('Bread', 'Groceries', 3000, 30, 10),
  Product('Chips', 'Snacks', 2000, 45, 15),
  Product('Biscuits', 'Snacks', 1800, 8, 15),
  Product('Sugar 1kg', 'Groceries', 5500, 6, 10),
];

class Cart extends ChangeNotifier {
  final Map<Product, int> items = {};
  void add(Product p) {
    items[p] = (items[p] ?? 0) + 1;
    notifyListeners();
  }

  void dec(Product p) {
    final q = (items[p] ?? 0) - 1;
    if (q <= 0) {
      items.remove(p);
    } else {
      items[p] = q;
    }
    notifyListeners();
  }

  void clear() {
    items.clear();
    notifyListeners();
  }

  int get count => items.values.fold(0, (a, b) => a + b);
  double get subtotal =>
      items.entries.fold(0.0, (a, e) => a + e.key.price * e.value);
  double get tax => subtotal * 0.18;
  double get total => subtotal + tax;
}

final Cart cart = Cart();
String paymentMethod = 'Cash';

class Customer {
  final String name, phone;
  Customer(this.name, this.phone);
}

final List<Customer> customers = [
  Customer('John Mwangi', '+256 700 123 456'),
  Customer('Sarah Nakato', '+256 772 987 654'),
  Customer('David Kato', '+256 703 456 789'),
  Customer('Aisha Namuiindwa', '+256 755 321 098'),
  Customer('Peter Ssemanda', '+256 787 654 321'),
];

// ------------------------------------------------------------------ APP
class PosApp extends StatelessWidget {
  const PosApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: themeColor,
      builder: (_, c, __) => MaterialApp(
        title: 'POS Retail Pro',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: c, primary: c),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
              centerTitle: false),
        ),
        home: const SplashPage(),
      ),
    );
  }
}

PreferredSizeWidget bar(String title, {bool back = true, List<Widget>? actions}) =>
    AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      automaticallyImplyLeading: back,
      actions: actions,
    );

ButtonStyle bigBtn(BuildContext c) => FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));

// ------------------------------------------------------------------ 1. SPLASH
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Icon(Icons.shopping_cart, size: 90, color: c),
            const SizedBox(height: 16),
            const Text('POS Retail Pro',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Manage your business\nanytime, anywhere',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16)),
            const Spacer(),
            FilledButton(
              style: bigBtn(context),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const LoginPage())),
              child: const Text('Get Started'),
            ),
            const SizedBox(height: 16),
            const Text('Version 1.0.0',
                style: TextStyle(color: Colors.black45, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ 2. LOGIN
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool hide = true, remember = false;
  final email = TextEditingController(), pass = TextEditingController();

  void login() {
    if (email.text.trim().isEmpty || pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter your email/phone and password')));
      return;
    }
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const HomeShell()), (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bar(''),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Login',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const Text('Sign in to your account',
              style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          TextField(
              controller: email,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'Email or Phone',
                  border: OutlineInputBorder())),
          const SizedBox(height: 14),
          TextField(
              controller: pass,
              obscureText: hide,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                      icon: Icon(hide ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => hide = !hide)))),
          Row(children: [
            Checkbox(
                value: remember,
                onChanged: (v) => setState(() => remember = v ?? false)),
            const Text('Remember me'),
            const Spacer(),
            TextButton(onPressed: () {}, child: const Text('Forgot password?')),
          ]),
          FilledButton(
              style: bigBtn(context), onPressed: login, child: const Text('Login')),
          const SizedBox(height: 16),
          const Center(child: Text('OR')),
          const SizedBox(height: 16),
          OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: login,
              icon: const Icon(Icons.g_mobiledata, size: 30),
              label: const Text('Continue with Google')),
          const SizedBox(height: 10),
          OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
              onPressed: login,
              icon: const Icon(Icons.apple),
              label: const Text('Continue with Apple')),
          const SizedBox(height: 20),
          Center(
              child: TextButton(
                  onPressed: () {},
                  child: const Text("Don't have an account? Sign Up"))),
        ]),
      ),
    );
  }
}

// ------------------------------------------------------------------ HOME SHELL (bottom nav)
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int i = 0;
  void go(int n) => setState(() => i = n);
  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(go: go),
      const ProductsPage(tab: true),
      const InventoryPage(tab: true),
      const CustomersPage(tab: true),
      const SettingsPage(tab: true),
    ];
    return Scaffold(
      body: IndexedStack(index: i, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: i,
        onDestinationSelected: go,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Sales'),
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          NavigationDestination(icon: Icon(Icons.people_outline), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}

void open(BuildContext c, Widget w) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => w));

// ------------------------------------------------------------------ 3. DASHBOARD
class DashboardPage extends StatelessWidget {
  final void Function(int) go;
  const DashboardPage({super.key, required this.go});
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;
    Widget tile(IconData ic, String t, VoidCallback f) => Expanded(
          child: InkWell(
            onTap: f,
            child: Container(
              height: 90,
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(10)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(ic, color: c, size: 30),
                const SizedBox(height: 6),
                Text(t),
              ]),
            ),
          ),
        );
    Widget tx(IconData ic, String t, String amt, String time) => ListTile(
          leading: CircleAvatar(
              backgroundColor: c.withOpacity(0.1), child: Icon(ic, color: c)),
          title: Text(t),
          subtitle: Text(time),
          trailing: Text(amt, style: const TextStyle(fontWeight: FontWeight.bold)),
        );
    return SafeArea(
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Row(children: [
          const Expanded(
              child: Text('Good Morning,\nBusiness Owner',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
          const CircleAvatar(child: Icon(Icons.person)),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration:
              BoxDecoration(color: c, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Today's Sales", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 6),
              Text('UGX 1,250,000',
                  style: TextStyle(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text('▲ 12%', style: TextStyle(color: Colors.white70)),
            ])),
            const Icon(Icons.bar_chart, color: Colors.white, size: 40),
          ]),
        ),
        const SizedBox(height: 10),
        Row(children: [
          tile(Icons.shopping_cart, 'New Sale', () => open(context, const ProductsPage())),
          tile(Icons.inventory_2, 'Inventory', () => go(2)),
        ]),
        Row(children: [
          tile(Icons.people, 'Customers', () => go(3)),
          tile(Icons.bar_chart, 'Reports', () => open(context, const ReportsPage())),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Text('Recent Transactions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('View All')),
        ]),
        tx(Icons.payments_outlined, 'Cash Sale', 'UGX 45,000', '10:24 AM'),
        tx(Icons.credit_card, 'Card Payment', 'UGX 120,000', '09:50 AM'),
        tx(Icons.phone_android, 'Mobile Money', 'UGX 80,000', '09:15 AM'),
      ]),
    );
  }
}

// ------------------------------------------------------------------ 4. PRODUCTS
class ProductsPage extends StatefulWidget {
  final bool tab;
  const ProductsPage({super.key, this.tab = false});
  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  String q = '', cat = 'All';
  @override
  Widget build(BuildContext context) {
    final cats = ['All', 'Beverages', 'Snacks', 'Groceries'];
    final list = products
        .where((p) =>
            (cat == 'All' || p.category == cat) &&
            p.name.toLowerCase().contains(q.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: bar('Products', back: !widget.tab, actions: [
        ListenableBuilder(
          listenable: cart,
          builder: (_, __) => IconButton(
            onPressed: () => open(context, const NewSalePage()),
            icon: Badge(
                isLabelVisible: cart.count > 0,
                label: Text('${cart.count}'),
                child: const Icon(Icons.shopping_cart_outlined)),
          ),
        ),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search products...',
                border: OutlineInputBorder()),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: cats
                .map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                          label: Text(c),
                          selected: cat == c,
                          onSelected: (_) => setState(() => cat = c)),
                    ))
                .toList(),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final p = list[i];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.local_drink)),
                title: Text(p.name),
                subtitle: Text('${money(p.price)}\nStock: ${p.stock}'),
                isThreeLine: true,
                trailing: IconButton.filled(
                    onPressed: () {
                      cart.add(p);
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            duration: const Duration(milliseconds: 700),
                            content: Text('${p.name} added')));
                    },
                    icon: const Icon(Icons.add)),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------------ 5. NEW SALE
class NewSalePage extends StatefulWidget {
  const NewSalePage({super.key});
  @override
  State<NewSalePage> createState() => _NewSalePageState();
}

class _NewSalePageState extends State<NewSalePage> {
  String customer = 'Walk-in Customer';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bar('New Sale'),
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          final entries = cart.items.entries.toList();
          return Column(children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(customer),
              trailing: TextButton(
                  onPressed: () async {
                    final r = await showDialog<String>(
                        context: context,
                        builder: (_) => SimpleDialog(
                              title: const Text('Select customer'),
                              children: [
                                SimpleDialogOption(
                                    onPressed: () =>
                                        Navigator.pop(context, 'Walk-in Customer'),
                                    child: const Text('Walk-in Customer')),
                                ...customers.map((c) => SimpleDialogOption(
                                    onPressed: () => Navigator.pop(context, c.name),
                                    child: Text(c.name))),
                              ],
                            ));
                    if (r != null) setState(() => customer = r);
                  },
                  child: const Text('Change')),
            ),
            const Divider(height: 1),
            Expanded(
              child: entries.isEmpty
                  ? const Center(child: Text('Cart is empty - add products first'))
                  : ListView(
                      children: entries
                          .map((e) => ListTile(
                                title: Text(e.key.name),
                                subtitle: Text(money(e.key.price)),
                                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(
                                      onPressed: () => cart.dec(e.key),
                                      icon: const Icon(Icons.remove_circle_outline)),
                                  Text('${e.value}',
                                      style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                      onPressed: () => cart.add(e.key),
                                      icon: const Icon(Icons.add_circle_outline)),
                                  SizedBox(
                                      width: 90,
                                      child: Text(money(e.key.price * e.value),
                                          textAlign: TextAlign.right)),
                                ]),
                              ))
                          .toList()),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.black12))),
              child: Column(children: [
                row('Subtotal', money(cart.subtotal)),
                row('Tax (18%)', money(cart.tax)),
                row('Total', money(cart.total), bold: true),
                const SizedBox(height: 10),
                Row(children: ['Cash', 'Card', 'Mobile Money']
                    .map((m) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: ChoiceChip(
                                label: Center(child: Text(m, style: const TextStyle(fontSize: 12))),
                                selected: paymentMethod == m,
                                onSelected: (_) => setState(() => paymentMethod = m)),
                          ),
                        ))
                    .toList()),
                const SizedBox(height: 10),
                FilledButton(
                    style: bigBtn(context),
                    onPressed: cart.count == 0
                        ? null
                        : () => open(context, const PaymentPage()),
                    child: const Text('Complete Sale')),
              ]),
            ),
          ]);
        },
      ),
    );
  }

  Widget row(String a, String b, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(a, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
          const Spacer(),
          Text(b, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        ]),
      );
}

// ------------------------------------------------------------------ 6. PAYMENT
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late String sel = paymentMethod == 'Card' ? 'Credit / Debit Card' : paymentMethod;
  @override
  Widget build(BuildContext context) {
    final opts = {
      'Cash': Icons.payments_outlined,
      'Credit / Debit Card': Icons.credit_card,
      'Mobile Money': Icons.phone_android,
      'Bank Transfer': Icons.account_balance,
    };
    return Scaffold(
      appBar: bar('Payment'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Total Amount', style: TextStyle(color: Colors.black54)),
          Text(money(cart.total),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...opts.entries.map((e) => Card(
                child: RadioListTile<String>(
                  value: e.key,
                  groupValue: sel,
                  onChanged: (v) => setState(() => sel = v!),
                  title: Text(e.key),
                  secondary: Icon(e.value),
                ),
              )),
          const Spacer(),
          FilledButton(
              style: bigBtn(context),
              onPressed: () async {
                final paid = money(cart.total);
                cart.clear();
                await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                          icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
                          title: const Text('Payment Successful'),
                          content: Text('$paid received via $sel.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Done'))
                          ],
                        ));
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeShell()),
                    (r) => false);
              },
              child: const Text('Pay Now')),
        ]),
      ),
    );
  }
}

// ------------------------------------------------------------------ 7. INVENTORY
class InventoryPage extends StatefulWidget {
  final bool tab;
  const InventoryPage({super.key, this.tab = false});
  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String view = 'Stock', q = '';
  @override
  Widget build(BuildContext context) {
    var list = products.where((p) => p.name.toLowerCase().contains(q.toLowerCase())).toList();
    if (view == 'Low Stock') list = list.where((p) => p.stock <= p.reorder).toList();
    return Scaffold(
      appBar: bar('Inventory', back: !widget.tab),
      floatingActionButton: FloatingActionButton(
          onPressed: () => addProduct(context), child: const Icon(Icons.add)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Stock', label: Text('Stock')),
              ButtonSegment(value: 'Low Stock', label: Text('Low Stock')),
              ButtonSegment(value: 'Categories', label: Text('Categories')),
            ],
            selected: {view},
            onSelectionChanged: (s) => setState(() => view = s.first),
          ),
        ),
        if (view != 'Categories')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
                onChanged: (v) => setState(() => q = v),
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search inventory...',
                    border: OutlineInputBorder())),
          ),
        Expanded(
          child: view == 'Categories'
              ? ListView(
                  children: ['Beverages', 'Snacks', 'Groceries']
                      .map((c) => ListTile(
                            leading: const Icon(Icons.category_outlined),
                            title: Text(c),
                            trailing: Text('${products.where((p) => p.category == c).length} items'),
                          ))
                      .toList())
              : ListView(
                  children: list
                      .map((p) => ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                            title: Text(p.name),
                            subtitle: Text('Stock: ${p.stock}   Reorder: ${p.reorder}'),
                            trailing: p.stock <= p.reorder
                                ? const Icon(Icons.warning_amber, color: Colors.orange)
                                : const Icon(Icons.chevron_right),
                          ))
                      .toList()),
        ),
      ]),
    );
  }

  void addProduct(BuildContext ctx) {
    final n = TextEditingController(), pr = TextEditingController(), st = TextEditingController();
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: const Text('Add product'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: n, decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                    controller: pr,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price (UGX)')),
                TextField(
                    controller: st,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock')),
              ]),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      if (n.text.trim().isNotEmpty) {
                        setState(() => products.add(Product(n.text.trim(), 'Groceries',
                            int.tryParse(pr.text) ?? 0, int.tryParse(st.text) ?? 0, 10)));
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save')),
              ],
            ));
  }
}

// ------------------------------------------------------------------ 8. CUSTOMERS
class CustomersPage extends StatefulWidget {
  final bool tab;
  const CustomersPage({super.key, this.tab = false});
  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final list = customers.where((c) => c.name.toLowerCase().contains(q.toLowerCase())).toList();
    return Scaffold(
      appBar: bar('Customers', back: !widget.tab),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
              onChanged: (v) => setState(() => q = v),
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search customers...',
                  border: OutlineInputBorder())),
        ),
        Expanded(
          child: ListView(
              children: list
                  .map((c) => ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(c.name),
                        subtitle: Text(c.phone),
                        trailing: const Icon(Icons.chevron_right),
                      ))
                  .toList()),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
              style: bigBtn(context),
              onPressed: () => add(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Customer')),
        ),
      ]),
    );
  }

  void add(BuildContext ctx) {
    final n = TextEditingController(), p = TextEditingController();
    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              title: const Text('Add customer'),
              content: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: n, decoration: const InputDecoration(labelText: 'Name')),
                TextField(
                    controller: p,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone')),
              ]),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                FilledButton(
                    onPressed: () {
                      if (n.text.trim().isNotEmpty) {
                        setState(() => customers.add(Customer(n.text.trim(), p.text.trim())));
                      }
                      Navigator.pop(ctx);
                    },
                    child: const Text('Save')),
              ],
            ));
  }
}

// ------------------------------------------------------------------ 9. REPORTS
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  String tab = 'Sales', range = '7 Days';
  @override
  Widget build(BuildContext context) {
    final data = {
      '7 Days': [4.0, 5.0, 4.5, 6.5, 6.0, 7.5, 8.45],
      '30 Days': [20.0, 24.0, 22.0, 30.0, 28.0, 35.0, 38.0],
      'Custom': [3.0, 4.0, 3.5, 5.0, 6.0, 5.5, 7.0],
    }[range]!;
    final total = {'7 Days': 'UGX 8,450,000', '30 Days': 'UGX 38,200,000', 'Custom': 'UGX 6,100,000'}[range]!;
    return Scaffold(
      appBar: bar('Reports'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'Sales', label: Text('Sales')),
            ButtonSegment(value: 'Inventory', label: Text('Inventory')),
            ButtonSegment(value: 'Customers', label: Text('Customers')),
          ],
          selected: {tab},
          onSelectionChanged: (s) => setState(() => tab = s.first),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: ['7 Days', '30 Days', 'Custom']
            .map((r) => ChoiceChip(
                label: Text(r), selected: range == r, onSelected: (_) => setState(() => range = r)))
            .toList()),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            title: Text('Total ${tab == 'Sales' ? 'Sales' : tab}'),
            subtitle: Text(total,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            trailing: const Text('▲ 15%', style: TextStyle(color: Colors.green)),
          ),
        ),
        const SizedBox(height: 10),
        const Text('Sales Trend', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: CustomPaint(
              painter: LineChartPainter(data, Theme.of(context).colorScheme.primary),
              child: Container()),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.star_outline),
                  label: const Text('Top Products'))),
          const SizedBox(width: 10),
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Payment Methods'))),
        ]),
      ]),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<double> d;
  final Color color;
  LineChartPainter(this.d, this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final grid = Paint()..color = Colors.black12;
    for (var i = 0; i < 4; i++) {
      final y = s.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(s.width, y), grid);
    }
    final mx = d.reduce((a, b) => a > b ? a : b) * 1.1;
    final pts = [
      for (var i = 0; i < d.length; i++)
        Offset(s.width * i / (d.length - 1), s.height - s.height * d[i] / mx)
    ];
    final line = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, line);
    for (final p in pts) {
      canvas.drawCircle(p, 4, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter o) => o.d != d || o.color != color;
}

// ------------------------------------------------------------------ 10. SETTINGS
class SettingsPage extends StatelessWidget {
  final bool tab;
  const SettingsPage({super.key, this.tab = false});
  @override
  Widget build(BuildContext context) {
    Widget item(IconData ic, String t, Widget? page) => ListTile(
          leading: Icon(ic),
          title: Text(t),
          trailing: const Icon(Icons.chevron_right),
          onTap: page == null
              ? () => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('$t - coming soon')))
              : () => open(context, page),
        );
    return Scaffold(
      appBar: bar('Settings', back: !tab),
      body: ListView(children: [
        const ListTile(
          leading: CircleAvatar(radius: 24, child: Icon(Icons.person)),
          title: Text('Business Owner', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('owner@business.com'),
        ),
        const Divider(),
        item(Icons.storefront_outlined, 'Business Profile', const BusinessProfilePage()),
        item(Icons.payment, 'Payment Settings', null),
        item(Icons.inventory_2_outlined, 'Inventory Settings', null),
        item(Icons.manage_accounts_outlined, 'User Management', null),
        item(Icons.settings_outlined, 'App Preferences', null),
        item(Icons.security, 'Security & Privacy', null),
        item(Icons.wifi_off, 'Offline Mode (demo)', const OfflinePage()),
        item(Icons.info_outline, 'About', null),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text('Log out', style: TextStyle(color: Colors.red)),
          onTap: () => Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(builder: (_) => const SplashPage()), (r) => false),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------------ 11. OFFLINE
class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bar(''),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const CircleAvatar(radius: 44, child: Icon(Icons.wifi_off, size: 44)),
          const SizedBox(height: 20),
          const Text("You're Offline",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
              'No internet connection detected. You can still process sales, view cached data and manage inventory.',
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          const Chip(avatar: Icon(Icons.check_circle, color: Colors.green), label: Text('Working Offline')),
          const SizedBox(height: 20),
          FilledButton(
              onPressed: () => Navigator.pop(context), child: const Text('Back to app')),
        ]),
      ),
    );
  }
}

// ------------------------------------------------------------------ 12. BUSINESS PROFILE
class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});
  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  final name = TextEditingController(text: 'My Store');
  String type = 'Retail Store';
  late Color color = themeColor.value;
  @override
  Widget build(BuildContext context) {
    final colors = [Colors.purple, const Color(0xFF1F6FEB), Colors.green, Colors.amber, Colors.orange];
    return Scaffold(
      appBar: bar('Business Profile'),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        const Text('Business Name'),
        const SizedBox(height: 6),
        TextField(controller: name, decoration: const InputDecoration(border: OutlineInputBorder())),
        const SizedBox(height: 16),
        const Text('Business Type'),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: type,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: ['Retail Store', 'Supermarket', 'Pharmacy', 'Restaurant']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => type = v!),
        ),
        const SizedBox(height: 16),
        const Text('Logo'),
        const SizedBox(height: 6),
        Row(children: [
          Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                  color: Colors.black12, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.image_outlined)),
          TextButton(onPressed: () {}, child: const Text('Change')),
        ]),
        const SizedBox(height: 16),
        const Text('Theme Color'),
        const SizedBox(height: 8),
        Row(
            children: colors
                .map((c) => GestureDetector(
                      onTap: () => setState(() => color = c),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                                width: 3,
                                color: color == c ? Colors.black : Colors.transparent)),
                      ),
                    ))
                .toList()),
        const SizedBox(height: 28),
        FilledButton(
            style: bigBtn(context),
            onPressed: () {
              themeColor.value = color; // whole app changes colour
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Profile saved')));
              Navigator.pop(context);
            },
            child: const Text('Save')),
      ]),
    );
  }
}
