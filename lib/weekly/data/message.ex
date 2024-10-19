defmodule Weekly.Data.Message do
  alias ExAws.{Dynamo, S3}
  @derive [Dynamo.Encodable]
  defstruct [:recipientEmail, :messageId, :receivedAt]

  @table_name "messages"
  @bucket_name "weekly-email-dot-wtf"

  def find_by_email(email_address) do
    Dynamo.query(
      @table_name,
      key_condition_expression: "recipientEmail = :recipientEmail",
      expression_attribute_values: %{
        "recipientEmail" => email_address
      },
      index_name: "recipientEmail-index"
    )
    |> ExAws.request!()
    |> Map.get("Items")
    |> Enum.map(&Dynamo.decode_item(&1, as: __MODULE__))
  end

  def delete(message_id) do
    Dynamo.delete_item(@table_name, [{:messageId, message_id}])
    |> ExAws.request!()
  end

  def fetch_content(message_id) do
    S3.get_object(@bucket_name, message_id)
    |> ExAws.request!()
    |> Map.get(:body)
    |> Mail.parse()
    |> Mail.get_text()
    |> Map.get(:body)
  end

  def table_name do
    @table_name
  end
end
