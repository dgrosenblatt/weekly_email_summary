defmodule Mix.Tasks.Summarize do
  use Mix.Task
  alias Weekly.Sender

  @moduledoc """
  Send weekly summaries to all recipients
  """

  @impl Mix.Task
  def run(_) do
    Mix.shell().info("Starting weekly summaries")
    Sender.perform()
  end
end
