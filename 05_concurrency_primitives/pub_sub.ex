defmodule PubSub do
  @moduledoc """
  Basic pub-sub messaging
  """

  @doc """
  Publish a message to a given list of PIDs
  """
  def publish(message, recipients) do
    for recipient <- recipients do
      send(recipient, message)
    end
  end
end

# # Publish a message to the current process.
# iex(29)> PubSub.publish("Hello", [self])
# ["Hello"]
# iex(30)> PubSub.publish("Hello", [self])
# ["Hello"]
# iex(31)> PubSub.publish("Hello", [self])
# ["Hello"]
#
# # Flush all the messages in the queue.
# iex(32)> flush
# "Hello"
# "Hello"
# "Hello"
# :ok
