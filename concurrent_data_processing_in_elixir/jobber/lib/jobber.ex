defmodule Jobber do
  @moduledoc """
  Documentation for `Jobber`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Jobber.hello()
      :world

  """
  alias Jobber.{JobRunner, JobSupervisor}

  def start_job(args) do
    if Keyword.get(args, :type) == "import" and Enum.count(running_imports()) >= 5 do
      {:error, :import_quota_reached}
    else
      DynamicSupervisor.start_child(JobRunner, {JobSupervisor, args})
    end
  end

  def running_imports() do
    match_all = {:"$1", :"$2", :"$3"}
    guards = [{:==, :"$3", "import"}]
    map_result = [%{id: :"$1", pid: :"$2", type: :"$3"}]
    Registry.select(Jobber.JobRegistry, [{match_all, guards, map_result}])
  end
end
