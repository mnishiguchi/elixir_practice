defmodule TodoList do
  # Describe the structure of the TodoList.
  defstruct auto_id: 1, entries: %{}

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
    entry
  ) do

    entry       = Map.put(entry, :id, auto_id)      # Set the new id.
    new_entries = Map.put(entries, auto_id, entry)  # Add the new entry to the list.

    # Update the struct and return.
    %TodoList{todo_list | entries: new_entries, auto_id: auto_id + 1 }
  end

  # Returns a list of entries that match with the specified date.
  def entries(
    %TodoList{ entries: entries },
    date
  ) do

    entries
    |> Stream.filter(
         fn({_, entry}) -> entry[:date] == date end) # Filter entries for specified date.
    |> Enum.map(
         fn({_, entry}) -> entry end) # Return a list of results
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

# # USAGE
#
# todo_list = TodoList.new |>
# TodoList.add_entry( %{ date: {2017, 1, 31}, title: "Dinner with wife" }) |>
# TodoList.add_entry( %{ date: {2017, 2, 1}, title: "Elixir" }) |>
# TodoList.add_entry( %{ date: {2017, 2, 1}, title: "Phoenix" })
# # %TodoList{
# #   auto_id: 4,
# #   entries: %{1 => %{date: {2017, 1, 31}, id: 1, title: "Dinner with wife"},
# #              2 => %{date: {2017, 2, 1}, id: 2, title: "Elixir"},
# #              3 => %{date: {2017, 2, 1}, id: 3, title: "Phoenix"}}}
#
# TodoList.entries( todo_list, {2017, 2, 1})
# # [%{date: {2017, 2, 1}, id: 2, title: "Elixir"},
# #  %{date: {2017, 2, 1}, id: 3, title: "Phoenix"}]
