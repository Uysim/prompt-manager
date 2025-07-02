module GenerationsHelper
  def model_display_name(model_id)
    AnthropicService.available_models[model_id] || model_id
  end
end
