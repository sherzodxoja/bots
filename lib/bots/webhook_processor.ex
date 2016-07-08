defmodule Bots.WebhookProcessor do
	import Plug.Conn
	require Logger

	@maximum_body_size_allowed 1_000_000

	def process(bot_name, conn) do
		Logger.info "new message for bot " <> bot_name
		{:ok, body, _} = read_body(conn, length: @maximum_body_size_allowed)
		spawn(Bots.BotsSupervisor, :send_msg_to_worker, [bot_name, body])
		send_resp(conn, 200, "")
	end

end