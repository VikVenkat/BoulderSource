class AddItemsToLists < ActiveRecord::Migration[5.1]
  def change
    add_column :lists, :start_page, :int
    add_column :lists, :no_pages, :int
    add_column :lists, :fail_count, :int
  end
end
