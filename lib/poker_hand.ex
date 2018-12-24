defmodule Poker.PokerHand do
  @moduledoc """
  This module is responsible for poker hand comparison.

  First the cli line is parsed by CliParser and then
  get_hand_value is called for each hand.

  Raw hand is a list of tuples like:
    [{s,2},{h,10},{h,10},{d,2},{s,2}] #full house

  Values are counted and put in sorted list like this:
    [3,2] #full house

  Values itself are stored respectively in another list
    [2, 10]

  Then lists are padded with zeros to 5 elements
  and converted into tuples:
    {3,2,0,0,0}
    {2,10,0,0,0}

  Such structure is comparable:
    {{3,2,0,0,0},{2,10,0,0,0}} > {{1,1,1,1,1},{10,8,6,4,2}}

  Winning is message is printed is there is a winner.
  """

  @doc """
  type_tuple_to_string(type_tuple)-> type_string

  Maps tuple that represents hand type to the
  string value.
  """
  def type_tuple_to_string(type_tuple) do
    type_map = %{
      {1, 1, 1, 1, 1} => "high_card",
      {2, 1, 1, 1, 0} => "two_of_kind",
      {2, 2, 1, 0, 0} => "two_pairs",
      {3, 1, 1, 0, 0} => "three_of_kind",
      {3, 1, 1, 1, 0} => "straight",
      {3, 1, 1, 1, 1} => "flush",
      {3, 2, 0, 0, 0} => "full_house",
      {4, 1, 0, 0, 0} => "four_of_kind",
      {4, 1, 1, 0, 0} => "stright_flush",
      {5, 0, 0, 0, 0} => "unknown_hand"
    }

    Map.get(type_map, type_tuple)
  end

  @doc """
  get_hand_value(hand) -> {hand_type,hand_strength}

  get_hand_value(hand) gets raw poker hand that was
  fetched and prepared by CliParser.

  Result is a tuple that consists of two tuples,
  where the first represents type of hand
  and the second strength of this hand.

  Results can be compared with each other by operators >, <, ==.

  Hand example: [{c, 1}, {d, 8}, {h, 10}, {h, 10}, {s, 10}]
  Result: {{3,1,1,0,0},{10,8,1,0,0}}
  """

  def get_hand_value(hand) do
    # IO.inspect(hand)

    val_to_nval_map =
      List.foldl(hand, %{}, fn {_suite, val}, acc ->
        old_val = Map.get(acc, val, 0)
        Map.put(acc, val, old_val + 1)
      end)

    val_to_nval_list =
      Enum.sort(
        Map.to_list(val_to_nval_map),
        &(elem(&1, 1) > elem(&2, 1))
      )

    {val_list0, n_val_list0} = Enum.unzip(val_to_nval_list)
    val_list = add_zero_padding(val_list0, 5)

    n_val_list =
      cond do
        length(n_val_list0) == 5 ->
          is_flush = flush?(hand)
          is_stright = stright?(val_list)
          is_bad_hand = contain_duplicates?(hand)

          case {is_flush, is_stright, is_bad_hand} do
            {_, _, true} -> [5, 0, 0, 0, 0]
            {true, true, _} -> [4, 1, 1, 0, 0]
            {true, false, _} -> [3, 1, 1, 1, 1]
            {false, true, _} -> [3, 1, 1, 1, 0]
            {false, false, _} -> n_val_list0
          end

        length(n_val_list0) < 5 ->
          case contain_duplicates?(hand) do
            true ->
              [5, 0, 0, 0, 0]

            false ->
              add_zero_padding(n_val_list0, 5)
          end
      end

    # IO.inspect({List.to_tuple(n_val_list), List.to_tuple(val_list)})
    {List.to_tuple(n_val_list), List.to_tuple(val_list)}
  end

  @doc """
  flush?(hand) -> true | false
  Returns true if given hand contains flush combination.

  hand : [{c, 1}, {d, 8}, {h, 10}, {h, 10}, {s, 10}]
  result: false

  hand : [{c, 1}, {c, 8}, {c, 10}, {c, 10}, {c, 10}]
  result: true
  """
  def flush?(hand = [{suite, _val} | _]) do
    flush_list = for {s, _} <- hand, s == suite, do: s
    length(flush_list) == 5
  end

  @doc """
  stright?(value_list) -> true | false

  Returns true if given value list contains integers
  that give a continuous sequence for stright combination.

  value_list : [1,2,3,4,5]
  result: true

  value_list : [1,3,4,6,8]
  result: false
  """
  def stright?(value_list) do
    max_value = Enum.max(value_list)
    # IO.inspect(value_list)
    expect_val_list = max_value..(max_value - 4)

    # IO.inspect(expect_val_list)

    stright_list =
      Enum.take_while(
        0..4,
        fn n -> Enum.member?(expect_val_list, Enum.at(value_list, n)) end
      )

    length(stright_list) == 5
  end

  @doc """
  contain_duplicates?(hand) -> true | false

  Returns true if given hand contains cards of the suite
  and the same value

  hand : [{c, 1}, {c, 1}, {c, 1}, {h, 10}, {s, 10}]
  result: false
  """
  def contain_duplicates?(hand) do
    Enum.uniq(hand) |> length != length(hand)
  end

  @doc """
  add_zero_padding(list, expected_length)-> new_list

  Appends zeroes to an end of a given list to make it of
  given expected_length.

  value_list : [1,2,3], expected_length 5
  result: [1,2,3,0,0]
  """
  def add_zero_padding(list, expected_length)
      when length(list) <= expected_length do
    n = expected_length - length(list)

    list ++ List.duplicate(0, n)
  end

  @doc """
  get_winner_of_two([{user1, hand1}, {user2, hand2}]) -> :ok

  Compares hands and print a winning message if there is a winner.
  """
  def get_winner_of_two([{user1, hand1}, {user2, hand2}]) do
    hand_value1 = get_hand_value(hand1)
    hand_value2 = get_hand_value(hand2)

    {winner, hand} =
      cond do
        hand_value1 > hand_value2 ->
          {user1, hand_value1}

        hand_value2 > hand_value1 ->
          {user2, hand_value2}

        hand_value1 == hand_value2 ->
          {nil, nil}
      end

    print_winning_message(winner, hand)

    {winner, hand}
  end

  @doc """
  print_winning_message(nil | hand) -> :ok

  Prints winning message for hand
  and 'Tie' for nil.
  """
  def print_winning_message(_user, nil) do
    msg = "Tie"
    Poker.CliParser.format_message(msg)
    msg
  end

  def print_winning_message(user, hand) do
    {hand_type_tuple, hand_value_tuple} = hand
    hand_type_string = type_tuple_to_string(hand_type_tuple)
    max_value = elem(hand_value_tuple, 0) |> Poker.CliParser.parse_integer_value()

    case hand_type_string do
      "unknown_hand" ->
        msg = "unknown_hand"
        Poker.CliParser.print_error(msg)
        msg

      "high_card" ->
        msg = "#{user} wins - #{hand_type_string}: #{max_value}"
        Poker.CliParser.format_message(msg)
        msg

      _ ->
        msg = "#{user} wins - #{hand_type_string}"
        Poker.CliParser.format_message(msg)
        msg
    end
  end
end
