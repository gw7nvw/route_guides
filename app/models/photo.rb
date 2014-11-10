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
  
def links
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='photo' and l."baseItem_id"=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='photo' and l.item_id=?)],self.id, self.id]
end

def linked(type)
   r=Link.find_by_sql [%q[select distinct id, item_id, item_type, item_url from links l
              where (l."baseItem_type"='photo' and l."baseItem_id"=? and item_type=?) 
        union select distinct id, "baseItem_id" as item_id, "baseItem_type" as item_type, '' as item_url from links l
              where  (l.item_type='photo' and l.item_id=? and "baseItem_type"=?)],self.id, type, self.id, type]
end

end
