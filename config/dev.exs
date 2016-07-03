use Mix.Config

# bots_spec is a list of tuples {BotModule, Options} where BotModule is a name of gen_server module, Options is a proplist
config :bots, :bots_spec, [
	{TelegramBot, [{:token, "182601977:AAH3HkVAeHBQfuFH_GrIh_qEKfgPmybhliU"}]}
]