defmodule ExMonTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias ExMon.{Player, Game}

  describe "create_player/4" do
    test "returns a player" do
      expected_response = %Player{life: 100, moves: %{move_avg: :soco, move_heal: :heal, move_rnd: :chute}, name: "Rafael"}

      assert expected_response == ExMon.create_player("Rafael", :chute, :soco, :heal)
    end
  end

  describe "start_game/1" do
    test "when the game is started, returns a message" do
      player = Player.build("Rafael", :chute, :soco, :cura)

      messages =
        capture_io(fn ->
          assert ExMon.start_game(player) == :ok
        end)

      assert messages =~ "The game is started!"
      assert messages =~ "status: :started"
      assert messages =~ "turn: :player"
    end
  end

  describe "make_move/1" do
    setup do
      player = Player.build("Rafael", :chute, :soco, :cura)

      capture_io(fn ->
        ExMon.start_game(player)
      end)

      :ok
    end

    test "when the move is valid, do the move and computer makes a move" do
      messages = capture_io(fn ->
        ExMon.make_move(:chute)
      end)

      assert messages =~ "The Player attacked the computer"
      assert messages =~ "It's computer turn"
      assert messages =~ "It's player turn"
      assert messages =~ "status: :continue"
    end

    test "when the move is invalid, returns an error message" do
      messages = capture_io(fn ->
        ExMon.make_move(:wrong)
      end)

      assert messages =~ "Invalid move: wrong"
    end

    test "when the game is over, returns a game over message" do
      new_state = %{
        computer: %Player{
          life: 85,
          moves: %{move_avg: :soco, move_heal: :cura, move_rnd: :chute},
          name: "Robotinik"
        },
        player: %Player{
          life: 0,
          moves: %{move_avg: :soco, move_heal: :cura, move_rnd: :chute},
          name: "Rafael"
        },
        status: :game_over,
        turn: :player
      }

      Game.update(new_state)

      messages = capture_io(fn ->
        ExMon.make_move(:wrong)
      end)

      assert messages =~ "The game is over"
      assert messages =~ "life: 0"
    end
  end
end