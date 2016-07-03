defmodule BotSupervisor do
	use Supervisor

	def start_link(bots_specs) do
		Supervisor.start_link(__MODULE__, bots_specs)
	end

	def init(bots_specs) do
		# Creating workers from bots specifications
		# TODO:
		#	1. adding bots 'on-the-fly'
		children = Enum.map(bots_specs, fn(x)->
			{bot_module, options} = x
			worker(bot_module, [options])
		end)

		supervise(children, strategy: :one_for_one)
	end
end