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
      generation_params[:input_variables],
      generation_params[:model] || AnthropicService.default_model,
      use_sequential_thinking
    )

    result = service.call

    if result[:success]
      @generation = result[:generation]
      @thinking_process = result[:thinking_process] if result[:thinking_process]

      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "generation_result",
            partial: "generations/result",
            locals: { generation: @generation, thinking_process: @thinking_process }
          )
        }
        format.html { redirect_to prompt_generation_path(@prompt, @generation) }
      end
    else
      flash[:error] = result[:error]
      redirect_to prompt_path(@prompt)
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
