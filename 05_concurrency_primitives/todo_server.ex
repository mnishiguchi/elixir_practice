defmodule TodoServer do

  #---
  # INTERFACE FUNCTIONS
  #---

  def start do
    initial_state = TodoList.new

    spawn(fn() ->
      loop(initial_state)
    end)
  end

  def add_entry(server_pid, new_entry) do
    send(server_pid, {:add_entry, new_entry})
  end

  def find_by_date(server_pid, date) do
    send(server_pid, {:find_by_date, self, date})

    receive do
      {:entries, entries} ->
        entries
      after 5000 ->
        {:error, :timeout}
    end
  end

  def all_entries(server_pid) do
    send(server_pid, {:all_entries, self})

    receive do
      {:entries, entries} ->
        entries
      after 5000 ->
        {:error, :timeout}
    end
  end

  def update_entry(server_pid, todo_id, updater_fun) do
    send(server_pid, {:update_entry, self, todo_id, updater_fun})

    receive do
      {:entries, entries} ->
        entries
      after 5000 ->
        {:error, :timeout}
    end
  end

  #---
  # IMPLEMENTATION FUNCTIONS
  #---

  defp loop(todo_list) do
    
    new_todo_list = receive do
      # NOTE: Ensure that process_message function returns a new todo list.
      message -> process_message(todo_list, message)
    end

    IO.puts("+++ prev +++")
    IO.inspect(todo_list)
    IO.puts("+++ next +++")
    IO.inspect(new_todo_list)

    loop(new_todo_list)
  end

  defp process_message(todo_list, {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end

  defp process_message(todo_list, {:find_by_date, caller, date}) do
    send(caller, {:entries, TodoList.find_by_date(todo_list, date)})
    todo_list  # State remains unchanged.
  end

  defp process_message(todo_list, {:update_entries, caller, todo_id, updater_fun}) do
    send(caller, {:entries, TodoList.update_entry(todo_list, todo_id, updater_fun)})
  end

  defp process_message(todo_list, {:all_entries, caller}) do
    send(caller, {:entries, TodoList.all_entries(todo_list)})
    todo_list  # State remains unchanged.
  end
end


defmodule TodoList do
  defstruct auto_id: 1, entries: %{}

  @moduledoc """
  Data structure
    %TodoList{ entries: entries, auto_id: auto_id } = todo_list
    %{ date: date, title: title }                   = entry
  """

  # Create a new TodoList instance with no entry.
  def new, do: %TodoList{}

  # Create a new TodoList instance with multiple entries.
  def new(entries \\ []) do
    Enum.reduce(
      entries,                           # A list of entries
      %TodoList{},                       # The initial accumulator value
      fn(entry, todo_list_acc) ->        # A lambda that updates the accumulator
        add_entry(todo_list_acc, entry)
      end
      # &add_entry(&2, &1)   # Shorthand
    )
  end

  # Add an entry to an existing TodoList instance.
  def add_entry(
    %TodoList{ entries: entries, auto_id: auto_id } = todo_list,
    %{ date: _date, title: _title }                 = entry
  ) do

    entry       = Map.put(entry, :id, auto_id)      # Set the new id.
    new_entries = Map.put(entries, auto_id, entry)  # Add the new entry to the list.

    # Update the struct and return.
    %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1 }
  end

  # Returns a list of entries that match with the specified date.
  def find_by_date(
    %TodoList{ entries: entries } = todo_list,
    date
  ) do

    entries
    |> Stream.filter(
         fn({_, entry}) -> entry[:date] == date end) # Filter entries for specified date.
    |> Enum.map(
         fn({_, entry}) -> entry end) # Return a list of results
  end

  # Returns all entries.
  def all_entries(%TodoList{ entries: entries } = todo_list) do
    entries
  end

  # Update an existing TodoList instance.
  def update_entry(
    %TodoList{ entries: entries } = todo_list,  # an instance of TodoList
    entry_id,                                   # the id of the entry that we want to update_entry
    updater_fun                                 # an updater lambda
  ) do

    case entries[entry_id] do
      nil -> todo_list
      old_entry ->
        new_entry = %{} = updater_fun.(old_entry)  # Ensure that updater_fun returns a map.
        new_entries = Map.put(entries, new_entry.id, new_entry)
        %TodoList{ todo_list | entries: new_entries }
    end
  end
end
