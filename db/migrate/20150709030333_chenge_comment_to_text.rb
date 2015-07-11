class ChengeCommentToText < ActiveRecord::Migration
def up
    change_column :comments, :comment, :text
end
def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :comments, :comment, :string
end
end
