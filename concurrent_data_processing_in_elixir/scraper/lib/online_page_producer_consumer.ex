# defmodule OnlinePageProducerConsumer do
#   use GenStage
#   require Logger

#   def start_link(id) do
#     initial_state = []
#     GenStage.start_link(__MODULE__, initial_state, name: via(id))
#   end

#   def init(initial_state) do
#     Logger.info("OnlinePageProducerConsumer init")

#     subscription = [
#       {PageProducer, min_demand: 0, max_demand: 1}
#     ]

#     {:producer_consumer, initial_state, subscribe_to: subscription}
#   end

#   def handle_events(events, _from, state) do
#     Logger.info("OnlinePageProducerConsumer received #{inspect(events)}")
#     events = Enum.filter(events, &Scraper.online?/1)
#     {:noreply, events, state}
#   end

#   def via(id) do
#     {:via, Registry, {ProducerConsumerRegistry, id}}
#   end
# end

defmodule OnlinePageProducerConsumer do
  use Flow

  def start_link(_args) do
    producers = [Process.whereis(PageProducer)]

    consumers = [
      {Process.whereis(PageConsumerSupervisor), max_demand: 2}
    ]

    Flow.from_stages(producers, max_demand: 1, stages: 2)
    |> Flow.filter(&Scraper.online?/1)
    |> Flow.into_stages(consumers)
  end
end
