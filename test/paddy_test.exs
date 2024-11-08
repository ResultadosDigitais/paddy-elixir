defmodule PaddyTest do
  use ExUnit.Case, async: false
  import Mock

  alias Paddy
  alias GoogleApi.PubSub.V1.Api.Projects

  describe "publish/1" do
    test "must receive params and publish event" do
      version = :v1
      company_id = :rand.uniform(100)
      event_type = "foobar_event"
      payload = %{id: 1, name: "foobar"}
      event_timestamp = ~N[2018-08-01 22:15:07]

      params = %{
        version: version,
        company_id: company_id,
        event_type: event_type,
        event_timestamp: event_timestamp,
        payload: payload
      }

      with_mocks [
        {Projects, [], pubsub_projects_topics_publish: fn _connection, project_id, topic_id, options ->
          publish_request = Keyword.get(options, :body)

          assert %GoogleApi.PubSub.V1.Model.PublishRequest{
                    messages: [%GoogleApi.PubSub.V1.Model.PubsubMessage{data: _}]
                  } = publish_request
          :ok
        end},
        {Goth.Token, [], for_scope: fn _ -> {:ok, %{token: "mocked_token"}} end}
      ] do
        Paddy.publish(params)
      end
    end

    test "publish with custom project_id and topic_id" do
      version = :v1
      company_id = :rand.uniform(100)
      event_type = "foobar_event"
      payload = %{id: 1, name: "foobar"}
      event_timestamp = ~N[2018-08-01 22:15:07]

      params = %{
        version: version,
        company_id: company_id,
        event_type: event_type,
        event_timestamp: event_timestamp,
        payload: payload
      }

      with_mocks [
        {Projects, [], pubsub_projects_topics_publish: fn _connection, project_id, topic_id, options ->
          assert project_id == "custom_project_id"
          assert topic_id == "custom_topic_id"

          publish_request = Keyword.get(options, :body)

          assert %GoogleApi.PubSub.V1.Model.PublishRequest{
                    messages: [%GoogleApi.PubSub.V1.Model.PubsubMessage{data: _}]
                  } = publish_request
          :ok
        end},
        {Goth.Token, [], for_scope: fn _ -> {:ok, %{token: "mocked_token"}} end}
      ] do
        Paddy.publish(params, project_id: "custom_project_id", topic_id: "custom_topic_id", client_email: "custom_client_email")
      end      
    end    
  end
end
