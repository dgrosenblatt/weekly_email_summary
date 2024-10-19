defmodule Mix.Tasks.Summarize do
  use Mix.Task
  alias Weekly.Sender

  @moduledoc """
  Send weekly summaries to all recipients
  """

  @impl Mix.Task
  def run(_) do
    Mix.shell().info("Starting weekly summaries")
    start()
    Sender.perform()
  end

  defp start do
    Application.ensure_all_started(:hackney)
    Application.ensure_started(:telemetry)
    Application.ensure_started(:ex_aws)
  end
end
