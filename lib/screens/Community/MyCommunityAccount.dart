// File: lib/screens/community/MyCommunityAccount.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/community_provider.dart';
import '../../widgets/community_widgets.dart'; // Contains SocialPostCard
import '../../utils/responsive.dart';

class MyCommunityAccount extends StatefulWidget {
  const MyCommunityAccount({super.key});

  @override
  State<MyCommunityAccount> createState() => _MyCommunityAccountState();
}

class _MyCommunityAccountState extends State<MyCommunityAccount> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load only my posts when entering this tab
    final provider = context.read<CommunityProvider>();
    provider.fetchMyPosts().then((_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }).catchError((error) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load posts: $error')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<CommunityProvider>();
    final padding = Responsive.padding(context);

    return Scaffold(
      
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => provider.fetchMyPosts(),
              child: provider.myPosts.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            "No posts yet.\nCreate your first one!",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
                      itemCount: provider.myPosts.length,
                      itemBuilder: (context, index) {
                        final post = provider.myPosts[index];
                        return SocialPostCard(
                          post: post,
                          showDelete: true, // Delete button visible only here
                        );
                      },
                    ),
            ),
    );
  }
}