module GenerationsHelper
  def model_display_name(model_id)
    case model_id
    when "claude-opus-4-20250514"
      "Claude Opus 4"
    when "claude-sonnet-4-20250514"
      "Claude Sonnet 4"
    when "claude-3-7-sonnet-20250219"
      "Claude Sonnet 3.7"
    when "claude-3-5-haiku-20241022"
      "Claude Haiku 3.5"
    when "claude-3-5-sonnet-20241022"
      "Claude Sonnet 3.5"
    when "claude-3-5-sonnet-20240620"
      "Claude Sonnet 3.5"
    when "claude-3-opus-20240229"
      "Claude Opus 3"
    when "claude-3-sonnet-20240229"
      "Claude Sonnet 3"
    when "claude-3-haiku-20240307"
      "Claude Haiku 3"
    else
      model_id
    end
  end
end
