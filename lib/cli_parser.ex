defmodule Poker.CliParser do
  @moduledoc """
  This module is responsible for parsing user cli input.
  """

  @doc """
  get_user_input() -> get_user_input()

  This function is called on start of application and
  it is looped.

  It parses user input and print error message if something
  went wrong.

  PokerHand.get_winner_of_two called is string was parsed successfully.
  """
  def get_user_input() do
    user_input =
      IO.gets(
        "Please enter two combinations like this: " <>
          "Black: 2H 3D 5S 9C KD White: 2C 3H 4S 8C AH\n"
      )

    try do
      user_hand_list = parse_user_input(user_input)
      Poker.PokerHand.get_winner_of_two(user_hand_list)
    rescue
      e in RuntimeError ->
        print_error(e.message)
    end

    get_user_input()
  end

  @doc """
  check_user_input(input_string) -> {user_name, raw_hand_list}

  This function parses raw input and converts it to
  convenient format.
  """
  def parse_user_input(input_string) do
    user_hand_list0 = String.trim(input_string)

    # get user names like "Black:" and "White:"
    name_list0 = Regex.scan(~r/[ ]?\w+: /, user_hand_list0)
    # Delete ":" from names
    name_list = Enum.map(name_list0, fn [name] -> Regex.replace(~r/[ :]/, name, "") end)

    # split string using pattern " UserName:"
    # relust is list of hand strings like
    # ["", "2H 3D 5S 9C KD", "2C 3H 4S 8C AH"]
    [_ | hand_list_raw] = Regex.split(~r/[ ]?\w+: /, user_hand_list0)

    # cobine names with hands [{name, hand},..]
    user_hand_list = Enum.zip(name_list, hand_list_raw)

    # IO.puts("user_hand_list")
    # IO.inspect(user_hand_list)

    cond do
      length(user_hand_list) != 2 ->
        raise "invalid_format"

      true ->
        :ok
    end

    Enum.map(user_hand_list, fn {user_name, hand_list_raw} ->
      # fetch cards from hand string
      hand_list = Regex.scan(~r/\w+/, hand_list_raw)
      # IO.inspect(hand_list)

      cond do
        length(hand_list) != 5 ->
          raise "hand_not_five"

        true ->
          # hand_list = [["5S"], ["TH"], ["AS"], ["2D"], ["7H"]]
          {user_name, Enum.map(hand_list, &parse_string_card/1)}
      end
    end)
  end

  @doc """
  parse_string_card(card_string) -> {suite, value}

  This function parses raw card string:
    "5S" -> {:s,4}
  """
  def parse_string_card([card_string]) do
    case Regex.scan(~R/\w/, card_string) do
      [[value_string], [suite_string]] ->
        {parse_string_suite(suite_string), parse_string_value(value_string)}

      _ ->
        raise "wrong_card_definition"
    end
  end

  @doc """
  parse_string_suite(suite_string) -> suite_atom

  This function parses raw card string:
    "S" -> :s
  """
  def parse_string_suite(suite_string) do
    suite_map = %{"C" => :c, "D" => :d, "H" => :h, "S" => :s}

    case Map.get(suite_map, suite_string, nil) do
      nil ->
        raise "wrong_suite" <> suite_string

      s ->
        s
    end
  end

  @doc """
  parse_string_value(value_string) -> value_integer

  This function parses raw card value:
    "1" => 0
  """
  def parse_string_value(value_string) do
    value_map = %{
      "1" => 0,
      "2" => 1,
      "3" => 2,
      "4" => 3,
      "5" => 4,
      "6" => 5,
      "7" => 6,
      "8" => 7,
      "9" => 8,
      "T" => 9,
      "J" => 10,
      "Q" => 11,
      "K" => 12,
      "A" => 13
    }

    case Map.get(value_map, value_string, nil) do
      nil ->
        raise "wrong_value" <> value_string

      v ->
        v
    end
  end

  @doc """
  parse_integer_value(value_int) -> value_string

  This function parses raw card value:
    "1" => 0
  """
  def parse_integer_value(value_int) do
    value_map = %{
      0 => "1",
      1 => "2",
      2 => "3",
      3 => "4",
      4 => "5",
      5 => "6",
      6 => "7",
      7 => "8",
      8 => "9",
      9 => "Ten",
      10 => "Jack",
      11 => "Queen",
      12 => "King",
      13 => "Ace"
    }

    Map.get(value_map, value_int)
  end

  @doc """
  print_error("wrong_value") -> :ok

  This function prints error message
  """
  def print_error(<<"wrong_value", value::utf8>>) do
    msg =
      "Incorrect card value '#{<<value>>}'. Please provide correct value for cards (2,3,4,5,6,7,8,9,T,J,Q,K,A)"

    format_message(msg)
  end

  def print_error(<<"wrong_suite", suite::utf8>>) do
    msg = "Incorrect card suite '#{<<suite>>}'. Please provide correct card suite (C,D,H,S)"
    format_message(msg)
  end

  def print_error("invalid_format") do
    msg = "Invalid or empty input was provided"
    format_message(msg)
  end

  def print_error("hand_not_five") do
    msg = "Hand should consist of five cards"
    format_message(msg)
  end

  def print_error("wrong_card_definition") do
    msg = "Card should consist of two symbols"
    format_message(msg)
  end

  def print_error("unknown_hand") do
    msg = "Input contains invalid unknown combination"
    format_message(msg)
  end

  def format_message(message) do
    IO.puts("""
    #---------------------------------------------------------------------------
      #{message}
    #---------------------------------------------------------------------------
    """)
  end
end
