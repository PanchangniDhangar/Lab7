import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

const Color primaryColor = Color(0xFFEF6C00);
const Color secondaryColor = Color(0xFFFFCC80);
const Color accentColor = Color(0xFF4E342E);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodieGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Text(
          "FoodieGo",
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> pastOrders = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Map<String, dynamic>> menuItems = [
    {'name': 'Burger', 'price': 150, 'image': '🍔'},
    {'name': 'Pizza', 'price': 250, 'image': '🍕'},
    {'name': 'Fries', 'price': 100, 'image': '🍟'},
    {'name': 'Coffee', 'price': 80, 'image': '☕'},
    {'name': 'Donut', 'price': 60, 'image': '🍩'},
  ];

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      cartItems.add(item);
    });
  }

  void checkout() {
    if (cartItems.isNotEmpty) {
      final timestamp = DateTime.now();
      final itemsWithTimestamp = cartItems
          .map((item) => {
                'name': item['name'],
                'price': item['price'],
                'timestamp': timestamp,
              })
          .toList();
      setState(() {
        pastOrders.addAll(itemsWithTimestamp);
        cartItems.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order placed!")));
    }
  }

  List<Widget> get _pages => [
        BackgroundWrapper(child: MenuTab(menuItems: menuItems, onAddToCart: addToCart)),
        BackgroundWrapper(child: CartTab(cartItems: cartItems, onCheckout: checkout)),
        BackgroundWrapper(child: OrdersTab(pastOrders: pastOrders)),
        BackgroundWrapper(child: ProfileTab()),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("FoodieGo")),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Menu"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Cart"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/bg.jpg",
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        child,
      ],
    );
  }
}

class MenuTab extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;
  final Function(Map<String, dynamic>) onAddToCart;

  const MenuTab({super.key, required this.menuItems, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(12),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return Card(
          color: Colors.white70,
          child: ListTile(
            leading: Text(item['image'], style: TextStyle(fontSize: 28)),
            title: Text(item['name']),
            subtitle: Text('₹${item['price']}'),
            trailing: ElevatedButton(
              onPressed: () => onAddToCart(item),
              child: Text("Add"),
            ),
          ),
        );
      },
    );
  }
}

class CartTab extends StatelessWidget {
  final List<Map<String, dynamic>> cartItems;
  final VoidCallback onCheckout;

  const CartTab({super.key, required this.cartItems, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(0, (sum, item) => sum + item['price']);

    return Column(
      children: [
        Expanded(
          child: cartItems.isEmpty
              ? Center(child: Text("Cart is empty", style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(item['name'], style: TextStyle(color: Colors.black)),
                        trailing: Text("₹${item['price']}", style: TextStyle(color: Colors.black)),
                      ),
                    );
                  },
                ),
        ),
        if (cartItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Total: ₹$total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onCheckout,
                  child: Text("Checkout"),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class OrdersTab extends StatelessWidget {
  final List<Map<String, dynamic>> pastOrders;

  const OrdersTab({super.key, required this.pastOrders});

  @override
  Widget build(BuildContext context) {
    return pastOrders.isEmpty
        ? Center(child: Text("No past orders", style: TextStyle(color: Colors.white)))
        : ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: pastOrders.length,
            itemBuilder: (context, index) {
              final item = pastOrders[index];
              String formattedTime = (item['timestamp'] as DateTime).toLocal().toString().substring(0, 19);
              return Card(
                color: Colors.white70,
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text("Ordered at: $formattedTime"),
                  trailing: Text("₹${item['price']}"),
                ),
              );
            },
          );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage("assets/pfp.jpg"),
          ),
          SizedBox(height: 10),
          Text("Mr.Foodie", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("foodie@example.com", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
