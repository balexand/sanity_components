defmodule Sanity.Components.Image do
  use Phoenix.Component

  @breakpoints [320, 768, 1024, 1600, 2048]

  def sanity_image(assigns) do
    {%{
       metadata: %{
         dimensions: %{height: height, width: width},
         palette: %{dominant: %{background: background}}
       },
       url: url
     }, assigns} = Map.pop!(assigns, :image)

    assigns =
      assigns
      |> Map.drop([:__changed__])
      |> Map.put_new(:height, height)
      |> Map.put_new(:width, width)
      |> Map.put_new(:style, "--sanity-image-bg: #{background}")
      |> Map.put_new(:sizes, "100vw")

    ~H"""
    <img {assigns} src={image_url(url, 1024)} srcset={srcset(url)} />
    """
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
