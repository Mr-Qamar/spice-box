import 'package:flutter/material.dart';

void main() => runApp(const SpiceBoxApp());

class SpiceBoxApp extends StatefulWidget {
  const SpiceBoxApp({super.key});

  @override
  State<SpiceBoxApp> createState() => _SpiceBoxAppState();
}

class _SpiceBoxAppState extends State<SpiceBoxApp> {
  final _Store store = _Store();

  @override
  Widget build(BuildContext context) {
    return _Scope(
      store: store,
      child: MaterialApp(
        title: 'Spice Box',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFEA580C)),
          scaffoldBackgroundColor: const Color(0xFFFFF7ED),
        ),
        home: const _Shell(),
      ),
    );
  }
}

class _Recipe {
  const _Recipe(this.title, this.time, this.tag, this.steps, this.shop);
  final String title;
  final String time;
  final String tag;
  final List<String> steps;
  final List<String> shop;
}

const recipes = [
  _Recipe('Chicken Karahi', '45 min', 'Pakistani', ['Heat oil', 'Add chicken + tomatoes', 'Ginger, chilies, garam masala', 'Finish with coriander'], ['Chicken', 'Tomatoes', 'Ginger', 'Green chili']),
  _Recipe('Daal Tadka', '30 min', 'Comfort', ['Boil masoor', 'Tadka: cumin, garlic', 'Pour over daal'], ['Masoor', 'Garlic', 'Cumin', 'Ghee']),
  _Recipe('Chana Chaat', '15 min', 'Street', ['Mix boiled chana', 'Onion, tomato, chaat masala', 'Lemon'], ['Chickpeas', 'Onion', 'Chaat masala', 'Lemon']),
  _Recipe('Aloo Paratha', '25 min', 'Breakfast', ['Stuff dough with spiced potato', 'Cook on tawa with ghee'], ['Atta', 'Potato', 'Ajwain', 'Ghee']),
];

class _Store extends ChangeNotifier {
  final favs = <int>{0};
  final cart = <String>{'Ginger'};

  void toggleFav(int i) {
    if (!favs.add(i)) favs.remove(i);
    notifyListeners();
  }

  void toggleCart(String item) {
    if (!cart.add(item)) cart.remove(item);
    notifyListeners();
  }
}

class _Scope extends InheritedNotifier<_Store> {
  const _Scope({required _Store store, required super.child}) : super(notifier: store);
  static _Store of(BuildContext c) => c.dependOnInheritedWidgetOfExactType<_Scope>()!.notifier!;
}

class _Shell extends StatefulWidget {
  const _Shell();
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tab,
        children: const [_Home(), _Favs(), _Shop(), _Tips()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: 'Cook'),
          NavigationDestination(icon: Icon(Icons.favorite_outline), selectedIcon: Icon(Icons.favorite), label: 'Saved'),
          NavigationDestination(icon: Icon(Icons.shopping_basket_outlined), selectedIcon: Icon(Icons.shopping_basket), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Tips'),
        ],
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Spice Box', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF9A3412))),
          const Text('Home recipes, 15–45 minutes'),
          const SizedBox(height: 16),
          for (var i = 0; i < recipes.length; i++)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFFFEDD5),
                  child: Text('${i + 1}', style: const TextStyle(color: Color(0xFF9A3412), fontWeight: FontWeight.w800)),
                ),
                title: Text(recipes[i].title, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${recipes[i].tag} · ${recipes[i].time}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _Detail(index: i))),
              ),
            ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    final r = recipes[index];
    final store = _Scope.of(context);
    final saved = store.favs.contains(index);
    return Scaffold(
      appBar: AppBar(title: Text(r.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('${r.tag} · ${r.time}', style: const TextStyle(color: Color(0xFF9A3412), fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          const Text('Steps', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          for (var i = 0; i < r.steps.length; i++)
            ListTile(leading: CircleAvatar(radius: 14, child: Text('${i + 1}')), title: Text(r.steps[i])),
          const Text('Add to shop list', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          for (final item in r.shop)
            CheckboxListTile(
              value: store.cart.contains(item),
              title: Text(item),
              onChanged: (_) => store.toggleCart(item),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => store.toggleFav(index),
        icon: Icon(saved ? Icons.favorite : Icons.favorite_border),
        label: Text(saved ? 'Saved' : 'Save'),
      ),
    );
  }
}

class _Favs extends StatelessWidget {
  const _Favs();
  @override
  Widget build(BuildContext context) {
    final store = _Scope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Saved', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          if (store.favs.isEmpty) const Text('Save a recipe from Cook.'),
          for (final i in store.favs)
            ListTile(
              title: Text(recipes[i].title),
              subtitle: Text(recipes[i].time),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _Detail(index: i))),
            ),
        ],
      ),
    );
  }
}

class _Shop extends StatelessWidget {
  const _Shop();
  @override
  Widget build(BuildContext context) {
    final store = _Scope.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Shop list', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          if (store.cart.isEmpty) const Text('Tick ingredients on a recipe.'),
          for (final item in store.cart)
            ListTile(
              leading: const Icon(Icons.check_box, color: Color(0xFFEA580C)),
              title: Text(item),
              trailing: IconButton(onPressed: () => store.toggleCart(item), icon: const Icon(Icons.close)),
            ),
        ],
      ),
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();
  @override
  Widget build(BuildContext context) {
    const tips = [
      'Toast whole spices 20 seconds before grinding.',
      'Salt tomatoes early so they break down in karahi.',
      'Rest paratha dough 15 minutes for softer layers.',
      'A squeeze of lemon lifts almost every chaat.',
    ];
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Kitchen tips', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final t in tips)
            Card(
              child: ListTile(leading: const Icon(Icons.lightbulb, color: Color(0xFFEA580C)), title: Text(t)),
            ),
        ],
      ),
    );
  }
}
