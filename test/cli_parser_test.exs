defmodule CliParserTest do
  use ExUnit.Case
  doctest Poker.CliParser

  test "test user input" do
    good_hand_list = [
      [
        call: "Black: 2H 3D 5S 9C KD White: 2C 3H 4S 8C AH\n",
        result: [
          {"Black", [h: 1, d: 2, s: 4, c: 8, d: 12]},
          {"White", [c: 1, h: 2, s: 3, c: 7, h: 13]}
        ]
      ],
      [
        call: "Black1: TH TD 5S 9C KD White1: 2C 3H 2S 8D 2S\n",
        result: [
          {"Black1", [h: 9, d: 9, s: 4, c: 8, d: 12]},
          {"White1", [c: 1, h: 2, s: 1, d: 7, s: 1]}
        ]
      ]
    ]

    bad_hand_list = [
      [
        call: "Black: 2H1 3D 5S 9C KD White: 2C 3H 4S 8C AH\n",
        catch: "wrong_card_definition"
      ],
      [
        call: "Black1: TH TD 5S 9C KD TS White1: 2C 3H 2S 8D 2S\n",
        catch: "hand_not_five"
      ],
      [
        call: "Black1: TH TD 5S 9C KD\n",
        catch: "invalid_format"
      ],
      [
        call: "Black1: TH TD 5S 9C KD White1: 2C 3H 2S 8D 2S Brown: 3C 4H 3S 9D 3S\n",
        catch: "invalid_format"
      ],
      [
        call: "Black1: FH TD 5S 9C KD White1: 2C 3H 2S 8D 2S\n",
        catch: "wrong_valueF"
      ],
      [
        call: "Black: 2V 3D 5S 9C KD White: 2C 3H 4S 8C AH\n",
        catch: "wrong_suiteV"
      ]
    ]

    Enum.each(good_hand_list, fn [call: string, result: res] ->
      assert(Poker.CliParser.parse_user_input(string) == res)
    end)

    Enum.each(bad_hand_list, fn [call: string, catch: error] ->
      assert_raise(RuntimeError, error, fn ->
        Poker.CliParser.parse_user_input(string)
      end)
    end)
  end
end
