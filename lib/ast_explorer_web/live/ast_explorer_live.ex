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
    children =  [%{name: ":def", children: []}, 
                 %{name: "(list - 3 items)", children: []}, 
                 %{name: "(list - 3 items)", children: []}
                ]
    [ %{name: "ast (tuple)", children: children} ]
    |> Jason.encode!
  end

  def handle_event("explore", params, socket) do
    IO.inspect(socket.assigns)
    code = Map.get(params, "code")
    IO.inspect(code, label: :code)
    ast = Code.string_to_quoted(code)
    
    socket = 
      assign(socket, [ast: ast_to_json(ast), code: code]) 
      |> push_event("ast-updated", %{})
    IO.inspect(socket.assigns)
    {:noreply, socket}
  end
end
