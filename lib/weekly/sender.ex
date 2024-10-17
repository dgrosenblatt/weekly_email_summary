defmodule Weekly.Sender do
  alias ExAws.Dynamo
  alias ExAws.S3
  alias ExAws.SES
  alias Weekly.{Message, Recipient}

  @recipients_table Recipient.table_name()
  @messages_table Message.table_name()
  @bucket_name "weekly-email-dot-wtf"
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
    messages
    |> Enum.reduce("", fn msg, acc ->
      message_id = Map.get(msg, :messageId)

      email =
        S3.get_object(@bucket_name, message_id)
        |> ExAws.request!()
        |> Map.get(:body)
        |> Mail.parse()
        |> Mail.get_text()
        |> Map.get(:body)

      email <> "\n\n\n**********\n\n\n" <> acc
    end)
    |> summarize()
    |> send_email(email_address)

    for message <- messages do
      Map.get(message, :messageId) |> Message.delete()
    end

    Recipient.delete(email_address)
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
  end

  def summarize(text) do
    response =
      OpenAI.chat_completion(
        model: "gpt-4o-mini",
        messages: [
          %{
            role: "system",
            content:
              "You are an assistant helping a busy person summarize their emails for the week."
          },
          %{
            role: "user",
            content:
              "I would like you to create a summary of a few emails.
            At the beginning have a special section that lists out any important dates and required action items that are mentioned in the emails.
            The tone of the summary should be upbeat and fun.
            The summary should be readable in two minutes or fewer. Err on the side of brevity.
            The summary should start with an old-timey extremely sensationalist newspaper headline.
            The emails will be separated with new lines and stars like this- \n\n\n**********\n\n\n ."
          },
          %{
            role: "user",
            content: "Emails:"
          },
          %{
            role: "user",
            content: text
          }
        ]
      )

    case response do
      {:ok, resp} ->
        [choice | _] = Map.get(resp, :choices)
        choice |> Map.get("message") |> Map.get("content")

      {:error, msg} ->
        IO.inspect(msg)
    end
  end
end
