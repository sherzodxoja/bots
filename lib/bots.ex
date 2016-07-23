defmodule Bots do
	@moduledoc """
	Данный метод является точкой отсчета. Здесь создается Supervisor для нашего бота.
	"""
	use Application

	def start(_type, _args) do
		Supervisor.start_link(Bots.RootSupervisor, [], [])
	end
end
