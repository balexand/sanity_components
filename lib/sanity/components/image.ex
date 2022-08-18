defmodule Sanity.Components.Image do
  @moduledoc """
  For rendering a [Sanity image asset](https://www.sanity.io/docs/assets).

  ## Examples

      use Phoenix.Component

      # ...

      # Example of image asset returned by Sanity CMS API
      assigns = %{
        image: %{
          _id: "image-da994d9e87efb226111cb83dbbab832d45b1365e-1500x750-jpg",
          _type: "sanity.imageAsset",
          metadata: %{
            dimensions: %{height: 750, width: 1500},
            palette: %{dominant: %{background: "#0844c5"}}
          },
          url:
            "https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg"
        }
      }

      ~H"<Sanity.Components.Image.sanity_image image={@image} />"
  """

  use Phoenix.Component

  @breakpoints [320, 768, 1024, 1600, 2048]

  @doc """
  Renders a responsive sanity image.

  The `src` and `srcset` attributes will be automatically set. Sanity CMS will [take care of
  resizing the images and serving WebP images to supported
  browsers](https://www.sanity.io/docs/image-urls). The `sizes` attribute will default to `100vw`.

  The `width` and `height` attributes will be automatically set. This ensures that on [modern
  browsers](https://caniuse.com/mdn-html_elements_img_aspect_ratio_computed_from_attributes)  the
  image will have the correct aspect ratio before the image loads. This avoids [layout
  shift](https://web.dev/cls/).

  See module doc for example.
  """
  def sanity_image(assigns) do
    {%{
       metadata: %{
         dimensions: %{height: height, width: width},
         palette: %{dominant: %{background: background}}
       },
       mime_type: mime_type,
       url: url
     }, assigns} = Map.pop!(assigns, :image)

    assigns =
      assigns
      |> Map.drop([:__changed__])
      |> Map.put_new(:height, height)
      |> Map.put_new(:width, width)
      |> Map.put_new(:style, "--sanity-image-bg: #{background}")
      |> Map.put_new(:sizes, "100vw")
      |> put_src(url, mime_type)

    ~H"""
    <img {assigns} />
    """
  end

  defp put_src(assigns, url, "image/svg+xml") do
    Map.put(assigns, :src, url)
  end

  defp put_src(assigns, url, _mime_type) do
    Map.merge(assigns, %{src: image_url(url, 1024), srcset: srcset(url)})
  end

  defp image_url(url, size) when is_binary(url) and is_integer(size) do
    params = %{auto: "format", fit: "min", w: size}

    "#{url}?#{URI.encode_query(params)}"
  end

  defp srcset(url) when is_binary(url) do
    {breakpoints, [last_breakpoint]} = Enum.split(@breakpoints, -1)

    breakpoints
    |> Enum.map(fn w -> "#{image_url(url, w)} #{w}w" end)
    |> Enum.concat([image_url(url, last_breakpoint)])
    |> Enum.join(",")
  end
end
