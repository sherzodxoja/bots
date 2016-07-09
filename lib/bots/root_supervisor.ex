defmodule Bots.RootSupervisor do
	@moduledoc """
	This module is the main supervisor of application, wich starts supervisor for bots and supervisor for web-server. Bots specification can be present in `:bots_spec` variable.
	"""
	use Supervisor

	
	def init(_) do
		list_of_bots = case Application.get_env(:bots, :bots_spec) do
			bots_spec when is_list(bots_spec) and length(bots_spec) > 0 ->
				bots_spec
			_->
				[]
		end		

		children = [
			supervisor(Bots.BotsSupervisor, [list_of_bots]),
			supervisor(Bots.WebSupervisor, [])
		]
		supervise(children, strategy: :one_for_one)
	end


end