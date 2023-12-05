defmodule AdventServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: Groat.AdventServer.TaskSupervisor},
      Supervisor.child_spec({Task, fn -> Groat.AdventServer.accept(port) end}, restart: :permanent)
    ]
    opts = [strategy: :one_for_one, name: Groat.AdventServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
