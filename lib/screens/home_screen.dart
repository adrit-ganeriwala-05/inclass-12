import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/firestore_service.dart';
import 'item_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _service = FirestoreService();
  String _searchQuery = '';

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        title: const Text('CONFIRM DELETE',
            style: TextStyle(
                color: Color(0xFFFFD600),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 2)),
        content: const Text(
          'This item will be permanently removed.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL',
                style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 1,
                    fontSize: 12)),
          ),
          ElevatedButton(
            onPressed: () {
              _service.deleteItem(id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
            child: const Text('DELETE',
                style: TextStyle(letterSpacing: 1.5, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: [
            Container(
              width: 4,
              height: 22,
              color: const Color(0xFFFFD600),
              margin: const EdgeInsets.only(right: 10),
            ),
            const Text(
              'INVENTORY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Column(
            children: [
              const Divider(height: 1, color: Color(0xFF2A2A2A)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'SEARCH ITEMS...',
                    hintStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        letterSpacing: 1.5),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFFFFD600), size: 20),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide:
                          const BorderSide(color: Color(0xFF333333)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide:
                          const BorderSide(color: Color(0xFF333333)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(
                          color: Color(0xFFFFD600), width: 1.5),
                    ),
                  ),
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase()),
                ),
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<List<Item>>(
        stream: _service.streamItems(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent)),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD600)),
            );
          }

          final items = (snapshot.data ?? [])
              .where((item) =>
                  item.name.toLowerCase().contains(_searchQuery) ||
                  item.category.toLowerCase().contains(_searchQuery))
              .toList();

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.white12),
                  const SizedBox(height: 16),
                  const Text('NO ITEMS FOUND',
                      style: TextStyle(
                          color: Colors.white24,
                          fontSize: 12,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isLow = item.quantity < 5;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border(
                    left: BorderSide(
                      color: isLow
                          ? Colors.redAccent
                          : const Color(0xFFFFD600),
                      width: 3,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      // Left: name + category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  item.name.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                    letterSpacing: 1,
                                  ),
                                ),
                                if (isLow) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.15),
                                      border: Border.all(
                                          color: Colors.redAccent,
                                          width: 1),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Text(
                                      'LOW STOCK',
                                      style: TextStyle(
                                          fontSize: 9,
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.5),
                                    ),
                                  ),
                                ]
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.category.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  letterSpacing: 2),
                            ),
                          ],
                        ),
                      ),
                      // Middle: qty + price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.numbers,
                                  size: 12, color: Colors.white38),
                              const SizedBox(width: 4),
                              Text(
                                '${item.quantity} units',
                                style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFFFFD600),
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Right: action buttons
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemFormScreen(
                                    service: _service, item: item),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF252525),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.edit,
                                  size: 16,
                                  color: Color(0xFFFFD600)),
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () =>
                                _confirmDelete(context, item.id!),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF252525),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  size: 16, color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemFormScreen(service: _service),
          ),
        ),
        backgroundColor: const Color(0xFFFFD600),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        icon: const Icon(Icons.add),
        label: const Text(
          'ADD ITEM',
          style: TextStyle(
              fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 12),
        ),
      ),
    );
  }
}