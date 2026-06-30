const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

// Initialize Express app and HTTP server
const app = express();
const server = http.createServer(app);

const io = new Server(server, {
    cors: {
        origin: "*",
        methods: ["GET", "POST"]
    }
});

app.get('/', (req, res) => {
    res.send('Socket.io server is running!');
});

let voteData = { pizza: 0, burger: 0 };

const votedUsers = new Set();

io.on('connection', (socket) => {
    console.log(`User connected: ${socket.id}`);

    socket.emit('update_votes', voteData);

    socket.on('cast_vote', (choice) => {

        if (votedUsers.has(socket.id)) {
            console.log(`🚫 Blocked: User ${socket.id} tried to vote again!`);

            socket.emit('vote_error', 'You have already cast your vote!');
            return;
        }

        if (voteData[choice] !== undefined) {
            voteData[choice]++;

            votedUsers.add(socket.id);
        }

        io.emit('update_votes', voteData);
    });

    socket.on('disconnect', () => {
        console.log(`❌ User disconnected: ${socket.id}`);
        // votedUsers.delete(socket.id);
    });
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`🚀 Server running on http://localhost:${PORT}`);
});