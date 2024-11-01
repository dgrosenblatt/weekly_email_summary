defmodule WeeklyWeb.SignupController do
  use WeeklyWeb, :controller
  alias Weekly.Data.Signup

  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, %{"email" => email}) do
    signup = %Signup{email: email, verified: false, forwarding: false}

    case Signup.create(signup) do
      {:ok, _} ->
        conn
        |> put_status(201)
        |> json(signup)

      {_, {_err, msg}} ->
        conn
        |> put_status(422)
        |> json(%{error: msg})
    end
  end
end
