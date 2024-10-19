defmodule Weekly.Message do
  alias ExAws.{Dynamo, S3}
  @derive [Dynamo.Encodable]
  defstruct [:recipientEmail, :messageId, :receivedAt]

  @table_name "messages"
  @bucket_name "weekly-email-dot-wtf"

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
