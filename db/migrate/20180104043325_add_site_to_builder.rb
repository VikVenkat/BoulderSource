class AddSiteToBuilder < ActiveRecord::Migration[5.1]
  def up
    add_column :builders, :site, :string
  end

  def down
    remove_column :builders, :site, :string
  end
end
