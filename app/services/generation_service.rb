class GenerationService
  def initialize(generation)
    @generation = generation
    @prompt = generation.prompt
    @input_variables = generation.input_data
    @model = generation.llm_model
  end

  def call
    validate_input_variables!

    # Process the prompt with variables
    processed_content = @prompt.process_content(@input_variables)

    return generate_preview(processed_content) if preview_only?

    # Combine prompt files and generation files
    all_files = @prompt.files + @generation.files

    begin
      # Start generation
      @generation.start_generation!
      if use_sequential_thinking?
        broadcast_generation_update("Using sequential thinking approach...")
      else
        broadcast_generation_update("Processing with AI...")
      end

      result = Intelligent.generate(
        llm_model: @model,
        variables: @input_variables,
        prompt: processed_content,
        files: all_files,
        use_sequential_thinking: use_sequential_thinking?
      )

      if result[:success]
        @generation.complete_generation!(
          result[:generated_text],
          {
            thinking_process: result[:thoughts],
            used_sequential_thinking: use_sequential_thinking?
          }
        )
        broadcast_generation_complete
        { success: true, generation: @generation }
      else
        @generation.fail_generation!(result[:error])
        broadcast_generation_error(result[:error])
        { success: false, error: result[:error], generation: @generation }
      end

    rescue => e
      # Handle any unexpected errors
      @generation.fail_generation!(e.message)
      broadcast_generation_error(e.message)
      { success: false, error: e.message, generation: @generation }
    end
  end

  private

  def use_sequential_thinking?
    @generation.metadata&.dig("use_sequential_thinking") || false
  end

  def preview_only?
    @generation.metadata&.dig("preview_only") || false
  end

  def generate_preview(processed_content)
    @generation.update!(generated_prompt: processed_content)
    @generation.complete_generation!("This is a preview of the prompt with the variables filled in.")
    broadcast_generation_complete
    { success: true, generation: @generation }
  end

  def validate_input_variables!
    missing_vars = @prompt.missing_variables(@input_variables)
    if missing_vars.any?
      error_msg = "Missing required variables: #{missing_vars.join(', ')}"
      @generation.fail_generation!(error_msg)
      broadcast_generation_error(error_msg)
      raise error_msg
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
