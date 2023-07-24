defmodule ChatServer do
  require Logger

  # use this function to start a server in the kernal, keep running for further listen
  def start_link do
    {:ok, pid} = Task.start_link(fn -> run() end)
    {:ok, pid}
  end

  # default listen to local machine, listen to chat_server.join_chatroom
  defp run do
    {:ok, socket} = :gen_tcp.listen(4040, [:binary, active: false])
    Logger.info("Server started, listening on port 4040")

    accept_connections(socket)
  end

  # main handler for listening to connection, multithread by different connection
  defp accept_connections(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.info("Accepted new client connection")

    # when listening to a connection, make a new thread to allow multile client
    spawn(fn ->
      handle_client(client)
    end)
    Logger.info("accept_connections: on make new thread 1")
    accept_connections(socket)
  end

  # send welcome message to affirm connection, loop handler to listean and broadcast user's input
  defp handle_client(socket) do
    send_message(socket, "Welcome to the chat room!\nPlease enter your username: ")
    Logger.info("handle_client: on listen client 1")

    # successfully receive, other case err message
    # [CRITICAL] Unsolved CaseClauseError: recv/1 should return {:ok, data}, returned :ok instead
    case recv(socket) do
      {:ok, username} ->
        Logger.info("#{username} joined the chat")
        broadcast_message("#{username} joined the chat")
        Logger.info("handle_client: on listen to client 2")

        # keep listening to user input
        loop(socket, username)
      {:error} ->
        Logger.info("Disconnected from the client")
    end
  end

  # if successfully connect, broadcast user input to other client, close if no longer connected, track by username
  defp loop(socket, username) do
    Logger.info("loop: on listen to client 1")
    case recv(socket) do
      {:ok, message} ->
        Logger.info("loop: on listen to client 2")
        broadcast_message("#{username}: #{message}")
        loop(socket, username)
      {:error} ->
        Logger.info("#{username} left the chat")
        broadcast_message("#{username} left the chat")
    end
  end

  # recive case handler, error if disconnect
  defp recv(socket) do
    Logger.info("recv: on listen to client 1")
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} ->
        # Logger.info("recv: message as #{data} [case :ok]")
      {:ok, String.trim(data)}
      {:error, _reason} ->
        # Logger.info("recv: message as error [case :error]")
        {:error}
    end
    Logger.info("recv: on listen to client 2")
  end

  # use tcp send
  defp send_message(socket, message) do
    :gen_tcp.send(socket, message)
    Logger.info("send_message: on send to client 1")
  end

  # for every related sockets, send message
  defp broadcast_message(message) do
    sockets = Process.whereis(ChatServer)
    Logger.info("broadcast_message: on listen to client 1")

    # an enumerate method to handle each related server
    if sockets do
      Logger.info("broadcast_message: on listen to client 2")
      Enum.each(sockets, fn pid ->
        send_message(pid, message)
      end)
    end
  end
end
