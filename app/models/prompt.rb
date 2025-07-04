class Prompt < ApplicationRecord
  has_many :generations, dependent: :destroy
  has_many_attached :files

  validates :title, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :content, presence: true
  validates :files, content_type: { in: %w[text/plain text/csv application/pdf image/jpeg image/png image/gif application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document], message: "must be a valid file type" }
  validates :files, size: { less_than: 10.megabytes, message: "must be less than 10MB" }

  # Extract variables from content (simple {{variable}} pattern)
  def extract_variables
    content.scan(/\{\{(\w+)\}\}/).flatten.uniq
  end

  # Process content with given variables
  def process_content(input_variables = {})
    processed_content = content.dup
    input_variables.each do |key, value|
      processed_content.gsub!("{{#{key}}}", value.to_s)
    end
    processed_content
  end

  # Check if all required variables are provided
  def variables_complete?(input_variables = {})
    required_vars = extract_variables
    provided_vars = input_variables.keys.map(&:to_s)
    (required_vars - provided_vars).empty?
  end

  # Get missing variables
  def missing_variables(input_variables = {})
    required_vars = extract_variables
    provided_vars = input_variables.keys.map(&:to_s)
    required_vars - provided_vars
  end

  # Get file content as text (for text files)
  def file_content_as_text
    files.map do |file|
      if file.content_type.start_with?("text/")
        file.download.force_encoding("UTF-8")
      else
        "#{file.filename} (binary file)"
      end
    end.join("\n\n")
  end
end
