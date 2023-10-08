defmodule AssetTracker.AddSaleTest do
  use ExUnit.Case
  doctest AssetTracker
  alias AssetTracker

  describe "add_sale/5" do
    test "adds a sale to an AssetTracker receiving gain or loss" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100)
        |> AssetTracker.add_purchase("APPL", "2021-01-05", 50, 100)
        |> AssetTracker.add_purchase("APPL", "2021-01-10", 25, 100)
        |> AssetTracker.add_sale("APPL", "2021-01-15", 100, 95)

      assert asset_tracker == {
               %AssetTracker{
                 sales: [
                   %AssetTracker.Sale{
                     symbol: "APPL",
                     sell_date: "2021-01-15",
                     quantity: Decimal.new("100"),
                     unit_price: Decimal.new("95"),
                     average_cost: Decimal.new("100")
                   }
                 ],
                 purchases: [
                   %AssetTracker.Purchase{
                     symbol: "APPL",
                     settle_date: "2021-01-05",
                     quantity: Decimal.new("50"),
                     unit_price: Decimal.new("100")
                   },
                   %AssetTracker.Purchase{
                     symbol: "APPL",
                     settle_date: "2021-01-10",
                     quantity: Decimal.new("25"),
                     unit_price: Decimal.new("100")
                   }
                 ]
               },
               Decimal.new("-500")
             }
    end

    test "adds a sale to an AssetTracker receiving gain or loss, with diferent assets" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100)
        |> AssetTracker.add_purchase("AMZO", "2021-01-05", 50, 100)
        |> AssetTracker.add_purchase("APPL", "2021-01-10", 25, 100)
        |> AssetTracker.add_sale("APPL", "2021-01-15", 105, 95)

      assert asset_tracker == {
               %AssetTracker{
                 sales: [
                   %AssetTracker.Sale{
                     symbol: "APPL",
                     sell_date: "2021-01-15",
                     quantity: Decimal.new("105"),
                     unit_price: Decimal.new("95"),
                     average_cost: Decimal.new("100")
                   }
                 ],
                 purchases: [
                   %AssetTracker.Purchase{
                     symbol: "AMZO",
                     settle_date: "2021-01-05",
                     quantity: Decimal.new("50"),
                     unit_price: Decimal.new("100")
                   },
                   %AssetTracker.Purchase{
                     symbol: "APPL",
                     settle_date: "2021-01-10",
                     quantity: Decimal.new("20"),
                     unit_price: Decimal.new("100")
                   }
                 ]
               },
               Decimal.new("-525")
             }
    end

    test "adds a sale to an AssetTracker receiving gain or loss, with diferent assets and quantity using decimal values" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", "45.4", 100)
        |> AssetTracker.add_purchase("APPL", "2021-01-10", "25.7", 100)
        |> AssetTracker.add_sale("APPL", "2021-01-15", "52.4", 95)

      assert asset_tracker == {
               %AssetTracker{
                 sales: [
                   %AssetTracker.Sale{
                     symbol: "APPL",
                     sell_date: "2021-01-15",
                     quantity: Decimal.new("52.4"),
                     unit_price: Decimal.new("95"),
                     average_cost: Decimal.new("100")
                   }
                 ],
                 purchases: [
                   %AssetTracker.Purchase{
                     symbol: "APPL",
                     settle_date: "2021-01-10",
                     quantity: Decimal.new("18.7"),
                     unit_price: Decimal.new("100")
                   }
                 ]
               },
               Decimal.new("-262.0")
             }
    end
  end
end
