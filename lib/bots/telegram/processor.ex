defmodule Bots.Telegram.Processor do
	@moduledoc """
	Декодирует json-сообщения, делегирует готовые объекты нужному коммандеру и отправляет ответ на сервер Телеграма.

	Модуль Processor декодирует приходящее в виде json сообщение от Телеграма в структуру `Bots.Telegram.TelegramResponse` в соответствии с официальной документацией Bot API. После парсинга структура передаётся в отдельный поток, где передаётся в коммандер, заданный в опциях бота. После получения ответа от коммандера происходит отправка подготовленных данных на сервере Телеграма.
	"""
	require Logger

	
	@doc """
	Декодирование json-данных, пришедших методом webhook

	Данные декодируются в структуру `Map`. После успешного декодирования результат отправляется в отдельный поток с функцией `process_messages`
	"""
	def decode_webhook_data(data, options) do
		{:ok, decoded} = Poison.Parser.parse(data)
		spawn(__MODULE__, :process_messages, [[decoded], options])
	end	

	@doc """
	Декодирование json-данных, пришедших в ответ на запрос

	Данные декодируются в структуру `Map`. После успешного декодирования результат отправляется в отдельный поток с функцией `process_messages`. Более того, этот метод возвращает максимальный идентификатор объекта update среди пришедших.
	"""
	def decode_response_data(data, options) do
		{:ok, decoded} = Poison.Parser.parse(data)
		case decoded["ok"] do
			true ->
				list_of_updates = decoded["result"]
				if length(list_of_updates) > 0 do
					max = Enum.max_by(list_of_updates, fn(x)-> 
						x["update_id"]
					end)
					spawn(__MODULE__, :process_messages, [list_of_updates, options])
					max["update_id"]
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
		{response_type, map_of_query_fields} = commander.get_response(update)
		path = case response_type do
			:send_message->
				"sendMessage"
			:edit_text->
				"editMessageText"
			:inline->
				"answerInlineQuery"
		end
		url = HTTPotion.process_url("https://api.telegram.org/bot#{token}/#{path}")
		IO.puts "request : " <> inspect url
		
		encoded = URI.encode_query(map_of_query_fields)
		response = HTTPotion.post url, [body: encoded, headers: ['Content-Type': "application/x-www-form-urlencoded"]]
		IO.puts "response: " <> inspect response

	end

end