defmodule Weekly.Data.Signup do
  alias ExAws.Dynamo
  @derive [Dynamo.Encodable, Jason.Encoder]
  @table_name "signups"
  defstruct [:email, :verified, :forwarding]

  def create(%__MODULE__{} = signup) do
    Dynamo.put_item(@table_name, signup)
    |> ExAws.request()
  end
end
