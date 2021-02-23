defmodule Foo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @doc ~S"""
  The entrypoint for the application
  """
  def start(_type, _args) do
    children = [
      Foo.Pipeline
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, restart: :permanent, name: Foo.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
