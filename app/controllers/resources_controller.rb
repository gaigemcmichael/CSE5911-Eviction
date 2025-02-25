class ResourcesController < ApplicationController
  def index
    @active_tab = params[:tab] || "resources"

    # Load FAQs from a text file
    faq_file_path = Rails.root.join('db', 'faq.txt')

    if File.exist?(faq_file_path)
      raw_faqs = File.read(faq_file_path).strip.split("\n")

      @faqs = []
      current_question = nil
      current_answer = []

      raw_faqs.each do |line|
        line.strip!

        if line.start_with?("Q: ")
          if current_question && current_answer.any?
            formatted_answer = current_answer.join(" ").gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
            @faqs << { question: current_question, answer: formatted_answer.html_safe }
          end

          current_question = line.sub("Q: ", "")
          current_answer = []
        elsif line.start_with?("A: ") || current_question
          current_answer << line.sub(/^A:\s*/, "")
        end
      end

      if current_question && current_answer.any?
        formatted_answer = current_answer.join(" ").gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
        @faqs << { question: current_question, answer: formatted_answer.html_safe }
      end
    else
      @faqs = []
    end
  end
end
