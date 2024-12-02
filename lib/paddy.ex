defmodule Paddy do
  @moduledoc """
  It is a wrapper around GooglePubSub library.

  The main focus is to hide from the final user that it is using the GCP libraries and only focus
  on use the Paddy Librady.
  """
  alias GoogleApi.PubSub.V1.Api.Projects
  alias GoogleApi.PubSub.V1.Model

  @project_id Application.get_env(:paddy, :project_id)
  @topic_id Application.get_env(:paddy, :topic_id)

  @doc """
  It will connect with GooglePubSub and publish the data to a topic.

  ## Examples

      iex> version = :v1
      iex> company_id = :rand.uniform(100)
      iex> event_type = "foobar_event"
      iex> payload = %{id: 1, name: "foobar"}
      iex> event_timestamp = ~N[2018-08-01 22:15:07]
      iex> params = %{
        version: :v1,
        company_id: company_id,
        event_type: event_type,
        event_timestamp: event_timestamp,
        payload: payload
      }
      iex> data = %{
        event_type: "#{:v1}_foobar_event",
        event_identifier: payload[:id],
        event_timestamp: event_timestamp,
        tenant_id: company_id,
        event_family: "DATALAKE",
        payload: payload
      }
      iex> alias Paddy
      iex> Paddy.publish(data)
      iex> {:ok,%GoogleApi.PubSub.V1.Model.PublishResponse{messageIds: ["422315144637561"]}}
  """

  def publish(data, args \\ []) do
    project_id = Keyword.get(args, :project_id, @project_id)
    topic_id = Keyword.get(args, :topic_id, @topic_id)
    client_email = Keyword.get(args, :client_email)

    encoded_data = encode_data(data)
    message = %Model.PubsubMessage{data: encoded_data}
    data_request = %Model.PublishRequest{messages: [message]}

    Projects.pubsub_projects_topics_publish(get_connection(client_email), project_id, topic_id,
      body: data_request
    )
  end

  defp encode_data(data) do
    # {:ok, encoded_data} = Poison.encode(data)
    Base.encode64(data)
  end

  ### Disclaimer!
  #
  # We do not need to be concerned about refreshing the token whenever we need to use it,
  # The lib documentation explains that this problem is already solved by the lib.
  #
  # We are currently using the lib in version 1.0.1 ~ 27/03/2019.
  #
  # Link for the doc: https://github.com/peburrows/goth/blob/master/lib/goth/token.ex#L3
  defp get_connection(client_email) do
    {:ok, token} = Goth.Token.for_scope({client_email, "https://www.googleapis.com/auth/pubsub"})

    token
    |> Map.get(:token)
    |> GoogleApi.PubSub.V1.Connection.new()
  end
end
