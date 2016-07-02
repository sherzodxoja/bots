defmodule TelegramCommander do

	import TelegramResponse

	def get_response(message) do
		command = message.text

		case command do
			"/hello"->
				"Hi, " <> message.from.first_name
			"/cat"->
				"dog"
			"/help"->
				"Available commands: \n/hello\tgreetings to you\n/cat\tshow products catalog"
			c->
				"Unknown command: " <> c <> ". Use /help and select proper command"
		end
	end
end