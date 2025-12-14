import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: CircleAvatar(
                backgroundColor: Color(0xFF1E2230),
                child: Icon(Icons.account_box_rounded, color: Colors.white),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Welcome, Alex!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Let's crush today's goals.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Color(0xFF1E2230),
              child: Icon(Icons.notifications, color: Colors.white),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: const [
                _CalendarCard(),
                SizedBox(height: 20),
                _WeeklyCheckInCard(),
                SizedBox(height: 20),
                _NearestGymCard(),
                SizedBox(height: 20),
                _BottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================
// Calendar Card
// =============================
class _CalendarCard extends StatelessWidget {
  const _CalendarCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            'October 2023',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((e) => Text(e, style: TextStyle(color: Colors.grey)))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DayItem(day: '29', status: DayStatus.done),
              _DayItem(day: '30', status: DayStatus.done),
              _DayItem(day: '1', status: DayStatus.done),
              _DayItem(day: '2', status: DayStatus.missed),
              _DayItem(day: '3', status: DayStatus.done),
              _DayItem(day: '4', status: DayStatus.done),
              _DayItem(day: '5', status: DayStatus.active),
            ],
          ),
        ],
      ),
    );
  }
}

enum DayStatus { done, missed, active }

class _DayItem extends StatelessWidget {
  final String day;
  final DayStatus status;

  const _DayItem({required this.day, required this.status});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: status == DayStatus.active
              ? Colors.deepPurple
              : const Color(0xFF0F111A),
          child: Text(
            day,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(height: 6),
        if (status == DayStatus.done)
          const Icon(Icons.check, color: Colors.green, size: 14)
        else if (status == DayStatus.missed)
          const Icon(Icons.close, color: Colors.red, size: 14),
      ],
    );
  }
}

// =============================
// Weekly Check-in
// =============================
class _WeeklyCheckInCard extends StatelessWidget {
  const _WeeklyCheckInCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2230),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: const [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.deepPurple,
                      child: Icon(Icons.auto_graph, size: 12, color: Colors.white),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Weekly Check-in',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Log your weight & height to refine your AI plan.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Log Stats'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b',
              width: 90,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================
// Nearest Gym (BUTTON)
// =============================
class _NearestGymCard extends StatelessWidget {
  const _NearestGymCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        // Navigate to gym map
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.55),
          ),
          child: Row(
            children: const [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Find Nearest Gym',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '1.2 mi away • Open until 11 PM',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_forward, color: Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================
// Bottom Actions (BUTTONS)
// =============================
class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _ActionCard(
            icon: Icons.restaurant,
            title: 'Update Diet',
            subtitle: 'Adjust calories',
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: _ActionCard(
            icon: Icons.groups,
            title: 'Community',
            subtitle: "See what's new",
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        // Handle navigation
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2230),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.deepPurple),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================
// Bottom Navigation
// =============================
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0F111A),
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Workout'),
        BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Diet'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}