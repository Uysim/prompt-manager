class GenerationsController < ApplicationController
  before_action :set_generation, only: [ :show, :destroy ]

  def index
    @generations = Generation.includes(:prompt).order(created_at: :desc)
  end

  def show
  end

  def create
    @prompt = Prompt.find(params[:prompt_id])
    use_sequential_thinking = params[:use_sequential_thinking] == "true"

    service = GenerationService.new(
      @prompt,
      params[:input_variables] || {},
      params[:model],
      use_sequential_thinking
    )

    result = service.call

    if result[:success]
      @generation = result[:generation]
      @thinking_process = result[:thinking_process] if result[:thinking_process]

      redirect_to prompt_generation_path(@prompt, @generation), notice: "Text generated successfully!"
    else
      flash[:error] = result[:error]
      render "prompts/show", status: :unprocessable_entity
    end
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
