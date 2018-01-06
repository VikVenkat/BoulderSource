class AddLengthAndContentToLists < ActiveRecord::Migration[5.1]
  def change
    add_column :lists, :length, :float
    add_column :lists, :content, :text
  end
end
