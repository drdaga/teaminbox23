class AddTypeToMessages < ActiveRecord::Migration[6.1]
    def change
      add_column :messages, :type, :string
    end
  end