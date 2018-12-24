# poker

This is a test application that help you with comparing poker hands.

Run application:

> mix compile

> iex -S mix

> Poker.start

Run tests:

> mix test



Exit application:

> Ctrl+G, q


Test input:
>	Black: 2H 3D 5S 9C KD White: 2C 3H 4S 8C AH

Result:
>	White wins - high_card: Ace


Test input:
>	User1: 3H 3D 3S 9C KD User2: 2C 3H 4S 5C 6H

Result:
>	User2 wins - straight

