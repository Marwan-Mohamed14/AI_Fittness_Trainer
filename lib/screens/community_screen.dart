import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../widgets/community_widgets.dart';
import '../utils/responsive.dart';
import 'MyCommunityAccount.dart'; // Import the new page here

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _currentIndex = 0;

  // The pages to navigate between
  final List<Widget> _pages = [
    const CommunityView(),
    const MyCommunityAccount(), 
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Note: Wrapping here keeps the same Provider instance alive
    // even when switching between the Feed and the Account page.
    return ChangeNotifierProvider(
      create: (_) => CommunityProvider(),
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
            IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          ],
        ),
        body: IndexedStack( // Using IndexedStack preserves the scroll position of your feed
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed, // Best for 2-4 items
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