class UserDecorator < Draper::Decorator
  delegate_all

  def image_file
    my_image.present? ? my_image : sns_image
  end

  def name_class
    if errors[:name].present?
      'form-control form-control-lg text-purple mt-4 mt-md-0 is-invalid'
    else
      'form-control form-control-lg text-purple mt-4 mt-md-0'
    end
  end

  def file_field_label
    h.content_tag :label, class: label_class, for: 'mypage_filefield' do
      h.content_tag :div, id: 'mypage_filename', class: 'mb-0' do
        button_text
      end
    end
  end

  def name_error
    return if errors[:name].blank?
    h.content_tag :div, class: 'invalid-feedback d-block' do
      errors[:name].each do |msg|
        h.concat h.content_tag :div, I18n.t('activerecord.attributes.user.name') + msg
      end
    end
  end

  def filefield_error
    return if errors[:my_image].blank?
    h.content_tag :div, class: 'invalid-feedback d-block' do
      errors[:my_image].each do |msg|
        h.concat h.content_tag :div, msg
      end
    end
  end

  private
  def label_class
    if errors[:my_image].present?
      'btn btn-lg btn-block btn-secondary bg-light-purple border-danger text-middle-purple mt-2 mt-lg-4'
    else
      'btn btn-lg btn-block btn-secondary bg-light-purple border-middle-purple text-middle-purple mt-2 mt-lg-4'
    end
  end

  def button_text
    if my_image.filename.present?
      my_image.filename
    else
      'ファイルを選択'
    end
  end
end
