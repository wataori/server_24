class AddIconToUsers < ActiveRecord::Migration
  def change
    add_column :users, :icon, :string
  end
end
