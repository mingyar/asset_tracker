defmodule UnrealizedGainOrLoss do
  use ExUnit.Case
  doctest AssetTracker
  alias AssetTracker

  describe "unrealized_gain_or_loss/3" do
    test "calculates unrealized gain or loss, with one purchase" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100.00)

      assert AssetTracker.unrealized_gain_or_loss(asset_tracker, "APPL", 200.00) == 10000.0
    end

    test "calculates unrealized gain or loss, with many purchases" do
      {asset_tracker, _gain_or_loss} =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100.00)
        |> AssetTracker.add_purchase("APPL", "2021-01-05", 50, 100.00)
        |> AssetTracker.add_purchase("APPL", "2021-01-10", 25, 100.00)
        |> AssetTracker.add_sale("APPL", "2021-01-15", 100, 95.00)

      assert AssetTracker.unrealized_gain_or_loss(asset_tracker, "APPL", 200.00) == 7500.0
    end

    test "calculates unrealized gain or loss, with no purchase" do
      asset_tracker = AssetTracker.new()

      assert AssetTracker.unrealized_gain_or_loss(asset_tracker, "APPL", 200.00) == 0.0
    end

    test "calculates unrealized gain or loss, with different kinds of assets" do
      {asset_tracker, _gain_or_loss} =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100.00)
        |> AssetTracker.add_purchase("AMZO", "2021-01-05", 50, 50.00)
        |> AssetTracker.add_purchase("APPL", "2021-01-10", 25, 75.00)
        |> AssetTracker.add_sale("APPL", "2021-01-15", 95, 110.00)

      assert AssetTracker.unrealized_gain_or_loss(asset_tracker, "APPL", 150.00) == 2125.0
    end
  end
end
