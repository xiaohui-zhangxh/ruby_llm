module RubyLLM
  class Conversation
    attr_reader :id, :messages, :tools

    def initialize(tools: [])
      @id = SecureRandom.uuid
      @messages = []
      @tools = tools
    end

    def add_message(message)
      @messages << message
      message
    end
  end
end
