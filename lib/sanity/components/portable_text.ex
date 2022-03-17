defmodule Sanity.Components.PortableText do
  @moduledoc """
  For rending [Sanity CMS portable text](https://www.sanity.io/docs/presenting-block-text).

  ## Examples

  ### Basic example

      use Phoenix.Component

      # ...

      assigns = %{
        portable_text: [
          %{
            _key: "f71173c80e3a",
            _type: "block",
            children: [%{_key: "d6c419dcf485", _type: "span", marks: [], text: "Test paragraph."}],
            mark_defs: [],
            style: "normal"
          }
        ]
      }

      ~H"<Sanity.Components.PortableText.portable_text value={@portable_text} />"

  ### Custom marks

      defmodule CustomMark do
        use Phoenix.Component
        use PortableText

        @impl true
        def mark(%{mark_type: "em"} = assigns) do
          ~H"<em class="awesome-em"><%= render_slot(@inner_block) %></em>"
        end

        def mark(assigns), do: super(assigns)
      end

  Then render the component like:

      ~H"<Sanity.Components.PortableText.portable_text mod={CustomMark} value={@portable_text} />"
  """

  use Phoenix.Component

  require Logger

  defmodule Behaviour do
    @callback block(map()) :: Phoenix.LiveView.Rendered.t()
    @callback mark(map()) :: Phoenix.LiveView.Rendered.t()
    @callback type(map()) :: Phoenix.LiveView.Rendered.t()
  end

  @behaviour Behaviour

  defmacro __using__([]) do
    quote do
      @behaviour Sanity.Components.PortableText.Behaviour

      def block(assigns), do: Sanity.Components.PortableText.block(assigns)
      def mark(assigns), do: Sanity.Components.PortableText.mark(assigns)
      def type(assigns), do: Sanity.Components.PortableText.type(assigns)

      defoverridable Sanity.Components.PortableText.Behaviour
    end
  end

  @doc """
  Renders Sanity CMS portable text. See module doc for examples.
  """
  def portable_text(assigns) do
    mod = Map.get(assigns, :mod, __MODULE__)

    ~H"""
    <%= for block <- @value do %><.render_with mod={mod} func={:type} value={block} />
    <% end %>
    """
  end

  defp render_with(assigns) do
    {func, assigns} = Map.pop!(assigns, :func)

    apply(assigns.mod, func, [assigns])
  end

  defp shared_props(assigns), do: Map.take(assigns, [:mod, :value])

  @doc false
  @impl true
  def type(%{value: %{_type: "block"}} = assigns) do
    ~H"""
    <.render_with func={:block} {shared_props(assigns)}>
      <%= for child <- @value.children do %><.marks marks={child.marks} {shared_props(assigns)}><%= child.text %></.marks><% end %>
    </.render_with>
    """
  end

  def type(%{value: %{_type: type}} = assigns) do
    Logger.error("unknown type: #{inspect(type)}")

    ~H""
  end

  @doc false
  @impl true
  def block(%{value: %{_type: "block", style: style}} = assigns)
      when style in ["blockquote", "h1", "h2", "h3", "h4", "h5", "h6"] do
    ~H"""
    <%= Phoenix.HTML.Tag.content_tag style do %><%= render_slot(@inner_block) %><% end %>
    """
  end

  def block(%{value: %{_type: "block", style: "normal"}} = assigns) do
    ~H"""
    <p><%= render_slot(@inner_block) %></p>
    """
  end

  def block(%{value: %{_type: "block", style: style}} = assigns) do
    Logger.error("unknown block style: #{inspect(style)}")

    ~H"""
    <p><%= render_slot(@inner_block) %></p>
    """
  end

  defp marks(%{marks: []} = assigns) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  defp marks(%{marks: [mark | remaining_marks]} = assigns) do
    mark_props =
      case Enum.find(assigns.value.mark_defs, &(&1._key == mark)) do
        nil ->
          %{
            mark_key: mark,
            mark_type: mark,
            value: nil
          }

        %{_type: type} = mark_def ->
          %{
            mark_key: mark,
            mark_type: type,
            value: mark_def
          }
      end

    ~H"""
    <.render_with mod={@mod} func={:mark} {mark_props}><.marks marks={remaining_marks} {shared_props(assigns)}><%= render_slot(@inner_block) %></.marks></.render_with>
    """
  end

  @doc false
  @impl true
  def mark(%{mark_type: "em"} = assigns) do
    ~H"""
    <em><%= render_slot(@inner_block) %></em>
    """
  end

  def mark(%{mark_type: "strong"} = assigns) do
    ~H"""
    <strong><%= render_slot(@inner_block) %></strong>
    """
  end

  def mark(%{mark_type: "link", value: value} = assigns) do
    ~H"""
    <a href={value.href}><%= render_slot(@inner_block) %></a>
    """
  end

  def mark(%{mark_type: mark_type} = assigns) do
    Logger.error("unknown mark type: #{inspect(mark_type)}")

    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end
end
