module Admin::UsersHelper
  def highlight_search_term(string)
    term = params[:query] or params[:q]
    if term and string
      return string.downcase.gsub(term.downcase, "<strong class=\"highlight\">#{term.downcase}</strong>").html_safe
    else
      return string
    end
  end
end