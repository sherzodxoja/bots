defmodule BotApp.Mixfile do
	use Mix.Project

	def project do
		[
			app: :bots,
			version: "0.1.0",
			elixir: "~> 1.3",
			build_embedded: Mix.env == :prod,
			start_permanent: Mix.env == :prod,
			deps: deps()
		]
  end

	def application do
		[
			applications: [:logger, :httpotion, :poison],
			mod: {BotApp, []}
		]
	end

	defp deps do
		[
			{:httpotion, "~> 3.0.0"},
			{:poison, "~> 2.2.0"},
			{:exrm, "~> 1.0.6"}
		]
	end
end
