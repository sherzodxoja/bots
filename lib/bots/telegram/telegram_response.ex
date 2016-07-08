defmodule Bots.Telegram.TelegramResponse do
	defmodule Response do
		defstruct [:ok, :result]
	end

	defmodule Update do
		defstruct [:update_id, :message, :edited_message, 
			:inline_query, :chosen_inline_result, :callback_query]
	end

	defmodule Message do
		defstruct [:message_id, :from, :date, :chat, :forward_from, :forward_from_chat, 
			:forward_date, :reply_to_message, :edit_date, :text, :entities, :audio, 
			:document, :photo]
	end

	defmodule User do
		defstruct [:id, :first_name, :last_name, :username]
	end

	defmodule Chat do
		defstruct [:id, :type, :title, :username, :first_name, :last_name]
	end

	defmodule MessageEntity do
		defstruct [:type, :offset, :length, :url, :user]
	end
end