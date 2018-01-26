class AddNamesToBuilders < ActiveRecord::Migration[5.1]
  def change
    add_column :builders, :first_name, :string
    add_column :builders, :last_name, :string
  end
end
