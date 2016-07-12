defmodule Bots.Telegram.BotPassive do
	use GenServer
	require Logger
	

	defmodule State do
		defstruct options: nil
	end


	def start_link(options) do
		GenServer.start_link(__MODULE__, %State{options: options}, [])
	end

	## Server Callbacks

	def init(state) do
		:io.format "Starting bot ~p with state: ~p~n", [self(), state.options]
		{:ok, state}
	end

	def handle_info({:new_message, json}, state) do
		Bots.Telegram.Processor.decode_webhook_data(json, state.options)
		{:noreply, state}
	end

	def handle_info(_, state) do
		{:noreply, state}
	end

	def handle_call(_, _from, state) do
		{:reply, :none, state}
	end

	def handle_cast(_, state) do
		{:noreply, state}
	end


end