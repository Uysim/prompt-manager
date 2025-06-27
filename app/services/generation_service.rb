class GenerationService
  def initialize(prompt, input_variables, model = "claude-sonnet-4-20250514")
    @prompt = prompt
    @input_variables = input_variables
    @model = model
  end

  def call
    # Validate input variables
    missing_vars = @prompt.missing_variables(@input_variables)
    return { success: false, error: "Missing required variables: #{missing_vars.join(', ')}" } if missing_vars.any?

    # Process the prompt with variables
    processed_content = @prompt.process_content(@input_variables)

    # Generate text using LLM
    llm_service = AnthropicService.new(model: @model)
    result = llm_service.generate(processed_content)

    if result[:success]
      # Save the generation
      generation = @prompt.generations.create!(
        input_data: @input_variables,
        generated_text: result[:text],
        llm_provider: "anthropic",
        llm_model: @model
      )

      { success: true, generation: generation }
    else
      { success: false, error: result[:error] }
    end
  end
end
