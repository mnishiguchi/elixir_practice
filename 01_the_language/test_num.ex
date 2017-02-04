defmodule TestNumber do
  def test(x) when is_number(x) and x < 0, do: :negative
  def test(0), do: :zero
  def test(x) when is_number(x) and x > 0, do: :positive
  def test(_), do: {:error, :invalid_input}
end

# A Lambda version of TestNumber
# test_number_fun = fn
#   (x) when is_number(x) and x < 0 ->
#     :negative
#   (0) -> :zero
#   (x) when is_number(x) and x > 0 ->
#     :positive
#   (_) -> {:error, :invalid_input}
# end
