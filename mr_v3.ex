# v3: Distribute across map and reduce.
# If map = O(f(n)) and reduce = O(g(n)), then map |> reduce is O(f(n) + g(n))
# MapReduce changes this to O(f(chunk_size) + g(chunk_size) + g(n / chunk_size))
# Try changing @chunk_size and see how long it takes

defmodule Benchmark do
  def measure(function) do
    function |> :timer.tc |> elem(0) |> Kernel./(1_000_000)
  end
end

defmodule MapReduce do
    @chunk_size 2
    
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
                        :timer.sleep(500) # reduce is expensive
                        x + acc 
                    end)
            send master, {:ok, result}
        end
        nil
    end
    
    defp total(data) do
        # resolves calculations in the master process
        Enum.reduce(data, 0, fn _, total ->
            :timer.sleep(500) # total is also expensive
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

IO.inspect Benchmark.measure(fn -> MapReduce.run 1..10 end)