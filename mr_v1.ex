# v1: Introducing distributed processing (on map).

defmodule MapReduce do
    defp map(data) do
        master = self() # save reference to current process
        Enum.each(data, fn x ->
            spawn fn ->
                :timer.sleep(1000) # simulate expensive calculation
                mapped = x * 2
                send master, {:ok, mapped}
            end 
        end)
    end
    
    defp reduce(data) do
        Enum.reduce(data, 0, fn _, total -> 
            receive do
                {:ok, count} -> count + total
            end
        end)
    end
    
    def run(data) do
        data |> map
        reduce data
    end
end

result = MapReduce.run [1, 2, 3]
IO.inspect result