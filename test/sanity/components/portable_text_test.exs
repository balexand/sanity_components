defmodule Sanity.Components.PortableTextTest do
  use ExUnit.Case, async: true
  doctest Sanity.Components.PortableText, import: true

  import ExUnit.CaptureLog
  import Phoenix.LiveViewTest
  alias Sanity.Components.PortableText

  @bold_and_italic [
    %{
      _key: "0e433bfe8d37",
      _type: "block",
      children: [
        %{_key: "bf904e7ae769", _type: "span", marks: [], text: "A "},
        %{_key: "a9e4523a1984", _type: "span", marks: ["strong"], text: "bold"},
        %{_key: "a864a6b825c9", _type: "span", marks: [], text: " "},
        %{_key: "8c568c366e65", _type: "span", marks: ["strong", "em"], text: "word"}
      ],
      mark_defs: [],
      style: "normal"
    }
  ]

  # Along with bold and italic, these are the marks which the Sanity editor supports by default
  @default_marks [
    %{
      _key: "cac150e65d8a",
      _type: "block",
      children: [
        %{_key: "12b6b9acccc7", _type: "span", marks: [], text: "normal "},
        %{
          _key: "76e4da946506",
          _type: "span",
          marks: ["underline"],
          text: "underline"
        },
        %{_key: "4fe55bc49e50", _type: "span", marks: [], text: " "},
        %{
          _key: "4e5b993c130a",
          _type: "span",
          marks: ["strike-through"],
          text: "strike"
        },
        %{_key: "75c152797366", _type: "span", marks: [], text: " "},
        %{_key: "1c23c2bdba45", _type: "span", marks: ["code"], text: "code"}
      ],
      mark_defs: [],
      style: "normal"
    }
  ]

  @blocks [
    %{
      _key: "4a62e0041050",
      _type: "block",
      children: [%{_key: "20845d169dc5", _type: "span", marks: [], text: "Head 1"}],
      mark_defs: [],
      style: "h1"
    },
    %{
      _key: "898752680f4f",
      _type: "block",
      children: [%{_key: "e9a629c69fab", _type: "span", marks: [], text: "Head 2"}],
      mark_defs: [],
      style: "h2"
    },
    %{
      _key: "a5259c951f4b",
      _type: "block",
      children: [%{_key: "886cd84f0a27", _type: "span", marks: [], text: "Head 3"}],
      mark_defs: [],
      style: "h3"
    },
    %{
      _key: "c8930db254f2",
      _type: "block",
      children: [%{_key: "3df7f2c64b07", _type: "span", marks: [], text: "Head 4"}],
      mark_defs: [],
      style: "h4"
    },
    %{
      _key: "9dac9ee32a94",
      _type: "block",
      children: [%{_key: "23a089a0b2fa", _type: "span", marks: [], text: "Head 5"}],
      mark_defs: [],
      style: "h5"
    },
    %{
      _key: "618f7b2f4b56",
      _type: "block",
      children: [%{_key: "f89f9f49000f", _type: "span", marks: [], text: "Head 6"}],
      mark_defs: [],
      style: "h6"
    },
    %{
      _key: "64cd30315558",
      _type: "block",
      children: [%{_key: "c9a8e699d5ec", _type: "span", marks: [], text: "quote"}],
      mark_defs: [],
      style: "blockquote"
    }
  ]

  @hard_breaks [
    %{
      _key: "c4cbfecb933e",
      _type: "block",
      children: [
        %{
          _key: "e1486a7850340",
          _type: "span",
          marks: [],
          text: "line1\nline2\n\nline3"
        }
      ],
      markDefs: [],
      style: "normal"
    }
  ]

  @image [
    %{
      _key: "d92a081af9f1",
      _type: "image",
      asset: %{
        _ref: "image-da994d9e87efb226111cb83dbbab832d45b1365e-1500x750-jpg",
        _type: "reference"
      }
    }
  ]

  @link [
    %{
      _key: "0e433bfe8d37",
      _type: "block",
      children: [%{_key: "47ea34958f3b", _type: "span", marks: ["7f977121c20a"], text: "my link"}],
      mark_defs: [%{_key: "7f977121c20a", _type: "link", href: "http://example.com/"}],
      style: "normal"
    }
  ]

  @lists [
    %{
      _key: "2cd554b8888a",
      _type: "block",
      children: [
        %{_key: "a62c8ea8edfb", _type: "span", marks: [], text: "paragraph"}
      ],
      mark_defs: [],
      style: "normal"
    },
    %{
      _key: "1e3423161b22",
      _type: "block",
      children: [%{_key: "909d56f6e943", _type: "span", marks: [], text: "b1"}],
      level: 1,
      list_item: "bullet",
      mark_defs: [],
      style: "normal"
    },
    %{
      _key: "ac40b45bdd3d",
      _type: "block",
      children: [%{_key: "3ab5b9a1317d", _type: "span", marks: [], text: "b2"}],
      level: 1,
      list_item: "bullet",
      mark_defs: [],
      style: "normal"
    },
    %{
      _key: "d33bfd25f1de",
      _type: "block",
      children: [%{_key: "2f4f7d0a6f6c", _type: "span", marks: [], text: "b3"}],
      level: 3,
      list_item: "bullet",
      mark_defs: [],
      style: "normal"
    },
    %{
      _key: "413f085a7217",
      _type: "block",
      children: [%{_key: "a1cf6b208373", _type: "span", marks: [], text: "one"}],
      level: 1,
      list_item: "number",
      mark_defs: [],
      style: "normal"
    },
    %{
      _key: "032199b04a97",
      _type: "block",
      children: [%{_key: "1c07f14262aa", _type: "span", marks: [], text: "aaa"}],
      level: 2,
      list_item: "number",
      mark_defs: [],
      style: "normal"
    },
    %{
      _key: "8df4318762fb",
      _type: "block",
      children: [%{_key: "a1739b477855", _type: "span", marks: [], text: "two"}],
      level: 1,
      list_item: "number",
      mark_defs: [],
      style: "normal"
    }
  ]

  @paragraph [
    %{
      _key: "f71173c80e3a",
      _type: "block",
      children: [%{_key: "d6c419dcf485", _type: "span", marks: [], text: "Test paragraph."}],
      mark_defs: [],
      style: "normal"
    }
  ]

  @unknown_block [
    %{
      _key: "f71173c80e3a",
      _type: "block",
      children: [%{_key: "d6c419dcf485", _type: "span", marks: [], text: "Test paragraph."}],
      mark_defs: [],
      style: "style-x"
    }
  ]

  @unknown_mark [
    %{
      _key: "2c5a598e37ca",
      _type: "block",
      children: [
        %{_key: "cd98c64ed2fb", _type: "span", marks: [], text: "A "},
        %{
          _key: "61800f03d7ef",
          _type: "span",
          marks: ["light"],
          text: "mark"
        },
        %{_key: "fc8987aec34a", _type: "span", marks: [], text: "."}
      ],
      mark_defs: [],
      style: "normal"
    }
  ]

  test "to_plain_text" do
    assert PortableText.to_plain_text(@blocks) ==
             "Head 1\n\nHead 2\n\nHead 3\n\nHead 4\n\nHead 5\n\nHead 6\n\nquote"
  end

  defmodule CustomBlock do
    use Phoenix.Component
    use PortableText

    @impl true
    def block(%{value: %{style: "normal"}} = assigns) do
      ~H"""
      <div class="custom-normal"><%= render_slot(@inner_block) %></div>
      """
    end

    def block(assigns), do: super(assigns)
  end

  defmodule CustomMark do
    use Phoenix.Component
    use PortableText

    @impl true
    def mark(%{mark_type: "em"} = assigns) do
      ~H"""
      <em class="awesome-em"><%= render_slot(@inner_block) %></em>
      """
    end

    def mark(assigns), do: super(assigns)
  end

  defmodule CustomType do
    use Phoenix.Component
    use PortableText

    @impl true
    def type(%{value: %{_type: "image"}} = assigns) do
      ~H"""
      <img src={@value.asset._ref} />
      """
    end

    def type(assigns), do: super(assigns)
  end

  defp render_trimmed(component, assigns, opts \\ []) do
    result =
      render_component(component, assigns)
      |> String.split("\n")
      |> Enum.map(fn string ->
        case Keyword.get(opts, :trim, :trailing) do
          :both -> String.trim(string)
          :trailing -> String.trim_trailing(string)
        end
      end)
      |> Enum.join("\n")
      |> String.trim()

    result <> "\n"
  end

  test "blocks" do
    assert render_trimmed(&PortableText.portable_text/1, [value: @blocks], trim: :both) == """
           <h1>
           Head 1
           </h1>

           <h2>
           Head 2
           </h2>

           <h3>
           Head 3
           </h3>

           <h4>
           Head 4
           </h4>

           <h5>
           Head 5
           </h5>

           <h6>
           Head 6
           </h6>

           <blockquote>
           quote
           </blockquote>
           """
  end

  test "bold_and_italic" do
    assert render_trimmed(&PortableText.portable_text/1, value: @bold_and_italic) == """
           <p>
             A <strong>bold</strong> <strong><em>word</em></strong>
           </p>
           """
  end

  test "default marks" do
    assert render_trimmed(&PortableText.portable_text/1, value: @default_marks) == """
           <p>
             normal <u>underline</u> <del>strike</del> <code>code</code>
           </p>
           """
  end

  test "custom block" do
    assert render_trimmed(&PortableText.portable_text/1, mod: CustomBlock, value: @paragraph) ==
             """
             <div class="custom-normal">
               Test paragraph.
             </div>
             """
  end

  test "custom mark" do
    assert render_trimmed(&PortableText.portable_text/1,
             mod: CustomMark,
             value: @bold_and_italic
           ) ==
             """
             <p>
               A <strong>bold</strong> <strong><em class="awesome-em">word</em></strong>
             </p>
             """
  end

  test "custom type image" do
    assert render_trimmed(&PortableText.portable_text/1, mod: CustomType, value: @image) ==
             """
             <img src="image-da994d9e87efb226111cb83dbbab832d45b1365e-1500x750-jpg">
             """
  end

  test "hard breaks" do
    assert render_trimmed(&PortableText.portable_text/1, value: @hard_breaks) ==
             """
             <p>
               line1<br>line2<br><br>line3
             </p>
             """
  end

  test "link" do
    assert render_trimmed(&PortableText.portable_text/1, value: @link) == """
           <p>
             <a href="http://example.com/">my link</a>
           </p>
           """
  end

  test "lists" do
    assert render_trimmed(&PortableText.portable_text/1, [value: @lists], trim: :both) == """
           <p>
           paragraph
           </p>
           <ul>

           <li>
           b1

           </li>

           <li>
           b2
           <ul>

           <li>

           <ul>

           <li>
           b3

           </li>

           </ul>
           </li>

           </ul>
           </li>

           </ul><ol>

           <li>
           one
           <ol>

           <li>
           aaa

           </li>

           </ol>
           </li>

           <li>
           two

           </li>

           </ol>
           """
  end

  test "list with marks" do
    value = [
      %{
        _key: "6d8b7dc4b0ef",
        _type: "block",
        children: [
          %{_key: "9dc4cbbe5ae4", _type: "span", marks: ["strong"], text: "bold"}
        ],
        level: 1,
        list_item: "number",
        mark_defs: [],
        style: "normal"
      }
    ]

    assert render_trimmed(&PortableText.portable_text/1, value: value) == """
           <ol>

               <li>
             <strong>bold</strong>

           </li>

           </ol>
           """
  end

  test "paragraph" do
    assert render_component(&PortableText.portable_text/1, value: @paragraph) == """

             <p>
             Test paragraph.
           </p>
           """
  end

  test "unknown block" do
    log =
      capture_log([level: :warning], fn ->
        assert render_trimmed(&PortableText.portable_text/1, value: @unknown_block) == """
               <p>
                 Test paragraph.
               </p>
               """
      end)

    assert log =~ ~S'[warning] unknown block style: "style-x"'
  end

  test "unknown mark" do
    log =
      capture_log([level: :warning], fn ->
        assert render_trimmed(&PortableText.portable_text/1, value: @unknown_mark) == """
               <p>
                 A mark.
               </p>
               """
      end)

    assert log =~ ~S'[warning] unknown mark type: "light"'
  end

  test "unknown type" do
    log =
      capture_log([level: :warning], fn ->
        assert render_trimmed(&PortableText.portable_text/1, value: @image) == "\n"
      end)

    assert log =~ ~S'[warning] unknown type: "image"'
  end

  defmodule AssertAssignsBlock do
    use Phoenix.Component
    use PortableText

    @impl true
    def block(assigns) do
      assert Map.keys(assigns) |> Enum.sort() == [:__changed__, :inner_block, :mod, :value]

      assert Map.take(assigns, [:value]) == %{
               value: %{
                 _key: "f71173c80e3a",
                 _type: "block",
                 children: [
                   %{_key: "d6c419dcf485", _type: "span", marks: [], text: "Test paragraph."}
                 ],
                 mark_defs: [],
                 style: "normal"
               }
             }

      ~H""
    end
  end

  defmodule AssertAssignsMark do
    use Phoenix.Component
    use PortableText

    @impl true
    def mark(assigns) do
      assert Map.keys(assigns) |> Enum.sort() == [
               :__changed__,
               :inner_block,
               :mark_key,
               :mark_type,
               :mod,
               :value
             ]

      assert Map.take(assigns, [:mark_key, :mark_type, :value]) == %{
               mark_key: "7f977121c20a",
               mark_type: "link",
               value: %{
                 _key: "7f977121c20a",
                 _type: "link",
                 href: "http://example.com/"
               }
             }

      ~H"x"
    end
  end

  defmodule AssertAssignsType do
    use Phoenix.Component
    use PortableText

    @impl true
    def type(assigns) do
      assert Map.keys(assigns) |> Enum.sort() == [:__changed__, :mod, :value]

      assert Map.take(assigns, [:value]) == %{
               value: %{
                 _key: "d92a081af9f1",
                 _type: "image",
                 asset: %{
                   _ref: "image-da994d9e87efb226111cb83dbbab832d45b1365e-1500x750-jpg",
                   _type: "reference"
                 }
               }
             }

      ~H""
    end
  end

  describe "assigns passed to custom handlers" do
    test "block" do
      assert render_trimmed(&PortableText.portable_text/1,
               mod: AssertAssignsBlock,
               value: @paragraph
             ) == "\n"
    end

    test "mark" do
      assert render_trimmed(&PortableText.portable_text/1, mod: AssertAssignsMark, value: @link) ==
               "<p>\n  x\n</p>\n"
    end

    test "type" do
      assert render_trimmed(&PortableText.portable_text/1, mod: AssertAssignsType, value: @image) ==
               "\n"
    end
  end
end
