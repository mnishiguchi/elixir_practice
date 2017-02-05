defmodule KeyValueStore do
  @moduledoc """
  A stateful key-value store that is built with the GenServer behaviour.
  """

  use GenServer

  #---
  # INTERFACE FUNCTIONS
  #---

  @doc """
  Works synchronously therefore the client process will be blocked until the
  server process is initialized.
  """
  def start do
    # Returns {:ok, pid} or {:stop, reason}
    GenServer.start(KeyValueStore, nil)
  end

  def put(pid, key, value) do
    # Returns the respoonse that is defined in handle_cast/2
    GenServer.cast(pid, { :put, key, value })
  end

  def get(pid, key) do
    # Returns the respoonse that is defined in handle_call/3
    GenServer.call(pid, { :get, key })
  end

  #---
  # GEN_SERVER CALLBACKS
  #---

  @doc """
  The first argument provides initial data to GenServer.start/2's second argument.
  Return { :ok, %{} }
  """
  def init(_initial_state) do
    { :ok, %{} }
  end

  @doc """
  Handles a put cast request (fire and forget).
  Returns { :noreply, new_state }
  """
  def handle_cast({:put, key, value}, state) do
    { :noreply, Map.put(state, key, value) }
  end

  @doc """
  Handles a get call request.
  Returns { :reply, new_state, state }
  """
  def handle_call({ :get, key }, _for_internal_use, state) do
    { :reply, Map.get(state, key), state }
  end

end

# ## USAGE
#
# iex> {:ok, pid} = KeyValueStore.start
# {:ok, #PID<0.324.0>}
# iex> pid
# #PID<0.324.0>
# iex> KeyValueStore.put(pid, :name, "Masatoshi")
# :ok
# iex> KeyValueStore.put(pid, :city, "Washington")
# :ok
# iex> KeyValueStore.get(pid, :name)
# "Masatoshi"
# iex> KeyValueStore.get(pid, :city)
# "Washington"
