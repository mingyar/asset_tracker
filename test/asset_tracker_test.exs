defmodule AssetTrackerTest do
  use ExUnit.Case
  doctest AssetTracker
  alias AssetTracker

  describe "new/1" do
    test "creates a new AssetTracker" do
      asset_tracker = AssetTracker.new()

      assert asset_tracker == %AssetTracker{sales: [], purchases: []}
    end
  end
end
