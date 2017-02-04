defmodule Fraction do
  defstruct a: nil, b: nil  # A struct may exist only in a module.

  def new(a, b) do
    %Fraction{a: a, b: b}
  end

  def value(%Fraction{a: a, b: b}) do
    a / b
  end

  def add(f1, f2) do
    new_a = f1.a * f2.b + f2.a * f1.b
    new_b = f1.b * f2.b
    new(new_a, new_b)
  end
end
