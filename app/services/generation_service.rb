class GenerationService
  def initialize(generation)
    @generation = generation
    @prompt = generation.prompt
    @input_variables = generation.input_data
    @model = generation.llm_model
    @use_sequential_thinking = generation.metadata&.dig("use_sequential_thinking") || false
  end

  def call
    validate_input_variables!

    # Process the prompt with variables
    processed_content = @prompt.process_content(@input_variables)

    # Combine prompt files and generation files
    all_files = @prompt.files + @generation.files

    begin
      # Start generation
      @generation.start_generation!
      broadcast_generation_update("Generation started...")

      if @use_sequential_thinking
        generate_with_sequential_thinking(processed_content, all_files)
      else
        generate_with_llm(processed_content, all_files)
      end
    rescue => e
      # Handle any unexpected errors
      @generation.fail_generation!(e.message)
      broadcast_generation_error(e.message)
      { success: false, error: e.message, generation: @generation }
    end
  end

  private

  def validate_input_variables!
    missing_vars = @prompt.missing_variables(@input_variables)
    if missing_vars.any?
      error_msg = "Missing required variables: #{missing_vars.join(', ')}"
      @generation.fail_generation!(error_msg)
      broadcast_generation_error(error_msg)
      raise error_msg
    end
  end

  def generate_with_sequential_thinking(processed_content, all_files)
    # Use sequential thinking for complex problems
    broadcast_generation_update("Using sequential thinking approach...")
    thinking_service = SequentialThinkingService.new(model: @model)
    result = thinking_service.think_through_problem(processed_content, all_files)

    if result[:success]
      # Complete the generation with thinking process
      @generation.complete_generation!(
        result[:final_text],
        {
          thinking_process: result[:thoughts],
          enhanced_prompt: result[:enhanced_prompt],
          used_sequential_thinking: true
        }
      )

      broadcast_generation_complete(result[:thoughts])
      { success: true, generation: @generation, thinking_process: result[:thoughts] }
    else
      @generation.fail_generation!(result[:error])
      broadcast_generation_error(result[:error])
      { success: false, error: result[:error], generation: @generation }
    end
  end

  def generate_with_llm(processed_content, all_files)
    # Standard generation with files
    broadcast_generation_update("Processing with AI...")
    llm_service = AnthropicService.new(model: @model)
    result = llm_service.generate(processed_content, all_files)

    if result[:success]
      @generation.complete_generation!(result[:text])
      broadcast_generation_complete
      { success: true, generation: @generation }
    else
      @generation.fail_generation!(result[:error])
      broadcast_generation_error(result[:error])
      { success: false, error: result[:error], generation: @generation }
    end
  end

  def broadcast_generation_update(message)
    Turbo::StreamsChannel.broadcast_update_to(
      "generation_#{@generation.id}",
      target: "generation_status",
      partial: "generations/status_update",
      locals: {
        generation: @generation,
        message: message,
        status: @generation.status
      }
    )
  end

  def broadcast_generation_complete(thinking_process = nil)
    Turbo::StreamsChannel.broadcast_replace_to(
      "generation_#{@generation.id}",
      target: "generation_content",
      partial: "generations/result",
      locals: {
        generation: @generation,
        thinking_process: thinking_process
      }
    )

    # Also broadcast to the prompt's generations list
    Turbo::StreamsChannel.broadcast_append_to(
      "prompt_#{@generation.prompt_id}_generations",
      target: "recent_generations",
      partial: "generations/generation_item",
      locals: { generation: @generation }
    )
  end

  def broadcast_generation_error(error_message)
    Turbo::StreamsChannel.broadcast_replace_to(
      "generation_#{@generation.id}",
      target: "generation_content",
      partial: "generations/error",
      locals: {
        generation: @generation,
        error_message: error_message
      }
    )
  end
end
