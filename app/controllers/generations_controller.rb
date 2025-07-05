class GenerationsController < ApplicationController
  before_action :set_generation, only: [ :show, :destroy ]

  def index
    @generations = Generation.includes(:prompt).order(created_at: :desc)
  end

  def show
    # Subscribe to updates for this generation
    @generation_id = @generation.id
  end

  def create
    @prompt = Prompt.find(params[:prompt_id])
    use_sequential_thinking = params[:use_sequential_thinking] == "true"

    # Validate input variables first
    missing_vars = @prompt.missing_variables(params[:input_variables] || {})
    if missing_vars.any?
      flash[:error] = "Missing required variables: #{missing_vars.join(', ')}"
      render "prompts/show", status: :unprocessable_entity
      return
    end

    # Create generation with pending status
    @generation = @prompt.generations.create!(
      input_data: params[:input_variables] || {},
      llm_provider: "anthropic",
      llm_model: params[:model] || "claude-sonnet-4-20250514",
      status: "pending",
      metadata: { use_sequential_thinking: use_sequential_thinking }
    )

    # Enqueue background job
    GenerationJob.perform_later(@generation.id)

    # Redirect to show page where user can watch progress
    redirect_to prompt_generation_path(@prompt, @generation),
                notice: "Generation started! You'll see updates in real-time."
  end

  def destroy
    prompt = @generation.prompt
    @generation.destroy
    redirect_to prompt, notice: "Generation was successfully deleted."
  end

  private

  def set_generation
    @generation = Generation.find(params[:id])
  end

  def generation_params
    params.require(:generation).permit(:input_variables, :model)
  end
end
