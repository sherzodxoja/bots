defmodule Bots.BotsSupervisor do
	@moduledoc """
	This supervisor for each bots in the list of specifications creates process according to bot's type. If type is `:active` will be created process with long-polling implementation. If type is `:passive` will becreated process with webhook implementation.
	"""
	use Supervisor
	require Logger

	@supervisor_name MainBotsSupervisor

	def start_link(bots_specs) do
		Supervisor.start_link(__MODULE__, bots_specs, [{:name, @supervisor_name}])
	end

	def init(bots_specs) do
		# Creating workers from bots specifications
		children = Enum.map(bots_specs, fn(bot)->
			case prepare_worker_spec(bot) do
				{:ok, spec}->
					spec
				_->
					[]
			end
		end)
		supervise(List.flatten(children), strategy: :one_for_one)
	end

	def create_bot(bot_spec) do
		case prepare_worker_spec(bot_spec) do
			{:ok, spec} ->
				case Supervisor.start_child(@supervisor_name, spec) do
					{:ok, _}->
						:ok
					{:ok, _, _}->
						:ok
					{:error, {:already_started, _}}->
						:already_started
					{:error, :already_present}->
						:already_present
					e->
						IO.puts inspect e
						e
				end
			Error->
				Error
		end
	end

	@doc """
	Валидация и подготовка спецификации бота

	## Примеры
		iex> Bots.BotsSupervisor.prepare_worker_spec({"bot_name", :active, []})
		{:ok, {"bot_name", {Bots.Telegram.BotActive, :start_link, [[]]}, :permanent, 5000, :worker, [Bots.Telegram.BotActive]}}

		iex> Bots.BotsSupervisor.prepare_worker_spec({"bot_name", :active, [], 1})
		:bad_bot_spec

		iex> Bots.BotsSupervisor.prepare_worker_spec({"bot_name", :medium, []})
		:bad_bot_type
	"""
	def prepare_worker_spec(bot_spec) do
		try do
			case bot_spec do
				_ when is_tuple(bot_spec) and tuple_size(bot_spec) == 3 ->
					{name, type, options} = bot_spec
					module = case type do
						:active->
							Bots.Telegram.BotActive
						:passive->
							Bots.Telegram.BotPassive
						_->
							throw :bad_bot_type
					end
					{:ok, worker(module, [options], [id: name])}
				_->
					throw :bad_bot_spec
			end
		catch
			error->
				Logger.error "Error: #{inspect error} in spec #{inspect bot_spec}"
				error
		end
	end

	@doc """
	Поиск процесса бота по имени и отправка сообщения в этот процесс

		iex> Bots.BotsSupervisor.send_msg_to_worker("bot_name_that_does_not_exists", "msg")
		:bot_not_found

		iex> Bots.BotsSupervisor.create_bot({"bot_name_that_exists", :active, []})
		iex> Bots.BotsSupervisor.send_msg_to_worker("bot_name_that_exists", "msg")
		:ok
	"""
	def send_msg_to_worker(name, msg) do
		children = Supervisor.which_children(@supervisor_name)
		IO.puts inspect children
		case :lists.keyfind(name, 1, children) do
			{_, pid, _, _}->
				send pid, {:new_message, msg}
				:ok
			:undefined->
				Logger.error "Bot not found: #{inspect name}"
				:bot_not_found
		end
	end

end