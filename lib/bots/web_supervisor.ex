defmodule Bots.WebSupervisor do
	use Supervisor

	def start_link() do
		Supervisor.start_link(__MODULE__, :ok)
	end

	def init(:ok) do
		cfg = case Application.get_env(:bots, :webserver) do
			:nil->
				[port: 8080]
			config->
				config
		end
		children = [
			Plug.Adapters.Cowboy.child_spec((if cfg[:keyfile] do :https else :http end), Bots.WebRouter, [], cfg)
		]
		supervise(children, strategy: :one_for_one)
	end
end