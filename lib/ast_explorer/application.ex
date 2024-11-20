defmodule AstExplorer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AstExplorerWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:ast_explorer, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AstExplorer.PubSub},
      # Start a worker by calling: AstExplorer.Worker.start_link(arg)
      # {AstExplorer.Worker, arg},
      # Start to serve requests, typically the last entry
      AstExplorerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AstExplorer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AstExplorerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
