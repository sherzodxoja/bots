defmodule Bots.Telegram.Processor do
	import Bots.Telegram.TelegramResponse
	require Logger

	
	def decode_single_update(data, options) do
		{:ok, decoded} = Poison.decode(data, as: 
			%Bots.Telegram.TelegramResponse.Update {
				message: %Bots.Telegram.TelegramResponse.Message {
					chat: %Bots.Telegram.TelegramResponse.Chat{}, 
					from: %Bots.Telegram.TelegramResponse.User{}
				}
			}
		)
		spawn(__MODULE__, :process_messages, [[decoded], options])
	end	

	def decode(data, options) do
		{:ok, decoded} = Poison.decode(data, as: 
			%Bots.Telegram.TelegramResponse.Response {
				result: [
					%Bots.Telegram.TelegramResponse.Update {
						message: %Bots.Telegram.TelegramResponse.Message {
							chat: %Bots.Telegram.TelegramResponse.Chat{}, 
							from: %Bots.Telegram.TelegramResponse.User{}
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
					spawn(__MODULE__, :process_messages, [list_of_updates, options])
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
		Enum.each(data, fn(update)->
			spawn(__MODULE__, :prepare_and_send, [commander, update, token])
		end)
	end

	def prepare_and_send(commander, update, token) do
		reply_msg = commander.get_response(update)
		send_message(token, reply_msg, update.message.chat.id)
	end

	defp send_message(token, msg, chat_id) when is_binary(msg) do
		send_message(token, {"", msg}, chat_id)
	end

	defp send_message(token, {parse_mode, msg} = msg_tuple, chat_id) when is_tuple(msg_tuple) do
		Logger.info "sending msg: " <> to_string(msg)
		url = HTTPotion.process_url("https://api.telegram.org/bot" <> token <> "/sendMessage", [query: %{text: msg, chat_id: chat_id, parse_mode: parse_mode}])
		HTTPotion.get url
	end
end