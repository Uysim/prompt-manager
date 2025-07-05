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
    if missing_vars.any?
      return { success: false, error: "Missing required variables: #{missing_vars.join(', ')}" }
    end

    # Process the prompt with variables
    processed_content = @prompt.process_content(@input_variables)

    # Create generation with pending status
    generation = @prompt.generations.create!(
      input_data: @input_variables,
      llm_provider: "anthropic",
      llm_model: @model,
      status: "pending"
    )

    begin
      # Start generation
      generation.start_generation!

      if @use_sequential_thinking
        # Use sequential thinking for complex problems
        thinking_service = SequentialThinkingService.new(model: @model)
        result = thinking_service.think_through_problem(processed_content, @prompt.files)

        if result[:success]
          # Complete the generation with thinking process
          generation.complete_generation!(
            result[:final_text],
            {
              thinking_process: result[:thoughts],
              enhanced_prompt: result[:enhanced_prompt],
              used_sequential_thinking: true
            }
          )

          { success: true, generation: generation, thinking_process: result[:thoughts] }
        else
          generation.fail_generation!(result[:error])
          { success: false, error: result[:error], generation: generation }
        end
      else
        # Standard generation with files
        llm_service = AnthropicService.new(model: @model)
        result = llm_service.generate(processed_content, @prompt.files)

        if result[:success]
          generation.complete_generation!(result[:text])
          { success: true, generation: generation }
        else
          generation.fail_generation!(result[:error])
          { success: false, error: result[:error], generation: generation }
        end
      end
    rescue => e
      # Handle any unexpected errors
      generation.fail_generation!(e.message)
      { success: false, error: e.message, generation: generation }
    end
  end
end
