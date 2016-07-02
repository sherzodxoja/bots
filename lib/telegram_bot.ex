defmodule TelegramBot do
	use GenServer
	require Logger
	

	defmodule State do
		defstruct botname: nil, token: nil, last_update_id: nil
	end

	@timeout_check 3000
	@timeout_polling 10
	@fetch_limit 100


	def start_link({botname, token}) do
		GenServer.start_link(__MODULE__, %State{botname: botname, token: token}, [])
	end

	## Server Callbacks

	def init(state) do
		:io.format "Starting bot ~p with state: ~p~n", [self(), state.token]
		Process.send_after(self(), :check, 1000)
		{:ok, state}
	end

	def handle_call(_, _from, state) do
		{:reply, :none, state}
	end

	def handle_info(_, state = %State{last_update_id: lui}) do
		response = make_query(state.token, (if lui === :nil, do: 0, else: lui+1))

		# TODO: If we use long-polling, we must use time threshold between bad requests
		# We must remember previous update id, it used as offset param in HTTP-query to fetch only new messages from telegram

		new_last_update_id = case response.status_code do
			200->
				case TelegramProcessor.decode(state.token, response.body) do
					:nil->
						#Logger.info "old update_id: " <> to_string(lui)
						lui
					max_last_update_id->
						#Logger.info "new update_id: " <> to_string(max_last_update_id)
						max_last_update_id
				end
			_->
				Logger.error "bad response: " <> to_string(response),
				lui
		end
		
		# Don't use timeout when long-polling enabled
		timeout = if @timeout_polling > 0, do: 0, else: @timeout_check
		Process.send_after(self(), :check, timeout)
		{:noreply, %{state | last_update_id: new_last_update_id}}
	end

	## Inner functions

	defp make_query(token, offset) do
		# Just preparing url and making request via 'GET' method
		url = HTTPotion.process_url("https://api.telegram.org/bot" <> token <> "/getUpdates", [query: %{offset: offset, limit: @fetch_limit, timeout: @timeout_polling}])
		#IO.puts inspect url
		response = HTTPotion.get url, [timeout: 12000]
		#IO.puts inspect response
		response
	end


end