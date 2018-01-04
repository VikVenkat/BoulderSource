class CreateBuilders < ActiveRecord::Migration[5.1]
  def change
    create_table :builders do |t|
      t.string :company
      t.string :phone
      t.string :email
      t.string :location
      t.string :typical
      t.string :url
      t.string :type
      t.string :contact_name

      t.timestamps
    end
  end
end
