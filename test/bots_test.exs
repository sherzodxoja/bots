defmodule BotAppTest do
	use ExUnit.Case
	doctest Bots.BotsSupervisor

	test "bot specifications" do
		assert Bots.BotsSupervisor.prepare_worker_spec({"bot_name", :active, [], 1}) == :bad_bot_spec
		assert Bots.BotsSupervisor.prepare_worker_spec({"bot_name", :medium, []}) == :bad_bot_type
		assert Bots.BotsSupervisor.prepare_worker_spec({"bot_name", :active, []}) == {:ok, {"bot_name", {Bots.Telegram.BotActive, :start_link, [[]]}, :permanent, 5000, :worker, [Bots.Telegram.BotActive]}}
		assert Bots.BotsSupervisor.prepare_worker_spec({"bot_name", :passive, []}) == {:ok, {"bot_name", {Bots.Telegram.BotPassive, :start_link, [[]]}, :permanent, 5000, :worker, [Bots.Telegram.BotPassive]}}
	end

	test "bots duplication" do
		assert Bots.BotsSupervisor.create_bot({"bot_name1", :active, []}) == :ok
		assert Bots.BotsSupervisor.create_bot({"bot_name2", :active, []}) == :ok
		assert Bots.BotsSupervisor.create_bot({"bot_name1", :passive, []}) == :already_started
	end
end
