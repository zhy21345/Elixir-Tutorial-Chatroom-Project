# Chatroom

A personal tutorial project on testing the functional programing feature of Elixir.

# System Explained

Uses a multi-thread server system that broadcast a connected client's message to simulate a chatroom.

# Pseudo Code Flow

Server.start_link
Server.accept
Client.join_chat
Client.send_username
Server.handle_client*
Server.loop
Client.send_message
Server.broadcast

# Unsolved Problem

Currently unsolved issue in Server.handle_client/1, where recv/1 cannot return client sent message {:ok, data}, CaseClauseError.
However, debug message indicates that recv/1 did capture data and returned {:ok, data}, still problem exists
