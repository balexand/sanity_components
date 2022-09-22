defmodule Sanity.Components.PortableText do
  @moduledoc ~S'''
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

  ### Custom rendering

      defmodule CustomBlock do
        use Phoenix.Component
        use Sanity.Components.PortableText

        @impl true
        def block(%{value: %{style: "normal"}} = assigns) do
          ~H"""
          <div class="custom-normal"><%= render_slot(@inner_block) %></div>
          """
        end

        def block(assigns), do: super(assigns)
      end

  Then render the component like:

      ~H"<Sanity.Components.PortableText.portable_text mod={CustomBlock} value={@portable_text} />"

  Similarly, marks and types can be customized by defining `mark/1` and `type/1` functions in the module.
  '''

  use Phoenix.Component

  require Logger

  defmodule Behaviour do
    @moduledoc false

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

  attr :value, :any, required: true
  attr :mod, :atom, default: __MODULE__

  def portable_text(assigns) do
    ~H"""
    <%= for group <- blocks_to_nested_lists(@value) do %><.blocks_or_list mod={@mod} value={group} /><% end %>
    """
  end

  @doc """
  Converts list of blocks to plain text.
  """
  def to_plain_text(blocks) when is_list(blocks) do
    blocks
    |> Enum.filter(fn
      %{_type: "block", children: [_ | _]} -> true
      _ -> false
    end)
    |> Enum.map(fn %{children: children} ->
      children
      |> Enum.map(fn
        %{_type: "span", text: text} -> text
        _ -> ""
      end)
      |> Enum.join(" ")
    end)
    |> Enum.join("\n\n")
  end

  defp blocks_to_nested_lists(blocks) do
    blocks
    |> Enum.chunk_by(fn block -> block[:list_item] end)
    |> Enum.map(fn
      [%{list_item: list_item} | _] = items when not is_nil(list_item) ->
        nest_list(items, %{type: list_item, level: 1, items: []})

      [%{} | _] = blocks ->
        %{type: "blocks", items: blocks}
    end)
  end

  defp nest_list([], acc) do
    update_in(acc.items, &Enum.reverse/1)
  end

  defp nest_list([%{level: level} = item | rest], %{level: level} = acc) do
    nest_list(rest, prepend_to_list(item, acc))
  end

  defp nest_list([%{level: level, list_item: list_item} | _] = items, acc)
       when level > acc.level do
    {deeper_items, rest} = Enum.split_while(items, fn i -> i.level > acc.level end)

    sub_list = nest_list(deeper_items, %{type: list_item, level: acc.level + 1, items: []})

    acc =
      case acc do
        %{items: [last_item | acc_rest]} ->
          put_in(acc.items, [Map.put(last_item, :sub_list, sub_list) | acc_rest])

        %{items: []} ->
          empty_list_block(%{level: acc.level + 1, list_item: acc.type})
          |> Map.put(:sub_list, sub_list)
          |> prepend_to_list(acc)
      end

    nest_list(rest, acc)
  end

  defp empty_list_block(%{level: level, list_item: list_item}) do
    %{
      _key: :crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower),
      _type: "block",
      children: [],
      level: level,
      list_item: list_item,
      mark_defs: [],
      style: "normal"
    }
  end

  defp prepend_to_list(item, %{items: items} = list), do: %{list | items: [item | items]}

  defp render_with(assigns) do
    {func, assigns} = Map.pop!(assigns, :func)

    apply(assigns.mod, func, [assigns])
  end

  defp shared_props(assigns), do: Map.take(assigns, [:mod, :value])

  defp blocks_or_list(%{value: %{type: "blocks"}} = assigns) do
    ~H"""
    <%= for block <- @value.items do %>
      <.render_with mod={@mod} func={:type} value={block} />
    <% end %>
    """
  end

  defp blocks_or_list(%{value: %{type: "bullet"}} = assigns) do
    ~H"""
    <ul>
      <%= for item <- @value.items do %>
        <.list_item mod={@mod} value={item} />
      <% end %>
    </ul>
    """
  end

  defp blocks_or_list(%{value: %{type: "number"}} = assigns) do
    ~H"""
    <ol>
      <%= for item <- @value.items do %>
        <.list_item mod={@mod} value={item} />
      <% end %>
    </ol>
    """
  end

  defp list_item(assigns) do
    ~H"""
    <li>
      <.children {shared_props(assigns)} />
      <%= if @value[:sub_list] do %><.blocks_or_list mod={@mod} value={@value.sub_list} /><% end %>
    </li>
    """
  end

  defp children(assigns) do
    ~H"""
    <%= for child <- @value.children do %><.marks marks={child.marks} {shared_props(assigns)}><%= child.text %></.marks><% end %>
    """
  end

  @doc false
  @impl true
  def type(%{value: %{_type: "block"}} = assigns) do
    ~H"""
    <.render_with func={:block} {shared_props(assigns)}>
      <.children {shared_props(assigns)} />
    </.render_with>
    """
  end

  def type(%{value: %{_type: type}} = assigns) do
    Logger.warn("unknown type: #{inspect(type)}")

    ~H""
  end

  @doc false
  @impl true
  def block(%{value: %{_type: "block", style: style}} = assigns)
      when style in ["blockquote", "h1", "h2", "h3", "h4", "h5", "h6"] do
    ~H"""
    <.dynamic_tag name={@value.style}><%= render_slot(@inner_block) %></.dynamic_tag>
    """
  end

  def block(%{value: %{_type: "block", style: "normal"}} = assigns) do
    ~H"""
    <p><%= render_slot(@inner_block) %></p>
    """
  end

  def block(%{value: %{_type: "block", style: style}} = assigns) do
    Logger.warn("unknown block style: #{inspect(style)}")

    ~H"""
    <p><%= render_slot(@inner_block) %></p>
    """
  end

  defp marks(%{marks: []} = assigns) do
    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end

  defp marks(%{marks: [_ | _]} = assigns) do
    ~H"""
    <.render_with mod={@mod} func={:mark} {mark_props(@value.mark_defs, List.first(@marks))}><.marks marks={remaining_marks(@marks)} {shared_props(assigns)}><%= render_slot(@inner_block) %></.marks></.render_with>
    """
  end

  defp mark_props(mark_defs, mark) do
    case Enum.find(mark_defs, &(&1._key == mark)) do
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
  end

  defp remaining_marks([_first | remaining]), do: remaining

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

  def mark(%{mark_type: "link"} = assigns) do
    ~H"""
    <a href={@value.href}><%= render_slot(@inner_block) %></a>
    """
  end

  def mark(%{mark_type: mark_type} = assigns) do
    Logger.warn("unknown mark type: #{inspect(mark_type)}")

    ~H"""
    <%= render_slot(@inner_block) %>
    """
  end
end
