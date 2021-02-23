defmodule Mix.Tasks.SetupRabbitmq do
  @moduledoc "Sets up a demo RabbitMQ exchange and queue"
  use Mix.Task

  @shortdoc @moduledoc
  def run(_) do
    Mix.Task.run("app.config")
    {:ok, conn} = AMQP.Connection.open()
    {:ok, chan} = AMQP.Channel.open(conn)
    AMQP.Exchange.declare(chan, Foo.env!(:exchange_name))
    AMQP.Queue.declare(chan, Foo.env!(:queue_name))
    AMQP.Queue.bind(chan, Foo.env!(:queue_name), Foo.env!(:exchange_name))
  end
end
