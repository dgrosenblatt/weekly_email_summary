defmodule Weekly.Summary do
  @doc """
  Generate a summary of text with OpenAI Chat Completion
  """
  def generate(text) do
    response =
      OpenAI.chat_completion(
        model: "gpt-4o-mini",
        messages: prompts() ++ [%{role: "user", content: text}]
      )

    case response do
      {:ok, resp} ->
        [choice | _] = Map.get(resp, :choices)
        content = choice |> Map.get("message") |> Map.get("content")
        {:ok, content}

      {:error, msg} ->
        {:error, msg}
    end
  end

  defp prompts do
    [
      %{
        role: "system",
        content: "You are an assistant helping a busy person summarize their emails for the week."
      },
      %{
        role: "user",
        content: "I would like you to create a summary of a few emails.
      At the beginning have a special section that lists out any important dates and required action items that are mentioned in the emails.
      The tone of the summary should be an old jewish man using many yiddish and hebrew expressions and also upbeat and fun.
      The summary should be readable in two minutes or fewer. Err on the side of brevity.
      The summary should start with an old-timey extremely sensationalist newspaper headline.
      The emails will be separated with new lines and stars like this- \n\n\n**********\n\n\n ."
      },
      %{
        role: "user",
        content: "Emails:"
      }
    ]
  end
end
