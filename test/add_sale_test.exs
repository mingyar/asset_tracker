defmodule AddSaleTest do
  use ExUnit.Case
  doctest AssetTracker
  alias AssetTracker

  describe "add_sale/5" do
    test "adds a sale to an AssetTracker receiving gain or loss" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100.00)
        |> AssetTracker.add_purchase("APPL", "2021-01-05", 50, 100.00)
        |> AssetTracker.add_purchase("APPL", "2021-01-10", 25, 100.00)
        |> AssetTracker.add_sale("APPL", "2021-01-15", 100, 95.00)

      assert asset_tracker == {
               %AssetTracker{
                 sales: [
                   %AssetTracker.Sale{
                     symbol: "APPL",
                     sell_date: "2021-01-15",
                     quantity: 100,
                     unit_price: 95.00,
                     average_cost: 100.0
                   }
                 ],
                 purchases: [
                   %AssetTracker.Purchase{
                     symbol: "APPL",
                     settle_date: "2021-01-05",
                     quantity: 50,
                     unit_price: 100.00
                   },
                   %AssetTracker.Purchase{
                     symbol: "APPL",
                     settle_date: "2021-01-10",
                     quantity: 25,
                     unit_price: 100.00
                   }
                 ]
               },
               -500.0
             }
    end

    test "adds a sale to an AssetTracker receiving gain or loss, with diferent assets" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100.00)
        |> AssetTracker.add_purchase("AMZO", "2021-01-05", 50, 100.00)
        |> AssetTracker.add_purchase("APPL", "2021-01-10", 25, 100.00)
        |> AssetTracker.add_sale("APPL", "2021-01-15", 105, 95.00)

      assert asset_tracker == {
               %AssetTracker{
                 sales: [
                   %AssetTracker.Sale{
                     symbol: "APPL",
                     sell_date: "2021-01-15",
                     quantity: 105,
                     unit_price: 95.00,
                     average_cost: 100.0
                   }
                 ],
                 purchases: [
                   %AssetTracker.Purchase{
                     symbol: "AMZO",
                     settle_date: "2021-01-05",
                     quantity: 50,
                     unit_price: 100.00
                   },
                   %AssetTracker.Purchase{
                     symbol: "APPL",
                     settle_date: "2021-01-10",
                     quantity: 20,
                     unit_price: 100.00
                   }
                 ]
               },
               -525.0
             }
    end
  end
end
