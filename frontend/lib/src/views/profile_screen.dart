// lib/src/views/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Profile Data
  static const _profileData = {
    'name': 'Yacine B.',
    'pseudo': '@yacine.explore',
    'badge': 'Grand Explorateur',
    'bio':
        'Passionné de voyages et de nouvelles expériences 🌏✈️ J\'adore découvrir les cultures du monde entier !',
    'avatarUrl': 'https://i.pravatar.cc/150?img=68',
  };

  // Mock Stats
  static const _stats = {
    'quests': 128,
    'countries': 31,
    'friends': 128,
    'followers': '2,4K',
  };

  // Mock Country Progression
  static final _countryProgression = [
    {'name': 'Algérie', 'flag': '🇩🇿', 'progress': 0.72},
    {'name': 'Japon', 'flag': '🇯🇵', 'progress': 0.45},
    {'name': 'Espagne', 'flag': '🇪🇸', 'progress': 0.30},
    {'name': 'France', 'flag': '🇫🇷', 'progress': 0.15},
  ];

  // Mock Badges
  static final _badges = [
    {'icon': Icons.shield, 'label': 'Shield Master', 'color': Colors.amber},
    {'icon': Icons.restaurant, 'label': 'Food Explorer', 'color': Colors.orange},
    {'icon': Icons.music_note, 'label': 'Music Lover', 'color': Colors.purple},
    {'icon': Icons.location_on, 'label': 'Navigator', 'color': Colors.teal},
  ];

  // Mock Quêtes
  static final _quests = [
    {
      'category': 'Histoire',
      'title': 'Découvre la Tour Eiffel',
      'location': 'Paris, France',
      'date': '12 Jan 2026',
      'xp': 50,
    },
    {
      'category': 'Culture',
      'title': 'Balade au Louvre',
      'location': 'Paris, France',
      'date': '10 Jan 2026',
      'xp': 40,
    },
    {
      'category': 'Gastronomie',
      'title': 'Croissant chez le boulanger',
      'location': 'Paris, France',
      'date': '08 Jan 2026',
      'xp': 20,
    },
    {
      'category': 'Nature',
      'title': 'Coucher de soleil à Montmartre',
      'location': 'Paris, France',
      'date': '05 Jan 2026',
      'xp': 60,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Profile
          SliverToBoxAdapter(
            child: _ProfileHeader(
              name: _profileData['name']!,
              pseudo: _profileData['pseudo']!,
              badge: _profileData['badge']!,
              bio: _profileData['bio']!,
              avatarUrl: _profileData['avatarUrl']!,
            ),
          ),

          // Stats Section
          SliverToBoxAdapter(child: _StatsSection(stats: _stats)),

          // Progression par pays
          SliverToBoxAdapter(
            child: _ProgressionSection(countries: _countryProgression),
          ),

          // Mes badges
          SliverToBoxAdapter(child: _BadgesSection(badges: _badges)),

          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              tabController: _tabController,
              tabs: const ['Quêtes', 'Photos'],
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _QuestsList(quests: _quests),
                _PhotosPlaceholder(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Profile Header Widget ============
class _ProfileHeader extends StatelessWidget {
  final String name;
  final String pseudo;
  final String badge;
  final String bio;
  final String avatarUrl;

  const _ProfileHeader({
    required this.name,
    required this.pseudo,
    required this.badge,
    required this.bio,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar + Badge
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(avatarUrl),
                backgroundColor: Colors.teal.withOpacity(0.1),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Pseudo
          Text(
            pseudo,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 8),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.amber,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Bio
          Text(
            bio,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Stats Section Widget ============
class _StatsSection extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(label: 'Quêtes', value: stats['quests'].toString()),
          _StatItem(label: 'Pays', value: stats['countries'].toString()),
          _StatItem(label: 'Amis', value: stats['friends'].toString()),
          _StatItem(label: 'Followers', value: stats['followers']),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// ============ Progression Section Widget ============
class _ProgressionSection extends StatelessWidget {
  final List<Map<String, dynamic>> countries;

  const _ProgressionSection({required this.countries});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progression par pays',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigation vers liste complète
                },
                child: const Text(
                  'Voir tout',
                  style: TextStyle(color: Colors.teal),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...countries.map((country) => _CountryProgressItem(
                name: country['name'],
                flag: country['flag'],
                progress: country['progress'],
              )),
        ],
      ),
    );
  }
}

class _CountryProgressItem extends StatelessWidget {
  final String name;
  final String flag;
  final double progress;

  const _CountryProgressItem({
    required this.name,
    required this.flag,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Badges Section Widget ============
class _BadgesSection extends StatelessWidget {
  final List<Map<String, dynamic>> badges;

  const _BadgesSection({required this.badges});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mes badges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: badges.map((badge) => _BadgeItem(
                  icon: badge['icon'],
                  label: badge['label'],
                  color: badge['color'],
                )).toList(),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _BadgeItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ============ Tab Bar Delegate ============
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController tabController;
  final List<String> tabs;

  _TabBarDelegate({required this.tabController, required this.tabs});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(context, shrinkOffset, overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TabBar(
        controller: tabController,
        labelColor: Colors.teal,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.teal,
        indicatorWeight: 3,
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate old) => false;
}

// ============ Quests List Widget ============
class _QuestsList extends StatelessWidget {
  final List<Map<String, dynamic>> quests;

  const _QuestsList({required this.quests});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quests.length,
      itemBuilder: (context, index) {
        final quest = quests[index];
        return _QuestItem(
          category: quest['category'],
          title: quest['title'],
          location: quest['location'],
          date: quest['date'],
          xp: quest['xp'],
        );
      },
    );
  }
}

class _QuestItem extends StatelessWidget {
  final String category;
  final String title;
  final String location;
  final String date;
  final int xp;

  const _QuestItem({
    required this.category,
    required this.title,
    required this.location,
    required this.date,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.explore, color: Colors.teal, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(
                      location,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+$xp XP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Photos Placeholder Widget ============
class _PhotosPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Photos à venir...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}