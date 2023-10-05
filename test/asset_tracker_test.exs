defmodule AssetTrackerTest do
  use ExUnit.Case
  doctest AssetTracker
  alias AssetTracker

  describe "new/1" do
    test "creates a new AssetTracker" do
      asset_tracker = AssetTracker.new()

      assert asset_tracker == %AssetTracker{sales: [], purchases: []}
    end
  end

  describe "add_purchase/5" do
    test "adds a purchase to an AssetTracker" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("AAPL", "2021-01-01", 100, 100.00)

      assert asset_tracker == %AssetTracker{
               sales: [],
               purchases: [
                 %AssetTracker.Purchase{
                   symbol: "AAPL",
                   settle_date: "2021-01-01",
                   quantity: 100,
                   unit_price: 100.00
                 }
               ]
             }
    end

    test "adds a purchases to an AssetTracker" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("AAPL", "2021-01-01", 100, 100.00)
        |> AssetTracker.add_purchase("AAPL", "2021-01-05", 50, 100.00)
        |> AssetTracker.add_purchase("AAPL", "2021-01-10", 25, 100.00)

      assert asset_tracker == %AssetTracker{
               sales: [],
               purchases: [
                 %AssetTracker.Purchase{
                   symbol: "AAPL",
                   settle_date: "2021-01-01",
                   quantity: 100,
                   unit_price: 100.00
                 },
                 %AssetTracker.Purchase{
                   symbol: "AAPL",
                   settle_date: "2021-01-05",
                   quantity: 50,
                   unit_price: 100.00
                 },
                 %AssetTracker.Purchase{
                   symbol: "AAPL",
                   settle_date: "2021-01-10",
                   quantity: 25,
                   unit_price: 100.00
                 }
               ]
             }
    end
  end

  describe "add_sale/5" do
    test "adds a sale to an AssetTracker receiving gain or loss" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("AAPL", "2021-01-01", 100, 100.00)
        |> AssetTracker.add_purchase("AAPL", "2021-01-05", 50, 100.00)
        |> AssetTracker.add_purchase("AAPL", "2021-01-10", 25, 100.00)
        |> AssetTracker.add_sale("AAPL", "2021-01-15", 100, 95.00)

      assert asset_tracker == {
               %AssetTracker{
                 sales: [
                   %AssetTracker.Sale{
                     symbol: "AAPL",
                     sell_date: "2021-01-15",
                     quantity: 100,
                     unit_price: 95.00,
                     average_cost: 100.0
                   }
                 ],
                 purchases: [
                   %AssetTracker.Purchase{
                     symbol: "AAPL",
                     settle_date: "2021-01-05",
                     quantity: 50,
                     unit_price: 100.00
                   },
                   %AssetTracker.Purchase{
                     symbol: "AAPL",
                     settle_date: "2021-01-10",
                     quantity: 25,
                     unit_price: 100.00
                   }
                 ]
               },
               -500.0
             }
    end
  end
end
