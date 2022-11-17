class Admin::Stats::SearchTextsController < Admin::AdminController
  def index
    @search_texts = SearchText.all_order_by_totals.page(params[:page])
  end
end
