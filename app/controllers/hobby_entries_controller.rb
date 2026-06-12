class HobbyEntriesController < ApplicationController
  before_action :set_entry, only: [:show, :edit, :update, :destroy]
  before_action :authorize_entry!, only: [:edit, :update, :destroy]

  def show
    @comments = @entry.comments.includes(:user).order(created_at: :asc)
    @comment = Comment.new
  end

  def new
    @entry = HobbyEntry.new
  end

  def create
    @entry = current_user.hobby_entries.build(entry_params)
    if @entry.save
      redirect_to root_path, notice: t('entries.added')
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    ids_to_remove = params.dig(:hobby_entry, :remove_attachment_ids) || []
    @entry.attachments.where(id: ids_to_remove).each(&:purge)

    new_files = Array(params.dig(:hobby_entry, :attachments)).select { |f|
      f.respond_to?(:original_filename) && f.original_filename.present?
    }
    @entry.attachments.attach(new_files) if new_files.any?

    if @entry.update(entry_params)
      redirect_to @entry, notice: t('entries.updated')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy
    redirect_to root_path, notice: t('entries.deleted')
  end

  private

  def set_entry
    @entry = HobbyEntry.find(params[:id])
  end

  def authorize_entry!
    redirect_to root_path, alert: t('entries.access_denied') unless @entry.user == current_user
  end

  def entry_params
    permitted = params.require(:hobby_entry).permit(
      :title, :category, :description, :rating, attachments: []
    )

    if action_name == "update"
      permitted.delete(:attachments)
    else
      real = Array(permitted[:attachments]).select { |f|
        f.respond_to?(:original_filename) && f.original_filename.present?
      }
      real.any? ? permitted[:attachments] = real : permitted.delete(:attachments)
    end

    permitted
  end
end
