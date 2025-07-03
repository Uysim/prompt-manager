require "anthropic"

class AnthropicService < LlmService
  def self.available_models
    {
      "claude-sonnet-4-20250514" => "Claude Sonnet 4 (Recommended)",
      "claude-opus-4-20250514" => "Claude Opus 4 (Most Capable)",
      "claude-3-7-sonnet-20250219" => "Claude Sonnet 3.7 (Fast)",
      "claude-3-5-haiku-20241022" => "Claude Haiku 3.5 (Fastest)"
    }
  end

  def self.default_model
    "claude-sonnet-4-20250514"
  end

  def initialize(model: self.class.default_model)
    super(provider: "anthropic", model: model)
    @client = Anthropic::Client.new(api_key: api_key)
  end

  def generate(prompt_content)
    return { error: "API key not configured" } unless api_key_present?

    begin
      response = @client.messages.create(
        model: model,
        max_tokens: 4000,
        messages: [
          {
            role: "user",
            content: prompt_content
          }
        ]
      )

      {
        success: true,
        text: response.content.first.text,
        usage: response.usage&.to_h
      }
    rescue Anthropic::Errors::APIError => e
      {
        error: "API request failed: #{e.message}",
        status: e.status
      }
    rescue => e
      { error: "Request failed: #{e.message}" }
    end
  end
end
