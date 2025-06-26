require "net/http"
require "json"

class AnthropicService < LlmService
  def initialize(model: "claude-3-5-sonnet-20241022")
    super(provider: "anthropic", model: model)
  end

  def generate(prompt_content)
    return { error: "API key not configured" } unless api_key_present?

    uri = URI("https://api.anthropic.com/v1/messages")
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["x-api-key"] = api_key
    request["anthropic-version"] = "2023-06-01"

    request.body = {
      model: model,
      max_tokens: 4000,
      messages: [
        {
          role: "user",
          content: prompt_content
        }
      ]
    }.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      {
        success: true,
        text: data.dig("content", 0, "text"),
        usage: data["usage"]
      }
    else
      {
        error: "API request failed: #{response.code} - #{response.body}",
        status: response.code
      }
    end
  rescue => e
    { error: "Request failed: #{e.message}" }
  end
end
