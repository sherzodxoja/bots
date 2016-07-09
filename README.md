# Bots
This is the system of deploying bots for popular instant messengers. Now it includes only implementaion of Telegram bots with webhook and long-polling.

<h2>Configuring</h2>
Application needs to be configured in <strong>config.exs</strong> such as:
```elixir
config :bots, :bots_spec, [
	{"worker_bot", :active, [{:token, "PlaceYourTokenHere"}, {:commander, Bots.Telegram.Commander}]}
	{"webhook_bot", :passive, [{:token, "PlaceYourTokenHere"}, {:commander, Bots.Telegram.Commander}]}
]
```
First element of each tuple in this list is a string bot name, which must be unique. Second element defines bot's mode: <strong>:active</strong> for bots with long-polling implementation and <strong>:passive</strong> for webhook implementation. Third element of tuple is a list of options. It may contain token or commander (module, which preparing response according with request).

<h2>Commander</h2>
Commander module must have public function <strong>get_response(message)</strong>, where message is a <a href="https://core.telegram.org/bots/api#message" target="_blank">Telegram's message object</a>
