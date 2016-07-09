defmodule Bots do
	@moduledoc """
	This module is the application, wich starts supervisor for bots and supervisor for web-server. Supervisors started only when at least one bot specification is presend in `:bots_spec` variable.
	"""
	use Application
	require Logger

	def start(_type, _args) do
		case Application.get_env(:bots, :bots_spec) do
			list_of_bots when is_list(list_of_bots) and length(list_of_bots) > 0 ->
				Bots.BotsSupervisor.start_link list_of_bots
			_->
				Logger.info "No bots specifications to start"
		end
		Bots.WebSupervisor.start_link
	end
end
