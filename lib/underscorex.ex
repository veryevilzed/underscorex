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
      def find(col, ifnone, iter), do: col |> Enum.find ifnone, fn(item)-> iter.({item, col}) end
      def find(col, iter), do: col |> Enum.find fn(item)-> iter.({item, col}) end
      
      def filter(col, iter, ctx), do: col |> Enum.filter fn(item) -> iter.({item, col, ctx}) end
      def filter(col, iter), do: col |> Enum.filter fn(item) -> iter.({item, col}) end

      def reject(col, iter, ctx), do: col |> Enum.reject fn(item) -> iter.({item, col, ctx}) end
      def reject(col, iter), do: col |> Enum.reject fn(item) -> iter.({item, col}) end

      def every(col, iter, ctx), do: col |> Enum.all? fn(item) -> iter.({item, col, ctx}) end
      def every(col, iter), do: col |> Enum.all? fn(item) -> iter.({item, col}) end
      def all?(col, iter, ctx), do: every(col, iter, ctx)
      def all?(col, iter), do: every(col, iter)

      def some(col, iter, ctx), do: col |> Enum.any? fn(item) -> iter.({item, col, ctx}) end
      def some(col, iter), do: col |> Enum.any? fn(item) -> iter.({item, col}) end
      def any?(col, iter, ctx), do: some(col, iter, ctx)
      def any?(col, iter), do: some(col, iter)

      def contains(col, value), do: col |> any? fn(item) -> item == value end
      def include(col, value), do: contains(col, value)

      def invoke(col, func, args \\ []), do: col |> map fn({item, _})-> apply(func, [item] ++ args) end
      def invoke(col, {m, f, []}), do: col |> map fn({item, _})-> apply(m, f, [item]) end
      def invoke(col, {m, f, a}), do: col |> map fn({item, _})-> apply(m, f, [item] ++ a) end


end

defmodule Underscorex.Utility do
  defmacro __using__(_options) do
    quote do
    end
  end

      def identity(0), do: false
      def identity(nil), do: false
      def identity(false), do: false
      def identity(""), do: false
      #def identity(''), do: false
      def identity([]), do: false
      def identity({}), do: false
      #def identity(<<"">>), do: false
      def identity(_), do: true

end

defmodule U do

  use Underscorex.Utility
  use Underscorex.Iterators

end

