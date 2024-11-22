defmodule AstExplorerWeb.AstExplorerLive do
  use AstExplorerWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, [ast: "[]"])
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
      |> push_event("ast-updated", %{ast: ast_to_json(ast, force_expanded: force_expanded)})
    IO.inspect(socket.assigns)
    {:noreply, socket}
  end

  def x(var) when is_tuple(var) do
    node =
    case var do
      {atom, [{:line, n}], rest} -> %{name: "Line #{n}", data: {atom, rest}}
      _ -> %{name: "{...}", data: var}
    end

    len = Tuple.to_list(node.data) |> length
    children = 
      node.data
        |> Tuple.to_list()
        |> Enum.map(fn var -> x(var) end)

    ~s|{ name: "#{node.name} - #{len} items", children: [#{children}] }, \n|
  end

  def x(var, [line: n]) when is_tuple(var) do
    len = Tuple.to_list(var) |> length
    ~s|{ name: "Line #{n} - #{len} items", children: [] }, \n|
  end

  def x(var) when is_list(var) do
    len = length(var)
    children = Enum.map(var, fn var -> x(var) end)
    ~s|{ name: "[...] - #{len} items", children: [#{children}] }, \n|
  end

  def x(var) when is_atom(var) do
    ~s|{name: ":#{var}", children: []}, \n|
  end

  def x(var) do
    ~s|{name: "#{var}", children: []}, \n|
  end
end
