use Mix.Config

if Mix.env == :test do
  config :goth,
    json: "#{Path.dirname(__DIR__)}/config/google-pub-sub-fake-data.json" |> File.read!()

  config :paddy,
    project_id: "project_id",
    topic_id: "topic_id"
end
