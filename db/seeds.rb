# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample prompts
prompts = [
  {
    title: "Email Response Generator",
    description: "Generate professional email responses for common business scenarios",
    content: "Write a professional email response to the following request:\n\nRequest: {{request}}\n\nTone: {{tone}}\n\nLength: {{length}}\n\nPlease make it {{tone}} and {{length}} in length."
  },
  {
    title: "Blog Post Introduction",
    description: "Create engaging blog post introductions",
    content: "Write an engaging introduction for a blog post about {{topic}}. The target audience is {{audience}}. Make it {{tone}} and approximately {{word_count}} words long."
  },
  {
    title: "Product Description",
    description: "Generate compelling product descriptions",
    content: "Create a compelling product description for {{product_name}}. The product is a {{product_type}} that helps with {{benefit}}. Target audience is {{audience}}. Make it {{tone}} and highlight the key features."
  },
  {
    title: "Social Media Post",
    description: "Generate engaging social media posts",
    content: "Create a {{platform}} post about {{topic}}. The tone should be {{tone}} and include a call to action. Make it engaging and suitable for {{audience}}."
  },
  {
    title: "Meeting Summary",
    description: "Generate meeting summaries from key points",
    content: "Create a professional meeting summary based on the following key points:\n\n{{key_points}}\n\nMeeting Date: {{date}}\n\nParticipants: {{participants}}\n\nPlease organize it clearly with action items highlighted."
  }
]

prompts.each do |prompt_data|
  Prompt.find_or_create_by!(title: prompt_data[:title]) do |prompt|
    prompt.description = prompt_data[:description]
    prompt.content = prompt_data[:content]
  end
end

puts "Created #{Prompt.count} sample prompts"
