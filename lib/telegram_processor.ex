defmodule TelegramProcessor do
	require Logger

	import TelegramResponse

	def decode(token, data) do
		{:ok, decoded} = Poison.decode(data, as: 
			%TelegramResponse.Response{
				result: [
					%TelegramResponse.Update{
						message: %TelegramResponse.Message{
							chat: %TelegramResponse.Chat{}, 
							from: %TelegramResponse.User{}
						}
					}
				]
			}
		)
		case decoded.ok do
			true ->
				list_of_updates = decoded.result
				if length(list_of_updates) > 0 do
					max = Enum.max_by(list_of_updates, fn(x)-> 
						x.update_id
					end)
					spawn(TelegramProcessor, :process_messages, [token, list_of_updates])
					max.update_id
				else
					Logger.info "no new messages"
					:nil
				end
			_->
				Logger.error "bad response"
				:nil
		end
	end

	def process_messages(token, data) do
		#IO.puts "Data for processing " <> inspect data
		# Need parallel execution here
		Enum.each(data, fn(update)->
			reply_msg = TelegramCommander.get_response(update.message)
			send_message(token, reply_msg, update.message.chat.id)
		end)
	end

	defp send_message(token, msg, chat_id) do
		Logger.info "sending msg: " <> to_string(msg)
		url = HTTPotion.process_url("https://api.telegram.org/bot" <> token <> "/sendMessage", [query: %{text: msg, chat_id: chat_id}])
		#IO.puts inspect url
		response = HTTPotion.get url
		#IO.puts inspect response
	end
end