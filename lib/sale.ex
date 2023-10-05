defmodule AssetTracker.Sale do
  @keys [:symbol, :sell_date, :quantity, :unit_price, :average_cost]
  @enforce_keys @keys

  defstruct @keys

  def new(symbol, sell_date, quantity, unit_price) do
    %__MODULE__{
      symbol: symbol,
      sell_date: sell_date,
      quantity: quantity,
      unit_price: unit_price,
      average_cost: 0.0
    }
  end

  def new(symbol, sell_date, quantity, unit_price, average_cost) do
    %__MODULE__{
      symbol: symbol,
      sell_date: sell_date,
      quantity: quantity,
      unit_price: unit_price,
      average_cost: average_cost
    }
  end
end
