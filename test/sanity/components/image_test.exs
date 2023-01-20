defmodule Sanity.Components.ImageTest do
  use ExUnit.Case, async: true

  import Sanity.Components.Image
  import Phoenix.LiveViewTest

  @image %{
    _id: "image-da994d9e87efb226111cb83dbbab832d45b1365e-1500x750-jpg",
    _type: "sanity.imageAsset",
    metadata: %{
      dimensions: %{height: 750, width: 1500},
      palette: %{dominant: %{background: "#0844c5"}}
    },
    mime_type: "image/jpeg",
    url:
      "https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg"
  }

  test "sanity_image" do
    assert render_component(&sanity_image/1, class: "w-full", image: @image) ==
             ~S'<img height="750" width="1500" style="--sanity-image-bg: #0844c5" sizes="100vw" src="https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=1024" srcset="https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=320 320w,https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=768 768w,https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=1024 1024w,https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=1600 1600w,https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=2048" class="w-full">'
  end

  test "sanity_image with svg" do
    assert render_component(&sanity_image/1, image: %{@image | mime_type: "image/svg+xml"}) ==
             ~S'<img height="750" width="1500" style="--sanity-image-bg: #0844c5" sizes="100vw" src="https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg">'
  end

  test "sanity_image without meta" do
    assert render_component(&sanity_image/1,
             class: "w-full",
             image: Map.delete(@image, :metadata)
           ) ==
             ~S'<img style="" sizes="100vw" src="https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=1024" srcset="https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=320 320w,https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=768 768w,https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=1024 1024w,https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=1600 1600w,https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg?auto=format&amp;fit=min&amp;w=2048" class="w-full">'
  end
end
