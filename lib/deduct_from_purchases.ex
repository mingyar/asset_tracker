defmodule AssetTracker.DeductFromPurchases do
  alias AssetTracker.{Purchase}

  def exec(
        [%{symbol: purchase_symbol} = purchase | purchases],
        updated_purchases,
        asset_symbol,
        quantity,
        selled_purchases
      )
      when purchase_symbol != asset_symbol do
    exec(
      purchases,
      updated_purchases ++ [purchase],
      asset_symbol,
      quantity,
      selled_purchases
    )
  end

  def exec(
        [%{quantity: purchase_quantity, symbol: purchase_symbol} = purchase | purchases],
        updated_purchases,
        asset_symbol,
        quantity,
        selled_purchases
      )
      when quantity > 0 and purchase_quantity == quantity and purchase_symbol == asset_symbol do
    exec(purchases, updated_purchases, asset_symbol, 0, [purchase | selled_purchases])
  end

  def exec(
        [%{quantity: purchase_quantity, symbol: purchase_symbol} = purchase | purchases],
        updated_purchases,
        asset_symbol,
        quantity,
        selled_purchases
      )
      when quantity > 0 and purchase_quantity < quantity and purchase_symbol == asset_symbol do
    exec(
      purchases,
      updated_purchases,
      asset_symbol,
      Decimal.sub(quantity, purchase_quantity),
      [purchase | selled_purchases]
    )
  end

  def exec(
        [%{quantity: purchase_quantity, symbol: purchase_symbol} = purchase | purchases],
        updated_purchases,
        asset_symbol,
        quantity,
        selled_purchases
      )
      when quantity > 0 and purchase_quantity > quantity and purchase_symbol == asset_symbol do
    updated_purchase =
      Purchase.new(
        purchase.symbol,
        purchase.settle_date,
        Decimal.sub(purchase.quantity, quantity),
        purchase.unit_price
      )

    selled_purchase =
      Purchase.new(
        purchase.symbol,
        purchase.settle_date,
        quantity,
        purchase.unit_price
      )

    exec(
      purchases ++ [updated_purchase],
      updated_purchases,
      asset_symbol,
      0,
      [selled_purchase | selled_purchases]
    )
  end

  def exec(purchases, updated_purchases, _asset_symbol, quantity, selled_purchases)
      when quantity == 0 do
    {updated_purchases ++ purchases, selled_purchases}
  end
end
