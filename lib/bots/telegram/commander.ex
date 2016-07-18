defmodule Bots.Telegram.Commander do


	def get_response(update) do
		IO.puts "msg: " <> inspect update
		cond do
			update["message"] ->
				message = update["message"]
				splited = String.split(message["text"], " ")
				command = hd(splited)
				chat_id = message["chat"]["id"]

				response = case command do
					"/hello"->
						{:send_message, %{text: "Hi, " <> message["from"]["first_name"], chat_id: chat_id}}
					c->
						{:send_message, %{text: "Unknown command: #{c}.", chat_id: chat_id}}
				end
		end
		
	end

end