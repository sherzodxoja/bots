defmodule Bots.Telegram.Processor do
	@moduledoc """
	Декодирует json-сообщения, делегирует готовые объекты нужному коммандеру и отправляет ответ на сервер Телеграма.

	Модуль Processor декодирует приходящее в виде json сообщение от Телеграма в структуру `Bots.Telegram.TelegramResponse` в соответствии с официальной документацией Bot API. После парсинга структура передаётся в отдельный поток, где передаётся в коммандер, заданный в опциях бота. После получения ответа от коммандера происходит отправка подготовленных данных на сервере Телеграма.
	"""
	import Bots.Telegram.TelegramResponse
	require Logger

	
	@doc """
	Декодирование json-данных, пришедших методом webhook

	Данные декодируются в структуру `Bots.Telegram.TelegramResponse`. После успешного декодирования результат отправляется в отдельный поток с функцией `process_messages`
	"""
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

	@doc """
	Декодирование json-данных, пришедших в ответ на запрос

	Данные декодируются в структуру `Bots.Telegram.TelegramResponse`. После успешного декодирования результат отправляется в отдельный поток с функцией `process_messages`. Более того, этот метод возвращает максимальный идентификатор объекта update среди пришедших.
	"""
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

	@doc """
	Параллельная обработка сообщений

	В опциях должен быть представлен коммандер для обработки сообщения и токен для отправки ответа. Каждое сообщение из массива выполняется в своём потоке.
	"""
	def process_messages(data, options) do
		commander = options[:commander]
		token = options[:token]
		Enum.each(data, fn(update)->
			spawn(__MODULE__, :prepare_and_send, [commander, update, token])
		end)
	end

	@doc """
	Получение ответа от коммандера и передача его в метод отправки
	"""
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