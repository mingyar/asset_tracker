defmodule AddPurchaseTest do
  use ExUnit.Case
  doctest AssetTracker
  alias AssetTracker

  describe "add_purchase/5" do
    test "adds a purchase to an AssetTracker" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100.00)

      assert asset_tracker == %AssetTracker{
               sales: [],
               purchases: [
                 %AssetTracker.Purchase{
                   symbol: "APPL",
                   settle_date: "2021-01-01",
                   quantity: 100,
                   unit_price: 100.00
                 }
               ]
             }
    end

    test "adds many purchases to an AssetTracker" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100.00)
        |> AssetTracker.add_purchase("AMZO", "2021-01-05", 50, 100.00)
        |> AssetTracker.add_purchase("APPL", "2021-01-10", 25, 100.00)

      assert asset_tracker == %AssetTracker{
               sales: [],
               purchases: [
                 %AssetTracker.Purchase{
                   symbol: "APPL",
                   settle_date: "2021-01-01",
                   quantity: 100,
                   unit_price: 100.00
                 },
                 %AssetTracker.Purchase{
                   symbol: "AMZO",
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
             }
    end
  end
end
