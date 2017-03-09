# v0: No distributed processing.

defmodule MapReduce do
    defp mapper(data) do
        Enum.map(data, fn x -> x*2 end)
    end
    
    defp reducer(data) do
        Enum.reduce(data, 0, fn x, acc -> x + acc end)
    end
    
    def run(data) do
        data |> mapper |> reducer
    end
end

result = MapReduce.run [1, 2, 3]
IO.inspect result