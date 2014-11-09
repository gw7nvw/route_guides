class Photo < ActiveRecord::Base

has_attached_file :image, 
:path => ":rails_root/public/system/:attachment/:id/:basename_:style.:extension",
:url => "/system/:attachment/:id/:basename_:style.:extension",
:styles => {
  :thumb    => ['102x76#',  :jpg, :quality => 70],
  :original    => ['1024>', :jpg, :quality => 50],
},
:convert_options => {
  :thumb    => '-set colorspace sRGB -strip',
  :original    => '-set colorspace sRGB',
}

validates_attachment :image,
    :presence => true,
    :size => { :in => 0..10.megabytes },
    :content_type => { :content_type => /^image\/(jpeg|png)$/ }

  belongs_to :createdBy, class_name: "User"
  validates :createdBy, :presence => true
  belongs_to :projection
  validates :location, presence: true
  validates :x, presence: true
  validates :y, presence: true
  validates :projection, presence: true
  

end
