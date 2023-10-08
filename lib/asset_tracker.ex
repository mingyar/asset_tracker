defmodule AssetTracker do
  alias __MODULE__.{Purchase, Sale, Helper}

  @moduledoc """
  This module is responsible for tracking assets.
  """

  @keys [:sales, :purchases]
  @enforce_keys @keys

  defstruct @keys

  def new do
    %__MODULE__{sales: [], purchases: []}
  end

  @doc """
   This function adds a purchase to an AssetTracker.

   ## Examples

      iex> asset_tracker = AssetTracker.new()
      %AssetTracker{sales: [], purchases: []}
      iex> AssetTracker.add_purchase(asset_tracker, "APPL", "2021-01-01", 100, 100)
      %AssetTracker{
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
  """
  def add_purchase(asset_tracker, asset_symbol, settle_date, quantity, unit_price) do
    Purchase.new(asset_symbol, settle_date, Decimal.new(quantity), Decimal.new(unit_price))
    |> Helper.add_purchase(asset_tracker)
  end

  @doc """
  This function adds a sale to an AssetTracker.

  ## Examples

      iex> asset_tracker = AssetTracker.new()
      %AssetTracker{sales: [], purchases: []}
      iex> asset_tracker = AssetTracker.add_purchase(asset_tracker, "APPL", "2021-01-01", 100, 100)
      %AssetTracker{
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
      iex> AssetTracker.add_sale(asset_tracker, "APPL", "2021-01-01", 100, 100)
      {%AssetTracker{
        sales: [
          %AssetTracker.Sale{
            symbol: "APPL",
            sell_date: "2021-01-01",
            quantity: Decimal.new("100"),
            unit_price: Decimal.new("100"),
            average_cost: Decimal.new("100")
          }
        ],
        purchases: []
      }, Decimal.new("0")}
  """
  def add_sale(asset_tracker, asset_symbol, sell_date, quantity, unit_price) do
    Sale.new(asset_symbol, sell_date, Decimal.new(quantity), Decimal.new(unit_price))
    |> Helper.add_sale(asset_tracker)
    |> Helper.deduct_from_purchases(asset_symbol, Decimal.new(quantity))
    |> case do
      {updated_asset_tracker, selled_assets} ->
        {updated_asset_tracker, selled_assets, unit_price}
    end
    |> Helper.realized_gain_or_loss()
  end

  @doc """
  This function calculates the unrealized gain or loss from an specific asset.

  ## Examples

      iex> asset_tracker = AssetTracker.new()
      %AssetTracker{sales: [], purchases: []}
      iex> asset_tracker = AssetTracker.add_purchase(asset_tracker, "APPL", "2021-01-01", 100, 100)
      %AssetTracker{
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
      iex> AssetTracker.unrealized_gain_or_loss(asset_tracker, "APPL", 200)
      Decimal.new("10000")
  """
  def unrealized_gain_or_loss(%{purchases: []}, _, _), do: Decimal.new("0")

  def unrealized_gain_or_loss(
        %{purchases: purchases} = _asset_tracker,
        asset_symbol,
        market_price
      ) do
    cost =
      purchases
      |> Enum.filter(fn %{symbol: symbol} -> symbol == asset_symbol end)
      |> Enum.map(fn %{quantity: quantity, unit_price: unit_price} ->
        Decimal.mult(quantity, unit_price)
      end)
      |> Enum.reduce(&Decimal.add/2)

    revenue =
      purchases
      |> Enum.filter(fn %{symbol: symbol} -> symbol == asset_symbol end)
      |> Enum.map(fn %{quantity: quantity} -> quantity end)
      |> Enum.reduce(&Decimal.add/2)
      |> Decimal.mult(market_price)

    Decimal.sub(revenue, cost)
  end
end
