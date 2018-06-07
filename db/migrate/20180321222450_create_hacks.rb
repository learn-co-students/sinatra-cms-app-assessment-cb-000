class CreateHacks < ActiveRecord::Migration[5.1]
  def change
    create_table :hacks do |t|
      t.string :title
      t.text :description
      t.string :vid_id
      t.integer :user_id
    end
  end
end
