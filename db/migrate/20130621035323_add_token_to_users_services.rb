class AddTokenToUsersServices < ActiveRecord::Migration
  def change
    add_column :users, :token, :string
    add_index :users, :token

    add_column :services, :token, :string
    add_index :services, :token
  end
end
