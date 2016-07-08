defmodule Bots.BotsSupervisor do
	use Supervisor

	@supervisor_name MainBotsSupervisor

	def start_link(bots_specs) do
		IO.puts inspect __MODULE__
		Supervisor.start_link(__MODULE__, bots_specs, [{:name, @supervisor_name}])
	end

	def init(bots_specs) do
		# Creating workers from bots specifications
		# TODO:
		#	1. adding bots 'on-the-fly'
		children = Enum.map(bots_specs, fn(bot)->
			{name, type, options} = bot
			module = case type do
				:active->
					Bots.Telegram.BotActive;
				:passive->
					Bots.Telegram.BotPassive;
			end
			IO.puts "module: " <> inspect module
			worker(module, [options], [id: name])
		end)

		supervise(children, strategy: :one_for_one)
	end

	def send_msg_to_worker(name, msg) do
		children = Supervisor.which_children(@supervisor_name)
		case :lists.keyfind(name, 1, children) do
			false->
				IO.puts "unknown bot " <> inspect name
			{_, pid, _, _} ->
				Bots.Telegram.BotPassive.new_message(pid, msg)
			B->
				IO.puts inspect B
		end
	end
end