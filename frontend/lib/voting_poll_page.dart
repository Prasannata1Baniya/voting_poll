import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class VotingPollPage extends StatefulWidget {
  const VotingPollPage({super.key});

  @override
  State<VotingPollPage> createState() => _VotingPollPageState();
}

class _VotingPollPageState extends State<VotingPollPage> {
  int pizzaVotes=0;
  int burgerVotes=0;
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket(){

    /*//For Android Emulator
    socket = io.io('http://10.0.2.2:3000', io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    socket.connect();*/
    socket = io.io('http://localhost:3000', io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build());

    socket.connect();

    socket.on('update_votes', (data){
      if(mounted){
        setState(() {
          pizzaVotes=data['pizza'] ?? 0;
          burgerVotes=data['burger'] ?? 0;
        });

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalVotes = pizzaVotes + burgerVotes;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'The Ultimate Food Showdown',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cast your vote live. See real-time global results below.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),

                // Voting Cards Row
                Row(
                  children: [
                    // Pizza Card
                    Expanded(
                      child: _buildVoteCard(
                        label: 'Gourmet Pizza',
                        imagePath: 'assets/pizza.jpg',
                        votes: pizzaVotes,
                        color: Colors.orangeAccent,
                        onTap: () => socket.emit('cast_vote', 'pizza'),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Burger Card
                    Expanded(
                      child: _buildVoteCard(
                        label: 'Classic Burger',
                        imagePath: 'assets/burger.jpg',
                        votes: burgerVotes,
                        color: Colors.amber,
                        onTap: () => socket.emit('cast_vote', 'burger'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Premium Scoreboard Wrapper
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLiveScoreTile('🍕 Pizza', pizzaVotes, const Color(0xFFFF6B6B)),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                      ),

                      /*// The Vertical Divider
                      const VerticalDivider(
                        color: Colors.grey,     // Color of the line
                        thickness: 1.5,         // How wide the line is
                        width: 40,              // The total invisible horizontal space around the line
                        indent: 10,             // Empty space at the top of the line
                        endIndent: 10,          // Empty space at the bottom of the line
                      ),*/

                      _buildLiveScoreTile('🍔 Burger', burgerVotes, const Color(0xFFFFBE0B)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoteCard({
    required String label,
    required String imagePath,
    required int votes,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withValues(alpha:0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveScoreTile(String label, int count, Color accentColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[500]),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: accentColor),
        ),
      ],
    );
  }
}
