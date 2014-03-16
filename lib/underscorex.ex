defmodule Underscorex.Iterators do
  @moduledoc """
  Проходит по всему списку элементов, вызывая для каждого из 
  них функцию iterators, которая будет вызвана в контексте ctx,
  если он был передан. При каждом вызове в iter будут переданы 
  3 аргумента: ({element, ctx, index}). 
  В случае, если list является dict объектом, то в iter будут переданы
  ({value, ctx, key})
  """
  defmacro __using__(_options) do
    quote do
    end
  end
      
      def is_dict(dict), do: is_record(dict, HashDict)

      def each(col, iter, ctx), do: col |> Enum.each fn(item) -> iter.({item, col, ctx}) end
      def each(col, iter), do: col |> Enum.each fn(item) -> iter.({item, col}) end
    
      def map(col, iter, ctx), do: col |> Enum.map fn(item) -> iter.({item, col, ctx}) end
      def map(col, iter), do: col |> Enum.map fn(item) -> iter.({item, col}) end

      def reduce(col, acc, iter, ctx), do: col |> Enum.reduce acc, fn(item, acc) -> iter.({item, acc, col, ctx}) end      
      def reduce(col, iter, ctx) when is_function(iter), do: col |> Enum.reduce fn(item, acc) -> iter.({item, acc, col, ctx}) end
      def reduce(col, acc, iter), do: col |> Enum.reduce acc, fn(item, acc) -> iter.({item, acc, col}) end
      def reduce(col, iter), do: col |> Enum.reduce fn(item, acc) -> iter.({item, acc, col}) end

      def find(col, ifnone, iter, ctx), do: col |> Enum.find ifnone, fn(item)-> iter.({item, col, ctx}) end
      def find(col, iter, ctx) when is_function(iter), do: col |> Enum.find fn(item)-> iter.({item, col, ctx}) end
      def find(col, ifnone, iter), do: col |> Enum.find ifnone, fn(item)-> iter.({item, col, ctx}) end
      def find(col, iter), do: col |> Enum.find fn(item)-> iter.({item, col}) end
      
      

end

defmodule U do
  use Underscorex.Iterators
end

