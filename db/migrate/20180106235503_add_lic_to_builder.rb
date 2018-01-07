class AddLicToBuilder < ActiveRecord::Migration[5.1]
  def change
    add_column :builders, :license, :string
  end
end
