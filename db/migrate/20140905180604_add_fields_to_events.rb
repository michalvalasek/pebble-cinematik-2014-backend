class AddFieldsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :original_name, :string
    add_column :events, :section, :string
    add_column :events, :meta, :string
    add_column :events, :director, :string
  end
end
