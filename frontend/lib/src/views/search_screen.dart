// path: lib/src/views/search_screen.dart
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Toutes';
  bool _isLoading = false;

  final List<Map<String, String>> _trendingResults = [
    {
      'title': 'La Casbah by night',
      'location': 'Alger',
      'followers': '2100 joueurs',
    },
  ];

  final List<Map<String, String>> _popularResults = [
    {
      'title': 'Le Paris secret',
      'followers': '1240 joueurs',
    },
    {
      'title': 'Ruelles de Lisbonne',
      'followers': '980 joueurs',
    },
    {
      'title': 'Street art Berlin',
      'followers': '760 joueurs',
    },
    {
      'title': 'Tokyo nocturne',
      'followers': '1530 joueurs',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un lieu, une quête...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),

                const SizedBox(height: 16),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Toutes
                      FilterChip(
                        label: const Text('Toutes'),
                        selected: _selectedFilter == 'Toutes',
                        onSelected: (selected) {
                          setState(() => _selectedFilter = 'Toutes');
                        },
                        backgroundColor: Colors.white,
                        selectedColor: Colors.black,
                        labelStyle: TextStyle(
                          color: _selectedFilter == 'Toutes' ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: _selectedFilter == 'Toutes' ? Colors.transparent : Colors.grey[300]!,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Historique
                      FilterChip(
                        label: const Text('Historique'),
                        selected: _selectedFilter == 'Historique',
                        onSelected: (selected) {
                          setState(() => _selectedFilter = 'Historique');
                        },
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: _selectedFilter == 'Historique' ? Colors.white : Colors.black,
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      const SizedBox(width: 8),

                      // Distance
                      FilterChip(
                        label: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.unfold_more, size: 16),
                            SizedBox(width: 4),
                            Text('Distance'),
                          ],
                        ),
                        onSelected: (selected) {},
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      const SizedBox(width: 8),

                      // Filter Icon
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: () {},
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Tendance Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.blue[800], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Tendance',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Trending Item
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'La Casbah by night',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Alger • 2100 joueurs',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Populaires Section
                const Text(
                  'Populaires près de toi',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                // Popular Grid
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _popularResults.length,
                  itemBuilder: (context, index) {
                    final item = _popularResults[index];
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Image Placeholder
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: Icon(
                                Icons.image,
                                color: Colors.grey[400],
                                size: 48,
                              ),
                            ),
                          ),

                          // Info
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['followers']!,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Loading Indicator
                if (_isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chargement...',
                            style: TextStyle(color: Colors.grey[600]),
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
    );
  }
}
