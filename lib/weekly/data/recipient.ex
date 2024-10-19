defmodule Weekly.Data.Recipient do
  alias ExAws.Dynamo
  @derive [Dynamo.Encodable]
  defstruct [:emailAddress]

  @table_name "recipients"

  def all do
    Dynamo.scan(@table_name)
    |> ExAws.request!()
    |> Map.get("Items")
    |> Enum.map(&Dynamo.decode_item(&1, as: __MODULE__))
  end

  def delete(email_address) do
    Dynamo.delete_item(@table_name, [{:emailAddress, email_address}])
    |> ExAws.request!()
  end
end
