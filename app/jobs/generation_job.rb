class GenerationJob < ApplicationJob
  queue_as :default

  def perform(generation)
    service = GenerationService.new(generation)
    service.call
  end
end
