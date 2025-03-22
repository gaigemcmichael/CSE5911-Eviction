class ResourcesController < ApplicationController
  def index
    @active_tab = params[:tab] || "resources"

    faq_categories = {
      "General" => Rails.root.join("db", "faq_general.txt"),
      "Data Privacy" => Rails.root.join("db", "faq_privacy.txt")
    }

    @faqs = {}

    faq_categories.each do |category, file_path|
      if File.exist?(file_path)
        raw_faqs = File.read(file_path).strip.split("\n")

        category_faqs = []
        current_question = nil
        current_answer = []

        raw_faqs.each do |line|
          line.strip!

          if line.start_with?("Q: ")
            if current_question && current_answer.any?
              formatted_answer = current_answer.join(" ").gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
              category_faqs << { question: current_question, answer: formatted_answer.html_safe }
            end

            current_question = line.sub("Q: ", "")
            current_answer = []
          elsif line.start_with?("A: ") || current_question
            current_answer << line.sub(/^A:\s*/, "")
          end
        end

        if current_question && current_answer.any?
          formatted_answer = current_answer.join(" ").gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>')
          category_faqs << { question: current_question, answer: formatted_answer.html_safe }
        end

        @faqs[category] = category_faqs
      else
        @faqs[category] = []
      end
    end
  end
end
