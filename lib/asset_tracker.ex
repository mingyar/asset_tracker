defmodule AssetTracker do
  alias __MODULE__.{Purchase, Sale}

  @keys [:sales, :purchases]
  @enforce_keys @keys

  defstruct @keys

  def new do
    %__MODULE__{sales: [], purchases: []}
  end

  def add_purchase(asset_tracker, asset_symbol, settle_date, quantity, unit_price) do
    Purchase.new(asset_symbol, settle_date, quantity, unit_price)
    |> add_purchase(asset_tracker)
  end

  def add_sale(asset_tracker, asset_symbol, sell_date, quantity, unit_price) do
    Sale.new(asset_symbol, sell_date, quantity, unit_price)
    |> add_sale(asset_tracker)
    |> deduct_from_purchases(asset_symbol, quantity)
    |> case do
      {updated_asset_tracker, selled_assets} ->
        {updated_asset_tracker, selled_assets, unit_price}
    end
    |> realized_gain_or_loss()
  end

  defp deduct_from_purchases(%{purchases: purchases} = asset_tracker, asset_symbol, quantity) do
    {updated_purchases, _, selled_assets} =
      purchases
      |> Enum.reduce({[], quantity, []}, fn purchase,
                                            {updated_purchases, remaining_quantity,
                                             selled_purchases} ->
        unless remaining_quantity == 0 do
          case asset_symbol == purchase.symbol do
            true ->
              if remaining_quantity >= purchase.quantity do
                updated_quantity = remaining_quantity - purchase.quantity

                case updated_quantity == 0 do
                  true ->
                    {updated_purchases, 0, [purchase | selled_purchases]}

                  false ->
                    updated_purchase =
                      Purchase.new(
                        purchase.symbol,
                        purchase.settle_date,
                        updated_quantity,
                        purchase.unit_price
                      )

                    {updated_purchases ++ [updated_purchase], updated_quantity,
                     [purchase | selled_purchases]}
                end
              else
                updated_quantity = purchase.quantity - remaining_quantity

                updated_purchase =
                  Purchase.new(
                    purchase.symbol,
                    purchase.settle_date,
                    updated_quantity,
                    purchase.unit_price
                  )

                selled_purchase =
                  Purchase.new(
                    purchase.symbol,
                    purchase.settle_date,
                    remaining_quantity,
                    purchase.unit_price
                  )

                {updated_purchases ++ [updated_purchase], 0, [selled_purchase | selled_purchases]}
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

  defp realized_gain_or_loss({asset_tracker, selled_assets, sale_unit_price}) do
    cost =
      selled_assets
      |> Enum.map(fn %{quantity: quantity, unit_price: unit_price} ->
        quantity * unit_price
      end)
      |> Enum.sum()

    average_cost =
      selled_assets
      |> Enum.map(fn %{quantity: quantity, unit_price: unit_price} ->
        quantity * unit_price
      end)
      |> Enum.sum()
      |> Kernel./(
        selled_assets
        |> Enum.map(fn %{quantity: quantity} -> quantity end)
        |> Enum.sum()
      )

    revenue =
      selled_assets
      |> Enum.map(fn %{quantity: quantity} -> quantity end)
      |> Enum.sum()
      |> Kernel.*(sale_unit_price)

    gain_or_loss = revenue - cost

    {
      update_last_sale_average_cost(asset_tracker, average_cost),
      gain_or_loss
    }
  end

  defp update_last_sale_average_cost(%{sales: sales} = asset_tracker, average_cost) do
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

  def unrealized_gain_or_loss(_asset_tracker, _asset_symbol, _market_price) do
    %{}
  end

  defp add_purchase(new_purchase, %{purchases: purchases} = asset_tracker),
    do: Map.put(asset_tracker, :purchases, purchases ++ [new_purchase])

  defp add_sale(new_sale, %{sales: sales} = asset_tracker),
    do: Map.put(asset_tracker, :sales, [new_sale | sales])
end
