defmodule AssetTracker.Helper do
  alias AssetTracker.{Sale, DeductFromPurchases}

  def deduct_from_purchases(%{purchases: purchases} = asset_tracker, asset_symbol, quantity) do
    {updated_purchases, selled_assets} =
      DeductFromPurchases.exec(purchases, [], asset_symbol, quantity, [])

    {Map.put(asset_tracker, :purchases, updated_purchases), selled_assets}
  end

  def average(assets) do
    total_asset_accumulated_value(assets)
    |> Decimal.div(total_asset_quantity(assets))
  end

  def total_asset_quantity(assets) do
    assets
    |> Enum.map(fn %{quantity: quantity} -> quantity end)
    |> Enum.reduce(0, &Decimal.add/2)
  end

  def total_asset_accumulated_value(assets) do
    assets
    |> Enum.map(fn %{quantity: quantity, unit_price: unit_price} ->
      Decimal.mult(quantity, unit_price)
    end)
    |> Enum.reduce(0, &Decimal.add/2)
  end

  def realized_gain_or_loss({asset_tracker, selled_assets, sale_unit_price}) do
    cost =
      selled_assets
      |> total_asset_accumulated_value()

    average_cost = average(selled_assets)

    revenue =
      selled_assets
      |> total_asset_quantity()
      |> Decimal.mult(sale_unit_price)

    gain_or_loss = Decimal.sub(revenue, cost)

    {
      update_last_sale_average_cost(asset_tracker, average_cost),
      gain_or_loss
    }
  end

  def update_last_sale_average_cost(%{sales: sales} = asset_tracker, average_cost) do
    last_sale = List.first(sales)

    updated_last_sale =
      Sale.new(
        last_sale.symbol,
        last_sale.sell_date,
        last_sale.quantity,
        last_sale.unit_price,
        average_cost
      )

    updated_sales = List.delete_at(sales, 0)

    asset_tracker
    |> Map.put(:sales, [updated_last_sale | updated_sales])
  end

  def add_purchase(new_purchase, %{purchases: purchases} = asset_tracker),
    do: Map.put(asset_tracker, :purchases, purchases ++ [new_purchase])

  def add_sale(new_sale, %{sales: sales} = asset_tracker),
    do: Map.put(asset_tracker, :sales, [new_sale | sales])
end
