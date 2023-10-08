defmodule AddPurchaseTest do
  use ExUnit.Case
  doctest AssetTracker
  alias AssetTracker

  describe "add_purchase/5" do
    test "adds a purchase to an AssetTracker" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100)

      assert asset_tracker == %AssetTracker{
               sales: [],
               purchases: [
                 %AssetTracker.Purchase{
                   symbol: "APPL",
                   settle_date: "2021-01-01",
                   quantity: Decimal.new("100"),
                   unit_price: Decimal.new("100")
                 }
               ]
             }
    end

    test "adds many purchases to an AssetTracker" do
      asset_tracker =
        AssetTracker.new()
        |> AssetTracker.add_purchase("APPL", "2021-01-01", 100, 100)
        |> AssetTracker.add_purchase("AMZO", "2021-01-05", 50, 100)
        |> AssetTracker.add_purchase("APPL", "2021-01-10", 25, 100)

      assert asset_tracker == %AssetTracker{
               sales: [],
               purchases: [
                 %AssetTracker.Purchase{
                   symbol: "APPL",
                   settle_date: "2021-01-01",
                   quantity: Decimal.new("100"),
                   unit_price: Decimal.new("100")
                 },
                 %AssetTracker.Purchase{
                   symbol: "AMZO",
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
             }
    end
  end
end
