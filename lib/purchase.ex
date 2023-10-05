defmodule AssetTracker.Purchase do
  @keys [:symbol, :settle_date, :quantity, :unit_price]
  @enforce_keys @keys

  defstruct @keys

  def new(symbol, settle_date, quantity, unit_price) do
    %__MODULE__{
      symbol: symbol,
      settle_date: settle_date,
      quantity: quantity,
      unit_price: unit_price
    }
  end
end
