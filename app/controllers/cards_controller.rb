class CardsController < ApplicationController
  before_action :set_myproject, only: %i[new create]
  before_action :set_project, only: %i[edit update destroy previous next]
  before_action :set_column
  before_action :set_card, only: %i[edit update destroy previous next]

  def new
    @card = @column.cards.build
    @card.assignee = current_user
  end

  def create
    @card = @column.cards.build(card_params)
    @card.project = @project

    if @card.save
      redirect_to project_path(@project), notice: 'カードを作成しました'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @card.update(card_params)
      redirect_to project_path(@project), notice: 'カードを更新しました'
    else
      render :edit
    end
  end

  def destroy
    if @card.destroy
      redirect_to project_path(@project), notice: 'カードを削除しました'
    else
      flash.now[:alert] = 'カードの削除に失敗しました。'
      render :edit
    end
  end

  def previous
    @card.column = @column.higher_item
    @card.save
    redirect_to project_path(@project)
  end

  def next
    @card.column = @column.lower_item
    @card.save
    redirect_to project_path(@project)
  end

  private

  def card_params
    params.require(:card).permit(:name, :due_date, :assignee_id)
  end

  def set_myproject
    @project = current_user.projects.find(params[:project_id])
  end

  def set_project
    @project = Project.accessible(current_user).find(params[:project_id])
  end

  def set_column
    @column = @project.columns.find(params[:column_id])
  end

  def set_card
    @card = @column.cards.find(params[:id])
  end
end
