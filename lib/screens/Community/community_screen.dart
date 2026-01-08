import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/community_widgets.dart';
import '../../utils/responsive.dart';
import 'MyCommunityAccount.dart'; // Your real account page

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _currentIndex = 0;
  late final CommunityProvider _provider; // Single instance

  @override
  void initState() {
    super.initState();
    // Create ONE provider instance for the entire screen
    _provider = CommunityProvider();
    // Pre-load community posts when screen opens
    _provider.fetchPosts();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  // The two tabs
  final List<Widget> _pages = const [
    CommunityView(),
    MyCommunityAccount(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _provider, // Use the same instance for both tabs
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: AppBar(
          title: Text(
            _currentIndex == 0 ? "Community" : "My Account",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (_currentIndex == 0)
              IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ],
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Optional: Load my posts when switching to Account tab
            if (index == 1) {
              _provider.fetchMyPosts();
            }
          },
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.group_outlined),
              activeIcon: Icon(Icons.group),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}

class CommunityView extends StatelessWidget {
  const CommunityView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CommunityProvider>();
    final padding = Responsive.padding(context);

    if (provider.isLoading && provider.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchPosts(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
        itemCount: provider.posts.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return const CreatePostSection();
          return SocialPostCard(post: provider.posts[index - 1]);
        },
      ),
    );
  }
}