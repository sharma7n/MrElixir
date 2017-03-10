# v0: No distributed processing.

defmodule MapReduce do
    defp map(data), do: Enum.map(data, fn x -> x*2 end)
    defp reduce(data), do: Enum.reduce(data, 0, fn x, acc -> x + acc end)
    def run(data), do: data |> mapper |> reducer
end

result = MapReduce.run [1, 2, 3]
IO.inspect result