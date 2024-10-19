defmodule Weekly.Sender do
  alias ExAws.Dynamo
  alias ExAws.SES
  alias Weekly.{Message, Recipient, Summary}

  @recipients_table Recipient.table_name()
  @messages_table Message.table_name()
  @from_email "hello@weeklyemail.wtf"

  def perform do
    recipients = fetch_recipients!()

    for recipient <- recipients do
      email_address = Map.get(recipient, :emailAddress)

      case fetch_messages(email_address) do
        {:ok, data} ->
          Map.get(data, "Items")
          |> Enum.map(&Dynamo.decode_item(&1, as: Message))
          |> process_recipient_messages(email_address)

        err ->
          IO.inspect(err)
      end
    end

    :ok
  end

  def fetch_recipients! do
    Dynamo.scan(@recipients_table)
    |> ExAws.request!()
    |> Map.get("Items")
    |> Enum.map(&Dynamo.decode_item(&1, as: Recipient))
  end

  def fetch_messages(email_address) do
    Dynamo.query(
      @messages_table,
      key_condition_expression: "recipientEmail = :recipientEmail",
      expression_attribute_values: %{
        "recipientEmail" => email_address
      },
      index_name: "recipientEmail-index"
    )
    |> ExAws.request()
  end

  def process_recipient_messages(messages, email_address) do
    summary =
      messages
      |> Enum.reduce("", fn msg, acc ->
        message_id = Map.get(msg, :messageId)
        Message.fetch_content(message_id) <> "\n\n\n**********\n\n\n" <> acc
      end)
      |> Summary.generate()

    case summary do
      {:ok, text} ->
        send_email(text, email_address)

      {:error, error_msg} ->
        IO.puts("Open AI error, skipping #{email_address}")
        IO.inspect(error_msg)
    end

    # for message <- messages do
    #   Map.get(message, :messageId) |> Message.delete()
    # end

    # Recipient.delete(email_address)
  end

  def send_email(summary, email_address) do
    content = %{
      Simple: %{
        Body: %{
          Text: %{
            Data: summary
          }
        },
        Subject: %{Data: "Weekly Summary"}
      }
    }

    destination = %{ToAddresses: [email_address]}

    SES.send_email_v2(destination, content, @from_email)
    |> ExAws.request!()

    IO.puts("Sent summary to #{email_address}")
  end
end
