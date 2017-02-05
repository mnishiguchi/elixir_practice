defmodule Calculator do
  @moduledoc """
  A concurrent stateful calculator.
  """

  #---
  # INTERFACE FUNCTIONS
  #---

  @doc """
  An interface function that is used by the client to start the server process.
  Creates a long-running process that runs forever.
  Returns a PID for the spawned process.
  """
  def start do
    initial_value = 0
    spawn(fn() ->
      loop(initial_value)
    end)
  end

  # @doc """
  # Called when the client wants to get the current value.
  # """
  def value(server_pid) do
    send(server_pid, {:value, self})
    receive do
      {:response, value} ->
        value
    end
  end

  # @doc """
  # Called when the client wants to do "+" operation on the current value
  # that is stored in the specified server.
  # """
  def add(server_pid, value) do
    send(server_pid, {:add, value})
    server_pid
  end

  # @doc """
  # Called when the client wants to do "-" operation on the current value
  # that is stored in the specified server.
  # """
  def sub(server_pid, value) do
    send(server_pid, {:sub, value})
    server_pid
  end

  # @doc """
  # Called when the client wants to do "*" operation on the current value
  # that is stored in the specified server.
  # """
  def mul(server_pid, value) do
    send(server_pid, {:mul, value})
    server_pid
  end

  # @doc """
  # Called when the client wants to do "/" operation on the current value
  # that is stored in the specified server.
  # """
  def div(server_pid, value) do
    send(server_pid, {:div, value})
    server_pid
  end

  #---
  # IMPLEMENTATION FUNCTIONS
  #---

  defp loop(current_value) do
    # Wait for an incoming request and generate a new value.
    new_value = receive do

      # A getter request for getting the current value.
      {:value, caller} ->
        send(caller, {:response, current_value})
        current_value

      # Requests for arithmetic operations on the current value.
      {:add, value} -> current_value + value
      {:sub, value} -> current_value - value
      {:mul, value} -> current_value * value
      {:div, value} -> current_value / value

      # Default request handler that handles unsuported requests.
      invalid_request ->
        IO.put("Invalid request #{invalid_request}")
        current_value  # Returns the value unchanged.
    end

    # Keep the new value as a current value
    loop(new_value)
  end
end


###############
# EXPERIMENTS
###############


# alias Calculator, as: C
# pid = C.start
# pid |> C.add(100) |> C.div(20) |> C.mul(5) |> C.sub(24) |> C.value
