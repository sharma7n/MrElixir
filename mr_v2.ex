# v2: Distribute processing on reduce step, instead.

defmodule MapReduce do
    defp map(data), do: Enum.map(data, fn x -> x * 2 end)
    defp divide(data), do: Enum.chunk(data, 1)
    
    defp reduce(data) do
        master = self()
        Enum.each(data, fn chunk ->
            spawn fn ->
                :timer.sleep(1000)
                one_chunk_result = Enum.reduce(chunk, 0, fn x, acc -> x + acc end)
                send master, {:ok, one_chunk_result}
            end
        end)
    end
    
    defp total(data) do
        Enum.reduce(data, 0, fn _, total -> 
            receive do
                {:ok, count} -> count + total
            end
        end)
    end
    
    def run(data) do
        mapped_data = data |> map |> divide
        reduce mapped_data
        total mapped_data
    end
end

result = MapReduce.run [1, 2, 3]
IO.inspect result