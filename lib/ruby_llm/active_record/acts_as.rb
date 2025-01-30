module RubyLLM
  module ActiveRecord
    module ActsAs
      def acts_as_llm_model(options = {})
        include ModelMethods
      end

      def acts_as_llm_conversation(options = {})
        include ConversationMethods
        has_many :messages, -> { order(created_at: :asc) }
      end

      def acts_as_llm_message(options = {})
        include MessageMethods
        belongs_to :conversation
      end
    end

    module ModelMethods
      extend ActiveSupport::Concern

      included do
        validates :name, presence: true
        validates :provider, presence: true
      end

      class_methods do
        def sync_models
          # Logic to sync models from providers
        end
      end
    end

    module ConversationMethods
      extend ActiveSupport::Concern

      included do
        before_create :set_default_model
      end

      def send_message(content, model: nil)
        transaction do
          message = messages.create!(
            role: :user,
            content: content
          )

          response = RubyLLM.client.chat(
            conversation_messages,
            model: model || current_model
          )

          messages.create!(
            role: :assistant,
            content: response.content,
            token_count: response.token_count
          )
        end
      end

      private

      def conversation_messages
        messages.map(&:to_llm_format)
      end

      def set_default_model
        self.current_model ||= RubyLLM.configuration.default_model
      end
    end

    module MessageMethods
      extend ActiveSupport::Concern

      included do
        validates :role, presence: true, inclusion: { in: RubyLLM::Message::VALID_ROLES.map(&:to_s) }
        validates :content, presence: true, unless: :tool_call?

        before_save :calculate_tokens
      end

      def to_llm_format
        RubyLLM::Message.new(
          role: role.to_sym,
          content: content,
          tool_calls: tool_calls,
          tool_results: tool_results
        )
      end

      private

      def calculate_tokens
        # Logic to calculate tokens
      end

      def tool_call?
        tool_calls.present? || tool_results.present?
      end
    end
  end
end
