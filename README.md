# Prompt Manager

A Ruby on Rails application for creating, managing, and executing prompts with language models (LLMs). Built with modern Rails conventions, Hotwire for dynamic interactions, and Tailwind CSS for styling.

## Features

- **Prompt Management**: Create, edit, and organize prompts with variable support
- **LLM Integration**: Execute prompts with multiple AI providers (OpenAI, Anthropic)
- **Generation History**: Track and view all prompt executions and results
- **Modern UI**: Responsive interface built with Hotwire and Tailwind CSS
- **Docker Support**: Containerized deployment ready

## Technology Stack

- **Backend**: Ruby on Rails 7.2+
- **Database**: PostgreSQL with UUID primary keys
- **Frontend**: Hotwire (Turbo + Stimulus), Tailwind CSS
- **JavaScript**: Importmap-based (no bundler required)
- **Deployment**: Docker containerization

## Prerequisites

- Ruby 3.1.4+
- PostgreSQL 9.3+
- Node.js (for Tailwind CSS compilation)

## Installation


### 1. Install dependencies

```bash
bundle install
```

### 2. Environment configuration

Copy the .env.example to .env file and configure your API keys


### 3. Database setup

```bash
# Create and setup database
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```


### 4. Start the development server

```bash
bin/dev
```

The application will be available at `http://localhost:3000`

## Development

### Running the application

```bash
# Start the development server with hot reloading
bin/dev

# Or start components individually
bin/rails server
bin/rails tailwindcss:watch
```


## Key Models

- **Prompt**: Stores prompt templates with variable placeholders
- **Generation**: Records prompt executions and LLM responses

## API Integration

The application integrates with multiple LLM providers through service objects:

- `AnthropicService`: Claude API integration
- `LlmService`: Generic LLM service interface

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.
