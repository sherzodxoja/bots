defmodule Bots do
	@moduledoc """
	Here entry point of application. It's starting root supervisor.
	"""
	use Application

	def start(_type, _args) do
		Supervisor.start_link(Bots.RootSupervisor, [], [])
	end
end
