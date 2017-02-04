defmodule LineCounter do
  def count(path) do
    File.read(path)
    |> line_number
  end

  defp line_number({:ok, contents}) do
    contents
    |> String.split("\n")
    |> length
  end

  defp line_number(error), do: error
end
