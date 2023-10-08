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
      iex> AssetTracker.add_purchase(asset_tracker, "AAPL", "2021-01-01", 100, 100.00)
      %AssetTracker{
        sales: [],
        purchases: [
          %AssetTracker.Purchase{
            symbol: "AAPL",
            settle_date: "2021-01-01",
            quantity: 100,
            unit_price: 100.0
          }
        ]
      }
  """
  def add_purchase(asset_tracker, asset_symbol, settle_date, quantity, unit_price) do
    Purchase.new(asset_symbol, settle_date, quantity, unit_price)
    |> Helper.add_purchase(asset_tracker)
  end

  @doc """
  This function adds a sale to an AssetTracker.

  ## Examples

      iex> asset_tracker = AssetTracker.new()
      %AssetTracker{sales: [], purchases: []}
      iex> asset_tracker = AssetTracker.add_purchase(asset_tracker, "AAPL", "2021-01-01", 100, 100.00)
      %AssetTracker{
        sales: [],
        purchases: [
          %AssetTracker.Purchase{
            symbol: "AAPL",
            settle_date: "2021-01-01",
            quantity: 100,
            unit_price: 100.0
          }
        ]
      }
      iex> asset_tracker = AssetTracker.add_sale(asset_tracker, "AAPL", "2021-01-01", 100, 100.00)
      {%AssetTracker{
        sales: [
          %AssetTracker.Sale{
            symbol: "AAPL",
            sell_date: "2021-01-01",
            quantity: 100,
            unit_price: 100.0,
            average_cost: 100.0
          }
        ],
        purchases: []
      }, 0.0}
  """
  def add_sale(asset_tracker, asset_symbol, sell_date, quantity, unit_price) do
    Sale.new(asset_symbol, sell_date, quantity, unit_price)
    |> Helper.add_sale(asset_tracker)
    |> Helper.deduct_from_purchases(asset_symbol, quantity)
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
      iex> asset_tracker = AssetTracker.add_purchase(asset_tracker, "AAPL", "2021-01-01", 100, 100.00)
      %AssetTracker{
        sales: [],
        purchases: [
          %AssetTracker.Purchase{
            symbol: "AAPL",
            settle_date: "2021-01-01",
            quantity: 100,
            unit_price: 100.0
          }
        ]
      }
      iex> AssetTracker.unrealized_gain_or_loss(asset_tracker, "AAPL", 200.00)
      10000.0
  """
  def unrealized_gain_or_loss(
        %{purchases: purchases} = _asset_tracker,
        asset_symbol,
        market_price
      ) do
    cost =
      purchases
      |> Enum.filter(fn %{symbol: symbol} -> symbol == asset_symbol end)
      |> Enum.map(fn %{quantity: quantity, unit_price: unit_price} ->
        quantity * unit_price
      end)
      |> Enum.sum()

    revenue =
      purchases
      |> Enum.filter(fn %{symbol: symbol} -> symbol == asset_symbol end)
      |> Enum.map(fn %{quantity: quantity} -> quantity end)
      |> Enum.sum()
      |> Kernel.*(market_price)

    revenue - cost
  end
end
