class Photo < ActiveRecord::Base
  belongs_to :gallery

  validate :gallery_length

  if Rails.env.production? or Rails.env.staging?
    has_attached_file :photo, :storage => :s3,
                      :s3_credentials => "#{Rails.root.to_s}/config/s3.yml",
                      :path => "/:style/:filename",
                      :styles => { :full => "960x640", :medium => "690x460", :gallery => "668>3000", :facebook => "500>3000", :gallery_thumb => "26x17#", :iphone => "480x320", :square => "320x320#", :thumb => "50x50#" }
  else
    has_attached_file :photo,
                      :url => "/assets/photos/:id/:style/:basename.:extension",
                      :path => ":rails_root/public/assets/photos/:id/:style/:basename.:extension",
                      :styles => { :full => "960x640", :medium => "690x460", :gallery => "668>3000", :facebook => "500>3000", :gallery_thumb => "26x17#", :iphone => "480x320", :square => "320x320#", :thumb => "50x50#" }
  end

  validates_attachment_presence :photo
  validates_attachment_size :photo, :less_than => 500000, :message => I18n.t("activerecord.errors.models.photo.only_500_kb") , :unless => Proc.new {|photo| photo.photo }

  private
  def gallery_length
    errors.add(:base, I18n.t("activerecord.errors.models.photo.gallery_has_5_photos")) if gallery.photos.length >= 5
  end
end
