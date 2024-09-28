defmodule Weekly.Message do
  alias ExAws.Dynamo
  @derive [Dynamo.Encodable]
  defstruct [:recipientEmail, :messageId, :receivedAt]

  @table_name "messages"

  def delete(message_id) do
    Dynamo.delete_item(@table_name, [{:messageId, message_id}])
    |> ExAws.request!()
  end

  def table_name do
    @table_name
  end
end
