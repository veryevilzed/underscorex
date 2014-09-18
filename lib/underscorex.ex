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
    quote location: :keep  do

      defdelegate each(col, iter), to: Enum, as: :each
      defdelegate map(col, iter), to: Enum, as: :map
      defdelegate reduce(col, acc, iter), to: Enum, as: :reduce
      defdelegate find(col, ifnone, iter), to: Enum, as: :find
      defdelegate find(col, iter), to: Enum, as: :find
      defdelegate detect(col, ifnone, iter), to: Enum, as: :find
      defdelegate detect(col, iter), to: Enum, as: :find
      defdelegate filter(col, iter), to: Enum, as: :filter
      defdelegate select(col, iter), to: Enum, as: :filter
      defdelegate reject(col, iter), to: Enum, as: :reject
      defdelegate every(col, iter), to: Enum, as: :all?
      defdelegate all(col, iter), to: Enum, as: :all?

      defdelegate some(col, iter), to: Enum, as: :any?
      defdelegate any(col, iter), to: Enum, as: :any?
      def any(col), do: any(col, &(identity &1))
      def all(col), do: all(col, &(identity &1))

      def contains(col, value), do: col |> Enum.any? fn(item) -> item == value end
      def include(col, value), do: contains(col, value)

      def invoke(col, func, args), do: col |> map fn({item, _})-> apply(func, [item] ++ args) end
      def invoke(col, {m, f, []}), do: col |> map fn({item, _})-> apply(m, f, [item]) end
      def invoke(col, {m, f, a}), do: col |> map fn({item, _})-> apply(m, f, [item] ++ a) end
      def invoke(col, func), do: col |> map fn({item, _})-> apply(func, [item]) end

      def takeitem(obj, propname) when is_map(obj), do: takeitem(obj.to_keywords, propname)
      def takeitem(obj, propname), do: Dict.get(obj, propname, nil)
      def takeitem(obj, propname, default) when is_map(obj), do: takeitem(obj.to_keywords, propname, default)
      def takeitem(obj, propname, default), do: Dict.get(obj, propname, default)

      def pluck(col, propname) when is_map(col), do: pluck(col.to_keywords, propname)
      def pluck(col, propname), do: col |> Enum.map fn(item) -> takeitem(item, propname) end
      def pluck(col, propname, default) when is_map(col), do: pluck(col.to_keywords, propname, default)
      def pluck(col, propname, default), do: col |> Enum.map fn(item) -> takeitem(item, propname, default) end

      # defdelegate at(col, index) when is_list(col), to: Enum, as: :at
      # defdelegate at(col, index, default) when is_list(col), to: Enum, as: :at
      

      def get(col, index) when is_list(col) and is_integer(index), do: Enum.at(col, index)
      # def get(col, path) when is_list(col) and is_binary(index) do
        
      # end

      def get(col, index, default) when is_list(col), do: Enum.at(col, index, default)

      def get(col, key), do: Dict.get(col, key)
      def get(col, key, default), do: Dict.get(col, key, default)

      def update(col, key, func) when is_list(col) and is_integer(key) and is_function(func), do: List.update_at(col, key, func)
      def update(col, key, item) when is_list(col) and is_integer(key), do: List.update_at(col, key, fn(x)-> item end)

      def update(col, key, func) when is_list(col) and is_function(func), do: Dict.put(col, key, func.(Dict.get(col, key, nil))) 
      def update(col, key, item) when is_list(col), do: Dict.put(col, key, item)

      def sort_by(col), do: Enum.sort col
      def sort_by(col, func), do: Enum.sort(col, func)
      def sort_by(col, func, ctx), do: Enum.sort(col, fn(x)-> func.({x, ctx}) end)

      def group_by(col, iter, ctx) do 
        reduce col, [], fn(item, res)-> 
            new_key = iter.({item, ctx})
            case Dict.has_key?(res, new_key) do
              true -> Dict.put res, new_key, res[new_key] ++ [item]
              _ -> Dict.put res, new_key, [item]
            end
          end
      end

      def group_by(col, iter) do 
        reduce col, [], fn(item, res) -> 
            new_key = iter.(item)
            case Dict.has_key?(res, new_key) do
              true -> Dict.put res, new_key, res[new_key] ++ [item]
              _ -> Dict.put res, new_key, [item]
            end
          end
      end

      def index_by(col, iter), do: group_by(col, iter) |> map fn({key, [h|_]}) -> {key, h} end
      def index_by(col, iter, ctx), do: group_by(col, iter, ctx) |> map fn({key, [h|_]}) -> {key, h} end

      def count_by(col, iter), do: group_by(col, iter) |> map fn({key, data}) -> {key, length(data)} end
      def count_by(col, iter, ctx), do: group_by(col, iter, ctx) |> map fn({key, data}) -> {key, length(data)} end

      def where(dict, args \\ []), do: filter(dict, fn({item, _})-> matches(item, args) end)
      def find_where(dict, args), do: find(dict, fn({item, _})-> matches(item, args) end)

      defdelegate max(col), to: Enum, as: :max
      defdelegate min(col), to: Enum, as: :min      
      defdelegate shuffle(col), to: Enum, as: :shuffle
      defdelegate reverse(col), to: Enum, as: :reverse

      def size(col) when is_list(col), do: length(col)
      def size(col), do: col |> Dict.keys |> length


    end
  end
end

defmodule Underscorex.Arrays do

  defmacro __using__(_options) do
    quote location: :keep  do

      defdelegate size(col), to: Kernel, as: :length
      defdelegate first(col), to: List, as: :first
      defdelegate head(col), to: List, as: :first
      defdelegate take(col), to: List, as: :first
      defdelegate last(col), to: List, as: :last
      defdelegate slice(col, s, e), to: Enum, as: :slice
      defdelegate flatten(col), to: List, as: :flatten

      def initial(col, n \\ 1), do: slice(col, 0, length(col)-n)
      def rest(col, n \\ 1), do: slice(col, n, length(col))
      def tail(col, n \\ 1), do: rest(col, n)
      def drop(col, n \\ 1), do: rest(col, n)

      def compact(col), do: col |> Enum.filter &(identity &1)
      
      def without(col, items) when is_list(items), do: Enum.reject(col, fn({key, val})-> key in items;(x)-> x in items end)
      def without(col, items), do: Enum.reject(col, fn(x)-> x == items end)
      
      def only(col, items) when is_list(items), do: Enum.filter(col, fn({key, val})-> key in items;(x)-> x in items end)
      def only(col, items), do: Enum.filter(col, fn(x)-> x == items end)


      def union(col1, col2), do: :coming_soon
      def union(cols) when is_list(cols), do: :coming_soon
      
      def intersection(col1, col2), do: :coming_soon
      def difference(col1, col2), do: :coming_soon

      def uniq(col), do: :coming_soon
      def unique(col), do: uniq(col)

      defdelegate zip(cols), to: List, as: :zip
      defdelegate zip(col1, col2), to: List, as: :zip

      def object(keys, values), do: zip(keys, values) |> Enum.reduce [], fn({key, val}, dict) -> Dict.put(dict, key, val) end

      def index_of(col, item), do: col |> Enum.find_index fn(x)-> x == item end
      def last_index_of(col, item), do: Enum.reverse(col) |> Enum.find_index fn(x)-> x == item end

      def range(start \\ 0, stop, step \\ 1), do: :coming_soon
      def sortedIndex(col, item), do: :coming_soon

    end
  end
end

defmodule Underscorex.Transform do
  defmacro __using__(_options) do
    quote do

      def integer?(bin) when is_binary(bin) do
        case Integer.parse(bin) do
          :errro -> false
          {_, ""} -> true
          _ -> false
        end
      end

      def float?(bin) when is_binary(bin) do
        case Float.parse(bin) do
          :errro -> false
          {_, ""} -> true
          _ -> false
        end
      end


      def to_integer(bin) when is_binary(bin), do: String.to_integer(bin)
      def to_integer(int) when is_integer(int), do: int

      def to_float(int) when is_integer(int), do: int * 1.0
      def to_float(bin) when is_binary(bin) do 
        {res, _} = Float.parse bin
        res
      end
      def to_float(flt) when is_float(flt), do: flt

      def to_atom(atm) when is_atom(atm), do: atm
      def to_atom(bin) when is_binary(bin), do: String.to_atom(bin)

      def to_binary(atm) when is_atom(atm), do: Atom.to_string(atm)
      def to_binary(int) when is_integer(int), do: "#{int}"
      def to_binary(bin) when is_binary(bin), do: bin

      def transform(x) do
        res = case String.first x do
          "\"" -> 
            case String.last x do
              "\"" -> String.slice x, 1, String.length(x)-2
              _ -> x
            end
          ":" -> to_atom(String.slice x, 1, String.length x)
          num ->
            case integer? x do
              true -> to_integer x
              false -> 
                case float? x do
                  true -> to_float x
                  false -> x
                end
            end
        end
        res
      end

      def binatom(x) do
        case String.first x do
          ":" -> to_atom(String.slice x, 1, String.length x)
          x -> x
        end
      end

    end
  end
end

defmodule Underscorex.Utility do
  defmacro __using__(_options) do
    quote location: :keep do

      def identity(0), do: false
      def identity(nil), do: false
      def identity(false), do: false
      def identity(""), do: false
      def identity([]), do: false
      def identity({}), do: false
      def identity(_), do: true

      def matches(obj, attrs) when obj == attrs, do: true
      def matches(obj, attrs) when is_map(obj), do: matches(obj.to_keywords, attrs)
      def matches(obj, attrs) when is_map(attrs), do: matches(obj, attrs.to_keywords)
      def matches(obj, attrs) do
        Enum.map(Dict.keys(attrs), fn(attr_keys) -> 
          case Dict.has_key? obj, attr_keys do
            false -> false
            true -> obj[attr_keys] == attrs[attr_keys]
          end
        end) |> Enum.all? &(&1)
      end
      
      def result({:ok, res}), do: res

      def result([res]), do: res
      def result(obj, attrs) when is_list(obj) and is_integer(attrs), do: Enum.fetch!(obj, attrs)
      def result(obj, attrs) when is_tuple(obj) and is_integer(attrs), do: elem(obj, attrs)
      def result(obj, attrs), do: obj[attrs]
      def result(res), do: res

    end
  end
end

defmodule Underscorex.DPath do
  defmacro __using__(_options) do
    quote location: :keep do

      defp __get(col, []), do: {:ok, col}
      defp __get(col, [h|t]) do
        case Dict.has_key?(col, h) do
          true -> __get(col[h], t)
          false -> 
            case Dict.has_key?(col, String.to_atom(h) ) do
              true -> __get(col[String.to_atom(h)], t)
              false -> {:error, :not_found}
            end
        end
      end

      def _get(col, path) when is_binary(path) and is_list(col), do: __get(col, String.split(path, "."))
      def _get(col, path, default) when is_binary(path) and is_list(col) do
        case _get(col, path) do
          {:error, :not_found} -> {:ok, default}
          res -> res
        end
      end

      def _get!(col, path, default) when is_binary(path) and is_list(col), do: _get(col, path, default) |> U.result
      def _get!(col, path) when is_binary(path) and is_list(col), do: _get(col, path) |> U.result
      
      defp __set(col, [h], item) when is_function(item), do: Dict.put(col, binatom(h), item.(col[binatom(h)]) )
      defp __set(col, [h], item) when is_list(col), do: Dict.put(col, binatom(h), item)
      defp __set(_, [_], _), do: raise "path error"
      defp __set(col, [h|t], item) do
        h = binatom(h)
        case Dict.has_key? col, h do
          true -> Dict.put(col, h, __set(col[h], t, item))
          false -> raise "path error"
        end
      end

      def _set(col, path, item) when is_binary(path) and is_list(col), do: __set(col, String.split(path, "."), item)
      def _update(col, pi), do: pi |> Enum.reduce col, fn({path, value}, acc)-> _set(acc, path, value) end

    end #quote
  end #defmacro
end #DPath

defmodule Underscorex.Functions do  
  defmacro __using__(_options) do
    quote location: :keep do

      def now do 
        {mega, secs, _} = :erlang.now()
        mega*1000000+secs
      end

      def uuid, do: uuid4
      def uuid1(pid \\ self), do: :uuid.get_v1(:uuid.new(pid)) |> uuid_to_string

      def uuid4, do: uuid4(:strong)
      def uuid4(:weak), do: :uuid.get_v4(:weak) |> uuid_to_string
      def uuid4(:strong), do: :uuid.get_v4(:strong) |> uuid_to_string
      def uuid4(:urandom), do: :uuid.get_v4_urandom |> uuid_to_string

      def uuid3(t), do: :uuid.get_v3(t) |> uuid_to_string
      def uuid5(t), do: :uuid.get_v5(t) |> uuid_to_string

      def md5(t), do: :crypto.hash(:md5, t) |> Hexagon.encode
      def sha1(t), do: :crypto.hash(:sha, t) |> Hexagon.encode
      def sha256(t), do: :crypto.hash(:sha256, t) |> Hexagon.encode
      def sha512(t), do: :crypto.hash(:sha512, t) |> Hexagon.encode

      defp uuid_to_string(uuid), do: uuid  |> :uuid.uuid_to_string |> List.to_string 

      def delay(time, func) do
        pid = spawn(fn ->
          receive do
            {:time_message, func} -> func.()
            _oth -> _oth
          end
        end)
        {pid, :erlang.send_after(time, pid, {:time_message, func})}
      end


      def delay(time, func, args) do
        pid = spawn(fn ->
          receive do
            {:time_message, func} -> apply(func, args)
            _oth -> _oth
          end
        end)
        {pid, :erlang.send_after(time, pid, {:time_message, func})}
      end


      # def triger(event, args \\ nil) do
      #   case :pg2.get_members(event) do
      #     {:error, res} -> {:error, res}
      #     pids -> Enum.each pids, fn(pid) -> send pid, { :bind_event, event, args }
      #   end
      # end

      # def bind(event, func), do: :coming_soon

    end
  end
end



defmodule U do
  use Underscorex.Utility
  use Underscorex.Iterators
  use Underscorex.Transform
  use Underscorex.Arrays
  use Underscorex.Functions 
  use Underscorex.DPath

  # LAX by d0rc

  defmodule Transformer do
    def exec({ {:., _, [Kernel, :access]}, _misc, [subj, [key]]}) do
      quote do
        U.getter(unquote(exec(subj)), unquote(exec(key)))
      end
    end
    def exec(code), do: code
  end
 
  defp scan_proplist([], _), do: nil
  defp scan_proplist([{key, value}|_rest], key), do: value
  defp scan_proplist([_|rest], key), do: scan_proplist(rest, key)
 
  def getter(subject, key) when not(is_atom(key)) and is_list(subject) do
    scan_proplist(subject, key)
  end
  def getter(subject, key) do
    Dict.get(subject, key)
  end
  defmacro la(code) do
    Transformer.exec(code)
  end

end