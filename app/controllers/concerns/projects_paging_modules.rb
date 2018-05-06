module ProjectsPagingModules
  extend ActiveSupport::Concern

  COUNT_FOR_FIRST_PAGE = 8
  COUNT_FOR_OTHER_PAGE = 9

  def set_myprojects
    if first_page?
      set_myprojects_first_page
    else
      set_myprojects_other_page
    end
  end

  def set_projects
    if first_page?
      set_projects_first_page
    else
      set_projects_other_page
    end
  end

  private

  def first_page?
    params[:page].blank?
  end

  def set_myprojects_first_page
    @projects = current_user.projects
                            .order(id: :desc)
                            .page(params[:page])
                            .per(COUNT_FOR_FIRST_PAGE)
  end

  def set_myprojects_other_page
    @projects = current_user.projects
                            .order(id: :desc)
                            .page(params[:page])
                            .per(COUNT_FOR_OTHER_PAGE)
                            .padding(COUNT_FOR_FIRST_PAGE - COUNT_FOR_OTHER_PAGE)
  end

  def set_projects_first_page
    @projects = Project.order(id: :desc)
                       .page(params[:page])
                       .per(COUNT_FOR_FIRST_PAGE)
  end

  def set_projects_other_page
    @projects = Project.order(id: :desc)
                       .page(params[:page])
                       .per(COUNT_FOR_OTHER_PAGE)
                       .padding(COUNT_FOR_FIRST_PAGE - COUNT_FOR_OTHER_PAGE)
  end
end
