defmodule Foo.Pipeline do
  @moduledoc """
  Broadway pipeline
  """
  use Broadway

  @processor_concurrency 10

  def start_link(_opts) do
    Broadway.start_link(
      __MODULE__,
      name: __MODULE__,
      producer: [
        module:
          {BroadwayRabbitMQ.Producer,
           queue: Foo.env!(:queue_name),
           connection: Foo.conn_options(),
           qos: [
             # this should never be less than @processor_concurrency
             # or else the processors won't all get messages
             prefetch_count: @processor_concurrency
           ],
           on_failure: :reject},
        concurrency: 1, # correct behavior
        # concurrency: 10, # try this for poor performance
      ],
      processors: [
        default: [
          concurrency: @processor_concurrency,
          max_demand: 1
        ]
      ]
    )
  end

  def handle_message(_processor_name, %{data: data} = message, _context) do
    message_count = get_message_count()

    IO.inspect(
      "processor #{inspect(self())} got '#{data}'; has #{message_count} message(s) in its mailbox"
    )

    simulate_work(data)

    message
  end

  defp get_message_count do
    {:messages, m} = :erlang.process_info(self(), :messages)
    Enum.count(m)
  end

  # Our actual workload is IO-bound
  defp simulate_work(data) do
    Process.sleep(1_000)
  end
end
