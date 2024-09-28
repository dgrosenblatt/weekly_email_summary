defmodule Mix.Tasks.Summarize do
  use Mix.Task
  alias Weekly.Sender

  @moduledoc """
  Send weekly summaries to all recipients
  """

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("Starting weekly summaries")
    Application.ensure_all_started(:hackney)
    Application.ensure_started(:telemetry)
    Sender.perform()
  end
end
