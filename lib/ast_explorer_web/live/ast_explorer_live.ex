defmodule AstExplorerWeb.AstExplorerLive do
  use AstExplorerWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, [ast: "[]", orig_ast: ""])
    {:ok, socket}
  end

  # Create a function that turns the ast into
  # [
  #   {name: "ast (tuple)", children: [
  #     {name: ":def", children: []}, 
  #     {name: "(list - 3 items)", children: []}, 
  #     {name: "list... - 3 items", children: []}
  #   ]}
  # ]

  def ast_to_json(ast, _) do
    ~s|[#{x(ast)}]| 
  end

  def handle_event("explore", params, socket) do
    IO.inspect(socket.assigns)
    code = Map.get(params, "code")
    IO.inspect(code, label: :code)
    ast = Code.string_to_quoted(code)
    force_expanded = Map.get(params, "force_expanded")
    
    socket = 
      assign(socket, [ast: ast_to_json(ast, force_expanded: force_expanded), code: code]) 
      |> assign(orig_ast: "#{inspect(ast)}")
      |> push_event("ast-updated", %{ast: ast_to_json(ast, force_expanded: force_expanded)})
    IO.inspect(socket.assigns)
    {:noreply, socket}
  end

  def x(var) when is_tuple(var) do
    len = Tuple.to_list(var) |> length
    node =
    case var do
      {atom, [{:line, n}], rest} when is_atom(atom) -> %{name: ":#{atom} // Line #{n}", data: {rest}}
      _ -> %{name: "TUPLE(#{len})", data: var}
    end

    children = 
      node.data
        |> Tuple.to_list()
        |> Enum.map(fn var -> x(var) end)

    ~s|{ name: "#{node.name}", children: [#{children}] }, \n|
  end

  def x(var, [line: n]) when is_tuple(var) do
    len = Tuple.to_list(var) |> length
    ~s|{ name: " - Line #{n} - (#{len})", children: [] }, \n|
  end

  def x(var) when is_list(var) do
    len = length(var)
    case len do
      0 -> ~s|{ name: "- (empty list)", children: [] }, \n|
      len -> 
        children = Enum.map(var, fn var -> x(var) end)
        ~s|{ name: "LIST(#{len})", children: [#{children}] }, \n|
    end
  end

  def x(var) when is_atom(var) do
    ~s|{name: " - :#{var}", children: []}, \n|
  end

  def x(var) do
    ~s|{name: "#{var}", children: []}, \n|
  end
end
