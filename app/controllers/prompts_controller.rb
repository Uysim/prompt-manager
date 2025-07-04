class PromptsController < ApplicationController
  before_action :set_prompt, only: [ :show, :edit, :update, :destroy, :generate, :generations, :remove_file ]

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
    use_sequential_thinking = params[:use_sequential_thinking] == "true"

    result = GenerationService.new(
      @prompt,
      params[:input_variables] || {},
      params[:model],
      use_sequential_thinking
    ).call

    if result[:success]
      redirect_to prompt_generation_path(@prompt, result[:generation]), notice: "Text generated successfully!"
    else
      redirect_to @prompt, alert: "Generation failed: #{result[:error]}"
    end
  end

  def generations
    @generations = @prompt.generations.order(created_at: :desc)
  end

  def remove_file
    file = @prompt.files.find(params[:file_id])
    file.purge
    redirect_to edit_prompt_path(@prompt), notice: "File removed successfully."
  rescue ActiveRecord::RecordNotFound
    redirect_to edit_prompt_path(@prompt), alert: "File not found."
  end

  private

  def set_prompt
    @prompt = Prompt.find(params[:id])
  end

  def prompt_params
    params.require(:prompt).permit(:title, :content, :description, files: [])
  end
end
