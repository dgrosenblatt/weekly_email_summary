defmodule WeeklyWeb.SignupControllerTest do
  use WeeklyWeb.ConnCase
  import Mock
  alias Weekly.Data.Signup

  setup_with_mocks([
    {
      Signup,
      [],
      [
        create: fn
          %Signup{email: "error@example.com"} -> {:error, {"Request error", "Resource not found"}}
          _ -> {:ok, %{}}
        end
      ]
    }
  ]) do
    {:ok, %{}}
  end

  test "POST /signups when succesful returns 201", %{conn: conn} do
    conn = post(conn, ~p"/signups", %{"email" => "test@example.com"})

    assert_called(
      Signup.create(%Signup{email: "test@example.com", verified: false, forwarding: false})
    )

    assert json_response(conn, 201) == %{
             "email" => "test@example.com",
             "verified" => false,
             "forwarding" => false
           }
  end

  test "POST /signups when an error occurs returns 422", %{conn: conn} do
    conn = post(conn, ~p"/signups", %{"email" => "error@example.com"})

    assert_called(
      Signup.create(%Signup{email: "error@example.com", verified: false, forwarding: false})
    )

    assert json_response(conn, 422) == %{"error" => "Resource not found"}
  end
end
