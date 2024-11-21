defmodule AstExplorerWeb.AstExplorerLive do
  use AstExplorerWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, [ast: ast_to_json("")])
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

  def ast_to_json(ast) do
    ~s|[#{x(ast)}]| 
  end

  def handle_event("explore", params, socket) do
    IO.inspect(socket.assigns)
    code = Map.get(params, "code")
    IO.inspect(code, label: :code)
    ast = Code.string_to_quoted(code)
    
    socket = 
      assign(socket, [ast: ast_to_json(ast), code: code]) 
      |> push_event("ast-updated", %{ast: ast_to_json(ast)})
    IO.inspect(socket.assigns)
    {:noreply, socket}
  end

  def x(var) when is_tuple(var) do
    children = 
      var
      |> Tuple.to_list()
      |> Enum.map(fn var -> x(var) end)
    ~s|{ name: "(Map - X items)", children: [#{children}] }, \n|
  end

  def x(var) when is_list(var) do
    children = Enum.map(var, fn var -> x(var) end)
    ~s|{ name: "(list - X items)", children: [#{children}] }, \n|
  end

  def x(var) do
    ~s|{name: "#{var}", children: []}, \n|
  end

  def xs(var) do
    cond do
      is_tuple(var) ->
        var
        |> Tuple.to_list()
        |> Enum.map(fn var -> x(var) end)
        |> List.to_tuple()

      is_list(var) ->
        var
        |> Enum.map(fn var -> x(var) end)

      true ->
        var
    end
  end


end
