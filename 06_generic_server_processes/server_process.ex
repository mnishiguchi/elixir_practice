defmodule ServerProcess do

  @doc """
  Starts a server process using the provided callback module.
  Takes a module atom as an argument.
  Returns the server pid.
  """
  def start(callback_module) do
    spawn(fn ->
      # Get an initial state using a callback function.
      initial_state = callback_module.init
      loop(callback_module, initial_state)
    end)
  end

  @doc """
  Handles messages using the provided callback module.
  """
  def loop(callback_module, current_state) do
    receive do
      # Handle a call request (synchronous request).
      {:call, request, caller} ->
        # Handle the message.
        # The callback function returns the esponse and new state.
        {response, new_state} = callback_module.handle_call(request, current_state)

        # Send the response back to the caller.
        send(caller, {:response, response})

        # Continue the loop with the new state.
        loop(callback_module, new_state)

      # Handle a cast request (asynchronous request).
      {:cast, request} ->
        # Handle the message.
        # The callback function returns the esponse and new state.
        new_state = callback_module.handle_cast(request, current_state)

        # Continue the loop with the new state.
        loop(callback_module, new_state)
    end
  end

  @doc """
  Issues a synchronous request to a server process.
  """
  def call(server_pid, request) do
    # Send a call message to the specified server.
    message = {:call, request, self}
    send(server_pid, message)

    # Wait for a response.
    receive do
      # Return a response.
      {:response, response} ->
        response
    end
  end

  @doc """
  Issues a fire-and-forget asynchronous request to a server process.
  """
  def cast(server_pid, request) do
    # Send a cast message to the specified server.
    message = {:cast, request}
    send(server_pid, message)
  end
end


defmodule KeyValueStore do

  #---
  # INTERFACE FUNCTIONS
  #---

  def start do
    ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, value) do
    ServerProcess.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
    ServerProcess.call(pid, {:get, key})
  end

  #---
  # FUNCTIONS THAT INTERACT WITH SERVER PROCESS
  #---

  def init, do: %{}

  @doc """
  Handles a put call request.
  Returns {response, new_state}
  """
  def handle_call({:put, key, value}, state) do
    response  = :ok
    new_state = Map.put(state, key, value)
    {response, new_state}
  end

  @doc """
  Handles a get call request.
  Returns {response, new_state}
  """
  def handle_call({:get, key}, state) do
    response  = Map.get(state, key)
    new_state = state
    {response, new_state}
  end

  @doc """
  Handles a put cast request.
  Returns new_state of Map type
  """
  def handle_cast({:put, key, value}, state) do
    Map.put(state, key, value) # Return the new state.
  end
end

# ---
# USAGE
# - Directly interacting with a generic server.
# ---

# iex> pid = ServerProcess.start(KeyValueStore)
# #PID<0.123.0>
# iex> ServerProcess.call(pid, {:put, :name, "Masatoshi"})
# :ok
# iex> ServerProcess.cast(pid, {:put, :city, "Washington"})
# :ok
# iex> ServerProcess.call(pid, {:get, :name})
# "Masatoshi"
# iex> ServerProcess.call(pid, {:get, :city})
# "Washington"

# ---
# USAGE
# - Calling through a wrapper functions that are implemented in KeyValueStore module.
# ---

# iex> pid = KeyValueStore.start
# #PID<0.118.0>
# iex> KeyValueStore.put(pid, :name, "Masatoshi")
# :ok
# iex> KeyValueStore.get(pid, :name)
# "Masatoshi"
