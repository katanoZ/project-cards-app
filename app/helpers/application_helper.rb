module ApplicationHelper
  def logged_in_projects?
    logged_in_by_correct_user? && controller.controller_name == 'projects'
  end
end
