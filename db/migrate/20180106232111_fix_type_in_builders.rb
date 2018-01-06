class FixTypeInBuilders < ActiveRecord::Migration[5.1]
  def change
    rename_column :builders, :type, :builder_type
  end
end
