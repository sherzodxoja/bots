defmodule TelegramProcessor do
	require Logger

	import TelegramResponse

	def decode(data, options) do
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
					spawn(TelegramProcessor, :process_messages, [list_of_updates, options])
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

	def process_messages(data, options) do
		commander = options[:commander]
		token = options[:token]
		#IO.puts "Data for processing " <> inspect data
		Enum.each(data, fn(update)->
			spawn(TelegramProcessor, :prepare_and_send, [commander, update, token])
		end)
	end

	def prepare_and_send(commander, update, token) do
		reply_msg = commander.get_response(update.message)
		send_message(token, reply_msg, update.message.chat.id)
	end

	defp send_message(token, msg, chat_id) when is_binary(msg) do
		send_message(token, {"", msg}, chat_id)
	end

	defp send_message(token, {parse_mode, msg} = msg_tuple, chat_id) when is_tuple(msg_tuple) do
		Logger.info "sending msg: " <> to_string(msg)
		url = HTTPotion.process_url("https://api.telegram.org/bot" <> token <> "/sendMessage", [query: %{text: msg, chat_id: chat_id, parse_mode: parse_mode}])
		#IO.puts inspect url
		response = HTTPotion.get url
		#IO.puts inspect response
	end
end