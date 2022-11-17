class Admin::Stats::AnswersController < Admin::AdminController
  def index
    @answers = AnswerQuestion.select("questions.code as question_code, question_options.code as question_option_code, count(answer_questions.id) as total_answers").joins(:question, :question_option).group("questions.code, question_options.code").order("questions.code asc, question_options.code asc").page(params[:page])
  end
end



