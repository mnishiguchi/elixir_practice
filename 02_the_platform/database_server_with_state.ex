defmodule DatabaseServer do
  # @@moduledoc """
  # A server process is internally sequential. It runs a loop that processes one message at a time.
  # """

  #---
  # INTERFACE FUNCTIONS
  #---

  # @doc """
  # An interface function that is used by the client to start the server process.
  # Creates a long-running process that runs forever.
  # Returns a PID for the spawned process.
  # """
  def start do
    # Start the loop concurrently.
    spawn(fn ->
      connection = :rand.uniform(1000) # Open a connection to a database.
      loop(connection)                 # Start the loop with the database connection as an argument.
    end)
  end

  # @doc """
  # Called when the client wants to execute a query.
  # """
  def run_async(server_pid, query_def) do
    send(server_pid, {:run_query, self, query_def})
  end

  # @doc """
  # Called when the client wants to get the query result.
  # """
  def get_result do
    receive do
      {:query_result, result} ->
        result
      after 5000 ->
        {:error, :timeout}
    end
  end

  #---
  # IMPLEMENTATION FUNCTIONS
  #---

  # @doc """
  # Implements an endless loop that handles incoming messages.
  # """
  defp loop(connection) do
    # NOTE: Process one message at a time.
    receive do
      {:run_query, from_pid, query_def} ->
        query_result = run_query(connection, query_def)  # Run the query, using the connection.
        send(from_pid, {:query_result, query_result})    # Send the response back to the server that sent a message.
    end

    loop(connection)  # Keep the connection in the loop by passing it in as an argument.
  end

  # @doc """
  # Simulates the query execution.
  # """
  defp run_query(connection, query_def) do
    :timer.sleep(2000)
    "Connection: #{connection} - #{query_def} result"
  end
end


###############
# EXPERIMENTS
###############


##
# START THE SERVER
#
server_pid = DatabaseServer.start

##
# A. SEQUENTIAL (One query)
#
#   2 sec * 1 => 2 sec
#
DatabaseServer.run_async(server_pid, "query 1")
DatabaseServer.get_result

##
# B. SEQUENTIAL (Multiple queries)
#
#   2 sec * 5 => 10 sec
#
1..5 |> Enum.each(fn(n) -> DatabaseServer.run_async(server_pid, "query #{n}") end)
1..5 |> Enum.map(fn(_) -> DatabaseServer.get_result end)

##
# C. CONCURRENT USING A POOL
#
#   2 sec / each => 2 sec
#
# Create 100 database-server processes and store their PIDs in a map of index to pid.
pool = for n <- 1..100,
           into: %{},
           do: { n, DatabaseServer.start }

1..5 |> Enum.each(fn(query_def) ->
  # Get a random number in the range of 1..N so that we can distribute queries
  # over a pool of database-server processes.
  server_pid = pool[:random.uniform(100) - 1]
  DatabaseServer.run_async(server_pid, query_def)
end)
1..5 |> Enum.map(fn(_) -> DatabaseServer.get_result end)
