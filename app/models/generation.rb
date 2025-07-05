class Generation < ApplicationRecord
  belongs_to :prompt
  has_many_attached :files

  # State enum with string values for data consistency
  enum status: {
    pending: "pending",
    generating: "generating",
    completed: "completed",
    error: "error"
  }

  # Validations
  validates :input_data, presence: true
  validates :llm_provider, presence: true
  validates :llm_model, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :files, content_type: { in: %w[text/plain text/csv application/pdf image/jpeg image/png image/gif application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document], message: "must be a valid file type" }
  validates :files, size: { less_than: 10.megabytes, message: "must be less than 10MB" }

  # Only require generated_text when completed
  validates :generated_text, presence: true, if: :completed?

  # State transition methods
  def start_generation!
    update!(status: "generating")
  end

  def complete_generation!(text, metadata_updates = {})
    update!(
      status: "completed",
      generated_text: text,
      metadata: metadata.merge(metadata_updates)
    )
  end

  def fail_generation!(error_message = nil)
    update!(
      status: "error",
      metadata: metadata.merge(error: error_message)
    )
  end

  # Get processed prompt content for this generation
  def processed_prompt_content
    prompt.process_content(input_data)
  end

  # Get variables used in this generation
  def variables_used
    input_data.keys
  end

  # Check if generation was successful (has content and completed)
  def successful?
    completed? && generated_text.present?
  end

  # Get error message from metadata
  def error_message
    metadata["error"] if error?
  end
end
