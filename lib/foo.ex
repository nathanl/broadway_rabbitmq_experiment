defmodule Foo do
  @moduledoc """
  Documentation for `Foo`.
  """

  def with_chan(func) do
    {:ok, conn} = AMQP.Connection.open(conn_options())
    {:ok, chan} = AMQP.Channel.open(conn)
    func.(chan)
    AMQP.Channel.close(chan)
    AMQP.Connection.close(conn)
  end

  def send_messages(count) when is_integer(count) and count > 0 do
    with_chan(fn chan ->
      for i <- 1..count do
        AMQP.Basic.publish(chan, env!(:exchange_name), "", "#{i}")
      end
    end)
  end

  def purge do
    with_chan(fn chan ->
      AMQP.Queue.purge(chan, env!(:queue_name))
    end)
  end

  def conn_options do
    [
      host: env!(:rabbitmq_host),
      port: env!(:rabbitmq_port),
      virtual_host: env!(:rabbitmq_virtual_host),
      username: env!(:rabbitmq_username),
      password: env!(:rabbitmq_password)
    ]
  end

  def env!(key) do
    Application.fetch_env!(:foo, key)
  end
end
