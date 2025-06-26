class Prompt < ApplicationRecord
  has_many :generations, dependent: :destroy

  validates :title, presence: true, length: { maximum: 255 }, uniqueness: true
  validates :content, presence: true

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
end
