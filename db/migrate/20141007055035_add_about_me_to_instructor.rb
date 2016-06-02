class AddAboutMeToInstructor < ActiveRecord::Migration
  def change
    add_column :instructors, :about_me, :text
  end
end
