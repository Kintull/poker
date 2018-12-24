defmodule PokerHandTest do
  use ExUnit.Case
  doctest Poker.PokerHand

  test "test stright check" do
    stright_lists = [
      [2, 3, 4, 5, 6],
      [5, 4, 3, 2, 1],
      [3, 5, 2, 4, 6],
      [5, 3, 4, 2, 6],
      [6, 2, 4, 3, 5]
    ]

    not_stright_list = [
      [2, 3, 4, 5, 7],
      [2, 4, 5, 6, 7],
      [2, 3, 4, 6, 7],
      [2, 3, 4, 5, 7],
      [7, 6, 5, 4, 2],
      [7, 5, 4, 3, 2],
      [7, 6, 4, 3, 2],
      [8, 7, 6, 5, 3],
      [10, 8, 6, 4, 2],
      [12, 11, 8, 7, 6]
    ]

    Enum.each(stright_lists, &assert(Poker.PokerHand.stright?(&1) == true))
    Enum.each(not_stright_list, &assert(Poker.PokerHand.stright?(&1) == false))
  end

  test "test flush check" do
    flush_lists = [
      [c: 1, c: 8, c: 10, c: 10, c: 10],
      [d: 1, d: 8, d: 10, d: 10, d: 10],
      [h: 1, h: 8, h: 10, h: 10, h: 10],
      [s: 1, s: 8, s: 10, s: 10, s: 10]
    ]

    not_flush_list = [
      [s: 1, c: 8, c: 10, c: 10, c: 10],
      [d: 1, s: 8, c: 10, c: 10, c: 10],
      [d: 1, s: 8, h: 10, c: 10, c: 10],
      [d: 1, s: 8, h: 10, d: 10, c: 10],
      [d: 1, s: 8, c: 10, d: 10, h: 10]
    ]

    Enum.each(flush_lists, &assert(Poker.PokerHand.flush?(&1) == true))
    Enum.each(not_flush_list, &assert(Poker.PokerHand.flush?(&1) == false))
  end

  test "parsing of raw hand suite-value list" do
    hand_list = [
      # high card
      [
        call: [c: 1, d: 8, h: 12, h: 10, s: 11],
        result: {"high_card", {12, 11, 10, 8, 1}}
      ],
      [
        call: [c: 14, d: 12, h: 2, h: 5, s: 11],
        result: {"high_card", {14, 12, 11, 5, 2}}
      ],

      # Two of kind
      [
        call: [c: 2, d: 2, h: 3, h: 4, s: 5],
        result: {"two_of_kind", {2, 5, 4, 3, 0}}
      ],
      [
        call: [c: 7, d: 10, h: 8, h: 10, s: 12],
        result: {"two_of_kind", {10, 12, 8, 7, 0}}
      ],

      #  two pairs
      [
        call: [c: 1, d: 1, h: 3, d: 3, s: 5],
        result: {"two_pairs", {3, 1, 5, 0, 0}}
      ],
      [
        call: [c: 1, d: 2, h: 2, h: 5, s: 5],
        result: {"two_pairs", {5, 2, 1, 0, 0}}
      ],

      #  three of kind
      [
        call: [c: 1, d: 1, h: 1, h: 4, s: 5],
        result: {"three_of_kind", {1, 5, 4, 0, 0}}
      ],
      [
        call: [c: 4, d: 2, h: 5, h: 4, s: 4],
        result: {"three_of_kind", {4, 5, 2, 0, 0}}
      ],

      #  straight
      [
        call: [c: 1, d: 2, h: 3, h: 4, s: 5],
        result: {"straight", {5, 4, 3, 2, 1}}
      ],
      [
        call: [c: 13, d: 12, h: 11, h: 9, s: 10],
        result: {"straight", {13, 12, 11, 10, 9}}
      ],

      # flush
      [
        call: [c: 1, c: 2, c: 3, c: 4, c: 10],
        result: {"flush", {10, 4, 3, 2, 1}}
      ],
      [
        call: [d: 1, d: 2, d: 3, d: 4, d: 12],
        result: {"flush", {12, 4, 3, 2, 1}}
      ],

      #  full_house
      [
        call: [c: 1, d: 1, h: 4, c: 4, h: 1],
        result: {"full_house", {1, 4, 0, 0, 0}}
      ],
      [
        call: [d: 10, s: 2, h: 2, h: 10, c: 10],
        result: {"full_house", {10, 2, 0, 0, 0}}
      ],

      #  four of kind
      [
        call: [c: 8, d: 8, h: 8, s: 8, s: 5],
        result: {"four_of_kind", {8, 5, 0, 0, 0}}
      ],
      [
        call: [c: 1, d: 1, h: 3, h: 1, s: 1],
        result: {"four_of_kind", {1, 3, 0, 0, 0}}
      ],

      #  strait flush
      [
        call: [c: 1, c: 2, c: 3, c: 4, c: 5],
        result: {"stright_flush", {5, 4, 3, 2, 1}}
      ],
      [
        call: [s: 9, s: 11, s: 12, s: 10, s: 13],
        result: {"stright_flush", {13, 12, 11, 10, 9}}
      ],

      # unknown combination 5 of kind
      [
        call: [s: 9, d: 9, h: 9, d: 9, s: 9],
        result: {"unknown_hand", {9, 0, 0, 0, 0}}
      ],
      [
        call: [s: 10, s: 10, s: 10, s: 10, s: 10],
        result: {"unknown_hand", {10, 0, 0, 0, 0}}
      ],

      # unknown combination duplicate
      [
        call: [s: 13, s: 11, s: 12, s: 13, h: 8],
        result: {"unknown_hand", {13, 12, 11, 8, 0}}
      ],
      [
        call: [s: 10, s: 10, s: 12, s: 13, h: 8],
        result: {"unknown_hand", {10, 13, 12, 8, 0}}
      ]
    ]

    Enum.each(hand_list, fn [call: hand, result: result] ->
      {hand_type, hand_value} = Poker.PokerHand.get_hand_value(hand)
      hand_type_string = Poker.PokerHand.type_tuple_to_string(hand_type)
      assert({hand_type_string, hand_value} == result)
    end)
  end

  test "test comparisons" do
    hand_list = [
      # high card
      [c: 1, d: 8, h: 12, h: 10, s: 11],
      [c: 14, d: 12, h: 2, h: 5, s: 11],

      # Two of kind
      [c: 2, d: 2, h: 3, h: 4, s: 5],
      [c: 7, d: 10, h: 8, h: 10, s: 12],

      #  two pairs
      [c: 1, d: 1, h: 3, d: 3, s: 5],
      [c: 1, d: 2, h: 2, h: 5, s: 5],

      #  three of kind
      [c: 1, d: 1, h: 1, h: 4, s: 5],
      [c: 4, d: 2, h: 5, h: 4, s: 4],

      #  straight
      [c: 1, d: 2, h: 3, h: 4, s: 5],
      [c: 13, d: 12, h: 11, h: 9, s: 10],

      # flush
      [c: 1, c: 2, c: 3, c: 4, c: 10],
      [d: 1, d: 2, d: 3, d: 4, d: 12],

      # full house
      [c: 1, d: 1, h: 4, c: 4, h: 1],
      [d: 10, s: 2, h: 2, h: 10, c: 10],

      #  four of kind
      [c: 1, d: 1, h: 3, h: 1, s: 1],
      [c: 8, d: 8, h: 8, s: 8, s: 5],

      #  strait flush
      [c: 1, c: 2, c: 3, c: 4, c: 5],
      [s: 9, s: 11, s: 12, s: 10, s: 13]
    ]

    Enum.each(Enum.with_index(hand_list), fn {hand, offset} ->
      Enum.each(Enum.with_index(hand_list), fn {hand_x, offset_x} ->
        cond do
          offset > offset_x ->
            parsed_hand = Poker.PokerHand.get_hand_value(hand)

            assert(
              Poker.PokerHand.get_winner_of_two([{"user1", hand}, {"user2", hand_x}]) ==
                {"user1", parsed_hand}
            )

          offset < offset_x ->
            parsed_hand_x = Poker.PokerHand.get_hand_value(hand_x)

            assert(
              Poker.PokerHand.get_winner_of_two([{"user1", hand}, {"user2", hand_x}]) ==
                {"user2", parsed_hand_x}
            )

          offset == offset_x ->
            assert(
              Poker.PokerHand.get_winner_of_two([{"user1", hand}, {"user2", hand_x}]) ==
                {nil, nil}
            )
        end
      end)
    end)
  end

  test "test printed message" do
    hand_list = [
      # high card
      [
        call: {"user1", {{1, 1, 1, 1, 1}, {12, 11, 10, 8, 1}}},
        res: "user1 wins - high_card: King"
      ],
      # Two of kind
      [call: {"user1", {{2, 1, 1, 1, 0}, {2, 5, 4, 3, 0}}}, res: "user1 wins - two_of_kind"],

      #  two pairs
      [call: {"user1", {{2, 2, 1, 0, 0}, {3, 1, 5, 0, 0}}}, res: "user1 wins - two_pairs"],

      #  three of kind
      [call: {"user1", {{3, 1, 1, 0, 0}, {1, 5, 4, 0, 0}}}, res: "user1 wins - three_of_kind"],

      #  straight
      [call: {"user1", {{3, 1, 1, 1, 0}, {5, 4, 3, 2, 1}}}, res: "user1 wins - straight"],

      # flush
      [call: {"user1", {{3, 1, 1, 1, 1}, {10, 4, 3, 2, 1}}}, res: "user1 wins - flush"],
      # full house
      [call: {"user1", {{3, 2, 0, 0, 0}, {1, 4, 0, 0, 0}}}, res: "user1 wins - full_house"],

      #  four of kind
      [call: {"user1", {{4, 1, 0, 0, 0}, {1, 3, 0, 0, 0}}}, res: "user1 wins - four_of_kind"],

      #  strait flush
      [call: {"user1", {{4, 1, 1, 0, 0}, {5, 4, 3, 2, 1}}}, res: "user1 wins - stright_flush"],

      # equal hands
      #  strait flush
      [call: {"user1", nil}, res: "Tie"]
    ]

    Enum.each(hand_list, fn [call: {user, hand}, res: result] ->
      assert(Poker.PokerHand.print_winning_message(user, hand) == result)
    end)
  end
end
