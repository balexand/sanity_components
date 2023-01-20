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
          mime_type: "image/jpeg",
          url:
            "https://cdn.sanity.io/images/csbsxnjq/production/da994d9e87efb226111cb83dbbab832d45b1365e-1500x750.jpg"
        }
      }

      ~H"<Sanity.Components.Image.sanity_image image={@image} />"
  """

  use Phoenix.Component

  @breakpoints [320, 768, 1024, 1600, 2048]

  @projection """
  {
    _id,
    _type,
    metadata {
      dimensions { height, width },
      palette {
        dominant { background }
      },
    },
    mimeType,
    url,
  }
  """

  @doc """
  Returns a GROQ projection for a Sanity image.
  """
  def projection, do: @projection

  @doc """
  Renders a responsive sanity image.

  The `src` and `srcset` attributes will be automatically set. Sanity CMS will [take care of
  resizing the images and serving WebP images to supported
  browsers](https://www.sanity.io/docs/image-urls).

  The `width` and `height` attributes will be automatically set to the dimensions of the image.
  This ensures that on [modern
  browsers](https://caniuse.com/mdn-html_elements_img_aspect_ratio_computed_from_attributes) the
  image will have the correct aspect ratio before the image loads. This avoids [layout
  shift](https://web.dev/cls/).

  The following CSS custom properties will be set if present in the Sanity image metadata:

    - `--sanity-image-bg` - Dominant background color of image. Useful for rendering placeholders.
    - `--sanity-image-height` and `--sanity-image-width` - Height/width of image.

  See module doc for example.
  """

  attr :image, :any, required: true
  attr :height, :integer, default: nil
  attr :width, :integer, default: nil
  attr :style, :string, default: nil
  attr :sizes, :string, default: "100vw"
  attr :rest, :global

  def sanity_image(assigns) do
    ~H"""
    <img
      height={@height || @image[:metadata][:dimensions][:height]}
      width={@width || @image[:metadata][:dimensions][:width]}
      style={style(@style, @image)}
      sizes={@sizes}
      src={src(@image)}
      srcset={srcset(@image)}
      {@rest}
    />
    """
  end

  defp style(style, image) do
    custom_properties =
      [
        {"--sanity-image-bg", image[:metadata][:palette][:dominant][:background]},
        {"--sanity-image-height", dimension(image, :height)},
        {"--sanity-image-width", dimension(image, :width)}
      ]
      |> Enum.filter(fn {_name, value} -> value end)
      |> Enum.map(fn {name, value} -> "#{name}: #{value}" end)

    [style | custom_properties]
    |> Enum.filter(& &1)
    |> Enum.join(";")
  end

  defp dimension(image, key) do
    case image[:metadata][:dimensions][key] do
      nil -> nil
      n -> "#{n}px"
    end
  end

  defp src(%{mime_type: "image/svg+xml", url: url}), do: url
  defp src(%{mime_type: _, url: url}), do: image_url(url, 1024)

  defp srcset(%{mime_type: "image/svg+xml"}), do: nil

  defp srcset(%{mime_type: _, url: url}) do
    {breakpoints, [last_breakpoint]} = Enum.split(@breakpoints, -1)

    breakpoints
    |> Enum.map(fn w -> "#{image_url(url, w)} #{w}w" end)
    |> Enum.concat([image_url(url, last_breakpoint)])
    |> Enum.join(",")
  end

  defp image_url(url, size) when is_binary(url) and is_integer(size) do
    params = %{auto: "format", fit: "min", w: size}

    "#{url}?#{URI.encode_query(params)}"
  end
end
