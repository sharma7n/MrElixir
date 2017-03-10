# v3: Distribute across map and reduce.
# Run time is O(n / # processes) == O(chunk size)
# Try changing @chunk_size and see how long it takes

defmodule MapReduce do
    @chunk_size 1
    
    defp process(chunk) do
        # distributes map and reduce steps across each chunk using spawn
        master = self()
        spawn fn ->
            result = chunk
                |> Enum.map(fn x ->
                        :timer.sleep(1000) # map is expensive
                        x * 2 
                    end)
                |> Enum.reduce(0, fn x, acc -> 
                        :timer.sleep(1000) # reduce is expensive
                        x + acc 
                    end)
            send master, {:ok, result}
        end
        nil
    end
    
    defp total(data) do
        # resolves calculations in the master process
        Enum.reduce(data, 0, fn _, total -> 
            receive do
                {:ok, count} -> count + total
            end
        end)
    end
    
    def run(data) do
        divided_data = Enum.chunk(data, @chunk_size)
        Enum.each(divided_data, fn chunk -> process chunk end)
        total divided_data
    end
end

result = MapReduce.run 1..50
IO.inspect result