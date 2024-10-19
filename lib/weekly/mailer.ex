defmodule Weekly.Mailer do
  alias ExAws.SES

  @from_email "hello@weeklyemail.wtf"

  def send_email(to, content) do
    content = %{
      Simple: %{
        Body: %{
          Text: %{
            Data: content
          }
        },
        Subject: %{Data: "Your Weekly Email Summary"}
      }
    }

    destination = %{ToAddresses: [to]}

    SES.send_email_v2(destination, content, @from_email)
    |> ExAws.request!()
  end
end
