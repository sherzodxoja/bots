defmodule Bots.WebSupervisor do
	use Supervisor

	def start_link() do
		Supervisor.start_link(__MODULE__, :ok)
	end

	def init(:ok) do
		children = [
			Plug.Adapters.Cowboy.child_spec(:http, Bots.WebRouter, [], [
				port: 8080,
				#port: 8443, 
				#keyfile: "/root/bot/dev/plug1/private.key",
				#certfile: "/root/bot/dev/plug1/public.crt",
				#cacertfile: "/root/bot/dev/plug1/gd_bundle-g2-g1.crt",
				otp_app: :plug
			])
		]
		supervise(children, strategy: :one_for_one)
	end
end