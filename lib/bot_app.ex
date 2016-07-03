defmodule BotApp do
	use Application
	require Logger

	def start(_type, _args) do
		case Application.get_env(:bots, :bots_spec) do
			list_of_bots when is_list(list_of_bots) and length(list_of_bots) > 0 ->
				BotSupervisor.start_link list_of_bots
			_->
				Logger.info "No bots specifications to start"
		end
	end
end
