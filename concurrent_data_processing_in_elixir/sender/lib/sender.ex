defmodule Sender do
  @moduledoc """
  Documentation for `Sender`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Sender.hello()
      :world

  """
  def hello do
    :world
  end

  def send_email("konnichiwa@world.com" = email),
    do: raise("Oops, couldn't send email to #{email}!")

  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email to #{email} sent")
    {:ok, "email_sent"}
  end

  # def notify_all(emails) do
  #   emails
  #   |> Enum.map(fn email ->
  #     Task.async(fn ->
  #       send_email(email)
  #     end)
  #   end)
  #   |> Enum.map(&Task.await/1)
  # end

  def notify_all(emails) do
    Sender.EmailTaskSupervisor
    |> Task.Supervisor.async_stream_nolink(emails, &send_email/1)
    |> Enum.to_list()
  end
end