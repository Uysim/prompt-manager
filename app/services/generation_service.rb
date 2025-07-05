class GenerationService
  def initialize(prompt, input_variables, model = "claude-sonnet-4-20250514", use_sequential_thinking = false)
    @prompt = prompt
    @input_variables = input_variables
    @model = model
    @use_sequential_thinking = use_sequential_thinking
  end

  def call
    # Validate input variables
    missing_vars = @prompt.missing_variables(@input_variables)
    return { success: false, error: "Missing required variables: #{missing_vars.join(', ')}" } if missing_vars.any?

    # Process the prompt with variables
    processed_content = @prompt.process_content(@input_variables)

    generation = @prompt.generations.new(
      input_data: @input_variables,
      llm_provider: "anthropic",
      llm_model: @model
    )

    if @use_sequential_thinking
      # Use sequential thinking for complex problems
      thinking_service = SequentialThinkingService.new(model: @model)
      result = thinking_service.think_through_problem(processed_content, @prompt.files)

      if result[:success]
        # Save the generation with thinking process
        generation.generated_text = result[:final_text]
        generation.metadata = {
          thinking_process: result[:thoughts],
          enhanced_prompt: result[:enhanced_prompt],
          used_sequential_thinking: true
        }

        generation.save!

        { success: true, generation: generation, thinking_process: result[:thoughts] }
      else
        {
          success: false,
          error: result[:error],
          generation: generation
        }
      end
    else
      # Standard generation with files
      llm_service = AnthropicService.new(model: @model)
      result = llm_service.generate(processed_content, @prompt.files)

      if result[:success]
        # Save the generation
        generation.generated_text = result[:text]
        generation.save!

        { success: true, generation: generation }
      else
        {
          success: false,
          error: result[:error],
          generation: generation
        }
      end
    end
  end
end
