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
      def detect(col, iter, ctx), do: find(col, iter, ctx)
      def detect(col, iter), do: find(col, iter)




      def filter(col, iter, ctx), do: col |> Enum.filter fn(item) -> iter.({item, col, ctx}) end
      def filter(col, iter), do: col |> Enum.filter fn(item) -> iter.({item, col}) end
      def select(col, iter, ctx), do: filter(col, iter, ctx)
      def select(col, iter), do: filter(col, iter)


      def reject(col, iter, ctx), do: col |> Enum.reject fn(item) -> iter.({item, col, ctx}) end
      def reject(col, iter), do: col |> Enum.reject fn(item) -> iter.({item, col}) end

      def every(col, iter, ctx), do: col |> Enum.all? fn(item) -> iter.({item, col, ctx}) end
      def every(col, iter), do: col |> Enum.all? fn(item) -> iter.({item, col}) end
      def all(col, iter, ctx), do: every(col, iter, ctx)
      def all(col, iter), do: every(col, iter)
      def all(col), do: every(col, &(Underscorex.Utility.identity &1))

      def some(col, iter, ctx), do: col |> Enum.any? fn(item) -> iter.({item, col, ctx}) end
      def some(col, iter), do: col |> Enum.any? fn(item) -> iter.({item, col}) end
      def any(col, iter, ctx), do: some(col, iter, ctx)
      def any(col, iter), do: some(col, iter)

      def contains(col, value), do: col |> any? fn(item) -> item == value end
      def include(col, value), do: contains(col, value)

      def invoke(col, func, args), do: col |> map fn({item, _})-> apply(func, [item] ++ args) end
      def invoke(col, {m, f, []}), do: col |> map fn({item, _})-> apply(m, f, [item]) end
      def invoke(col, {m, f, a}), do: col |> map fn({item, _})-> apply(m, f, [item] ++ a) end
      def invoke(col, func), do: col |> map fn({item, _})-> apply(func, [item]) end



      def takeitem(obj, propname) when is_record(obj), do: takeitem(obj.to_keywords, propname)
      def takeitem(obj, propname), do: Dict.get(obj, propname, nil)
      def takeitem(obj, propname, default) when is_record(obj), do: takeitem(obj.to_keywords, propname, default)
      def takeitem(obj, propname, default), do: Dict.get(obj, propname, default)

      def pluck(col, propname) when is_record(col), do: pluck(col.to_keywords, propname)
      def pluck(col, propname), do: col |> Enum.map fn(item) -> takeitem(item, propname) end
      def pluck(col, propname, default) when is_record(col), do: pluck(col.to_keywords, propname, default)
      def pluck(col, propname, default), do: col |> Enum.map fn(item) -> takeitem(item, propname, default) end

      def sort(col), do: Enum.sort col
      def sort(col, func), do: Enum.sort(col, func)
      def sort(col, func, ctx), do: Enum.sort(col, fn(x)-> func.({x, ctx}) end)

      # def group(col, func, ctx) do 
      #   Enum.reduce col, [], fn(item, res)-> 
      #       new_key = func.({item, ctx})
      #       case Dict.has_key?(res, new_key) do
      #         true -> 
      #           res[new_key] = res[new_key] ++ [item]
      #           res
      #         _ -> 
      #           res[new_key] = [item]
      #           res
      #       end
      #     end
      # end

      def where(dict, args \\ []), do: filter(dict, fn({item, _})-> Underscorex.Utility.matches(item, args) end)
      def find_where(dict, args), do: find(dict, fn({item, _})-> Underscorex.Utility.matches(item, args) end)

      def max(col), do: Enum.max col
      def min(col), do: Enum.min col
      def shuffle(col), do: Enum.shuffle col
      def reverse(col), do: Enum.reverse col


end

defmodule Underscorex.Arrays do

      def size(col), do: length(col)

      def first(col), do: List.first(col)
      def head(col), do: first(col)
      def take(col), do: first(col)


      def last(col), do: List.last(col)
      
      def initial(col, n \\ 1), do: Enum.slice(col, 0, length(col)-n)
      def rest(col, n \\ 1), do: Enum.slice(col, n, length(col))
      def tail(col, n \\ 1), do: rest(col, n)
      def drop(col, n \\ 1), do: rest(col, n)

      def compact(col), do: col |> Enum.filter &(Underscorex.Utility.identity &1)
      def flatten(col), do: col |> List.flatten 
      def without(col, items) when is_list(items), do: Enum.reject(col, fn(x)-> x in items end)
      def without(col, items), do: Enum.reject(col, fn(x)-> x == items end)
      def only(col, items) when is_list(items), do: Enum.filter(col, fn(x)-> x in items end)
      def only(col, items), do: Enum.filter(col, fn(x)-> x == items end)

      def union(col1, col2), do: :coming_soon
      def union(cols) when is_list(cols), do: :coming_soon
      def intersection(col1, col2), do: :coming_soon
      def difference(col1, col2), do: :coming_soon

      def uniq(col), do: :coming_soon
      def unique(col), do: uniq(col)

      def zip(cols), do: List.zip(cols)
      def zip(col1, col2), do: Enum.zip(col1, col2)

      def object(keys, values), do: zip(keys, values) |> Enum.reduce [], fn({key, val}, dict) -> Dict.put(dict, key, val) end

      def index_of(col, item), do: col |> Enum.find_index fn(x)-> x == item end
      def last_index_of(col, item), do: Enum.reverse(col) |> Enum.find_index fn(x)-> x == item end

      def range(start // 0, stop, step // 1), do: :coming_soon
      def sortedIndex(col, item), do: :coming_soon

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
      def identity([]), do: false
      def identity({}), do: false
      def identity(_), do: true

      def matches(obj, attrs) when obj == attrs, do: true
      def matches(obj, attrs) when is_record(obj), do: matches(obj.to_keywords, attrs)
      def matches(obj, attrs) when is_record(attrs), do: matches(obj, attrs.to_keywords)
      def matches(obj, attrs) do
         Enum.map(Dict.keys(attrs), fn(attr_keys) -> 
          case Dict.has_key? obj, attr_keys do
            false -> false
            true -> obj[attr_keys] == attrs[attr_keys]
          end
        end) |> Enum.all? &(&1)
      end

      def result(obj, attrs) when is_list(obj) && is_integer(attrs), do: Enum.fetch!(obj, attrs)
      def result(obj, attrs) when is_tuple(obj) && is_integer(attrs), do: elem(obj, attrs)
      def result(obj, attrs), do: obj[attrs]

end

defmodule U do

  use Underscorex.Utility
  use Underscorex.Iterators

end

