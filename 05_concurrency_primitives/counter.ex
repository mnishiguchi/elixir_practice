defmodule Counter do
  def start(initial_count) do
    loop(initial_count)
  end

  defp loop(current_count) do
    new_count = receive do
      :increment -> current_count + 1
      :decrement -> current_count - 1
    end

    IO.puts(new_count)
    loop(new_count)
  end
end

# iex(14)> counter = spawn(Counter, :start, [0])
# #PID<0.121.0>
# iex(15)> send(counter, :increment)
# 1
# :increment
# iex(16)> send(counter, :increment)
# 2
# :increment
# iex(17)> send(counter, :increment)
# 3
# :increment
# iex(18)> send(counter, :decrement)
# 2

# https://startlearningelixir.com/elixir-for-rubyists
#
# This pattern is so commonly used, that it is provided by the following reusable abstractions available in Elixir and OTP:
#
# Agent     - Simple wrappers around state.
# GenServer - Generic servers (processes) that encapsulate state, provide sync and async calls, support code reloading, and more.
# Task      - Asynchronous units of computation that allow spawning a process and potentially retrieving its result at a later time.
