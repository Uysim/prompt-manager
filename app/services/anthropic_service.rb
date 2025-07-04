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

  def generate(prompt_content, files = [])
    return { error: "API key not configured" } unless api_key_present?

    # Prepare message content
    content = [ { type: "text", text: prompt_content } ]

    # Add files to content if provided
    files.each do |file|
      file_content = prepare_file_content(file)
      content << file_content if file_content
    end

    begin


      response = @client.messages.create(
        model: model,
        max_tokens: 4000,
        messages: [
          {
            role: "user",
            content: content
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

  private

  def prepare_file_content(file)
    case file.content_type
    when /^image\//
      # For images, we need to encode as base64
      {
        type: "image",
        source: {
          type: "base64",
          media_type: file.content_type,
          data: Base64.strict_encode64(file.download)
        }
      }
    when /^text\//
      # For text files, we can include the content directly
      {
        type: "text",
        text: file.download.force_encoding("UTF-8")
      }
    when "application/pdf"
      # For PDFs, use the document content type with base64 encoding
      {
        type: "document",
        source: {
          type: "base64",
          media_type: "application/pdf",
          data: Base64.strict_encode64(file.download)
        }
      }
    else
      raise "Unsupported file type: #{file.content_type} for file: #{file.filename}"
    end
  end
end
