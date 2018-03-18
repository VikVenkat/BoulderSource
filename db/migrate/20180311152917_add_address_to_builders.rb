class AddAddressToBuilders < ActiveRecord::Migration[5.1]
  def change
    add_column :builders, :street, :string
    add_column :builders, :city, :string
    add_column :builders, :state, :string
    add_column :builders, :zip, :string
  end
end
