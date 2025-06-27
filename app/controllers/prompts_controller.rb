class PromptsController < ApplicationController
  before_action :set_prompt, only: [ :show, :edit, :update, :destroy, :generate, :generations ]

  def index
    @prompts = Prompt.order(created_at: :desc)
  end

  def show
  end

  def new
    @prompt = Prompt.new
  end

  def create
    @prompt = Prompt.new(prompt_params)

    if @prompt.save
      redirect_to @prompt, notice: "Prompt was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @prompt.update(prompt_params)
      redirect_to @prompt, notice: "Prompt was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @prompt.destroy
    redirect_to prompts_url, notice: "Prompt was successfully deleted."
  end

  def generate
    input_variables = params[:input_variables] || {}
    selected_model = params[:model] || "claude-sonnet-4-20250514"

    # Check if all required variables are provided
    missing_vars = @prompt.missing_variables(input_variables)
    if missing_vars.any?
      redirect_to @prompt, alert: "Missing required variables: #{missing_vars.join(', ')}"
      return
    end

    # Process the prompt with variables
    processed_content = @prompt.process_content(input_variables)

    # Generate text using LLM with selected model
    llm_service = AnthropicService.new(model: selected_model)
    result = llm_service.generate(processed_content)

    if result[:success]
      # Save the generation
      generation = @prompt.generations.create!(
        input_data: input_variables,
        generated_text: result[:text],
        llm_provider: "anthropic",
        llm_model: selected_model
      )

      redirect_to generation, notice: "Text generated successfully!"
    else
      redirect_to @prompt, alert: "Generation failed: #{result[:error]}"
    end
  end

  def generations
    @generations = @prompt.generations.order(created_at: :desc)
  end

  private

  def set_prompt
    @prompt = Prompt.find(params[:id])
  end

  def prompt_params
    params.require(:prompt).permit(:title, :content, :description)
  end
end
