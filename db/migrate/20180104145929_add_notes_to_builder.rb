class AddNotesToBuilder < ActiveRecord::Migration[5.1]
  def change
    add_column :builders, :notes, :string
  end
end
