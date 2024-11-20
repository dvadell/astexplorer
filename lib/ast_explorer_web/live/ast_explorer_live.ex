defmodule AstExplorerWeb.AstExplorerLive do
  use AstExplorerWeb, :live_view

  def mount(_params, _session, socket) do
    ast = Jason.encode!(%{"sample": "thing", "make": 1, "isi": %{"hey": "jude"}})
    socket = assign(socket, [ast: ast])
    {:ok, socket}
  end

  def handle_event("explore", params, socket) do
    IO.inspect(socket.assigns)
    code = Map.get(params, "code")
    IO.inspect(code, label: :code)
    #ast = Code.string_to_quoted(code)
    ast = Jason.encode!(%{"sample": "thing", "make": 1, "isi": %{"hey": "jude"}})
    socket = 
      assign(socket, [ast: ast, code: code]) 
      |> push_event("ast-updated", %{})
    IO.inspect(socket.assigns)
    {:noreply, socket}
  end
end
