defmodule Bots.Mixfile do
	use Mix.Project

	def project do
		[
			app: :bots,
			version: "0.1.0",
			elixir: "~> 1.3",
			build_embedded: Mix.env == :prod,
			start_permanent: Mix.env == :prod,
			deps: deps(),
			description: "System of deploying bots for popular instant messengers",
			name: "Bots",
			docs: [extras: ["README.md"], source_url: "https://github.com/TokiTori/bots"]
		]
	end

	def application do
		[
			applications: [:logger, :httpotion, :poison, :cowboy, :plug, :ssl, :pgsql],
			mod: {Bots, []}
		]
	end

	defp deps do
		[
			{:httpotion, "~> 3.0.0"},
			{:poison, "~> 2.2.0"},
			{:exrm, "~> 1.0.6"},
			{:cowboy, "~> 1.0.0"},
			{:plug, "~> 1.0"},
			{:pgsql, git: "https://github.com/semiocast/pgsql.git", tag: "25"},
			{:ex_doc, "~> 0.12", only: :dev}
		]
	end
end
