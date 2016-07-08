defmodule Bots.WebRouter do
	use Plug.Router

	plug :match
	plug :dispatch

	post "/bot/:name", do: Bots.WebhookProcessor.process(name, conn)

	match _, do: send_resp(conn, 404, "not found")
end
