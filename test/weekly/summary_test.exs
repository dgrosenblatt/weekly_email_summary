defmodule Weekly.SummaryTest do
  use ExUnit.Case
  import Mock
  alias Weekly.{Mailer, Summary, Sender}
  alias Weekly.Data.{Message, Recipient}

  setup_with_mocks([
    {Mailer, [], [send_email: fn _to, _body -> :ok end]},
    {Summary, [], [generate: fn text -> {:ok, "Summary: #{text}"} end]},
    {Recipient, [], [all: fn -> [%Recipient{emailAddress: "hello@example.com"}] end]},
    {Message, [],
     [
       delete: fn _ -> :ok end,
       fetch_content: fn id -> "Content for message #{id}" end,
       find_by_email: fn _ ->
         [
           %{
             recipientEmail: "hello@example.com",
             messageId: "1",
             receivedAt: "2024-10-18T14:24:54.899Z"
           },
           %Message{
             recipientEmail: "hello@example.com",
             messageId: "2",
             receivedAt: "2024-10-16T14:33:39.815Z"
           }
         ]
       end
     ]}
  ]) do
    {:ok, %{}}
  end

  test "runs" do
    assert :ok == Sender.perform()
  end
end
