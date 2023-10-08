defmodule AssetTracker.Helper do
  alias AssetTracker.{Purchase, Sale}

  def deduct_from_purchases(%{purchases: purchases} = asset_tracker, asset_symbol, quantity) do
    {updated_purchases, _, selled_assets} =
      purchases
      |> Enum.reduce({[], quantity, []}, fn purchase,
                                            {updated_purchases, remaining_quantity,
                                             selled_purchases} ->
        unless Decimal.equal?(remaining_quantity, 0) do
          case asset_symbol == purchase.symbol do
            true ->
              case purchase.quantity do
                purchase_quantity when purchase_quantity == remaining_quantity ->
                  {updated_purchases, 0, [purchase | selled_purchases]}

                purchase_quantity when purchase_quantity < remaining_quantity ->
                  {updated_purchases, Decimal.sub(remaining_quantity, purchase_quantity),
                   [purchase | selled_purchases]}

                purchase_quantity when purchase_quantity > remaining_quantity ->
                  updated_purchase =
                    Purchase.new(
                      purchase.symbol,
                      purchase.settle_date,
                      Decimal.sub(purchase.quantity, remaining_quantity),
                      purchase.unit_price
                    )

                  selled_purchase =
                    Purchase.new(
                      purchase.symbol,
                      purchase.settle_date,
                      remaining_quantity,
                      purchase.unit_price
                    )

                  {updated_purchases ++ [updated_purchase], 0,
                   [selled_purchase | selled_purchases]}
              end

            false ->
              {updated_purchases ++ [purchase], remaining_quantity, selled_purchases}
          end
        else
          {updated_purchases ++ [purchase], remaining_quantity, selled_purchases}
        end
      end)

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
