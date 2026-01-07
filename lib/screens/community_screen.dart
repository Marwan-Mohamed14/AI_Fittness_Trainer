import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/community_provider.dart';
import '../widgets/community_widgets.dart';
import '../utils/responsive.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommunityProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Text("Community", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          ],
        ),
        body: const CommunityView(),
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

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
      itemCount: provider.posts.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return const CreatePostSection();
        return SocialPostCard(post: provider.posts[index - 1]);
      },
    );
  }
}