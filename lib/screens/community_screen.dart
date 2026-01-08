import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../widgets/community_widgets.dart';
import '../utils/responsive.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _currentIndex = 0;
  late CommunityProvider _provider; // Store provider instance

  @override
  void initState() {
    super.initState();
    _provider = CommunityProvider(); // Create once
    _provider.fetchPosts(); // Load initial posts
  }

  @override
  void dispose() {
    _provider.dispose(); // Clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierProvider.value(
      value: _provider, // Use existing instance
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
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            CommunityView(),
            MyCommunityAccount(),
          ],
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

class MyCommunityAccount extends StatelessWidget {
  const MyCommunityAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 20),
          Text("My Community Profile", style: Theme.of(context).textTheme.titleLarge),
          const Text("Posts and stats will appear here later."),
        ],
      ),
    );
  }
}