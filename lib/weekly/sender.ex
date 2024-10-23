defmodule Weekly.Sender do
  alias Weekly.{Data, Mailer, Summary}

  def perform do
    ensure_started()

    for recipient <- Data.Recipient.all() do
      email_address = Map.get(recipient, :emailAddress)
      messages = Data.Message.find_by_email(email_address)
      process_recipient_messages(messages, email_address)
    end

    :ok
  end

  def process_recipient_messages([], email_address),
    do: IO.puts("No messages found for recipient #{email_address}. Skipping...")

  def process_recipient_messages(messages, email_address) do
    summary = fetch_and_join_messages(messages) |> Summary.generate()

    case summary do
      {:ok, text} ->
        Mailer.send_email(email_address, text)
        IO.puts("Sent summary to #{email_address}")
        clear_messages(messages)

      {:error, error_msg} ->
        IO.puts("Open AI error, skipping #{email_address}")
        IO.inspect(error_msg)
    end
  end

  def fetch_and_join_messages(messages) do
    Enum.reduce(messages, "", fn msg, acc ->
      message_id = Map.get(msg, :messageId)
      Data.Message.fetch_content(message_id) <> "\n\n\n**********\n\n\n" <> acc
    end)
  end

  def clear_messages(messages) do
    for message <- messages do
      Map.get(message, :messageId) |> Data.Message.delete()
    end
  end

  def ensure_started do
    Application.ensure_all_started(:hackney)
    Application.ensure_started(:telemetry)
    Application.ensure_started(:ex_aws)
    Application.ensure_started(:openai)
  end
end
