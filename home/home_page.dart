import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:code_initial/data/local/database.dart';
import 'package:code_initial/navigation.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  String? _selectedBrand;
  int _selectedGender = 0;
  final List<String> _genders = const ['Tous', 'Homme', 'Femme'];
  final _searchController = TextEditingController();
  late final List<Map<String, dynamic>> _products;
  late List<Map<String, dynamic>> _visibleProducts;
  late List<Map<String, dynamic>> _visibleFavProducts;
  late RangeValues _priceRange;
  int _visibleCount = 6;
  Timer? _chevronTimer;
  bool _chevronUp = false;
  final Set<String> _favIds = {};
  final Map<String, int> _cartQty = {};
  bool _showGenderIcon = true;
  late final PageController _headerController;
  Timer? _headerTimer;
  final _messages = const [
    'Bienvenus à VESTIGO',
    'Faites votre choix parmi nos vêtements de grande marque',
    'Profitez de nos collections du moment',
  ];
  final _headerImages = const [
    'assets/images/vestigo_product_men1.png',
    'assets/images/vestigo_product_men2.png',
    'assets/images/vestigo_product_women1.png',
  ];
  int _messageIndex = 0;
  Timer? _msgTimer;
  String? _userFirstName;
  String? _userLastName;
  String? _userEmail;
  DateTime? _userCreatedAt;

  @override
  void initState() {
    super.initState();
    _products = [
      {
        'title': 'VestiGo Men 1',
        'price': 25000,
        'image': 'assets/images/vestigo_product_men1.png',
        'brand': 'Nike',
        'gender': 'Homme',
      },
      {
        'title': 'VestiGo Men 2',
        'price': 30000,
        'image': 'assets/images/vestigo_product_men2.png',
        'brand': 'Adidas',
        'gender': 'Homme',
      },
      {
        'title': 'VestiGo Men 3',
        'price': 27000,
        'image': 'assets/images/vestigo_product_men3.png',
        'brand': 'FILA',
        'gender': 'Homme',
      },
      {
        'title': 'VestiGo Men 4',
        'price': 32000,
        'image': 'assets/images/vestigo_product_men4.png',
        'brand': 'Puma',
        'gender': 'Homme',
      },
      {
        'title': 'VestiGo Men 5',
        'price': 26000,
        'image': 'assets/images/vestigo_product_men5.png',
        'brand': 'Nike',
        'gender': 'Homme',
      },
      {
        'title': 'VestiGo Men 6',
        'price': 34000,
        'image': 'assets/images/vestigo_product_men6.png',
        'brand': 'Adidas',
        'gender': 'Homme',
      },
      {
        'title': 'VestiGo Men 7',
        'price': 28000,
        'image': 'assets/images/vestigo_product_men7.png',
        'brand': 'FILA',
        'gender': 'Homme',
      },
      {
        'title': 'VestiGo Men 8',
        'price': 30000,
        'image': 'assets/images/vestigo_product_men8.png',
        'brand': 'Puma',
        'gender': 'Homme',
      },
      {
        'title': 'VestiGo Men 9',
        'price': 25000,
        'image': 'assets/images/vestigo_product_men9.png',
        'brand': 'Nike',
        'gender': 'Homme',
      },
      {
        'title': 'VestiGo Men 10',
        'price': 33000,
        'image': 'assets/images/vestigo_product_men10.png',
        'brand': 'Adidas',
        'gender': 'Homme',
      },
      {
        'title': 'VestiGo Women 1',
        'price': 35000,
        'image': 'assets/images/vestigo_product_women1.png',
        'brand': 'Nike',
        'gender': 'Femme',
      },
      {
        'title': 'VestiGo Women 2',
        'price': 40000,
        'image': 'assets/images/vestigo_product_women2.png',
        'brand': 'Adidas',
        'gender': 'Femme',
      },
      {
        'title': 'VestiGo Women 3',
        'price': 38000,
        'image': 'assets/images/vestigo_product_women3.png',
        'brand': 'FILA',
        'gender': 'Femme',
      },
      {
        'title': 'VestiGo Women 4',
        'price': 42000,
        'image': 'assets/images/vestigo_product_women4.png',
        'brand': 'Puma',
        'gender': 'Femme',
      },
      {
        'title': 'VestiGo Women 5',
        'price': 36000,
        'image': 'assets/images/vestigo_product_women5.png',
        'brand': 'Nike',
        'gender': 'Femme',
      },
    ];
    _priceRange = const RangeValues(0, 100000);
    _visibleProducts = List.from(_products);
    _visibleFavProducts = const [];
    _visibleCount = _visibleProducts.length >= 6 ? 6 : _visibleProducts.length;
    // Auto-défilement ralenti
    _chevronTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (mounted) setState(() => _chevronUp = !_chevronUp);
    });
    _headerController = PageController(initialPage: 0, viewportFraction: 0.9);
    _headerTimer = Timer.periodic(const Duration(seconds: 18), (_) {
      final next = (_messageIndex + 1) % _messages.length;
      if (_headerController.hasClients) {
        _headerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOut,
        );
        if (mounted) setState(() => _messageIndex = next);
      }
    });
    _loadPersistedState();
  }

  @override
  void dispose() {
    _msgTimer?.cancel();
    _chevronTimer?.cancel();
    _searchController.dispose();
    _headerTimer?.cancel();
    _headerController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final search = _searchController.text.trim().toLowerCase();
    final brand = _selectedBrand;
    final gender = _genders[_selectedGender];
    _visibleProducts = _products.where((p) {
      final nameMatch =
          search.isEmpty ||
          (p['title'] as String).toLowerCase().contains(search);
      final brandMatch = brand == null || p['brand'] == brand;
      final genderMatch = gender == 'Tous' || p['gender'] == gender;
      final price = p['price'] as int;
      final priceMatch =
          price >= _priceRange.start.round() &&
          price <= _priceRange.end.round();
      final stock = (p['stock'] ?? 10) as int;
      final stockMatch = stock > 0;
      return nameMatch && brandMatch && genderMatch && priceMatch && stockMatch;
    }).toList();
    _visibleFavProducts = _products.where((p) {
      final nameMatch =
          search.isEmpty ||
          (p['title'] as String).toLowerCase().contains(search);
      final brandMatch = brand == null || p['brand'] == brand;
      final genderMatch = gender == 'Tous' || p['gender'] == gender;
      final price = p['price'] as int;
      final priceMatch =
          price >= _priceRange.start.round() &&
          price <= _priceRange.end.round();
      final favMatch = _favIds.contains(p['image'] as String);
      final stock = (p['stock'] ?? 10) as int;
      final stockMatch = stock > 0;
      return nameMatch &&
          brandMatch &&
          genderMatch &&
          priceMatch &&
          favMatch &&
          stockMatch;
    }).toList();
    _visibleCount = _visibleProducts.length >= 6 ? 6 : _visibleProducts.length;
    setState(() {});
  }

  Future<void> _loadPersistedState() async {
    final db = AppDatabase.db;
    final favRows = await db.query('favorites');
    final cartRows = await db.query('cart');
    _favIds
      ..clear()
      ..addAll(favRows.map((r) => r['product_id'] as String));
    _cartQty.clear();
    for (final r in cartRows) {
      _cartQty[r['product_id'] as String] = (r['quantity'] as int);
    }
    _applyFilters();

    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      if (email != null) {
        final rows = await db.query(
          'users',
          where: 'email = ?',
          whereArgs: [email],
          limit: 1,
        );
        if (rows.isNotEmpty) {
          final u = rows.first;
          _userFirstName = u['first_name'] as String?;
          _userLastName = u['last_name'] as String?;
          _userEmail = u['email'] as String?;
          final created = u['created_at'] as String?;
          if (created != null) {
            _userCreatedAt = DateTime.tryParse(created);
          }
          setState(() {});
        }
      }
    } catch (_) {}
  }

  String _inscriptionText() {
    if (_userCreatedAt == null) return 'Inscrit il y a --- jour(s)';
    final days = DateTime.now().difference(_userCreatedAt!).inDays;
    return 'Inscrit il y a $days  jour(s)';
  }

  void _openAccountSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      '${_userFirstName ?? ''} ${_userLastName ?? ''}'.trim(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _inscriptionText(),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _accountField('Nom', _lastOrDash(_userFirstName)),
              const SizedBox(height: 8),
              _accountField('Prénom', _lastOrDash(_userLastName)),
              const SizedBox(height: 8),
              _accountField('Numéro de téléphone', '---'),
              const SizedBox(height: 8),
              _accountField('E-mail', _lastOrDash(_userEmail)),
              const SizedBox(height: 8),
              _accountField('Mot de passe', '********************'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Valider'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _lastOrDash(String? v) => (v == null || v.trim().isEmpty) ? '---' : v!;

  Widget _accountField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value),
        ),
      ],
    );
  }

  Map<String, dynamic>? _productById(String id) {
    try {
      return _products.firstWhere((p) => p['image'] == id);
    } catch (_) {
      return null;
    }
  }

  void _addToCart(Map<String, dynamic> p) {
    final id = p['image'] as String;
    final current = _cartQty[id] ?? 0;
    _cartQty[id] = current + 1;
    setState(() {});
    _persistCart(id, _cartQty[id]!);
  }

  void _updateQty(String id, int delta) {
    final q = (_cartQty[id] ?? 0) + delta;
    if (q <= 0) {
      _cartQty.remove(id);
      _persistCart(id, 0);
    } else {
      _cartQty[id] = q;
      _persistCart(id, q);
    }
    setState(() {});
  }

  Future<void> _persistFav(String id, bool fav) async {
    final db = AppDatabase.db;
    if (fav) {
      await db.insert('favorites', {
        'product_id': id,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await db.delete('favorites', where: 'product_id = ?', whereArgs: [id]);
    }
  }

  Future<void> _persistCart(String id, int qty) async {
    final db = AppDatabase.db;
    if (qty <= 0) {
      await db.delete('cart', where: 'product_id = ?', whereArgs: [id]);
    } else {
      await db.insert('cart', {
        'product_id': id,
        'quantity': qty,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  int _cartSubtotal() {
    int sum = 0;
    _cartQty.forEach((id, q) {
      final p = _productById(id);
      if (p != null) {
        sum += (p['price'] as int) * q;
      }
    });
    return sum;
  }

  void _cycleGender() {
    if (!_showGenderIcon) return;
    setState(() {
      _showGenderIcon = false;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _selectedGender = (_selectedGender + 1) % _genders.length;
        _showGenderIcon = true;
        _applyFilters();
      });
    });
  }

  Widget _genderIcon() {
    switch (_genders[_selectedGender]) {
      case 'Homme':
        return const Icon(
          Icons.male,
          key: ValueKey('Homme'),
          color: Color(0xFF0D47A1),
          size: 22,
        );
      case 'Femme':
        return const Icon(
          Icons.female,
          key: ValueKey('Femme'),
          color: Colors.pink,
          size: 22,
        );
      default:
        return Row(
          key: const ValueKey('Tous'),
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.male, color: Color(0xFF0D47A1), size: 20),
            SizedBox(width: 6),
            Icon(Icons.female, color: Colors.pink, size: 20),
          ],
        );
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String? tempBrand = _selectedBrand;
        RangeValues tempRange = _priceRange;
        return StatefulBuilder(
          builder: (context, setModalState) {
            final dynamicBrands =
                _visibleProducts
                    .map((p) => p['brand'] as String)
                    .toSet()
                    .toList()
                  ..sort();
            final brands = ['Tous', ...dynamicBrands];
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Marque',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: brands.map((b) {
                      final isTous = b == 'Tous';
                      final selected = isTous
                          ? tempBrand == null
                          : tempBrand == b;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() => tempBrand = isTous ? null : b);
                          setState(() => _selectedBrand = isTous ? null : b);
                          _applyFilters();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF0D47A1)
                                : const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            b,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tranche de prix',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  RangeSlider(
                    values: tempRange,
                    min: 0.0,
                    max: 100000.0,
                    divisions: 20,
                    labels: RangeLabels(
                      '${tempRange.start.round()} FCFA',
                      '${tempRange.end.round()} FCFA',
                    ),
                    activeColor: const Color(0xFF0D47A1),
                    onChanged: (v) => setModalState(() => tempRange = v),
                    onChangeEnd: (v) {
                      setState(() => _priceRange = v);
                      _applyFilters();
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempBrand = null;
                            tempRange = const RangeValues(0, 100000);
                          });
                          setState(() {
                            _selectedBrand = null;
                            _priceRange = const RangeValues(0, 100000);
                          });
                          _applyFilters();
                        },
                        child: const Text('Réinitialiser'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Fermer'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _modernBottomBar() {
    final outlineIcons = const [
      Icons.home_outlined,
      Icons.favorite_outline,
      Icons.shopping_bag_outlined,
      Icons.person_outline,
    ];
    final filledIcons = const [
      Icons.home,
      Icons.favorite,
      Icons.shopping_bag,
      Icons.person,
    ];
    return SafeArea(
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
          border: const Border(
            top: BorderSide(color: Color(0xFF0D47A1), width: 1),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final zone = constraints.maxWidth / 4;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOut,
                  left: _tab * zone + (zone - 80) / 2,
                  top: 14,
                  child: Container(
                    width: 80,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8F0FE), Color(0xFFD6E4FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(4, (i) {
                    final selected = _tab == i;
                    return Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          setState(() => _tab = i);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: selected ? 1.12 : 1.0,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (c, a) =>
                                    ScaleTransition(scale: a, child: c),
                                child: Icon(
                                  selected ? filledIcons[i] : outlineIcons[i],
                                  key: ValueKey(selected),
                                  color: selected
                                      ? const Color(0xFF0D47A1)
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('email');
      await prefs.setBool('loggedIn', false);
      Get.offAllNamed('/onboarding');
    } catch (e) {
      Get.snackbar(
        'Déconnexion',
        'Erreur de déconnexion',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Get.snackbar(
                        'Menu',
                        'Fonctionnalité non encore prête',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF0D47A1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'VestiGo',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: Color(0xFF0D47A1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/vestigo_logo.png',
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_tab != 2 && _tab != 3) ...[
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    controller: _headerController,
                    itemCount: _messages.length,
                    padEnds: false,
                    itemBuilder: (context, i) {
                      final selected = i == _messageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 12,
                              bottom: 0,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFE8F0FE), Colors.white],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 280),
                                scale: selected ? 1.0 : 0.98,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Bonjour',
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: SizedBox(
                                                  width: 60,
                                                  child: Divider(
                                                    thickness: 3,
                                                    color: Color(0xFF0D47A1),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _messages[i],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 130,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(12),
                                            bottomRight: Radius.circular(12),
                                          ),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              Image.asset(
                                                _headerImages[i %
                                                    _headerImages.length],
                                                fit: BoxFit.cover,
                                              ),
                                              Container(
                                                decoration: const BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.white,
                                                      Colors.transparent,
                                                    ],
                                                    begin: Alignment.centerLeft,
                                                    end: Alignment.centerRight,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => _applyFilters(),
                          decoration: const InputDecoration(
                            hintText: 'Recherche...',
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.black54,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        Get.snackbar(
                          'Recherche vocale',
                          'Fonctionnalité non encore prête',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D47A1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.mic, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _cycleGender,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 44,
                        width: 72,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0D47A1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 48,
                            height: 24,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 280),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeOut,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              transitionBuilder: (child, animation) {
                                final currentKey = ValueKey(
                                  _genders[_selectedGender],
                                );
                                final isIncoming = child.key == currentKey;
                                final inTween = Tween<Offset>(
                                  begin: const Offset(0.4, 0),
                                  end: Offset.zero,
                                );
                                final outTween = Tween<Offset>(
                                  begin: Offset.zero,
                                  end: const Offset(-0.4, 0),
                                );
                                final tween = isIncoming ? inTween : outTween;
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                              child: _showGenderIcon
                                  ? _genderIcon()
                                  : const SizedBox.shrink(
                                      key: ValueKey('empty'),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _openFilterSheet,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0D47A1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.tune, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 12),
              const SizedBox(height: 16),
              if (_tab == 0 || _tab == 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_tab == 0) ...[
                      const Text(
                        'Nos articles',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      GestureDetector(
                        onTap: () {
                          final add = 12;
                          setState(() {
                            _visibleCount = (_visibleCount + add)
                                .clamp(0, _visibleProducts.length)
                                .toInt();
                          });
                        },
                        child: const Text(
                          'Tout afficher',
                          style: TextStyle(color: Colors.black45),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Favoris',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ],
                ),
              const SizedBox(height: 12),
              Expanded(
                child: _tab == 0
                    ? ListView(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8,
                              left: 8,
                              right: 8,
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  'Tous',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 250,
                            child: Stack(
                              children: [
                                ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  itemCount: _visibleProducts.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final p = _visibleProducts[index];
                                    return SizedBox(
                                      width: 200,
                                      child: TweenAnimationBuilder<double>(
                                        key: ValueKey(p['image']!),
                                        tween: Tween(begin: 0, end: 1),
                                        duration: Duration(
                                          milliseconds: 280 + (index % 8) * 60,
                                        ),
                                        curve: Curves.easeOut,
                                        builder: (ctx, v, child) => Opacity(
                                          opacity: v,
                                          child: Transform.translate(
                                            offset: Offset((1 - v) * 12, 0),
                                            child: child,
                                          ),
                                        ),
                                        child: _ProductCard(
                                          title: p['title']!,
                                          price: '${p['price']} FCFA',
                                          imagePath: p['image']!,
                                          fav: _favIds.contains(p['image']!),
                                          stock: (p['stock'] ?? 10) as int,
                                          rating: ((p['rating'] ?? 4) as num)
                                              .toDouble(),
                                          onToggleFav: () {
                                            final id = p['image']! as String;
                                            setState(() {
                                              if (_favIds.contains(id)) {
                                                _favIds.remove(id);
                                              } else {
                                                _favIds.add(id);
                                              }
                                            });
                                            _persistFav(
                                              id,
                                              _favIds.contains(id),
                                            );
                                            _applyFilters();
                                          },
                                          onAddToCart: () => _addToCart(p),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: IgnorePointer(
                                    child: Container(
                                      width: 38,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.0),
                                            Colors.white,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.black26,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              bottom: 8,
                              left: 8,
                              right: 8,
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  'Homme',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 250,
                            child: Stack(
                              children: [
                                ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  itemCount: _visibleProducts
                                      .where((p) => p['gender'] == 'Homme')
                                      .length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final list = _visibleProducts
                                        .where((p) => p['gender'] == 'Homme')
                                        .toList();
                                    final p = list[index];
                                    return SizedBox(
                                      width: 200,
                                      child: _ProductCard(
                                        title: p['title']!,
                                        price: '${p['price']} FCFA',
                                        imagePath: p['image']!,
                                        fav: _favIds.contains(p['image']!),
                                        stock: (p['stock'] ?? 10) as int,
                                        rating: ((p['rating'] ?? 4) as num)
                                            .toDouble(),
                                        onToggleFav: () {
                                          final id = p['image']! as String;
                                          setState(() {
                                            if (_favIds.contains(id)) {
                                              _favIds.remove(id);
                                            } else {
                                              _favIds.add(id);
                                            }
                                          });
                                          _persistFav(id, _favIds.contains(id));
                                          _applyFilters();
                                        },
                                        onAddToCart: () => _addToCart(p),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: IgnorePointer(
                                    child: Container(
                                      width: 38,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.0),
                                            Colors.white,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.black26,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 12,
                              bottom: 8,
                              left: 8,
                              right: 8,
                            ),
                            child: Row(
                              children: const [
                                Text(
                                  'Femme',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 250,
                            child: Stack(
                              children: [
                                ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  itemCount: _visibleProducts
                                      .where((p) => p['gender'] == 'Femme')
                                      .length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final list = _visibleProducts
                                        .where((p) => p['gender'] == 'Femme')
                                        .toList();
                                    final p = list[index];
                                    return SizedBox(
                                      width: 200,
                                      child: _ProductCard(
                                        title: p['title']!,
                                        price: '${p['price']} FCFA',
                                        imagePath: p['image']!,
                                        fav: _favIds.contains(p['image']!),
                                        stock: (p['stock'] ?? 10) as int,
                                        rating: ((p['rating'] ?? 4) as num)
                                            .toDouble(),
                                        onToggleFav: () {
                                          final id = p['image']! as String;
                                          setState(() {
                                            if (_favIds.contains(id)) {
                                              _favIds.remove(id);
                                            } else {
                                              _favIds.add(id);
                                            }
                                          });
                                          _persistFav(id, _favIds.contains(id));
                                          _applyFilters();
                                        },
                                        onAddToCart: () => _addToCart(p),
                                      ),
                                    );
                                  },
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: IgnorePointer(
                                    child: Container(
                                      width: 38,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.0),
                                            Colors.white,
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.chevron_right,
                                        color: Colors.black26,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _tab == 1
                    ? (_visibleFavProducts.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.heart_broken,
                                    size: 72,
                                    color: Colors.black26,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Aucun produit liké',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.72,
                                  ),
                              itemCount: _visibleFavProducts.length,
                              itemBuilder: (context, index) {
                                final p = _visibleFavProducts[index];
                                return TweenAnimationBuilder<double>(
                                  key: ValueKey(p['image']!),
                                  tween: Tween(begin: 0, end: 1),
                                  duration: Duration(
                                    milliseconds: 280 + (index % 8) * 60,
                                  ),
                                  curve: Curves.easeOut,
                                  builder: (ctx, v, child) => Opacity(
                                    opacity: v,
                                    child: Transform.translate(
                                      offset: Offset(0, (1 - v) * 16),
                                      child: child,
                                    ),
                                  ),
                                  child: _ProductCard(
                                    title: p['title']!,
                                    price: '${p['price']} FCFA',
                                    imagePath: p['image']!,
                                    fav: true,
                                    stock: (p['stock'] ?? 10) as int,
                                    rating: ((p['rating'] ?? 4) as num)
                                        .toDouble(),
                                    onToggleFav: () {
                                      final id = p['image']! as String;
                                      setState(() {
                                        if (_favIds.contains(id)) {
                                          _favIds.remove(id);
                                        } else {
                                          _favIds.add(id);
                                        }
                                      });
                                      _persistFav(id, _favIds.contains(id));
                                      _applyFilters();
                                    },
                                    onAddToCart: () => _addToCart(p),
                                  ),
                                );
                              },
                            ))
                    : _tab == 2
                    ? Column(
                        children: [
                          Expanded(
                            child: _cartQty.isEmpty
                                ? const Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 72,
                                          color: Colors.black26,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'Panier vide',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: _cartQty.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final id = _cartQty.keys.elementAt(index);
                                      final p = _productById(id)!;
                                      final q = _cartQty[id] ?? 0;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.04,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Image.asset(
                                                  p['image'] as String,
                                                  height: 64,
                                                  width: 64,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      p['title'] as String,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      '${p['price']} FCFA',
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    onPressed: () =>
                                                        _updateQty(id, -1),
                                                    icon: const Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                    ),
                                                  ),
                                                  Text(
                                                    '$q',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () =>
                                                        _updateQty(id, 1),
                                                    icon: const Icon(
                                                      Icons.add_circle_outline,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    onPressed: () =>
                                                        _updateQty(id, -q),
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 12,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Sous-total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text('${_cartSubtotal()} FCFA'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Livraison',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text('${_cartSubtotal()} FCFA'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text('${_cartSubtotal() * 2} FCFA'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Get.toNamed('/checkout');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D47A1),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.payment),
                                  label: const Text('Continuer vers paiement'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 8),
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      '${_userFirstName ?? ''} ${_userLastName ?? ''}'
                                          .trim(),
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _lastOrDash(_userEmail),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Information Personnelle',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              const SizedBox(height: 8),
                              _ProfileItem(
                                icon: Icons.account_circle_outlined,
                                title: 'Compte',
                                subtitle: 'Modifier les détails du compte',
                                onTap: () async {
                                  final changed = await Get.toNamed(
                                    Routes.PROFILE_EDIT,
                                  );
                                  if (changed == true) {
                                    _loadPersistedState();
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              _ProfileItem(
                                icon: Icons.local_shipping_outlined,
                                title: 'Commandes',
                                subtitle: "Suivre l'état des commandes",
                                onTap: () {
                                  Get.snackbar(
                                    'Commandes',
                                    'Fonctionnalité non encore prête',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              const _ProfileItem(
                                icon: Icons.notifications_none,
                                title: 'Notifications',
                                subtitle: 'Voir  toutes les notification',
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.black12,
                                  indent: 16,
                                  endIndent: 16,
                                ),
                              ),
                              const Text(
                                'Paramètres Généraux',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const _ProfileItem(
                                icon: Icons.settings_outlined,
                                title: 'Paramètres',
                                subtitle: 'Définir mes préférences',
                              ),
                              const SizedBox(height: 12),
                              const _ProfileItem(
                                icon: Icons.help_outline,
                                title: 'Aides',
                                subtitle: 'Se faire aider',
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _modernBottomBar(),
      persistentFooterButtons: _tab == 3
          ? [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InkWell(
                  onTap: _logout,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF5350), Color(0xFFD32F2F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Se déconnecter',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ]
          : null,
    );
  }
}

class _ProductCard extends StatefulWidget {
  final String title;
  final String price;
  final String imagePath;
  final bool fav;
  final int stock;
  final double rating;
  final VoidCallback onToggleFav;
  final VoidCallback onAddToCart;
  const _ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imagePath,
    required this.fav,
    required this.stock,
    this.rating = 4.0,
    required this.onToggleFav,
    required this.onAddToCart,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _pulse = false;
  Timer? _pulseTimer;
  double _rating = 0;

  void _animateAdd() {
    _pulseTimer?.cancel();
    setState(() => _pulse = true);
    _pulseTimer = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _pulse = false);
    });
  }

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                        width: double.infinity,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: _stockBadge(widget.stock),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(5, (i) {
                      final filled = i < _rating.round();
                      return GestureDetector(
                        onTap: () {
                          setState(() => _rating = (i + 1).toDouble());

                          Get.snackbar(
                            'Avis',
                            'Votre avis a été publié',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: Icon(
                          filled ? Icons.star : Icons.star_border,
                          size: 18,
                          color: const Color(0xFFFFC107),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.price,
                    style: const TextStyle(color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: IconButton(
                              key: ValueKey(widget.fav),
                              icon: Icon(
                                widget.fav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                widget.onToggleFav();
                              },
                              visualDensity: const VisualDensity(
                                horizontal: -2,
                                vertical: -2,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              iconSize: 20,
                            ),
                          ),
                          const SizedBox(width: 1),
                          AnimatedScale(
                            scale: _pulse ? 1.15 : 1.0,
                            duration: const Duration(milliseconds: 180),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, anim) =>
                                  ScaleTransition(scale: anim, child: child),
                              child: IconButton(
                                key: ValueKey(_pulse),
                                icon: Icon(
                                  _pulse
                                      ? Icons.shopping_cart_checkout
                                      : Icons.add_shopping_cart,
                                  color: _pulse
                                      ? const Color(0xFF2E7D32)
                                      : const Color(0xFF0D47A1),
                                ),
                                onPressed: () {
                                  widget.onAddToCart();
                                  _animateAdd();
                                },
                                visualDensity: const VisualDensity(
                                  horizontal: -2,
                                  vertical: -2,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                iconSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _stockColor(int s) {
    if (s < 5) return const Color(0xFFD32F2F);
    if (s < 25) return const Color(0xFFF57C00);
    return const Color(0xFF2E7D32);
  }

  Widget _stockBadge(int s) {
    final c = _stockColor(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$s',
        style: TextStyle(fontWeight: FontWeight.w700, color: c),
      ),
    );
  }
}

class _ProfileItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  const _ProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  State<_ProfileItem> createState() => _ProfileItemState();
}

class _ProfileItemState extends State<_ProfileItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      builder: (ctx, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 10),
          child: child,
        ),
      ),
      child: InkWell(
        onTap:
            widget.onTap ??
            () {
              Get.snackbar(
                widget.title,
                'Fonctionnalité non encore prête',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
        onHighlightChanged: (h) => setState(() => _hover = h),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hover ? 0.08 : 0.06),
                blurRadius: _hover ? 12 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: Colors.black87),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }
}
