class GenerationJob < ApplicationJob
  queue_as :default

  def perform(generation_id)
    generation = Generation.find(generation_id)
    service = GenerationService.new(generation)
    service.call
  end
end
