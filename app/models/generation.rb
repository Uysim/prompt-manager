class Generation < ApplicationRecord
  belongs_to :prompt

  validates :input_data, presence: true
  validates :generated_text, presence: true
  validates :llm_provider, presence: true
  validates :llm_model, presence: true


  # Get processed prompt content for this generation
  def processed_prompt_content
    prompt.process_content(input_data)
  end

  # Get variables used in this generation
  def variables_used
    input_data.keys
  end

  # Check if generation was successful (has content)
  def successful?
    generated_text.present?
  end
end
