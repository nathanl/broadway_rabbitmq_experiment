import Config

config :foo,
  rabbitmq_host: System.get_env("RABBITMQ_HOST", "localhost"),
  rabbitmq_port: String.to_integer(System.get_env("RABBITMQ_PORT", "5672")),
  rabbitmq_virtual_host: System.get_env("RABBITMQ_VIRTUAL_HOST", "/"),
  rabbitmq_username: System.get_env("RABBITMQ_USERNAME", "guest"),
  rabbitmq_password: System.get_env("RABBITMQ_PASSWORD", "guest"),
  exchange_name: System.get_env("RABBITMQ_EXCHANGE_NAME", "test_exchange"),
  queue_name: System.get_env("RABBITMQ_QUEUE_NAME", "test_queue")
