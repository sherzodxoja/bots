defmodule Bots.WebSupervisor do
	use Supervisor

	def start_link() do
		Supervisor.start_link(__MODULE__, :ok)
	end

	def init(:ok) do
		cfg = case Application.get_env(:bots, :webserver) do
			:nil->
				[
					ssl: false,
					port: 8080,
					#port: 8443,
					#keyfile: "/root/bot/dev/plug1/private.key",
					#certfile: "/root/bot/dev/plug1/public.crt",
					#cacertfile: "/root/bot/dev/plug1/gd_bundle-g2-g1.crt",
				]
			config->
				config
		end
		children = [
			Plug.Adapters.Cowboy.child_spec((if cfg[:ssl] do :https else :http end), Bots.WebRouter, [], cfg)
		]
		supervise(children, strategy: :one_for_one)
	end
end