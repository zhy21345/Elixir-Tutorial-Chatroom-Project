defmodule ChatClient do
  require Logger

  # listen message from server, also use recv for handling disconnection
  defp receive_message(socket) do
    case recv(socket) do
      {:ok, message} ->
        IO.puts(message)
        receive_message(socket)
      _ ->
        Logger.info("Disconnected from the server")
    end
  end

  # recive case handler, error if disconnect
  defp recv(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> {:ok, String.trim(data)}
      {:error, _reason} -> {:error}
    end
  end

  # use tcp send
  defp send_message(socket, message) do
    :gen_tcp.send(socket, message)
  end

  # use this function to connect to test server, it is hardcoded at 4040
  def join_chatroom do
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, [:binary, active: false])

    IO.puts("Welcome to the chat room!")
    IO.puts("Please enter your username: ")
    username = IO.gets("") |> String.trim()

    # in the client handler, it will get the username and start a new loop with this username,
    # this specific part is causing an unsolved error
    send_message(socket, username)

    # also a loop handler, for safety purpose also use multithread here although technially
    # there's only one thread connecting to server
    spawn(fn ->
      loop(socket)
    end)

    # accept message besides message sent
    receive_message(socket)
  end

  # loop handler for broadcast or other message
  defp loop(socket) do
    # send whatever writen here to the server
    message = IO.gets("") |> String.trim()

    send_message(socket, message)

    loop(socket)
  end
end
