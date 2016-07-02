defmodule BotSupervisor do
	use Supervisor

	def start_link do
		Supervisor.start_link(__MODULE__, :ok)
	end

	def init(:ok) do
		children = [
			# Creating worker specification for telegram bot with name and token
			# TODO:
			#	1. make bot's name and token configurable from config.exs
			#	2. adding bots 'on-the-fly'
			worker(TelegramBot, [{"TestBot1", "182601977:AAH3HkVAeHBQfuFH_GrIh_qEKfgPmybhliU"}])
		]

		supervise(children, strategy: :one_for_one)
	end
end