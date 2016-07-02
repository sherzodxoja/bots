defmodule TelegramCommander do

	import TelegramResponse

	def get_response(message) do
		command = message.text

		case command do
			"/hello"->
				"Hi, " <> message.from.first_name
			"/cat"->
				"dog"
			"/help"->
				"Available commands: \n/help\tshow this message\n/hello\tgreetings to you\n/cat\tshow products catalog\n/markdown\ttest markdown formatting\n/html\ttest html formatting"
			"/markdown"->
				{"Markdown", "Markdown below\n*bold text*
					_italic text_
					[http://www.tender.pro/](URL)
					`inline fixed-width code`
					```text
					pre-formatted fixed-width code block
					```"}
			"/html"->
				{"HTML", "HTML below\n<b>bold</b>, <strong>bold</strong>
					<i>italic</i>, <em>italic</em>
					<a href=\"http://www.tender.pro/\">inline URL</a>
					<code>inline fixed-width code</code>
					<pre>pre-formatted fixed-width code block</pre>"}
			c->
				"Unknown command: " <> c <> ". Use /help and select proper command"
		end
	end
end