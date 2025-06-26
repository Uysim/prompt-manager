class GenerationsController < ApplicationController
  before_action :set_generation, only: [ :show, :destroy ]

  def index
    @generations = Generation.includes(:prompt).order(created_at: :desc)
  end

  def show
  end

  def create
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
end
