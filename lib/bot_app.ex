defmodule BotApp do
	use Application

	def start(_type, _args) do
		BotSupervisor.start_link
	end
end
