defmodule Poker do
  @moduledoc """
  This module is a starting point of application
  """

  @doc """
  start() -> :ok
  Function starts cli_parser loop

  """
  def start() do
    Poker.CliParser.get_user_input()
  end
end
