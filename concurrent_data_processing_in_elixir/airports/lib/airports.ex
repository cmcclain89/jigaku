defmodule Airports do
  @moduledoc """
  Documentation for `Airports`.
  """
  alias NimbleCSV.RFC4180, as: CSV

  @doc """
  Hello world.

  ## Examples

      iex> Airports.hello()
      :world

  """
  def hello do
    :world
  end

  def open_airports_old() do
    airports_csv()
    |> File.read!()
    |> CSV.parse_string()
    |> Enum.map(fn row ->
      %{
        id: Enum.at(row, 0),
        type: Enum.at(row, 2),
        name: Enum.at(row, 3),
        country: Enum.at(row, 8)
      }
    end)
    |> Enum.reject(&(&1.type == "closed"))
  end

  def open_airports() do
    window = Flow.Window.trigger_every(Flow.Window.global(), 1000)

    airports_csv()
    |> File.stream!()
    # |> Stream.map(fn event ->
    #   Process.sleep(Enum.random([0, 0, 0, 1]))
    #   event
    # end)
    |> Flow.from_enumerable()
    |> Flow.map(fn row ->
      [row] = CSV.parse_string(row, skip_headers: false)

      %{
        id: Enum.at(row, 0),
        type: Enum.at(row, 2),
        name: Enum.at(row, 3),
        country: Enum.at(row, 8)
      }
    end)
    |> Flow.reject(&(&1.type == "closed"))
    |> Flow.partition(window: window, key: {:key, :country})
    |> Flow.group_by(& &1.country)
    |> Flow.on_trigger(fn acc, _partition_info, {_type, _id, trigger} ->
      # Show progress in IEx, or use the data for something else.
      events =
        acc
        |> Enum.map(fn {country, data} -> {country, Enum.count(data)} end)
        |> IO.inspect(label: inspect(self()))

      case trigger do
        :done ->
          {events, acc}

        {:every, 1000} ->
          {[], acc}
      end
    end)
    |> Enum.sort(fn {_, a}, {_, b} -> a > b end)
    |> Enum.take(10)

    # |> Flow.on_trigger(fn map ->
    #   country_data = Enum.map(map, fn {country, data} -> {country, Enum.count(data)} end)
    #   {country_data, map}
    # end)
    # |> Flow.take_sort(10, fn {_, a}, {_, b} -> a > b end)
    # |> Enum.to_list()

    # |> List.flatten()

    # very annoying, the example of Map from the book doesn't work, can't be called after group_by and reduce
    # on_trigger works at least
  end

  def airports_csv() do
    Application.app_dir(:airports, "/priv/airports.csv")
  end
end
