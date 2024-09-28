defmodule Weekly.Recipient do
  alias ExAws.Dynamo
  @derive [Dynamo.Encodable]
  defstruct [:emailAddress]

  @table_name "recipients"

  def delete(email_address) do
    Dynamo.delete_item(@table_name, [{:emailAddress, email_address}])
    |> ExAws.request!()
  end

  def table_name do
    @table_name
  end
end
