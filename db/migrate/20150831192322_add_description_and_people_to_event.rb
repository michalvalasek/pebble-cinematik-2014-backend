class AddDescriptionAndPeopleToEvent < ActiveRecord::Migration
  def change
    add_column :events, :description, :text
    add_column :events, :people, :text
  end
end
