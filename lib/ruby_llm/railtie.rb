module RubyLLM
  class Railtie < Rails::Railtie
    initializer 'ruby_llm.initialize' do
      ActiveSupport.on_load(:active_record) do
        extend RubyLLM::ActiveRecord::ActsAs
      end
    end
  end
end
